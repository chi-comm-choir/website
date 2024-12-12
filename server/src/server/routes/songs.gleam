import server/response
import cake/insert
import cake/select
import cake/where
import gleam/http.{Get, Post}
import gleam/dynamic.{type Dynamic}
import gleam/json
import gleam/option.{type Option}
import wisp.{type Request, type Response}
import server/db/song
import shared
import sqlight

pub fn songs(req: Request) -> Response {
  case req.method {
    Get -> list_songs_res(req)
    Post -> todo as "create_song(req)"
    _ -> wisp.method_not_allowed([Get, Post])
  }
}

pub fn list_songs(req: Request) -> Result(List(shared.Song), String) {
  case song.get_songs_query()
  |> song.run_song_query([]) {
    Ok(rows) -> Ok(song.song_rows_to_song(req, rows, False))
    Error(_) -> Error("Selecting songs")
  }
}

pub fn list_songs_res(req: Request) -> Response {
  let query = case song.get_songs_query() |> song.run_song_query([]) {
    Ok(rows) -> Ok(rows)
    Error(_) -> Error("Selecting songs")
  }

  case query {
    Ok(rows) -> Ok(
      json.object([
        #(
          "songs",
          song.song_rows_to_song(req, rows, False)
          |> json.array(fn(song) { song.song_to_json(song) }),
        ),
      ])
      |> json.to_string_tree
    )
    Error(error) -> Error(error)
  }
  |> response.generate_wisp_response
}

type CreateSong {
  CreateSong(
    title: String,
    href: Option(String),
    filepath: Option(String),
    tags: List(Int),
  )
}

fn decode_create_song(
  json: Dynamic
) -> Result(CreateSong, dynamic.DecodeErrors) {
  let decoder = dynamic.decode4(
    CreateSong,
    dynamic.field("title", dynamic.string),
    dynamic.optional_field("href", dynamic.string),
    dynamic.optional_field("filepath", dynamic.string),
    dynamic.field("tags", dynamic.list(dynamic.int)),
  )
  decoder(json)
}

fn insert_song_to_db(req: Request, song: CreateSong) {

}
