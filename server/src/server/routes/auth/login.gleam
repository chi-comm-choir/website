import gleam/bool
import gleam/dynamic
import gleam/http.{Post}
import gleam/json
import gleam/result
import wisp.{type Request, type Response}

pub fn login(req: Request) -> Response {
  use body <- wisp.require_json(req)

  case req.method {
    Post -> do_login(req, body)
    _ -> wisp.method_not_allowed([Post])
  }
}

type Login {
  Login(password: String)
}

fn decode_create_user(
  json: dynamic.Dynamic,
) -> Result(Login, dynamic.DecodeErrors) {
  let decoder =
    dynamic.decode1(
      Login,
      dynamic.field("password", dynamic.string),
    )
  case decoder(json) {
    Ok(login) ->
      Ok(Login(
        password: login.password,
      ))
    Error(error) -> Error(error)
  }
}

fn do_login(req: Request, body: dynamic.Dynamic) -> Response {
  let result = {
    use user <- result.try(case decode_create_user(body) {
      Ok(val) -> Ok(val)
      Error(_) -> Error("Invalid body recieved")
    })

    use <- bool.guard(
      when: user.password != "test",
      return: Error("Passwords do not match"),
    )

    // TODO: Real session token generation
    // use session_token <- result.try(user_session.create_user_session(user.id))

    Ok("test_session_token")
  }

  case result {
    Ok(session_token) ->
      wisp.json_response(
        json.object([#("message", json.string("Logged in"))])
          |> json.to_string_tree,
        201,
      )
      |> wisp.set_cookie(
        req,
        "lf_session_token",
        session_token,
        wisp.PlainText,
        60 * 60 * 24 * 1000,
      )
    Error(error) ->
      wisp.json_response(
        json.object([#("error", json.string(error))])
          |> json.to_string_tree,
        200,
      )
  }
}
