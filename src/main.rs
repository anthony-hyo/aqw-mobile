use reqwest::{Client, Response};
use serde::Deserialize;
use std::collections::HashMap;
use std::error::Error;
use std::fs::{self, File};
use std::io::Write;
use std::path::Path;
use std::process::{Command, ExitStatus};

#[tokio::main]
async fn main() {
    let assets = Path::new("assets");

    let patches = Path::new("patches");
    let patches_aqw = Path::new("pocket-patches/aqw");
    let patches_final = Path::new("patches-final");

    #[rustfmt::skip]
    clear_dir(patches_final)
        .expect("Failed to clear existing directory.");

    #[rustfmt::skip]
    clear_dir(assets)
        .expect("Failed to clear existing assets directory.");

    #[rustfmt::skip]
    download_asset()
        .await
        .expect("Failed to download asset.");

    #[rustfmt::skip]
    export_bytecode()
        .expect("Failed to export bytecode from target asset.");

    #[rustfmt::skip]
    get_patches(patches, patches_final)
        .expect("Failed to load patch files from target directory.");

    #[rustfmt::skip]
    get_patches(patches_aqw, patches_final)
        .expect("Failed to load patch files from target directory.");

    #[rustfmt::skip]
    let patches: HashMap<String, String> = load_patch(patches_final)
        .expect("Failed to load patch files from target directory.");

    #[rustfmt::skip]
    apply_patch(&patches, Path::new("assets/Game-0"))
        .expect("Failed to apply patches to target asset.");

    #[rustfmt::skip]
    build()
        .expect("Build failed.");
}

fn build() -> Result<(), Box<dyn Error>> {
    let output_rabcasm = Command::new("rabcasm")
        .arg("assets/Game-0/Game-0.main.asasm")
        .status()?;

    let output_abcreplace: ExitStatus = Command::new("abcreplace")
        .arg("assets/Game.swf")
        .arg("0")
        .arg("assets/Game-0/Game-0.main.abc")
        .status()?;

    println!(
        "rabcasm: {}, abcreplace : {}",
        output_abcreplace, output_rabcasm
    );

    if Path::new("loader/gamefiles/Game.swf").exists() {
        fs::remove_file("loader/gamefiles/Game.swf")?;
    }

    fs::create_dir_all("loader/gamefiles")?;

    fs::rename("assets/Game.swf", "loader/gamefiles/Game.swf")?;

    Ok(())
}

fn find_all_original_blocks(content: &str, find_normalized: &str) -> Vec<String> {
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

fn apply_patch(patches: &HashMap<String, String>, path: &Path) -> Result<(), Box<dyn Error>> {
    for files in fs::read_dir(path)? {
        if let Ok(file) = files {
            if file.file_type()?.is_dir() {
                let _ = apply_patch(&patches, &file.path());
            } else {
                if file.path().extension().map_or(false, |ext| ext == "asasm") {
                    let mut content = fs::read_to_string(&file.path())?;

                    for (find, replace) in patches {
                        let find_normalized = find
                            .lines()
                            .map(|l| l.trim())
                            .filter(|l| !l.is_empty())
                            .collect::<Vec<_>>()
                            .join("\n");

                        let content_normalized = content
                            .lines()
                            .map(|l| l.trim())
                            .filter(|l| !l.is_empty())
                            .collect::<Vec<_>>()
                            .join("\n");

                        if content_normalized.contains(&find_normalized) {
                            let blocks = find_all_original_blocks(&content, &find_normalized);

                            println!("Applying patch to {:?}", file.path());
                            //println!("Find: {}", find);
                            //println!("Replace: {}", replace);

                            for original in blocks {
                                content = content.replacen(&original, replace, 1);
                            }

                            fs::write(file.path(), &content)?;
                        }
                    }
                }
            }
        }
    }

    Ok(())
}

fn load_patch(path: &Path) -> Result<HashMap<String, String>, Box<dyn Error>> {
    let mut patches_files: HashMap<String, String> = HashMap::new();

    for file in fs::read_dir(path)? {
        let file = file?;

        let sub_path = file.path();

        let find_path = sub_path.join("find.txt");

        if find_path.exists() {
            let replace_path = sub_path.join("replace.txt");

            let find_content: String = fs::read_to_string(&find_path)?;

            if !find_content.is_empty() {
                patches_files.insert(
                    find_content,
                    if replace_path.exists() {
                        fs::read_to_string(&replace_path)?
                    } else {
                        String::new()
                    },
                );
            }
        }

        if file.file_type()?.is_dir() {
            patches_files.extend(load_patch(&file.path())?);
        }
    }

    Ok(patches_files)
}

fn export_bytecode() -> Result<(), Box<dyn Error>> {
    let output_abcexport: ExitStatus = Command::new("abcexport").arg("assets/Game.swf").status()?;

    let output_rabcdasm: ExitStatus = Command::new("rabcdasm").arg("assets/Game-0.abc").status()?;

    println!(
        "abcexport: {}, rabcdasm : {}",
        output_abcexport, output_rabcdasm
    );

    Ok(())
}

fn get_patches(path: &Path, target: &Path) -> Result<(), Box<dyn Error>> {
    if path.exists() {
        copy_dir(path, target)?;
    }

    Ok(())
}

fn clear_dir(path: &Path) -> Result<(), Box<dyn Error>> {
    if path.exists() {
        fs::remove_dir_all(path)?;
    }

    fs::create_dir(path)?;

    Ok(())
}

fn copy_dir(source: &Path, target: &Path) -> Result<(), Box<dyn Error>> {
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

async fn download_asset() -> Result<(), Box<dyn std::error::Error>> {
    let client: Client = Client::new();

    let response: Response = client
        .get("https://game.aq.com/game/api/data/gameversion")
        .header("User-Agent", "Mozilla/5.0")
        .header("Accept", "application/json")
        .send()
        .await?;

    let text: String = response.text().await?;
    let game_version: GameVersion = serde_json::from_str(&text)?;

    println!("Downloading: {}", game_version.file);

    let mut response: Response = client
        .get(format!(
            "https://game.aq.com/game/gamefiles/{}",
            game_version.file
        ))
        .header("User-Agent", "Mozilla/5.0")
        .send()
        .await?;

    let mut downloaded_file: File = File::create("assets/Game.swf")?;

    while let Some(chunk) = response.chunk().await? {
        downloaded_file.write_all(&chunk)?;
    }

    Ok(())
}

#[derive(Debug, Deserialize)]
struct GameVersion {
    #[serde(rename = "sFile")]
    file: String,
    //#[serde(rename = "sTitle")]
    //title: String,

    //#[serde(rename = "sBG")]
    //bg: String,

    //#[serde(rename = "sVersion")]
    //version: String,
}
