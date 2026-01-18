# Step-by-step for Neovide setup with Unity and Godot
- I know this has gotta be the most niche thing ever, but I really like Neovim (and by extension neovide)
- I just wanna make getting Neovim integrated into your workflow as painless as possible
- so you can get back to what really matters, messing with your dotfiles lmao

## Godot/Unity setup with Neovide
- Obviously you need neovim before neovide, so go grab that
- Here's a cool way to do it
```bash
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
sudo rm -rf /opt/nvim-linux-x86_64
sudo mkdir -p /opt/nvim-linux-x86_64
sudo chmod a+rX /opt/nvim-linux-x86_64
sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz

sudo ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/
```
- Now go get neovide in the same way
- Make sure to add $HOME/.local/bin to your path if its not there already
```bash
curl -LO https://github.com/neovide/neovide/releases/download/0.15.2/neovide-linux-x86_64.tar.gz
rm -rf $HOME/.local/bin/neovide-linux-x86_64
mkdir -p $HOME/.local/bin/neovide-linux-x86_64
chmod a+rX $HOME/.local/bin/neovide-linux-x86_64
tar -C $HOME/.local/bin -xzf neovide-linux-x86_64.tar.gz
```
- Now you gotta go get Unity and Godot 
- ([one ](https://godotengine.org/download) of these is easier than the other to install...)
    - if you're on debian like me just do this
    - then just pick a unity version
```bash
sudo install -d /etc/apt/keyrings
curl -fsSL https://hub.unity3d.com/linux/keys/public | sudo gpg --dearmor -o /etc/apt/keyrings/unityhub.gpg
echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/unityhub.gpg] https://hub.unity3d.com/linux/repos/deb stable main" | sudo tee /etc/apt/sources.list.d/unityhub.list

sudo apt update
sudo apt install unityhub
```
- Ok now download my magic linker scripts
- Download both bridge.sh files and put them somewhere cool
    - I put them in `$HOME/Binaries`
    - *(I also recommend downloading `neovide-wrapper.sh` and making `Neovide.desktop` point to it)*
        - It loads your .bashrc (if you don't use bash sorry lmao it prob isn't hard to tinker it)
- Ok time for the hard part actually configuring the details

### Unity:
- Ok first we gotta setup LSP which is actually really easy
    - Go grab [roslyn.nvim](https://github.com/seblyng/roslyn.nvim) with this config
    - **Make sure to follow the instructions to download Roslyn using Mason!**
```lua
{
  "seblyng/roslyn.nvim",
  config = function()
    require("roslyn").setup({})
    vim.lsp.config("roslyn", {})
    vim.lsp.enable("roslyn")
  end,
}
```
- Now we have our lsp, and you could just be good with this
- However sometimes when opening files your lsp won't detect Unity types so let's configure
    - copy from my github the `cs.lua` file and put it in `nvim/after/ftplugin`
- Now open any Unity project
- Go to Edit > Preferences > External Tools
    - Oh by the way you do need to download some other editor so you can build the project files
    - That's so easy though just download VSCode and it'll probably automatically be detected
- Click Regenerate Project Files so Roslyn gets all the Unity classes
- Click External Script Editor > Browse to where you put `neovide-unity-bridge.sh`
- Change the arguments
```bash
# Configs:
/path/to/this/neovide-unity-bridge.sh
$(File) $(Line)
```
- You can now click on any Unity file to go to it in neovide! 
- if your autocomplete isn't working just run `:Roslyn target` and switch solution files until it does

### Godot:
- Make sure you don't have the steam version it DOES NOT WORK
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

- Now open any godot project, go to Editor > Editor Settings > Text Editor > External
- Tick Use External Editor
- Once again, change the arguments
```bash
# Configs:
/path/to/file/neovide-godot-bridge.sh
{file} {line} {col}
```
- And once again, you're good, click a file and it opens in your editor
- Happy game developing!
