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
import shared.{Admin, Member}

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
              // TODO: Maybe make this a single component, rather than a whole other page?
              // refactor the below into a component
              ui.input([event.on_input(msg.LoginUpdatePassword)]),
              // msg.RequestLogin event on enter, button click?
              html.a([attribute.href("/auth/login")], [element.text("Login")]),
            ]
            Some(Member) -> [navbutton("songs", "Songs")]
            Some(Admin) -> {[
              navbutton("songs", "Songs"),
              html.a([], [element.text(" | ")]),
              navbutton("create-post", "Create new post"),
            ]}
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
