import lustre
import lustre/effect.{type Effect}
import lustre/element.{type Element}

import client/lib
import client/lib/model.{type Model, Model}
import client/lib/msg.{type Msg}
import client/pages/app

pub fn main() {
  let app = lustre.application(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)

  Nil
}

fn init(_) -> #(Model, Effect(Msg)) {
  let model = Model(route: lib.get_route(), songs: [])
  let effect = effect.batch([])

  #(model, effect)
}

fn update(model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
  case msg {
    msg.AddSong(_title, _path) -> #(model, effect.none())
    msg.RenameSong(_from, _to) -> #(model, effect.none())
    msg.SongsReceived(get_songs_result) ->
      case get_songs_result {
        Ok(get_songs) -> #(
          Model(..model, songs: get_songs.songs),
          effect.none(),
        )
        Error(_) -> #(model, effect.none())
      }
  }
}

pub fn view(model: Model) -> Element(Msg) {
  app.app(model)
}
