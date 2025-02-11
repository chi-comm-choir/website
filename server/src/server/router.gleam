import client
import client/lib/model.{Model}
import client/lib/route.{
  About, CreateSong, Index, NotFound, ShowSong, Songs,
}
import cors_builder as cors
import gleam/http
import gleam/int
import gleam/option.{None, Some}
import lustre/element
import server/db/auth
import server/db/user_session
import server/response
import server/routes/song
import server/routes/songs
import server/routes/auth/login
import server/routes/auth/logout
import server/routes/auth/validate
import server/scaffold
import server/web
import shared.{AuthUser}
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
    ["api", "songs"] ->
      case user_session.get_user_from_session(req) {
        Ok(_) -> songs.songs(req)
        Error(_) -> response.error("Unauthorized - please log in")
      }
    ["api", "songs", song_id] -> {
      case user_session.get_user_from_session(req) {
        Ok(_) -> 
          case int.parse(song_id) {
            Ok(id) -> song.song(req, id)
            Error(_) -> response.error("Invalid song_id for song, must be int")
          }
        Error(_) -> response.error("Unauthorized - please log in")
      }
    }
    ["api", "auth", "login"] -> login.login(req)
    ["api", "auth", "validate"] -> validate.validate(req)
    ["api", "auth", "logout"] -> logout.logout(req)
    _ -> wisp.not_found()
  }
}

fn protected_route(
  req: Request,
  route: #(route.Route, Int),
  admin_only: Bool,
) -> #(route.Route, Int) {
  case user_session.get_user_from_session(req) {
    Ok(user) -> case user, admin_only {
      #(_, 1), True -> route
      _, False -> route
      _, True -> #(Index, 401)
    }
    Error(_) -> #(Index, 401)
  }
}

fn page_routes(req: Request, route_segments: List(String)) -> Response {
  let #(route, response) = case route_segments {
    [] -> #(Index, 200)
    ["about"] -> #(About, 200)
    ["songs"] -> protected_route(req, #(Songs, 200), False)
    // ["auth", "login"] -> #(Login, 200)
    ["create-song"] -> protected_route(req, #(CreateSong, 200), True)
    ["song", song_id] ->
      case int.parse(song_id) {
        Ok(id) -> protected_route(req, #(ShowSong(id), 200), False)
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
      auth_user: case user_session.get_user_from_session(req) {
        Ok(#(_, 1)) -> Some(AuthUser(is_admin: True))
        Ok(_) -> Some(AuthUser(is_admin: False))
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
