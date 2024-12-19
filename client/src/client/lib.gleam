import client/lib/model.{type Model}
import client/lib/msg.{type Msg}
import client/lib/route.{type Route, Active, NotFound}
import decode
import gleam/json
import gleam/uri
import lustre/effect.{type Effect}
import lustre_http
import shared.{type Song, Song}

@external(javascript, "../ffi.mjs", "get_route")
fn do_get_route() -> String

pub fn get_route() -> Route {
  let assert Ok(uri) = do_get_route() |> uri.parse

  case uri.path |> uri.path_segments {
    [] -> Active
    _ -> NotFound
  }
}

@external(javascript, "../ffi.mjs", "set_url")
pub fn set_url(url: String) -> String

pub fn get_songs() -> Effect(Msg) {
  let url = "/api/posts"

  let response_decoder =
    decode.into({
      use songs <- decode.parameter
      msg.GetSongsResponse(songs)
    })
    |> decode.field("songs", decode.list(song_decoder()))

  lustre_http.get(
    url,
    lustre_http.expect_json(
      fn(data) { response_decoder |> decode.from(data) },
      msg.SongsReceived,
    ),
  )
}

pub fn get_show_song() -> Effect(Msg) {
  let url = "/api/songs/" <> get_song_id()

  lustre_http.get(
    url,
    lustre_http.expect_json(
      fn(data) { decode.from(song_decoder(), data) },
      msg.ShowSongReceived,
    ),
  )
}

fn get_song_id() -> String {
  let uri = case do_get_route() |> uri.parse {
    Ok(uri) -> uri
    _ -> panic as "Invalid uri"
  }

  case uri.path |> uri.path_segments {
    ["song", song_id] -> song_id
    _ -> ""
  }
}

pub fn create_song(model: Model) {
  lustre_http.post(
    "/api/songs",
    json.object([
      #("title", json.string(model.create_song_title)),
      case model.create_song_use_filepath {
        True -> #("filepath", json.string(model.create_song_filepath))
        False -> #("href", json.string(model.create_song_href))
      },
    ]),
    lustre_http.expect_json(
      msg.message_error_decoder(),
      msg.CreateSongResponded,
    ),
  )
}

pub fn song_decoder() {
  decode.into({
    use id <- decode.parameter
    use title <- decode.parameter
    use href <- decode.parameter
    use filepath <- decode.parameter
    use tags <- decode.parameter
    use created_at <- decode.parameter

    Song(id, title, href, filepath, tags, created_at)
  })
  |> decode.field("id", decode.int)
  |> decode.field("title", decode.string)
  |> decode.field("href", decode.optional(decode.string))
  |> decode.field("filepath", decode.optional(decode.string))
  |> decode.field("tags", decode.list(decode.string))
  |> decode.field("created_at", decode.int)
}
