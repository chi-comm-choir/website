import gleam/io
import gleam/json
import lustre/effect.{type Effect}
import lustre_http
import client/lib/model.{type Model}
import client/lib/msg.{type Msg}

pub fn login(model: Model) -> Effect(Msg) {
  lustre_http.post(
    // TODO: get the correct server api url here
    "http://dev.jazzkid.xyz/api/auth/login",
    json.object([#("password", json.string(model.login_password))]),
    lustre_http.expect_json(msg.message_error_decoder(), msg.LoginResponded)
  )
}
