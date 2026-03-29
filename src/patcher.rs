use reqwest::{Client, Response};
use serde::Deserialize;
use std::error::Error;
use std::fs::File;
use std::io::Write;
use std::path::Path;
use std::process::{Command, ExitStatus};

enum DownloadSource {
    Game,
    Direct(String),
}

struct Patcher {
    name: &'static str,
    source: DownloadSource,
}

impl Patcher {
    
    pub fn get_target_swf_file(&self) -> String {
        format!("patches/{}/target/{}.swf", self.name, self.name)
    }
    
    pub fn get_target_abc_file(&self) -> String {
        format!("patches/{}/target/{}.abc", self.name, self.name)
    }

    pub fn get_default_path(&self) -> String {
        format!("patches/{}/default/", self.name)
    }

    pub fn get_final_path(&self) -> String {
        format!("patches/{}/final/", self.name)
    }

    pub fn export_bytecode(&self) -> Result<(), Box<dyn Error>> {
        let output_abcexport: ExitStatus = Command::new("abcexport").arg(self.get_target_swf_file()).status()?;

        let output_rabcdasm: ExitStatus = Command::new("rabcdasm").arg(self.get_target_abc_file()).status()?;

        println!(
            "abcexport: {}, rabcdasm : {}",
            output_abcexport, output_rabcdasm
        );

        Ok(())
    }
    
}

#[derive(Deserialize)]
struct GameVersion {
    #[serde(rename = "sFile")]
    file: String,
}

async fn download(client: &Client, asset: &Patcher) -> Result<(), Box<dyn Error>> {
    let url: String = match &asset.source {
        DownloadSource::Game => {
            let resp = client
                .get("https://game.aq.com/game/api/data/gameversion")
                .header("User-Agent", "Mozilla/5.0")
                .send()
                .await?
                .text()
                .await?;

            let version: GameVersion = serde_json::from_str(&resp)?;

            format!("https://game.aq.com/game/gamefiles/{}", version.file)
        }
        DownloadSource::Direct(url) => url.clone(),
    };

    let mut response: Response = client
        .get(&url)
        .header("User-Agent", "Mozilla/5.0")
        .send()
        .await?;
    
    let mut file = File::create(asset.get_target_swf_file())?;

    while let Some(chunk) = response.chunk().await? {
        file.write_all(&chunk)?;
    }

    println!("Downloaded: {}", asset.name);
    
    Ok(())
}

pub async fn download_assets() -> Result<(), Box<dyn Error>> {
    let client = Client::new();

    let assets = vec![
        Patcher {
            name: "game",
            source: DownloadSource::Game
        },
        Patcher {
            name: "world-map",
            source: DownloadSource::Direct("https://game.aq.com/game/gamefiles/wip.swf".into())
        },
        Patcher {
            name: "book-of-lore",
            source: DownloadSource::Direct("https://game.aq.com/game/gamefiles/wip.swf".into())
        },
    ];

    for asset in &assets {
        download(&client, asset).await?;
    }

    Ok(())
}