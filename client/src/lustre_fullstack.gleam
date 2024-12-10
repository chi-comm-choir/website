import lustre
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import lustre/effect.{type Effect}

import lustre_fullstack/lib/model.{type Model, Model}
import lustre_fullstack/lib/msg.{type Msg}
import lustre_fullstack/pages/app

pub fn main() {
  let app = lustre.application(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)

  Nil
}

fn init(_) -> #(Model, Effect(Msg)) {
  let model = Model(songs: [])
  let effect = effect.none()

  #(model, effect)
}

fn update(_model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
  case msg {
    msg.AddSong(title, path) -> todo
    msg.RenameSong(from, to) -> todo
  }
}

fn view(model: Model) -> Element(Msg) {
  app.app(model)
}
