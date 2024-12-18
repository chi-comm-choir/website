import client/lib/model.{type Model}
import client/lib/msg.{type Msg}
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import lustre/ui
import lustre/ui/button
import lustre/ui/classes

pub fn navbar(_model: Model) -> Element(Msg) {
  html.div([classes.shadow_md(), classes.py_md(), attribute.style([#("display", "flex"), #("justify-content", "center")])], [
    ui.centre(
      [],
      html.nav([], [
        html.a([attribute.href("/")], [ui.button([], [element.text("Index")])]),
        html.a([], [element.text(" | ")]),
        html.a([attribute.href("about")], [
          ui.button([button.info(), button.outline(), button.warning()], [
            element.text("About"),
          ]),
        ]),
        html.a([], [element.text(" | ")]),
        html.a([attribute.href("songs")], [
          ui.button([button.greyscale(), button.outline()], [
            element.text("Songs"),
          ]),
        ]),
      ]),
    ),
    html.hr([attribute.style([#("opacity", "0")])]),
  ])
}
