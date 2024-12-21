import gleam/option.{None, Some}
import lustre
import lustre/effect.{type Effect}
import lustre/element.{type Element}

import client/lib
import client/lib/model.{type Model, Model}
import client/lib/msg.{type Msg}
import client/lib/route
import client/routes/app

import modem

pub fn main() {
  let app = lustre.application(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)

  Nil
}

fn init(_) -> #(Model, Effect(Msg)) {
  let model =
    Model(
      route: lib.get_route(),
      create_song_title: "",
      create_song_href: "",
      create_song_filepath: "",
      create_song_use_filepath: False,
      create_song_error: None,
      login_password: "",
      login_error: None,
      auth_user: None,
      songs: [],
      show_song: None,
    )
  let effect = effect.batch([])

  #(model, effect)
}

fn update(model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
  case msg {
    msg.OnRouteChange(route) -> #(
      Model(
        ..model,
        route: route,
        show_song: case route {
          route.ShowSong(_) -> None
          _ -> model.show_song
        },
      ),
      case route {
        route.ShowSong(_) -> lib.get_show_song()
        route.CreateSong -> effect.none()
        //  TODO: tags
        _ -> effect.none()
      },
    )
    msg.SongsReceived(get_songs_result) -> {
      case get_songs_result {
        Ok(get_songs) -> #(
          Model(..model, songs: get_songs.songs),
          effect.none(),
        )
        Error(_) -> #(model, effect.none())
      }
    }
    msg.ShowSongReceived(get_song_result) -> {
      case get_song_result {
        Ok(get_song) -> #(
          Model(..model, show_song: Some(get_song)),
          effect.none(),
        )
        Error(_) -> #(model, effect.none())
      }
    }
    msg.CreateSongUpdateTitle(value) -> #(
      Model(..model, create_song_title: value),
      effect.none(),
    )
    msg.CreateSongUpdateHref(value) -> #(
      Model(..model, create_song_href: value),
      effect.none(),
    )
    msg.CreateSongUpdateFilePath(value) -> #(
      Model(..model, create_song_filepath: value),
      effect.none(),
    )
    msg.CreateSongUpdateError(value) -> #(
      Model(..model, create_song_error: value),
      effect.none(),
    )
    msg.RequestCreateSong -> #(model, lib.create_song(model))
    msg.CreateSongResponded(resp_result) -> {
      case resp_result {
        Ok(resp) -> {
          case resp.error {
            Some(err) -> #(
              model,
              effect.from(fn(dispatch) {
                dispatch(msg.CreateSongUpdateError(Some(err)))
              }),
            )
            None -> #(
              Model(
                ..model,
                create_song_title: "",
                create_song_href: "",
                create_song_filepath: "",
                create_song_error: None,
              ),
              effect.batch([modem.push("/", None, None), lib.get_songs()]),
            )
          }
        }
        Error(_) -> #(
          model,
          effect.from(fn(dispatch) {
            dispatch(msg.CreateSongUpdateError(Some("HTTP Error")))
          }),
        )
      }
    }
  }
}

pub fn view(model: Model) -> Element(Msg) {
  app.app(model)
}
