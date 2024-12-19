import client/lib/route.{type Route}
import gleam/option.{type Option}
import shared.{type Song}

pub type Model {
  Model(
    route: Route,
    create_song_title: String,
    create_song_href: String,
    create_song_filepath: String,
    create_song_use_filepath: Bool,
    create_song_error: Option(String),
    songs: List(Song),
    show_song: Option(Song),
  )
}
