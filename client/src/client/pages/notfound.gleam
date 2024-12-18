import client/lib/model.{type Model}
import lustre/element
import lustre/element/html

pub fn notfound(_model: Model) {
  html.div([], [element.text("404 not found")])
}
