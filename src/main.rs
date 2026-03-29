use crate::patcher::{DownloadFile, Patcher};

mod patcher;
mod util;

#[tokio::main]
async fn main() {
    let log_level = if cfg!(debug_assertions) {
        tracing::Level::DEBUG
    } else {
        tracing::Level::INFO
    };

    tracing_subscriber::fmt().with_max_level(log_level).init();

    Patcher::new("game", DownloadFile::Game).build().await;

    Patcher::new(
        "world-map",
        DownloadFile::Direct("https://game.aq.com/game/gamefiles/title/Generic2.swf".into()),
    )
    .build()
    .await;

    Patcher::new(
        "book-of-lore",
        DownloadFile::Direct("https://game.aq.com/game/gamefiles/title/Generic2.swf".into()),
    )
    .build()
    .await;
}
