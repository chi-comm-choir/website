import client/lib/model.{type Model}
import lustre/element
import lustre/element/html

pub fn index(model: Model) {
  html.div([], [
    html.div([], [
      element.text("index"),
    ]),
    html.div([], [
      element.text("password:" <> model.login_password)
    ]),
  ])
}
