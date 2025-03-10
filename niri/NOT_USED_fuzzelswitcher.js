#! /usr/bin/env node

const fuzzel = process.argv[2] || "fuzzel"

const { spawnSync } = require("node:child_process")

const niri_workspaces = JSON.parse(
  spawnSync("niri", ["msg", "--json", "workspaces"]).stdout.toString()
)
let niri_windows = JSON.parse(
  spawnSync("niri", ["msg", "--json", "windows"]).stdout.toString()
)

let workspaces = []
for (let ws of niri_workspaces) {
  workspaces[ws.id] = ws
}

niri_windows = niri_windows.map(window => {
  window.workspace = workspaces[window.workspace_id]
  if (window.workspace.name == null) {
    window.workspace.name = window.workspace.output + "#" + window.workspace.idx
  }
  return window
})

niri_windows.sort((a, b) => {
  // Sort by output first
  if (a.workspace.output < b.workspace.output) {
    return -1
  }
  if (a.workspace.output > b.workspace.output) {
    return 1
  }

  // Workspace ID second
  ws_sort = a.workspace_id - b.workspace_id
  if (ws_sort != 0) {
    return ws_sort
  }

  // and then by window id
  return a.id - b.id
})

const longest_workspace_name =
      workspaces.reduce((acc, val) => {
        if (val.name && val.name.length > acc.length) {
          return val.name
        }
        return acc
      }, "", workspaces)

const fuzzel_input = niri_windows.map(window => {
  const ws = "[" + window.workspace.name + "]"
  return ws.padEnd(longest_workspace_name.length + 2) + " "
    + window.title
    + " \x00icon\x1f" + window.app_id
}).join("\n")

const chosen_window_id =
      spawnSync(fuzzel,
                [
                  "--counter", "--dmenu", "--index",
                  "--font", "Monaspace Neon:size=16.25",
                  "--width", 100,
                  "--lines", 30,
                  "--match-mode", "fuzzy",
                  "--prompt", "window> ",
                ],
                { input: fuzzel_input }).stdout.toString()

if (chosen_window_id != "") {
  const wid = parseInt(chosen_window_id)
  spawnSync("niri", ["msg", "action", "focus-window", "--id", niri_windows[wid].id])
}