use std::error::Error;
use std::fs;
use std::path::{Path, PathBuf};

pub fn clear_dir(path: &Path) -> Result<(), Box<dyn Error>> {
    if path.exists() {
        fs::remove_dir_all(path)?;
    }

    fs::create_dir_all(path)?;

    Ok(())
}

pub fn merge_patches(name: &str) -> Result<(), Box<dyn Error>> {
    let src = PathBuf::from(format!("pocket-patches/aqw/{}", name));
    let dst = PathBuf::from(format!("patches/{}/bytecodes", name));

    if src.exists() {
        if dst.exists() {
            fs::remove_dir_all(&dst)?;
        }

        copy_dir(&src, &dst)?;
    }

    Ok(())
}

pub fn copy_dir(source: &Path, target: &Path) -> Result<(), Box<dyn Error>> {
    fs::create_dir_all(target)?;

    for entry in fs::read_dir(source)? {
        let entry = entry?;
        let target_path = target.join(entry.file_name());

        if entry.path().is_dir() {
            copy_dir(&entry.path(), &target_path)?;
            continue;
        }

        fs::copy(entry.path(), target_path)?;
    }

    Ok(())
}

pub fn find_all_original_blocks(content: &str, find_normalized: &str) -> Vec<String> {
    let find_lines: Vec<&str> = find_normalized.lines().collect();
    let content_lines: Vec<&str> = content.lines().collect();
    let mut results = Vec::new();

    let mut ci = 0;

    'outer: while ci < content_lines.len() {
        let mut fi = 0;
        let mut start = None;
        let mut tmp_ci = ci;

        while tmp_ci < content_lines.len() {
            let cl = content_lines[tmp_ci].trim();

            if cl.is_empty() {
                tmp_ci += 1;
                continue;
            }

            if cl == find_lines[fi] {
                if fi == 0 {
                    start = Some(tmp_ci);
                }
                fi += 1;
                tmp_ci += 1;

                if fi == find_lines.len() {
                    let block = content_lines[start.unwrap()..tmp_ci].join("\n");
                    results.push(block);
                    ci = start.unwrap() + 1;
                    continue 'outer;
                }
            } else {
                break;
            }
        }

        ci += 1;
    }

    results
}

pub fn replace_trait_method(content: &str, method_name: &str, replacement: &str) -> Option<String> {
    let content = content.replace("\r\n", "\n");
    let lines: Vec<&str> = content.lines().collect();

    let start = lines.iter().position(|l| {
        let t = l.trim();
        t.starts_with("trait ") && t.contains(&format!("\"{}\"", method_name))
    })?;

    let mut depth = 0usize;
    let mut end = None;

    for (offset, line) in lines[start..].iter().enumerate() {
        let t = line.trim();
        if t.starts_with("trait ") {
            depth += 1;
        } else if t.starts_with("end ; trait") {
            depth = depth.saturating_sub(1);
            if depth == 0 {
                end = Some(start + offset);
                break;
            }
        }
    }

    let end = end?;

    let mut result = lines[..start].join("\n");
    if !result.is_empty() {
        result.push('\n');
    }

    result.push_str(replacement.trim_end());
    result.push('\n');

    let tail = lines[end + 1..].join("\n");
    if !tail.is_empty() {
        result.push_str(&tail);
    }

    if !result.ends_with('\n') {
        result.push('\n');
    }

    Some(result)
}