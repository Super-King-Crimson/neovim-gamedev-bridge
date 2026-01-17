local function log(msg)
  vim.schedule(function()
    vim.notify(msg, vim.log.levels.INFO, { title = "Roslyn root initialized" })
  end)
end

-- first index of this is the first prj file we found
local sln_match = vim.fs.find(function(name)
  return string.match(name, "%.sln.*$")
end, {
  upward = true,
  stop = vim.uv.os_homedir(),
  path = vim.fs.dirname(vim.api.nvim_buf_get_name(0)),
})[1]

if sln_match then
  local project_root = vim.fn.fnamemodify(sln_match, ":p:h")

  if vim.g.last_detected_godot_root ~= project_root then
    log("Project detected at " .. project_root)

    vim.api.nvim_set_current_dir(project_root)
    vim.g.last_detected_godot_root = project_root

    vim.schedule(function()
      vim.cmd("Roslyn target")
    end)

    log("Switched to new project.")
  end
end
