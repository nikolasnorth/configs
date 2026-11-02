// Comment on a terminal selection (ChatGPT-style "reply to highlight").
// Opened by the comment-menu mod with props { quote, terminal, overlay }.
// Shows the quote, takes a comment, adds "> quote\n\ncomment" to the terminal's input (not sent).
// Enter adds, Shift+Enter is a newline, Esc cancels. An empty comment adds just the quote.
import { View, div } from "gpui-kit";
import { v_flex, h_flex, TextareaState, Textarea } from "gpui-base";
import { props, closeOverlay, theme, notify, settings, exec, run } from "herdr";

// Terminal text → markdown quote: drop trailing spaces and the shared indent.
function quoteBlock(text) {
  const lines = text.replace(/\s+$/, "").split("\n").map((l) => l.replace(/\s+$/, ""));
  while (lines.length && !lines[0]) lines.shift();
  const indent = Math.min(...lines.filter((l) => l).map((l) => l.match(/^ */)[0].length));
  return lines.map((l) => l.slice(indent)).map((l) => (l ? `> ${l}` : ">")).join("\n");
}

export default class Comment extends View {
  init(_props, cx) {
    this.sending = false;
    this.focused = true;
    this.ta = TextareaState.new({ placeholder: "Comment…", rows: 3 });
    this.ta.set_auto_grow(3, 10);
    this.ta.on("submit", (e, cx) => {
      // Shift+Enter: keep the newline. Enter / Cmd+Enter: add.
      if (!e?.shift) this.send(cx);
    });
    this.ta.on("focus", (_e, cx) => { this.focused = true; cx.notify(); });
    this.ta.on("blur", (_e, cx) => { this.focused = false; cx.notify(); });
    this.ta.focus();
    cx.timer.after(400, () => this.ta.focus());
    this.handle = cx.focus_handle();
  }

  // Adds "> quote\n\ncomment" to the program's input without submitting, so several comments
  // can pile up before sending. hc can only paste-and-Enter, so this borrows the clipboard:
  // copy the text, terminal.paste into the clicked terminal, put the old clipboard back.
  send(cx) {
    const p = props() ?? {};
    if (this.sending) return;
    this.sending = true;
    cx.notify();
    const comment = this.ta.value().trim();
    const text = `${quoteBlock(p.quote ?? "")}\n\n${comment ? `${comment}\n\n` : ""}`;
    cx.spawn(async () => {
      try {
        const saved = (await exec("pbpaste")).stdout;
        await exec("sh", ["-c", 'printf %s "$1" | pbcopy', "sh", text]);
        run("pane.focus", { terminal: p.terminal });
        run("terminal.paste");
        // Restore in the background (it outlives this dialog); empty: the clipboard held an image.
        if (saved) exec("sh", ["-c", 'sleep 0.3; printf %s "$1" | pbcopy', "sh", saved]);
      } catch (e) {
        notify({ title: "Comment not added", body: String(e).slice(0, 240), level: "error" });
      }
      closeOverlay(p.overlay);
    });
  }

  render(cx) {
    const t = theme();
    const p = props() ?? {};
    const mono = settings().font_family ?? "JetBrains Mono";
    const button = (id, text, primary, action) =>
      h_flex().id(id).h(30).px(13).items_center().rounded(8)
        .border_1().border_color(primary ? t.solid : t.input).bg(primary ? t.solid : t.raised)
        .text_color(primary ? t.solid_foreground : t.foreground).text_size(12.5).font_medium().cursor_pointer()
        .hover((s) => s.opacity(0.88)).on_click(action).child(text);
    return v_flex()
      .id("comment")
      .track_focus(this.handle)
      .on_key_down((e, cx) => {
        if (e.key === "escape") { closeOverlay(p.overlay); cx.stop_propagation(); }
      })
      .w_full().min_h(0).p(16).gap(12).bg(t.popover).text_color(t.foreground)
      .child(h_flex().items_center()
        .child(div().flex_1().text_size(14).font_semibold().child("Comment on selection"))
        .child(div().text_size(11).text_color(t.dim).child("Esc")))
      .child(div().id("comment-quote").max_h(150).overflow_y_scroll()
        .border_l_2().border_color(t.border).pl(10).py(2)
        .font_family(mono).text_size(11.5).text_color(t.muted)
        .child(quoteBlock(p.quote ?? "").replace(/^> ?/gm, "")))
      .child(Textarea.new(this.ta).px(10).py(8).rounded(9).border_1()
        .border_color(this.focused ? t.accent : t.input).bg(t.background).text_size(12.8).text_color(t.foreground))
      .child(h_flex().gap(8).items_center()
        .child(div().flex_1().text_size(11).text_color(t.dim).child("Enter add to message · Shift+Enter newline"))
        .child(button("cm-cancel", "Cancel", false, () => closeOverlay(p.overlay)))
        .child(button("cm-send", this.sending ? "Adding…" : "Add", true, (_e, cx) => this.send(cx))));
  }
}
