#!/usr/bin/python3
import urwid
import urwid_readline
from shanepy import *

def unhandled_input(txt, key):
    if key in ("ctrl q", "ctrl Q"):
        raise urwid.ExitMainLoop()
    txt.set_edit_text("unknown key: " + repr(key))
    txt.set_edit_pos(len(txt.edit_text))

def handle_change(a_txt, user_data):
    bash("cat >> /tmp/events.txt ", a_txt.text)

def main():
    txt = urwid_readline.ReadlineEdit(multiline=True)
    fill = urwid.Filler(txt, "top")
    #bash("ns " + txt.text)

    urwid.connect_signal(txt, 'change', handle_change)

    loop = urwid.MainLoop(
        fill #, unhandled_input=lambda key: unhandled_input(txt, key)
    )
    loop.run()

if __name__ == "__main__":
    main()