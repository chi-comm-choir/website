import client/lib/model.{type Model}
import client/lib/msg.{type Msg}
import gleam/list
import gleam/option.{None, Some}
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import lustre/event
import lustre/ui
import lustre/ui/button
import lustre/ui/classes

pub fn navbar(model: Model) -> Element(Msg) {
  html.div(
    [
      classes.shadow_md(),
      classes.py_md(),
      attribute.style([#("text-align", "center")]),
    ],
    [
      html.nav(
        [],
        [
          navbutton("/", "Index"),
          html.a([], [element.text(" | ")]),
          navbutton("about", "About"),
          html.a([], [element.text(" | ")]),
        ]
          |> list.append(case model.auth_user {
            None -> [
              // TODO: msg.RequestLogin event on enter
              ui.input([event.on_input(msg.LoginUpdatePassword)]),
              ui.button([button.solid(), event.on_click(msg.RequestLogin)], [element.text("Login")]),
            ]
            Some(user) -> case user.is_admin {
              False -> [
                navbutton("songs", "Songs"),
                html.a([], [element.text(" | ")]),
                ui.button([button.solid(), event.on_click(msg.RequestLogout)], [element.text("Log out")]),
              ]
              True -> {[
                navbutton("songs", "Songs"),
                html.a([], [element.text(" | ")]),
                navbutton("create-post", "Create new post"),
                html.a([], [element.text(" | ")]),
                ui.button([button.solid(), event.on_click(msg.RequestLogout)], [element.text("Log out")]),
              ]}
            }
          }),
      ),
      html.hr([attribute.style([#("opacity", "0")])]),
    ],
  )
}

fn navbutton(href: String, title: String) {
  html.a([attribute.href(href)], [
    ui.button([button.greyscale(), button.outline()], [element.text(title)]),
  ])
}
