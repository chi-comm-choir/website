import lustre
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import lustre/effect.{type Effect}

import client/lib
import client/lib/model.{type Model, Model}
import client/lib/msg.{type Msg}
import client/lib/route.{type Route}
import client/pages/app

pub fn main() {
  let app = lustre.application(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)

  Nil
}

fn init(_) -> #(Model, Effect(Msg)) {
  let model = Model(
    route: lib.get_route(),
    songs: []
  )
  let effect = effect.batch([
  ])

  #(model, effect)
}

fn update(model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
  case msg {
    msg.AddSong(title, path) -> #(model, effect.none())
    msg.RenameSong(from, to) -> #(model, effect.none())
  }
}

pub fn view(model: Model) -> Element(Msg) {
  app.app(model)
}
