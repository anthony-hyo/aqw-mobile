use reqwest::{Client, Response};
use serde::Deserialize;
use std::collections::HashMap;
use std::error::Error;
use std::fs::File;
use std::fs::{self, FileType, ReadDir};
use std::io::Write;
use std::path::Path;
use std::process::{Command, ExitStatus};

#[tokio::main]
async fn main() {
    clear_asset_dir();

    download_asset().await.expect("Could not load Game.swf");

    export_bytecode();

    let patches: HashMap<String, String> = load_patch();

    apply_patch(&patches, Path::new("assets/Game-0")).expect("Error while applying the patch");

    build();
}

fn build() {
    let output: ExitStatus = Command::new("rabcasm")
        .arg("assets/Game-0/Game-0.main.asasm")
        .status()
        .expect("failed to build rabcasm");

    println!("status: {}", output);

    let output: ExitStatus = Command::new("abcreplace")
        .arg("assets/Game.swf")
        .arg("0")
        .arg("assets/Game-0/Game-0.main.abc")
        .status()
        .expect("failed to execute abcreplace");

    println!("status: {}", output);
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

                            //println!("Applying patch to {:?}", file.path());
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

fn load_patch() -> HashMap<String, String> {
    let mut patches_files: HashMap<String, String> = HashMap::new();

    let patches: ReadDir = fs::read_dir("patches").expect("Failed to load patches directory.");

    for patch_dir in patches {
        if let Ok(p) = patch_dir {
            let file_type: FileType = p.file_type().expect("Error reading file type.");

            if file_type.is_dir() {
                let patch: ReadDir =
                    fs::read_dir(p.path()).expect("Failed to load patch directory.");

                let mut find_content: String = String::new();
                let mut replace_content: String = String::new();

                for patch_files in patch {
                    if let Ok(file) = patch_files {
                        match &*file.file_name().to_string_lossy() {
                            "find.txt" => {
                                find_content = fs::read_to_string(file.path())
                                    .expect("Error reading find.txt");
                            }
                            "replace.txt" => {
                                replace_content = fs::read_to_string(file.path())
                                    .expect("Error reading replace.txt");
                            }
                            _ => {
                                // Default
                            }
                        }
                    }
                }

                if !find_content.is_empty() {
                    patches_files.insert(find_content, replace_content);
                }
            }
        }
    }

    patches_files
}

fn export_bytecode() {
    let output: ExitStatus = Command::new("abcexport")
        .arg("assets/Game.swf")
        .status()
        .expect("failed to execute abcexport");

    println!("status: {}", output);

    let output: ExitStatus = Command::new("rabcdasm")
        .arg("assets/Game-0.abc")
        .status()
        .expect("failed to execute rabcdasm");

    println!("status: {}", output);
}

fn clear_asset_dir() {
    match fs::remove_dir_all("assets") {
        Ok(()) => println!("File successfully deleted."),
        Err(error) => eprintln!("Error deleting file: {}", error),
    }

    match fs::create_dir("assets") {
        Ok(()) => println!("File successfully deleted."),
        Err(error) => eprintln!("Error deleting file: {}", error),
    }
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
