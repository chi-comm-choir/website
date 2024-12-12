import client
import client/lib/model.{Model}
import client/lib/route.{type Route, Index, NotFound}
import cors_builder as cors
import gleam/http
import lustre/element
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
    ps -> page_routes(req, ps)
  }
}

fn page_routes(_req: Request, route_segments: List(String)) -> Response {
  let route: Route = case route_segments {
    [] -> Index
    _ -> NotFound
  }

  let model = Model(route: route, songs: [])

  wisp.response(200)
  |> wisp.set_header("Content-Type", "text-html")
  |> wisp.html_body(
    client.view(model)
    |> scaffold.page_scaffold()
    |> element.to_document_string_builder(),
  )
}
