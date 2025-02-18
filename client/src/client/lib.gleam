import client/lib/model.{type Model}
import client/lib/msg.{type Msg}
import client/lib/route.{
  type Route, About, CreateSong, Index, NotFound, ShowSong, Songs,
}
import gleam/dynamic/decode
import gleam/int
import gleam/json
import gleam/uri
import lustre/effect.{type Effect}
import lustre_http
import shared.{type Song, AuthUser, Song}

@external(javascript, "../ffi.mjs", "get_route")
fn do_get_route() -> String

pub fn get_route() -> Route {
  let assert Ok(uri) = do_get_route() |> uri.parse

  case uri.path |> uri.path_segments {
    [] -> Index
    ["about"] -> About
    ["songs"] -> Songs
    ["create-song"] -> CreateSong
    ["song", song_id] ->
      case int.parse(song_id) {
        Ok(id) -> ShowSong(id)
        Error(_) -> NotFound
      }
    _ -> NotFound
  }
}

@external(javascript, "../ffi.mjs", "set_url")
pub fn set_url(url: String) -> String

pub fn get_auth_user() -> Effect(Msg) {
  let url = "https://dev.chicommunitychoir.com/api/auth/validate"

  let decoder = {
    use is_admin <- decode.field("is_admin", decode.bool)
    decode.success(AuthUser(is_admin: is_admin))
  }

  lustre_http.get(url, lustre_http.expect_json(decoder, msg.AuthUserReceived))
}

pub fn get_songs() -> Effect(Msg) {
  let url = "/api/posts"

  let response_decoder = {
    use songs <- decode.field("songs", decode.list(song_decoder()))
    decode.success(msg.GetSongsResponse(songs))
  }

  lustre_http.get(
    url,
    lustre_http.expect_json(
      response_decoder,
      msg.SongsReceived,
    ),
  )
}

pub fn get_show_song() -> Effect(Msg) {
  let url = "/api/songs/" <> get_song_id()

  lustre_http.get(
    url,
    lustre_http.expect_json(
      song_decoder(),
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
  use id <- decode.field("id", decode.int)
  use title <- decode.field("title", decode.string)
  use href <- decode.field("href", decode.optional(decode.string))
  use filepath <- decode.field("filepath", decode.optional(decode.string))
  use tags <- decode.field("tags", decode.list(decode.string))
  use created_at <- decode.field("created_at", decode.int)
  decode.success(Song(id, title, href, filepath, tags, created_at))
}
