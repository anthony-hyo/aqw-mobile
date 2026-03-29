use std::error::Error;
use std::fs;
use std::path::Path;

pub fn clear_dir(path: &Path) -> Result<(), Box<dyn Error>> {
    if path.exists() {
        fs::remove_dir_all(path)?;
    }

    fs::create_dir(path)?;

    Ok(())
}

pub fn get_patches(path: &Path, target: &Path) -> Result<(), Box<dyn Error>> {
    if path.exists() {
        copy_dir(path, target)?;
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

pub fn copy_files(source: &Path, target: &Path) -> Result<(), Box<dyn Error>> {
    if !source.exists() {
        return Ok(());
    }

    for entry in fs::read_dir(source)? {
        let entry = entry?;
        let path = entry.path();

        if path.is_dir() {
            copy_files(&path, target)?;
        } else if path.extension().map_or(false, |ext| ext == "asasm") {
            let file_name = path.file_name().unwrap();
            let dest = target.join(file_name);

            println!("Adding new file: {:?}", dest);

            fs::copy(&path, &dest)?;
        }
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
