import client/lib/model.{type Model}
import lustre/element
import lustre/element/html

pub fn about(_model: Model) {
  html.div([], [element.text("about")])
}
