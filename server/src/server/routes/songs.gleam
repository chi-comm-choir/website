import gleam/http.{Get, Post}
import wisp.{type Request, type Response}

pub fn songs(req: Request) -> Response {
  case req.method {
    Get -> list_songs_res(req)
    Post -> create_song(req)
    _ -> wisp.method_not_allowed([Get, Post])
  }
}

pub fn list_songs(req: Request) -> Result(List(shared.Song), String) {
}
