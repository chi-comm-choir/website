import client/lib/model.{type Model}
import lustre/attribute
import lustre/element
import lustre/element/html
import lustre/ui/classes

pub fn songs(_model: Model) {
  html.div([], [
    html.div([attribute.style([#("display", "flex"), #("justify-content", "center")])], [
      html.p([classes.font_alt()], [
        element.text("Songs")
      ])
    ])
  ])
}
