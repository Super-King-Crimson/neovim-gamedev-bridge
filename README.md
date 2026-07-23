# Step-by-step Neovide/Neovim setup with Unity and Godot
- I spent a couple days trying to figure this stuff out, and I think I stumbled upon a pretty decent solution
- All other solutions I found were okay, but kinda finicky, and required you to download a unity package or something
- Anyways yeah I think this is probably the easiest setup for unity and godot yet! No more struggling with this stuff

## Note!
- I have not set up DAP, so I don't know if this setup is debugger friendly
- When I start getting into debugging I'll come update this and fix it

## Installation
- If you have the AppImage for nvim or you installed it with your system package manager, uninstall it
- Here's a fast way to do it that sets up everything for you
```bash
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
sudo rm -rf /opt/nvim-linux-x86_64
sudo mkdir -p /opt/nvim-linux-x86_64
sudo chmod a+rX /opt/nvim-linux-x86_64
sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz

sudo ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/
```
- Now go get neovide in the same way, again getting the latest release
```bash
curl -LO https://github.com/neovide/neovide/releases/download/0.15.2/neovide-linux-x86_64.tar.gz
sudo rm -rf /opt/neovide-linux-x86_64
sudo mkdir -p /opt/neovide-linux-x86_64
sudo chmod a+rX /opt/neovide-linux-x86_64
sudo tar -C /opt -xzf neovide-linux-x86_64.tar.gz

sudo ln -sf /opt/neovide /usr/local/bin/
```

- Now you gotta go get Unity and Godot 
- ([one ](https://godotengine.org/download) of these is easier than the other to install...)
    - if you're on debian or its derivatives go [here](https://docs.unity3d.com/hub/manual/InstallHub.html#install-hub-linux) to download
    - Everyone else good luck lmao

### Aside
- By the way, if you're just getting into Neovide you'll realize that the `.desktop` file provided by default does NOT load your `.bashrc` (aliases, etc)
    - If you care about this, I've included a handy little wrapper script that just runs bash in interactive mode then runs neovide
    - Simply download my `/desktop` folder, make `neovide-wrapper.sh` executable, then put it anywhere
    - Go into `Neovide.desktop` and change the `Exec` field to where you put it
    - Then put `Neovide.desktop` in `.local/share/applications` and `neovide.svg` anywhere in `.local/share/icons`
        - i just put it in the top level like a neanderthal

## LSP

### Unity/Godot with C#
- Go grab [roslyn.nvim](https://github.com/seblyng/roslyn.nvim) with this config
    - **Follow the guide to install the Roslyn (C#) LSP, then come back**
    - We're also gonna grab [roslyn-filewatch.nvim](https://github.com/khoido2003/roslyn-filewatch.nvim) just because my god it has so many features
- You could absolutely configure the brains off these two plugins, but these are the settings that work for me
```lua
{
    "seblyng/roslyn.nvim",
    dependencies = {
        { "khoido2003/roslyn-filewatch.nvim", opts = {} },
    },
    config = function()
        require("roslyn_filewatch").setup({
            preset = "unity",
        })

        require("roslyn").setup({
            lock_target = true,
            filewatching = "off",
            choose_target = function(targets)
                if #targets == 1 then
                    return targets[1]
                end
            end,
        })
    end,
  }
```
## Godot with GDScript
- Make sure you don't have the steam version it DOES NOT WORK for this guide
- Godot lsp is kinda weird because the engine is the lsp
- Meaning you don't really have to do anything but configure it
- If you have nvim-lspconfig just run `vim.lsp.enable("gdscript")` literally anywhere and you're good
- If you don't, then put this in `nvim/after/ftplugin/gdscript.lua`
```lua
local port = os.getenv("GDScript_Port") or "6005"
local cmd = vim.lsp.rpc.connect("127.0.0.1", tonumber(port))

---@type vim.lsp.Config
vim.lsp.config("godot", {
  name = "Godot",
  cmd = cmd,
  filetypes = { "gd", "gdscript", "gdscript3" },
  root_markers = { "project.godot", ".git" },
})

vim.lsp.enable("godot")
```

## Setup
- Ok now download my linker scripts (in `/linker`)
    - Make sure everything in there is executable
    - Put them somewhere easy to access bc you will have to navigate to this file a lot
    - Now open `/linker/code` and *if you're \*NOT\* using neovide*, open the file and follow the instructions
- Now open either a Unity or Godot project
    - In Unity, go to Edit > Preferences > External Tools > External Script Editor
        - Browse to where you put `/linker/code`
        - Click `Regenerate project files`
        - You will have to do this everytime you open Unity, to get around this make a symlink at `/usr/local/bin/code` that points to this path
    - In Godot, go to Editor > Editor Settings > Text Editor > External
        - Again, Browse to `/linker/code`
        - Tick `Use External Editor`
- Happy game developing!
