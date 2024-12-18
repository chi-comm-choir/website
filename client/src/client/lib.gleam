import client/lib/msg.{type Msg, GetSongsResponse, SongsReceived}
import client/lib/route.{type Route, Index, NotFound, Songs}
import decode
import gleam/uri
import lustre/effect.{type Effect}
import lustre_http
import shared.{type Song, Song}

@external(javascript, "../ffi.mjs", "get_route")
fn do_get_route() -> String

pub fn get_route() -> Route {
  let assert Ok(uri) = do_get_route() |> uri.parse

  case uri.path |> uri.path_segments {
    [] -> Index
    ["songs"] -> Songs
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
      GetSongsResponse(songs)
    })
    |> decode.field("songs", decode.list(song_decoder()))

  lustre_http.get(
    url,
    lustre_http.expect_json(
      fn(data) { response_decoder |> decode.from(data) },
      SongsReceived,
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
