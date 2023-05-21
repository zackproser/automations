# Under construction

These docs will be expanded and updated soon!

## Integrating autogit/autogit.sh with your shell 

# Override your builtin cd command 

This is currently saved to my `~/.zshrc` file. It works by overriding your built in change directory command, still calling 

This function assumes you have copied `autogit.sh` to `~/bin/autogit.sh`. If you have installed it elsewhere on your system, be sure to update the path in this function.

Note this also assumes you have installed github.com/charmbracelet/gum. Be sure to run `zsh` in a new terminal or shell after updating your ~/.zshrc file for your changes to take effect.

```
function cd() {
  builtin cd "$@" && gum spin --title "Autogit updating git repo if necessary..." --show-output ~/bin/autogit.sh
}
```
## Integrating autocommitmessage with your shell

# Create a new shell function named whatever you like 

I picked `gcai`, because my git commit alias is already `gc` - so `gcai` stands for `git commit A.I.`

```
function gcai() {
  autocommitmessage 
}
```
