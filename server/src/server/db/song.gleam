import cake/fragment
import cake/join
import cake/select.{type Select}
import cake/where
import decode
import gleam/dynamic
import gleam/int
import gleam/json.{type Json}
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import server/db.{list_to_tuple}
import shared.{type Song, Song}
import sqlight.{type Value}
import wisp.{type Request}

pub type ListSongsDBRow {
  ListSongsDBRow(
    song_id: Int,
    song_title: String,
    song_href: Option(String),
    song_filepath: Option(String),
    created_at: Int,
  )
}

pub fn get_songs_query() -> Select {
  select.new()
  |> select.selects([])
  |> select.from_table("song")
  |> select.group_by("song.id")
  |> select.order_by_desc("song.created_at")
}

pub fn run_song_query(select: Select, params: List(Value)) {
  select.to_query(select)
  |> db.execute_read(params, fn(data) {
    decode.into({
      use song_id <- decode.parameter
      use song_title <- decode.parameter
      use song_href <- decode.parameter
      use song_filepath <- decode.parameter
      use created_at <- decode.parameter

      ListSongsDBRow(song_id, song_title, song_href, song_filepath, created_at)
    })
    |> decode.field(0, decode.int)
    |> decode.field(1, decode.string)
    |> decode.field(2, decode.optional(decode.string))
    |> decode.field(3, decode.optional(decode.string))
    |> decode.field(4, decode.int)
    |> decode.from(data |> list_to_tuple)
  })
}

pub fn song_rows_to_song(_req: Request, rows: List(ListSongsDBRow)) {
  use row <- list.map(rows)
  Song(
    id: row.song_id,
    title: row.song_title,
    href: row.song_href,
    filepath: row.song_filepath,
    tags: [],
    created_at: row.created_at,
  )
}

pub fn song_to_json(song: Song) {
  json.object([
    #("id", json.int(song.id)),
    #("title", json.string(song.title)),
    case song.href {
      Some(href) -> #("href", json.string(href))
      None ->
        case song.filepath {
          Some(filepath) -> #("filepath", json.string(filepath))
          None -> panic as "Invalid State"
        }
    },
    #("tags", json.array(song.tags, fn(tag) { json.string(tag) })),
    #("created_at", json.int(song.created_at)),
  ])
}
