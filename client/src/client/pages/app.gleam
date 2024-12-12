import lustre/element.{type Element}
import lustre/element/html
import client/lib/model.{type Model}
import client/lib/msg.{type Msg}

pub fn app(model: Model) -> Element(Msg) {
  html.div([], [element.text("hello world")])
}
