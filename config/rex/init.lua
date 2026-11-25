rex.action {
  name = "review_branch",
  title = "Review Branch in tuicr",
  run = function(ctx)
    assert(ctx.block_id, "Select a terminal pane first")
    local location, err = rex.block.call("com.superlogical.terminal", "pwd", {})
    assert(location, err)
    local cwd = location.pwd
    -- OSC 7 reporting is optional; Rex can also inspect the running process.
    if not cwd or cwd == "" then
      local process, process_err = rex.block.call("com.superlogical.terminal", "process", {})
      assert(process, process_err)
      cwd = process.foreground and process.foreground.cwd
      if not cwd or cwd == "" then
        cwd = process.child and process.child.cwd
      end
    end
    assert(cwd and cwd ~= "", "Cannot determine the terminal's working directory")
    if cwd:match("^file://") then
      cwd = assert(cwd:match("^file://[^/]*(/.*)"), "Invalid terminal directory URL")
      cwd = cwd:gsub("%%(%x%x)", function(hex) return string.char(tonumber(hex, 16)) end)
    end
    assert(cwd:sub(1, 1) == "/", "Terminal directory must be an absolute path")
    local result, split_err = rex.session.new_split {
      session_id = ctx.session_id,
      anchor_id = ctx.block_id,
      direction = "horizontal",
      side = "after",
      focus = true,
      layout = {
        block = {
          flavor = "com.superlogical.terminal.shell",
          label = "Review",
          options = {
            cwd = cwd,
            command = { "bash", os.getenv("HOME") .. "/.config/review/branch.sh" },
          },
        },
      },
    }
    assert(result, split_err)
    return result
  end,
}
rex.bind("ctrl+f>r", "review_branch")
rex.bind("ctrl+f>shift+\\", "pane.split", { direction = "right" })
rex.bind("ctrl+f>-", "pane.split", { direction = "down" })
rex.bind("ctrl+f>,", "client.tab.rename")
rex.bind("ctrl+h", "pane.focus", { direction = "left" })
rex.bind("ctrl+j", "pane.focus", { direction = "down" })
rex.bind("ctrl+k", "pane.focus", { direction = "up" })
rex.bind("ctrl+l", "pane.focus", { direction = "right" })
rex.bind("ctrl+f>h", "pane.focus", { direction = "left" })
rex.bind("ctrl+f>j", "pane.focus", { direction = "down" })
rex.bind("ctrl+f>k", "pane.focus", { direction = "up" })
rex.bind("ctrl+f>l", "pane.focus", { direction = "right" })
rex.bind("ctrl+f>v", "pane.split", { direction = "right" })
rex.bind("ctrl+alt+shift+left", "pane.resize", { direction = "left" })
rex.bind("ctrl+alt+shift+down", "pane.resize", { direction = "down" })
rex.bind("ctrl+alt+shift+up", "pane.resize", { direction = "up" })
rex.bind("ctrl+alt+shift+right", "pane.resize", { direction = "right" })
rex.bind("ctrl+f>ctrl+f", "pane.send_key", { key = "ctrl+f" })
