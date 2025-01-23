import client
import client/lib/model.{Model}
import client/lib/route.{
  About, CreateSong, Index, Login, NotFound, ShowSong, Songs,
}
import cors_builder as cors
import gleam/http
import gleam/int
import gleam/option.{None, Some}
import lustre/element
import server/db/user_session
import server/response
import server/routes/song
import server/routes/songs
import server/routes/auth/login
import server/scaffold
import server/web
import wisp.{type Request, type Response}

pub fn handle_request(req: Request) -> Response {
  use req <- web.middleware(req)
  use req <- cors.wisp_middleware(
    req,
    cors.new()
      |> cors.allow_origin("http://localhost:1234")
      |> cors.allow_method(http.Get)
      |> cors.allow_method(http.Post)
      |> cors.allow_header("Content-Type"),
  )

  case wisp.path_segments(req) {
    ["api", ..] -> api_routes(req, wisp.path_segments(req))
    ps -> page_routes(req, ps)
  }
}

fn api_routes(req: Request, route_segments: List(String)) -> Response {
  case route_segments {
    ["api", "songs"] -> songs.songs(req)
    ["api", "songs", song_id] -> {
      case int.parse(song_id) {
        Ok(id) -> song.song(req, id)
        Error(_) -> response.error("Invalid song_id for song, must be int")
      }
    }
    ["api", "auth", "login"] -> login.login(req)
    // ["api", "auth", "logout"] -> logout.logout(req)
    _ -> wisp.not_found()
  }
}

fn page_routes(req: Request, route_segments: List(String)) -> Response {
  let #(route, response) = case route_segments {
    [] -> #(Index, 200)
    ["about"] -> #(About, 200)
    ["songs"] -> #(Songs, 200)
    // ["auth", "login"] -> #(Login, 200)
    ["create-song"] -> #(CreateSong, 200)
    ["song", song_id] ->
      case int.parse(song_id) {
        Ok(id) -> #(ShowSong(id), 200)
        Error(_) -> #(NotFound, 404)
      }
    _ -> #(NotFound, 404)
  }

  let model =
    Model(
      route: route,
      create_song_title: "",
      create_song_href: "",
      create_song_filepath: "",
      create_song_use_filepath: False,
      create_song_error: None,
      login_password: "",
      login_error: None,
      auth_user: case user_session.get_user_priviledges_from_session(req) {
        Ok(priviledges) -> Some(priviledges)
        Error(_) -> None
      },
      songs: case songs.list_songs(req) {
        Ok(songs) -> songs
        Error(_) -> []
      },
      show_song: case route {
        route.ShowSong(id) -> {
          case song.show_song(req, id) {
            Ok(song) -> Some(song)
            Error(_) -> None
          }
        }
        _ -> None
      },
    )

  wisp.response(response)
  |> wisp.set_header("Content-Type", "text-html")
  |> wisp.html_body(
    client.view(model)
    |> scaffold.page_scaffold()
    |> element.to_document_string_builder(),
  )
}
