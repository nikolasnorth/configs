import { View, div } from "gpui-kit";
import { theme, layout, run, nextCommand, spaces } from "herdr";

// Drag strip above the panes in the `minimal` layout. It's 0px tall while the
// tab sidebar shows and STRIP_PX while it's hidden, so the macOS window buttons
// never cover a pane. It's never hidden, so it always receives cmd-b's
// "toggle" and can flip the sidebar and its own height in the same tick.
const STRIP_PX = 34;

function find(node, id) {
  if (node?.id === id) return node;
  for (const child of node?.children ?? []) {
    const found = find(child, id);
    if (found) return found;
  }
  return null;
}

export default class Strip extends View {
  init(_props, cx) {
    cx.spawn(async () => {
      for (;;) {
        const c = await nextCommand();
        if (c === "toggle") this.toggle();
        else if (c === "next") this.step(1);
        else if (c === "prev") this.step(-1);
      }
    });
    // Catches sidebar toggles from elsewhere (palette, other commands).
    cx.timer.every(250, () => this.sync());
    this.sync();
  }

  toggle() {
    const tabs = find(layout(), "tabs");
    if (!tabs) return;
    const hide = !tabs.hidden;
    run("layout.resize", { id: "strip", px: hide ? STRIP_PX : 0 });
    run(hide ? "layout.hide" : "layout.show", { id: "tabs" });
  }

  // cmd-shift-] / [: next or previous tab, running on into the next or
  // previous space after its last or first tab, wrapping at the ends.
  step(dir) {
    const all = spaces().flatMap(sp => sp.tabs.map(tab => ({ sp, tab })));
    if (all.length < 2) return;
    const at = all.findIndex(x => x.sp.active && x.tab.active);
    const to = all[((at < 0 ? 0 : at) + dir + all.length) % all.length];
    if (!to.sp.active) run("space.select", { id: to.sp.id });
    run("tab.select", { id: to.tab.id });
  }

  sync() {
    const root = layout(), tabs = find(root, "tabs"), strip = find(root, "strip");
    if (!tabs || !strip) return;
    const want = tabs.hidden ? STRIP_PX : 0;
    if (strip.size?.px !== want) run("layout.resize", { id: "strip", px: want });
  }

  render() {
    return div().size_full().bg(theme().canvas);
  }
}
