import client/lib/route.{type Route}
import gleam/dynamic/decode
import gleam/option.{type Option}
import lustre_http
import shared.{type AuthUser, type Song, Song}

pub type Msg {
  OnRouteChange(Route)

  AuthUserReceived(Result(AuthUser, lustre_http.HttpError))

  SongsReceived(Result(GetSongsResponse, lustre_http.HttpError))
  ShowSongReceived(Result(Song, lustre_http.HttpError))

  LoginUpdatePassword(value: String)
  LoginUpdateError(value: Option(String))
  RequestLogin
  RequestLogout
  LoginResponded(
    resp_result: Result(MessageErrorResponse, lustre_http.HttpError),
  )
  LogoutResponded(
    resp_result: Result(MessageErrorResponse, lustre_http.HttpError),
  )

  CreateSongUpdateTitle(value: String)
  CreateSongUpdateHref(value: String)
  CreateSongUpdateFilePath(value: String)
  CreateSongUpdateError(value: Option(String))
  RequestCreateSong
  CreateSongResponded(
    resp_result: Result(MessageErrorResponse, lustre_http.HttpError),
  )
}

pub type GetSongsResponse {
  GetSongsResponse(songs: List(Song))
}

pub type MessageErrorResponse {
  MessageErrorResponse(message: Option(String), error: Option(String))
}

pub fn message_error_decoder() {
  use message <- decode.field("message", decode.optional(decode.string))
  use error <- decode.field("error", decode.optional(decode.string))
  decode.success(MessageErrorResponse(message: message, error: error))
}
