#!/usr/bin/env python3.7

import iterm2
import sys

WORK_DIR = "~/Developer/mono"

async def main(connection):
    app = await iterm2.async_get_app(connection)
    for window in app.terminal_windows:
        for tab in window.tabs:
            if sys.argv[1] == "gm":
                await tab.sessions[0].async_split_pane()
                await tab.sessions[1].async_split_pane(vertical = True)
                for session in tab.sessions:
                    await session.async_send_text('cd {}\n'.format(WORK_DIR))
                await tab.sessions[0].async_activate()
            if sys.argv[1] == "gn":
                for idx, session in enumerate(tab.sessions):
                    if idx > 0:
                        await session.async_close(True)
                    else:
                        await session.async_send_text('\x03')

iterm2.run_until_complete(main)
