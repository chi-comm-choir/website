import lustre/attribute.{attribute, href, name, rel, src}
import lustre/element
import lustre/element/html.{head, html, link, meta, script, title}

pub fn page_scaffold(content: element.Element(a)) {
  html([], [
    head([], [
      meta([attribute("charset", "UTF-8")]),
      meta([
        attribute("content", "width=device-width, initial-scale=1.0"),
        name("viewport"),
      ]),
      title([], "Lustre-Fullstack"),
      meta([
        attribute("content", "Test fullstack app with lustre"),
        name("description"),
      ]),
      meta([attribute("content", "max-image-preview:large"), name("robots")]),
      meta([attribute("content", "en_US"), attribute("property", "og:locale")]),
      meta([
        attribute("content", "Lustre-Fullstack"),
        attribute("property", "og:site_name"),
      ]),
      meta([attribute("content", "website"), attribute("property", "og:type")]),
      meta([
        attribute("content", "Lustre_Fullstack"),
        attribute("property", "og:title"),
      ]),
      meta([
        attribute("content", "Test fullstack app with lustre"),
        attribute("property", "og:description"),
      ]),
      meta([attribute("content", ""), attribute("property", "og:url")]),
      meta([
        attribute("content", "Test fullstack app with lustre"),
        name("twitter:description"),
      ]),
      link([
        href("/priv/static/favicon.ico"),
        attribute.type_("image/x-icon"),
        rel("icon"),
      ]),
      script([src("/static/client.min.mjs"), attribute.type_("module")], ""),
      // TODO: Custom CSS
      // link([href("/static/client.min.css"), rel("stylesheet")]),
      // TODO: Custom JS
      // script(
      //   [
      //     src("https://lustre_fullstack.example/js/script.js"),
      //     attribute("data-domain", "lustre_fullstack.example"),
      //     attribute("defer", ""),
      //   ],
      //   "",
      // ),
    ]),
    content,
  ])
}
