use crate::util;
use reqwest::{Client, Response};
use serde::Deserialize;
use std::collections::HashMap;
use std::error::Error;
use std::fs;
use std::fs::File;
use std::io::Write;
use std::path::{Path, PathBuf};
use std::process::{Command, ExitStatus};

pub enum DownloadFile {
    Game,
    Direct(String),
}

pub struct Patcher {
    name: &'static str,
    source: DownloadFile,
    patches: HashMap<String, String>,
}

impl Patcher {
    pub fn new(name: &'static str, source: DownloadFile) -> Self {
        Self {
            name,
            source,
            patches: HashMap::new(),
        }
    }

    pub async fn build(&mut self) {
        tracing::info!("[{}] Starting build", self.name);

        match util::clear_dir(&*self.get_bytecode_final_path()) {
            Ok(()) => tracing::info!("[{}] Cleared final directory", self.name),
            Err(e) => {
                tracing::error!("[{}] Failed to clear final directory: {}", self.name, e);
                return;
            }
        }

        match util::clear_dir(&*self.get_build_path()) {
            Ok(()) => tracing::info!("[{}] Cleared build directory", self.name),
            Err(e) => {
                tracing::error!("[{}] Failed to clear build directory: {}", self.name, e);
                return;
            }
        }

        match self.download().await {
            Ok(()) => tracing::info!("[{}] Download completed", self.name),
            Err(e) => {
                tracing::error!("[{}] Failed to download swf: {}", self.name, e);
                return;
            }
        }

        match self.export_bytecode() {
            Ok(()) => tracing::info!("[{}] Bytecodes exported", self.name),
            Err(e) => {
                tracing::error!("[{}] Failed to export bytecode: {}", self.name, e);
                return;
            }
        }

        match self.get_patches() {
            Ok(()) => tracing::info!("[{}] Patches initialed", self.name),
            Err(e) => {
                tracing::error!("[{}] Failed to init patches: {}", self.name, e);
                return;
            }
        }

        match self.load_patch(&self.get_bytecode_final_path()) {
            Ok(()) => tracing::info!("[{}] Patches loaded", self.name),
            Err(e) => {
                tracing::error!("[{}] Failed to load patch: {}", self.name, e);
                return;
            }
        }

        tracing::info!(
            "[{}] Total patches loaded: {}",
            self.name,
            self.patches.len()
        );

        match self.apply_patch(&self.get_build_rabcdasm_path()) {
            Ok(()) => tracing::info!("[{}] Patches applied", self.name),
            Err(e) => {
                tracing::error!("[{}] Failed to apply patches: {}", self.name, e);
                return;
            }
        }

        self.start().expect("Build failed.");

        tracing::info!("[{}] Build complete", self.name);
    }

    fn get_build_path_string(&self) -> String {
        format!("patches/{}/build", self.name)
    }

    fn get_build_rabcdasm_path_string(&self) -> String {
        format!("{}/{}-0", self.get_build_path_string(), self.name)
    }

    fn get_build_swf_file_string(&self) -> String {
        format!("{}/{}.swf", self.get_build_path_string(), self.name)
    }

    fn get_build_abc_file_string(&self) -> String {
        format!("{}/{}-0.abc", self.get_build_path_string(), self.name)
    }

    fn get_bytecodes_path_string(&self) -> String {
        format!("patches/{}/bytecodes", self.name)
    }

    fn get_bytecodes_final_path_string(&self) -> String {
        format!("patches/{}/final", self.name)
    }

    fn get_build_path(&self) -> PathBuf {
        PathBuf::from(self.get_build_path_string())
    }

    fn get_build_rabcdasm_path(&self) -> PathBuf {
        PathBuf::from(self.get_build_rabcdasm_path_string())
    }

    fn get_target_swf_file(&self) -> PathBuf {
        PathBuf::from(self.get_build_swf_file_string())
    }

    fn get_build_abc_file(&self) -> PathBuf {
        PathBuf::from(self.get_build_abc_file_string())
    }

    fn get_bytecode_path(&self) -> PathBuf {
        PathBuf::from(self.get_bytecodes_path_string())
    }

    fn get_bytecode_final_path(&self) -> PathBuf {
        PathBuf::from(self.get_bytecodes_final_path_string())
    }

    async fn download(&self) -> Result<(), Box<dyn Error>> {
        tracing::info!("[{}] Fetching download URL...", self.name);

        let url: String = match &self.source {
            DownloadFile::Game => {
                let resp = Client::new()
                    .get("https://game.aq.com/game/api/data/gameversion")
                    .header("User-Agent", "Mozilla/5.0")
                    .send()
                    .await?
                    .text()
                    .await?;

                let version: GameVersion = serde_json::from_str(&resp)?;

                format!("https://game.aq.com/game/gamefiles/{}", version.file)
            }
            DownloadFile::Direct(url) => url.clone(),
        };

        let mut response: Response = Client::new()
            .get(&url)
            .header("User-Agent", "Mozilla/5.0")
            .send()
            .await?;

        let mut file = File::create(self.get_target_swf_file())?;

        while let Some(chunk) = response.chunk().await? {
            file.write_all(&chunk)?;
        }

        tracing::info!("[{}] Downloaded successfully", self.name);

        Ok(())
    }

    fn export_bytecode(&self) -> Result<(), Box<dyn Error>> {
        tracing::info!(
            "[{}] Running abcexport on {}",
            self.name,
            self.get_build_swf_file_string()
        );

        let output: ExitStatus = Command::new("abcexport")
            .arg(self.get_build_swf_file_string())
            .status()?;

        tracing::info!("[{}] abcexport exited with {}", self.name, output);

        tracing::info!(
            "[{}] Running rabcdasm on {}",
            self.name,
            self.get_build_abc_file_string()
        );

        let output: ExitStatus = Command::new("rabcdasm")
            .arg(self.get_build_abc_file_string())
            .status()?;

        tracing::info!("[{}] rabcdasm exited with {}", self.name, output);

        Ok(())
    }

    fn get_patches(&self) -> Result<(), Box<dyn Error>> {
        let get_bytecode_path = self.get_bytecode_path();

        if get_bytecode_path.exists() {
            tracing::info!(
                "[{}] Copying bytecodes {} -> {}",
                self.name,
                self.get_bytecodes_path_string(),
                self.get_bytecodes_final_path_string()
            );

            util::copy_dir(&*get_bytecode_path, &*self.get_bytecode_final_path())?;
        } else {
            tracing::warn!(
                "[{}] No bytecodes directory found, skipping patch copy",
                self.name
            );
        }

        Ok(())
    }

    fn load_patch(&mut self, path: &Path) -> Result<(), Box<dyn Error>> {
        tracing::info!("[{}] Loading patches from {:?}", self.name, path);

        for file in fs::read_dir(path)? {
            let file = file?;

            let sub_path = file.path();

            let find_path = sub_path.join("find.txt");

            if find_path.exists() {
                let replace_path = sub_path.join("replace.txt");

                let find_content: String = fs::read_to_string(&find_path)?;

                if !find_content.is_empty() {
                    self.patches.insert(
                        find_content,
                        if replace_path.exists() {
                            fs::read_to_string(&replace_path)?
                        } else {
                            String::new()
                        },
                    );

                    tracing::debug!("[{}] Loaded patch: {:?}", self.name, find_path);
                }
            }

            if file.file_type()?.is_dir() {
                self.load_patch(&file.path())?;
            }
        }

        Ok(())
    }

    fn apply_patch(&self, path: &Path) -> Result<(), Box<dyn Error>> {
        for files in fs::read_dir(path)? {
            if let Ok(file) = files {
                if file.file_type()?.is_dir() {
                    let _ = self.apply_patch(&file.path());
                } else {
                    if file.path().extension().map_or(false, |ext| ext == "asasm") {
                        let mut content = fs::read_to_string(&file.path())?;

                        let mut matched = false;

                        for (find, replace) in &self.patches {
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
                                matched = true;

                                let blocks =
                                    util::find_all_original_blocks(&content, &find_normalized);

                                tracing::info!(
                                    "[{}] Applying patch to {:?}",
                                    self.name,
                                    file.path()
                                );

                                for original in blocks {
                                    content = content.replacen(&original, replace, 1);
                                }

                                fs::write(file.path(), &content)?;
                            }
                        }

                        if !matched {
                            tracing::debug!(
                                "[{}] No patches matched in {:?}",
                                self.name,
                                file.path()
                            );
                        }
                    }
                }
            }
        }

        Ok(())
    }

    fn start(&self) -> Result<(), Box<dyn Error>> {
        let main_asasm = format!(
            "{}/{}-0.main.asasm",
            self.get_build_rabcdasm_path_string(),
            self.name
        );

        tracing::info!("[{}] Assembling {}", self.name, main_asasm);

        let main_abc = format!(
            "{}/{}-0.main.abc",
            self.get_build_rabcdasm_path_string(),
            self.name
        );

        let output_rabcasm = Command::new("rabcasm").arg(&main_asasm).status()?;

        tracing::info!("[{}] rabcasm exited with {}", self.name, output_rabcasm);

        tracing::info!("[{}] Replacing ABC in SWF", self.name);

        let output_abcreplace: ExitStatus = Command::new("abcreplace")
            .arg(self.get_build_swf_file_string())
            .arg("0")
            .arg(&main_abc)
            .status()?;

        tracing::info!(
            "[{}] abcreplace exited with {}",
            self.name,
            output_abcreplace
        );

        let output_swf = format!("loader/gamefiles/{}.swf", self.name);

        if Path::new(&output_swf).exists() {
            fs::remove_file(&output_swf)?;
        }

        tracing::info!("[{}] Moving SWF to {}", self.name, output_swf);

        fs::create_dir_all("loader/gamefiles")?;

        fs::rename(self.get_build_swf_file_string(), &output_swf)?;

        Ok(())
    }
}

#[derive(Deserialize)]
struct GameVersion {
    #[serde(rename = "sFile")]
    file: String,
}
