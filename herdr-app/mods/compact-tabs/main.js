import { View, div, svg, image } from "gpui-kit";
import { h_flex, v_flex } from "gpui-base";
import { spaces, panes, run, openOverlay, theme, home } from "herdr";

// Sidebar for the `minimal` layout: every space as a header with its tabs
// under it. Each tab shows its programs' tiles and its lead pane's title.

function folder(cwd) {
  if (!cwd) return "";
  const h = home();
  return cwd === h ? "~" : cwd.startsWith(h + "/") ? "~" + cwd.slice(h.length) : cwd;
}

// The pane a tab speaks for: the focused one, else its agent, else the first.
function lead(mine) {
  return mine.find(p => p.focused) ?? mine.find(p => p.program?.agent) ?? mine[0];
}

// What a tab is called: its given name, else its lead pane's name.
function label(tab, p) {
  return tab.named ? tab.name : paneLabel(p);
}

// What a pane is called: what its agent set as the terminal title (spinner
// glyphs stripped), else "<program> <folder>".
function paneLabel(p) {
  const title = (p?.title ?? "").replace(/^[^\p{L}\p{N}]+/u, "").trim();
  if (p?.program?.agent && title && title !== p.program.name) return title;
  const name = p?.program?.name ?? "Terminal";
  return p?.cwd ? `${name} ${folder(p.cwd)}` : name;
}

function glyph(t, g, size) {
  if (!g?.icon) return svg("mods/workspace-chrome/terminal.svg").size(size - 1).text_color(t.muted);
  return g.tint ? svg(g.icon).size(size).text_color(g.color ?? t.foreground) : image(g.icon).size(size);
}

function tile(t, g, size) {
  return div().flex_none().size(size).rounded(size / 4).border_1().border_color("#ffffff14")
    .bg(g?.tile ?? t.raised).flex().items_center().justify_center()
    .child(glyph(t, g, Math.round(size * 0.58)));
}

// A tab's icon, stacked like a deck of cards: the front pane's tile centered,
// and up to two of the tab's other panes peeking out above it, each a little
// narrower. `ring` matches the row's background so each card stands out.
function icon(t, mine, front, ring) {
  const others = mine.filter(p => p !== front).slice(0, 2);
  if (!others.length) return tile(t, front?.program, 20);
  const card = (p, w, top) => div().absolute().top(top).left((20 - w) / 2).w(w).h(w)
    .rounded(6).border_1().border_color(ring).bg(p?.program?.tile ?? t.raised);
  return div().relative().flex_none().w(20).h(24)
    .when(others.length > 1, el => el.child(card(others[1], 12, 0)))
    .child(card(others[0], 15, 3))
    .child(div().absolute().top(5).left(1).rounded(7).border_1().border_color(ring).child(tile(t, front?.program, 18)));
}

function status(t, st, size) {
  if (st === "working") return svg("mods/workspace-chrome/spinner.svg").size(size).flex_none().text_color(t.working).spin(900);
  if (st === "blocked" || st === "done") return div().size(size / 2).flex_none().rounded(size / 4).bg(t[st]);
  return null;
}

// Shown on a tab while one of its panes is zoomed.
function zoomBadge(t, size) {
  return svg("mods/minimal-pane/zoom.svg").size(size).flex_none().text_color(t.accent);
}

export default class Tabs extends View {
  init() {
    this.pressed = null;
    // Spaces folded with their chevron; remembered across restarts.
    try { this.folded = JSON.parse(localStorage.getItem("folded") ?? "{}"); } catch { this.folded = {}; }
  }

  fold(id, cx) {
    if (this.folded[id]) delete this.folded[id]; else this.folded[id] = true;
    try { localStorage.setItem("folded", JSON.stringify(this.folded)); } catch {}
    cx.notify();
  }

  render() {
    const t = theme();
    const all = panes();
    const stop = (_e, cx) => cx.stop_propagation();
    const iconButton = (id, icon, action) => div().id(id).size(26).flex_none().flex().items_center().justify_center().rounded(6)
      .text_color(t.dim).hover(s => s.bg(t.hover).text_color(t.foreground))
      .on_mouse_down("left", stop).on_click(action)
      .child(svg(icon).size(15));

    const row = (space, c, i) => {
      const mine = all.filter(p => p.tab === c.id);
      const p = lead(mine);
      const current = space.active && c.active;
      const ring = current ? t.raised : t.chrome;
      return h_flex().id(`tab-${c.id}`).w_full().h(30).px(7).gap(8).rounded(8).items_center().flex_none().text_size(13)
        .border_1().border_color(current ? t.border : t.chrome)
        .bg(ring).text_color(current ? t.foreground : t.muted)
        .hover(s => s.bg(current ? t.raised : t.hover))
        .on_mouse_down("left", (e, cx) => {
          cx.stop_propagation();
          this.pressed = { space: space.id, i };
          if (e.click_count === 2) run("tab.rename", { id: c.id });
        })
        .on_mouse_up("left", () => {
          const from = this.pressed; this.pressed = null;
          if (from && from.space === space.id && from.i !== i) run("tab.move", { id: space.tabs[from.i].id, index: i + 1 });
          else { if (!space.active) run("space.select", { id: space.id }); run("tab.select", { id: c.id }); }
        })
        .on_mouse_down("right", (_e, cx) => { cx.stop_propagation(); openOverlay({ mod: "menu", kind: "popup", width: 200, props: { tab: "tab", target: { id: c.id, space: space.id } } }); })
        .child(icon(t, mine, p, ring))
        .child(div().flex_1().min_w(0).truncate().child(label(c, p)))
        .when(c.zoomed, el => el.child(zoomBadge(t, 13)))
        .when(Boolean(status(t, c.status, 12)), el => el.child(status(t, c.status, 12)));
    };

    // Space header, Rex style: name, then (+) for a new tab in this space and
    // a chevron that folds its tabs away. Folded, it shows the space's status.
    const small = (id, child, action) => div().id(id).size(18).flex_none().flex().items_center().justify_center().rounded(5)
      .text_color(t.dim).hover(s => s.bg(t.hover).text_color(t.foreground))
      .on_mouse_down("left", stop)
      .on_click((_e, cx) => { cx.stop_propagation(); action(cx); })
      .child(child);
    const group = space => {
      const folded = Boolean(this.folded[space.id]);
      return v_flex().w_full().gap(1)
        .child(h_flex().id(`space-${space.id}`).w_full().pl(9).pr(3).pt(6).pb(1).gap(2).items_center()
          .on_mouse_down("left", stop)
          .on_click(() => run("space.select", { id: space.id }))
          .on_mouse_down("right", (_e, cx) => { cx.stop_propagation(); openOverlay({ mod: "menu", kind: "popup", width: 200, height: 260, props: { tab: "space", target: { id: space.id } } }); })
          .child(div().flex_1().min_w(0).truncate().text_size(11.5).font_semibold()
            .text_color(space.active ? t.muted : t.dim).child(space.name))
          .when(folded && Boolean(status(t, space.status, 10)), el => el.child(div().px(4).child(status(t, space.status, 10))))
          .child(small(`space-new-${space.id}`,
            div().size(13).rounded(7).border_1().border_color(t.dim).flex().items_center().justify_center().child(svg("mods/workspace-chrome/plus.svg").size(9)),
            () => run("tab.new", { space: space.id })))
          .child(small(`space-fold-${space.id}`,
            svg(`mods/workspace-chrome/${folded ? "chevron-right" : "chevron-down"}.svg`).size(12),
            cx => this.fold(space.id, cx))))
        .when(!folded, el => el.children(space.tabs.map((c, i) => row(space, c, i))));
    };

    return v_flex().size_full().min_w(0).bg(t.chrome)
      .on_mouse_up("left", () => { this.pressed = null; })
      // Header: room for the macOS window buttons, then sidebar toggle and new tab.
      .child(h_flex().w_full().h(46).flex_none().pl(80).pr(8).gap(2).items_center()
        .child(iconButton("sidebar-toggle", "mods/workspace-chrome/sidebar.svg", () => run("minimal-strip.toggle")))
        .child(div().flex_1())
        .child(iconButton("tab-new", "mods/workspace-chrome/plus.svg", () => openOverlay({ mod: "new-menu", kind: "popup", width: 250, height: 512 }))))
      .child(v_flex().id("tab-scroll").flex_1().min_h(0).w_full().px(8).pb(8).gap(2).overflow_y_scrollbar().children(spaces().map(group)));
  }
}
