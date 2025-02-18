import client/lib/model.{type Model}
import client/lib/msg.{type Msg}
import gleam/json
import lustre/effect.{type Effect}
import lustre_http

pub fn login(model: Model) -> Effect(Msg) {
  lustre_http.post(
    // TODO: get the correct server api url here
    "https://dev.chicommunitychoir.com/api/auth/login",
    json.object([#("password", json.string(model.login_password))]),
    lustre_http.expect_json(msg.message_error_decoder(), msg.LoginResponded),
  )
}

pub fn logout(_model: Model) -> Effect(Msg) {
  lustre_http.post(
    "https://dev.chicommunitychoir.com/api/auth/logout",
    json.object([]),
    lustre_http.expect_json(msg.message_error_decoder(), msg.LogoutResponded),
  )
}
