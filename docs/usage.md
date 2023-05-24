
## Installation & Usage

### Prerequisites

Please ensure you have the following installed. The scripts will ensure they are installed and error out with a helpful message about where to find them if they are not.

* [mods](https://github.com/charmbracelet/mods)
* [glow](https://github.com/charmbracelet/glow) 
* [gum](https://github.com/charmbracelet/gum) 

## Installation 

Generally speaking, `automations` are all shell scripts, so you can run them however you like. 

I tend to copy them from their source folders to `~/bin/<script-name>` and then run `chmod +x ~/bin/<script-name>` to make them executable.

You could then choose to further `alias` them like so:

```
alias gcai="~/bin/autocommitmessage.sh"
alias review="~/bin/autoreview.sh"
alias autopr="~/bin/autopullrequest.sh"
```
The exact way you pull this off and where you write your aliases will differ slightly depending on your shell. I'll include shell-specific installation guides shortly.

## Script-specific integrations

### Integrating autogit/autogit.sh with your shell 

**Override your builtin cd command**

This is currently saved to my `~/.zshrc` file. It works by overriding your built in change directory command, still calling 

This function assumes you have copied `autogit.sh` to `~/bin/autogit.sh`. If you have installed it elsewhere on your system, be sure to update the path in this function.

Note this also assumes you have installed github.com/charmbracelet/gum. Be sure to run `zsh` in a new terminal or shell after updating your ~/.zshrc file for your changes to take effect.

```
function cd() {
  builtin cd "$@" && gum spin --title "Autogit updating git repo if necessary..." --show-output ~/bin/autogit.sh
}
```
### Integrating autocommitmessage with your shell

**Create a new shell function named whatever you like**

I picked `gcai`, because my git commit alias is already `gc` - so `gcai` stands for `git commit A.I.`

```
function gcai() {
  # This assumes you've already got an alias for the autocommitmessage script and have the script installed and made executable
  autocommitmessage 
}
```
