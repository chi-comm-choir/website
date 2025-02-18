import client/lib/model.{type Model}
import lustre/element.{text}
import lustre/element/html.{div, section, h1, h2, p, img, a}
import lustre/attribute.{class, alt, href}

pub fn about(_model: Model) {
  div([], [
    section([class("about-hero")], [
      div([class("container")], [
        h1([], [text("About Us")]),
        p([class("lead")], [text("about")]),
        img([alt("banner image")]),
      ]),
    ]),
    section([class("directors-bio")], [
      div([class("container")], [
        div([class("directors-image")], [
          img([alt("Directors Caroline and John")]),
        ]),
        div([class("directors-info")], [
          h2([], [text("Our Directors")]),
          p([], [text("Both our choir leaders have extensive knowledge & years of experience in building fabulous vocal groups, and vast amounts of enthusiasm to get our local community singing!.")]),
          // Edited to remove post-pandemic stuff
        ])
      ]),
    ]),
    section([class("choir-info")], [
      div([class("container")], [
        p([], [text("Meeting every week on Tuesday evenings, we aim to provide singers with the opportunity to explore a wide variety of musical styles. We perform in rich harmony using SATB voice parts: from madrigals to mash-ups, rounds to rock and canons to classical.")]),
        // Paragraph about post-pandemic adaptations removed.
        p([], [
          text("For details on how to join us email "), a([href("mailto://caroline@chicommunitychoir.com")], [text("caroline@chicommunitychoir.com")])
        ]),
      ]),
    ]),
    section([class("foundation")], [
      div([class("container")], [
        p([], [text("Chichester Community Choir was founded by Steve Flashman, who soon realised that not everyone could make it to evening rehearsals. He set up satellite daytime choirs to complement the CCC, which are now run by Caroline as Upbeat Singers, in Southbourne and East Preston. John also runs a daytime choir, the Ok Chorale.")]),
      ])
    ])
  ])
}
