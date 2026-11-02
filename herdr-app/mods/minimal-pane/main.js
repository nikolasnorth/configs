// Pane header for the `minimal` layout, Rex style: the program's glyph and
// the pane's title on the left; split, zoom and close buttons on the right
// while the pane is focused or hovered. Props from the app: { pane, terminal }.

import { View, div, svg, image } from "gpui-kit";
import { h_flex } from "gpui-base";
import { panes, props, run, theme, home } from "herdr";

function folder(cwd) {
  if (!cwd) return "";
  const h = home();
  return cwd === h ? "~" : cwd.startsWith(h + "/") ? "~" + cwd.slice(h.length) : cwd;
}

// Same naming as the sidebar: the agent's terminal title (spinner glyphs
// stripped), else "<program> <folder>".
function label(p) {
  const title = (p.title ?? "").replace(/^[^\p{L}\p{N}]+/u, "").trim();
  if (p.program?.agent && title && title !== p.program.name) return title;
  const name = p.program?.name ?? "Terminal";
  return p.cwd ? `${name} ${folder(p.cwd)}` : name;
}

function glyph(t, g) {
  if (!g?.icon) return svg("mods/workspace-chrome/terminal.svg").size(14).flex_none().text_color(t.muted);
  return g.tint ? svg(g.icon).size(15).flex_none().text_color(t.foreground) : image(g.icon).size(15).flex_none();
}

export default class Pane extends View {
  init() { this.hovered = false; }

  button(t, id, icon, command, args) {
    return div().id(id).p(4).rounded(5).text_color(t.dim)
      .hover(s => s.bg(t.hover).text_color(t.foreground))
      .on_mouse_down("left", (_e, cx) => cx.stop_propagation())
      .on_click((_e, cx) => { cx.stop_propagation(); run(command, args); })
      .child(svg(`mods/minimal-pane/${icon}.svg`).size(14));
  }

  render() {
    const t = theme();
    const p = panes().find(x => x.pane === props()?.pane);
    if (!p) return div();
    const pane = p.pane, st = p.status;
    return h_flex().id(`pane-head-${pane}`).size_full().px(12).gap(8).items_center()
      .bg(t.surface).text_size(14)
      .on_hover((hovered, cx) => { this.hovered = hovered; cx.notify(); })
      .on_click(() => run("pane.focus", { pane }))
      .child(glyph(t, p.program))
      .child(div().flex_1().min_w(0).truncate().font_medium().text_color(p.focused ? t.foreground : t.muted).child(label(p)))
      .when(st === "working", el => el.child(svg("mods/workspace-chrome/spinner.svg").size(12).flex_none().text_color(t.working).spin(900)))
      .when(st === "blocked", el => el.child(div().flex_none().px(6).h(18).flex().items_center().rounded(5).bg(t.blocked + "26").text_size(10.5).font_semibold().text_color(t.blocked).child("Needs you")))
      .when(st === "done", el => el.child(div().size(7).flex_none().rounded(4).bg(t.done)))
      .when(this.hovered || p.focused, el => el
        .child(this.button(t, `ph-r-${pane}`, "split-right", "pane.split", { direction: "right", pane }))
        .child(this.button(t, `ph-d-${pane}`, "split-down", "pane.split", { direction: "down", pane }))
        .child(this.button(t, `ph-z-${pane}`, p.zoomed ? "unzoom" : "zoom", "pane.zoom", { pane }))
        .child(this.button(t, `ph-x-${pane}`, "close", "pane.close", { pane })));
  }
}
