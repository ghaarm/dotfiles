# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# If you come from bash you might have to change your $PATH.
# export PATH="/Volumes/Macintosh HD/Applications/MikTex Console.app/Contents/bin:$PATH" ### Konfiguration für MikTex mittlerweile gelöscht
# export PATH="/usr/local/texlive/2023/bin/x86_64-darwin:$PATH" ### Konfiguration für Tex Live

# Alias für pdflatex auf miktex-pdftex setzen
# alias pdflatex="/Volumes/Macintosh\ HD/Applications/MikTex Console.app/Contents/bin/miktex-pdftex"### Konfiguration für MikTex mittlerweile gelöscht

# Texinput für die sty dateien
# export TEXINPUTS="/Users/g/Library/Application Support/MiKTeX/texmfs/install/tex//:" ### Konfiguration für MikTex mittlerweile gelöscht
# export TEXINPUTS="/usr/local/texlive/2023/texmf-dist/tex/latex//:"  ### Konfiguration für Tex Live

# aus vimimtex :help vimtex-faq-zathura-macos
export DBUS_SESSION_BUS_ADDRESS="unix:path=$DBUS_LAUNCHD_SESSION_BUS_SOCKET"

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true" 

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git zsh-autosuggestions zsh-syntax-highlighting web-search)

# Kitty-Completion aus fpath entfernen
fpath=(${fpath:#/Applications/kitty.app/Contents/Resources/kitty/shell-integration/zsh/completions})

# Zsh Completion initialisieren
source $ZSH/oh-my-zsh.sh
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
source /opt/homebrew/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh
bindkey '^M' accept-line # damit zsh autocomplete enter nicht blockiert
# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.


export PATH="/path/to/lua-language-server/bin:$PATH"
# textbausteine für Ordner
# alias pr="cd ~/Library/Mobile\ Documents/com~apple~CloudDocs/'#Docs iCloud'/R\ Statistik,\ icloud/R,\ projects"
# alias cd="/Users/g/qmk_firmware/keyboards/beekeeb/piantor_pro/keymaps"


# cd configuration

alias cdconf="cd ~/dotfiles && nvim"

alias cdzsh="cd ~/dotfiles/home && nvim .zshrc"

alias cdnvim="cd ~/dotfiles/config/nvim && nvim"

alias cdtemp="cd ~/dotfiles/config/nvim/templates && nvim"

alias cdaero="cd ~/dotfiles/config/aerospace && nvim aerospace.toml"

alias cdplug="cd ~/dotfiles/config/nvim/lua/plugins && nvim"

alias cdcore="cd ~/dotfiles/config/nvim/lua/core && nvim keybindings.lua"

alias cdfunc="cd ~/dotfiles/config/nvim/lua/core/functions && nvim"

alias cdqmk="builtin cd /Users/g/Library/Mobile\ Documents/com~apple~CloudDocs/'!Docs iCloud'/qmk-icloud && nvim" # öffnet neovim automatisch 

alias cdpianmac="builtin cd /Users/g/Library/Mobile\ Documents/com~apple~CloudDocs/'!Docs iCloud'/qmk-icloud/piantor_colemak && nvim keymap.c" # öffnet neovim automatisch 

alias cdpianwin="builtin cd /Users/g/Library/Mobile\ Documents/com~apple~CloudDocs/'!Docs iCloud'/qmk-icloud/piantor_win && nvim keymap.c" # öffnet neovim automatisch 

alias cdpianlinux="builtin cd /Users/g/Library/Mobile\ Documents/com~apple~CloudDocs/'!Docs iCloud'/qmk-icloud/piantor_linux && nvim keymap.c" # öffnet neovim automatisch 

alias cdpianpro="/Users/g/Library/Mobile\ Documents/com~apple~CloudDocs/'!Docs iCloud'/GitHub,\ iCloud/piantor-bt-colemak/config && nvim piantor_pro_bt.keymap"

alias cdpianbt="/Users/g/Library/Mobile\ Documents/com~apple~CloudDocs/'!Docs iCloud'/GitHub,\ iCloud/piantor-bt-colemak && nvim config/piantor_pro_bt.keymap"

### DRACOON
cddracoon() {
  builtin cd "$HOME/Library/Application Support/DRACOON/Volumes.noindex/DRACOON.localized"
}

# cd iCloud

alias cdic="cd ~/Library/Mobile\ Documents/com~apple~CloudDocs/'!Docs iCloud'" 

alias cddocs="cd ~/Library/Mobile\ Documents/com~apple~CloudDocs/'!Docs iCloud'" 

alias cdedit="cd ~/Library/Mobile\ Documents/com~apple~CloudDocs/'!Docs iCloud'/Vorlagen && nvim vorlage-edit-nvim.md" 

alias cdtodo="cd ~/Library/Mobile\ Documents/com~apple~CloudDocs/'!Docs iCloud'/todo-icloud && nvim" 

alias cdwork="cd ~/Library/Mobile\ Documents/com~apple~CloudDocs/'!Docs iCloud'/work-gpt-icloud && nvim"

alias cdwork-proj="cd ~/Library/Mobile\ Documents/com~apple~CloudDocs/'!Docs iCloud'/work-gpt-icloud/projects-work-gpt && nvim"


alias cdobsidian='builtin cd "/Users/g/Library/Mobile Documents/iCloud~md~obsidian/Documents/obsidian-icloud" && nvim'

cd10o2root() {
  builtin cd '/Users/g/Library/Mobile Documents/com~apple~CloudDocs/!Docs iCloud/10o2-icloud' && nvim
}

cd10o2proj() {
  builtin cd '/Users/g/Library/Mobile Documents/com~apple~CloudDocs/!Docs iCloud/10o2-icloud/10o2-project-list' && nvim
}
#
cdcodexproj() {
  builtin cd '/Users/g/Library/Mobile Documents/com~apple~CloudDocs/!Docs iCloud/codex-projects-icloud' && nvim
}

cdcodexprojlat() {
  builtin cd '/Users/g/Library/Mobile Documents/com~apple~CloudDocs/!Docs iCloud/codex-projects-icloud/codex-projects-latex/' && nvim
}
#
#
# alias cd10o2proj='builtin cd "/Users/g/Library/Mobile Documents/iCloud~md~obsidian/Documents/10o2-icloud/10o2-project-list" && nvim'

alias cdlinux="cd ~/Library/Mobile\ Documents/com~apple~CloudDocs/'!Docs iCloud'/linux && nvim" 

alias cdphd="cd ~/Library/Mobile\ Documents/com~apple~CloudDocs/'!Docs iCloud'/phd-pmu && nvim" 

alias cdscan="cd ~/Library/Mobile\ Documents/com~apple~CloudDocs/@Tabea\ \&\ Golo\ iCloud/@Scans && y" 

alias cdsteuer="cd ~/Library/Mobile\ Documents/com~apple~CloudDocs/@Tabea\ \&\ Golo\ iCloud/steuer-icloud && nvim" 

alias cddown="/Users/g/Library/Mobile\ Documents/com~apple~CloudDocs/\#Downloads\ iCloud && yazi"

alias cdgit="/Users/g/Library/Mobile\ Documents/com~apple~CloudDocs/'!Docs iCloud'/GitHub,\ iCloud"

alias cdessen="cd ~/Library/Mobile\ Documents/com~apple~CloudDocs/@Tabea\ \&\ Golo\ iCloud/Rezepte\ Essen\ Golo" 

# cd für js
alias cdjs="cd ~/Library/Mobile\ Documents/com~apple~CloudDocs/'!Docs iCloud'/R\ Statistik,\ icloud/js-projects/textbausteine-js && nvim" 

alias cdjsshiny="cd ~/Library/Mobile\ Documents/com~apple~CloudDocs/'!Docs iCloud'/R\ Statistik,\ icloud/js-shiny-project && nvim" 

alias cdshinyonecom="cd ~/Library/Mobile\ Documents/com~apple~CloudDocs/'!Docs iCloud'/R\ Statistik,\ icloud/js-shiny-one-com && nvim" 


alias cdshinytextbausteine="cd ~/Library/Mobile\ Documents/com~apple~CloudDocs/'!Docs iCloud'/R\ Statistik,\ icloud/js-projects/textbausteine-js/shiny-textbausteine-html && nvim" 

alias cdjstextbausteine="cd ~/Library/Mobile\ Documents/com~apple~CloudDocs/'!Docs iCloud'/R\ Statistik,\ icloud/js-projects/textbausteine-js/shiny-textbausteine-html && nvim" 

# cd für r
alias bs="cd ~/Library/Mobile\ Documents/com~apple~CloudDocs/'!Docs iCloud'/R\ Statistik,\ icloud/R,\ projects/shiny-app/shiny-bslib && nvim" 

alias shinyjs="cd ~/Library/Mobile\ Documents/com~apple~CloudDocs/'!Docs iCloud'/R\ Statistik,\ icloud/R,\ projects/shiny-app/shiny-js && nvim" 

alias bscodex="cd ~/Library/Mobile\ Documents/com~apple~CloudDocs/'!Docs iCloud'/R\ Statistik,\ icloud/R,\ projects/shiny-app/shiny-bslib-codex && nvim" 

alias cdalpha="cd ~/Library/Mobile\ Documents/com~apple~CloudDocs/'!Docs iCloud'/R\ Statistik,\ icloud/R,\ projects/shiny-app/ShinyICUalpha && nvim server.r" 

alias cdpmustatistik="cd ~/Library/Mobile\ Documents/com~apple~CloudDocs/'!Docs iCloud'/Statistik/statistik-pmu && nvim" 

alias bsmod="cd ~/Library/Mobile\ Documents/com~apple~CloudDocs/'!Docs iCloud'/R\ Statistik,\ icloud/R,\ projects/shiny-app/shiny-bslib-mod && nvim" 

alias cdrpmu="cd ~/Library/Mobile\ Documents/com~apple~CloudDocs/'!Docs iCloud'/R\ Statistik,\ icloud/R,\ projects/r-statistik-pmu && nvim" 

alias cdrallgemein="cd ~/Library/Mobile\ Documents/com~apple~CloudDocs/'!Docs iCloud'/R\ Statistik,\ icloud/R,\ projects/r-allgemein && nvim" 

alias cddienstplan="cd ~/Library/Mobile\ Documents/com~apple~CloudDocs/'!Docs iCloud'/R\ Statistik,\ icloud/R,\ projects/r-dienstplan && nvim" 

alias cdr="cd ~/Library/Mobile\ Documents/com~apple~CloudDocs/'!Docs iCloud'/R\ Statistik,\ icloud/R,\ projects && nvim" 

alias cdrecmo="cd ~/Library/Mobile\ Documents/com~apple~CloudDocs/'!Docs iCloud'/R\ Statistik,\ icloud/R,\ projects/ECMO\ Diplom && nvim" 

alias cdrlukas="cd ~/Library/Mobile\ Documents/com~apple~CloudDocs/'!Docs iCloud'/Diplomarbeit\ 10\ II/Diplomarbeit\ Lukas\ Rücker/lukas-analysen-r && nvim" 

alias cdrluisa="cd ~/Library/Mobile\ Documents/com~apple~CloudDocs/'!Docs iCloud'/Diplomarbeit\ 10\ II/Diplomarbeit\ Luisa\ Holzheu/luisa-analysen-r && nvim" 

alias cdshinyzaboideen="cd ~/Library/Mobile\ Documents/com~apple~CloudDocs/'!Docs iCloud'/R\ Statistik,\ icloud/R,\ projects/shiny-app/ShinyZabo/shiny-zabo-ideen && nvim" 

alias cdshinyzabo="cd ~/Library/Mobile\ Documents/com~apple~CloudDocs/'!Docs iCloud'/R\ Statistik,\ icloud/R,\ projects/shiny-app/ShinyZabo && nvim" 


# cd für latex
alias cdlat="cd ~/Library/Mobile\ Documents/com~apple~CloudDocs/'!Docs iCloud'/R\ Statistik,\ icloud/Latex,\ icloud/Latex\ Projekte && nvim" 

alias cdicu="cd ~/Library/Mobile\ Documents/com~apple~CloudDocs/'!Docs iCloud'/R\ Statistik,\ icloud/Latex,\ icloud/Latex\ Projekte/icu-latex && nvim" 

alias cdicubook="cd ~/Library/Mobile\ Documents/com~apple~CloudDocs/'!Docs iCloud'/R\ Statistik,\ icloud/Latex,\ icloud/Latex\ Projekte/icu-latex/icu-book-latex && nvim" 

alias cdgmics="cd ~/Library/Mobile\ Documents/com~apple~CloudDocs/'!Docs iCloud'/R\ Statistik,\ icloud/Latex,\ icloud/Latex\ Projekte/icu-latex/gmics-latex && nvim" 

alias cdbeamer="cd ~/Library/Mobile\ Documents/com~apple~CloudDocs/'!Docs iCloud'/R\ Statistik,\ icloud/Latex,\ icloud/Latex\ Projekte/icu-latex/beamer-latex-icu && nvim" 


# Zaboracker
alias cdzabo="cd /Users/g/Library/Mobile\ Documents/com~apple~CloudDocs/'@Tabea & Golo iCloud'/'Naomi (直美)'/Zaboracker && nvim" 

alias cdzabo-r="cd ~/Library/Mobile\ Documents/com~apple~CloudDocs/'!Docs iCloud'/R\ Statistik,\ icloud/R,\ projects/zaboracker-r"


alias cdnext="cd /Users/g/Library/Mobile\ Documents/com~apple~CloudDocs/'@Tabea & Golo iCloud'/'Naomi (直美)'/Zaboracker/nextcloud-zaboracker && nvim" 

alias cdnextvorstand="cd /Users/g/Library/Mobile\ Documents/com~apple~CloudDocs/'@Tabea & Golo iCloud'/'Naomi (直美)'/Zaboracker/nextcloud-zaboracker/Vorstand && nvim" 

alias cdvorstand="cd /Users/g/Library/Mobile\ Documents/com~apple~CloudDocs/'@Tabea & Golo iCloud'/'Naomi (直美)'/Zaboracker/vorstand-zaboracker && nvim" 

alias cdvorstandlat="cd /Users/g/Library/Mobile\ Documents/com~apple~CloudDocs/'@Tabea & Golo iCloud'/'Naomi (直美)'/Zaboracker/vorstand-zaboracker/vorstand-latex && nvim" 

# privat
alias cdwomo="cd /Users/g/Library/Mobile Documents/com~apple~CloudDocs/@Tabea & Golo iCloud/Wohnmobil-icloud && nvim" 


# Arbeit 10 II

alias cdat="cd ~/Library/Mobile\ Documents/com~apple~CloudDocs/'!Docs iCloud'/atmungstherapie-knn && nvim" 
# alias projtemp="cd ~/.config/nvim/templates" 


# Example aliases
# alias zshconfig="mate ~/.zshrc" 
# alias ohmyzsh="mate ~/.oh-my-zsh" 

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh


# history setup
HISTFILE=$HOME/.zhistory
SAVEHIST=1000
HISTSIZE=999
setopt share_history
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_verify
# setopt hist_verifysource /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# completion using arrow keys (based on history)
# bindkey '^[[A' history-search-backward
# bindkey '^[[B' history-search-forward
# source /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh
# source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh


# Befehle
alias pianmac="qmk compile -kb beekeeb/piantor_pro -km piantor_colemak"

alias pianwin="qmk compile -kb beekeeb/piantor_pro -km piantor_win"


# ---- Eza (better ls) -----

# alias ls="eza --icons=always"

alias ls="eza --color=always --long --icons=always"

# ---- Zoxide (better cd) ----
eval "$(zoxide init zsh)"

alias cd="z"

# ---- fzf keybindings für fuzzy finder ----
eval "$(fzf --zsh)"

# -- Use fd instead of fzf --

export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"

# Use fd (https://github.com/sharkdp/fd) for listing path candidates.
# - The first argument to the function ($1) is the base path to start traversal
# - See the source code (completion.{bash,zsh}) for the details.
_fzf_compgen_path() {
  fd --hidden --exclude .git . "$1"
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
  fd --type=d --hidden --exclude .git . "$1"
}


# # Normales `cd` Verhalten ohne fzf
# alias cd="builtin cd"
#
# # Funktion für `cd` mit fzf-Unterstützung
# cdz() {
#   local dir
#   dir=$(fd --type d --hidden --exclude .git . | fzf)
#   if [[ -n "$dir" ]]; then
#     cd "$dir"
#   fi
# }


# für imagemagick um images in nvim anzeigen zu lassen https://github.com/3rd/image.nvim
export DYLD_LIBRARY_PATH="$(brew --prefix)/lib:$DYLD_LIBRARY_PATH"


# ---- TheFuck ----
# thefuck alias
# eval $(thefuck --alias)
# eval $(thefuck --alias fk)

# Created by `pipx` on 2024-07-04 16:51:32
export PATH="$PATH:/Users/g/.local/bin"

# pnpm
export PNPM_HOME="/Users/g/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
#
#
# for yazi https://www.josean.com/posts/how-to-use-yazi-file-manager
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

export EDITOR=nvim


# Homebrew keg-only tools für CBC zum schnelleren Dienstplan berechnen statt GLPK
export PATH="/opt/homebrew/opt/cbc/bin:$PATH"

# pkg-config: COIN-OR libs für rcbc / ROI.plugin.cbc
export PKG_CONFIG_PATH="/opt/homebrew/opt/cbc/lib/pkgconfig:/opt/homebrew/opt/clp/lib/pkgconfig:/opt/homebrew/opt/coinutils/lib/pkgconfig:/opt/homebrew/opt/osi/lib/pkgconfig:/opt/homebrew/opt/cgl/lib/pkgconfig:$PKG_CONFIG_PATH"

# hilft beim kompilieren (rcbc)
export CPPFLAGS="-I/opt/homebrew/opt/cbc/include -I/opt/homebrew/opt/clp/include -I/opt/homebrew/opt/coinutils/include -I/opt/homebrew/opt/osi/include -I/opt/homebrew/opt/cgl/include $CPPFLAGS"
export LDFLAGS="-L/opt/homebrew/opt/cbc/lib -L/opt/homebrew/opt/clp/lib -L/opt/homebrew/opt/coinutils/lib -L/opt/homebrew/opt/osi/lib -L/opt/homebrew/opt/cgl/lib $LDFLAGS"

# OpenAI API Key (aus externer Datei laden)
# if [ -f "$HOME/.config/secrets/openai.env" ]; then
#   source "$HOME/.config/secrets/openai.env"
# fi

# pomodoro timer bashbunni https://gist.github.com/bashbunni/f6b04fc4703903a71ce9f70c58345106 
# a pop up notification and sound alert (using the built-in sounds for macOS)

# Requires https://github.com/caarlos0/timer to be installed
# brew install caarlos0/tap/timer

# Mac setup for pomo
alias pomo25="timer 25m && terminal-notifier -message 'Pomodoro'\
        -title 'Work Timer is up! Take a Break 😊'\
        -appIcon '~/Pictures/pumpkin.png'\
        -sound Crystal"
alias pomo50="timer 50m && terminal-notifier -message 'Pomodoro'\
        -title 'Work Timer is up! Take a Break 😊'\
        -appIcon '~/Pictures/pumpkin.png'\
        -sound Crystal"
        
alias rest10="timer 10m && terminal-notifier -message 'Pomodoro'\
        -title 'Break is over! Get back to work 😬'\
        -appIcon '~/Pictures/pumpkin.png'\
        -sound Crystal"
alias rest5="timer 5m && terminal-notifier -message 'Pomodoro'\
        -title 'Break is over! Get back to work 😬'\
        -appIcon '~/Pictures/pumpkin.png'\
        -sound Crystal"

parakeet() {
  if pgrep -x MacParakeet >/dev/null; then
    echo "MacParakeet läuft bereits."
    return 0
  fi

  /Applications/MacParakeet.app/Contents/MacOS/MacParakeet \
    </dev/null >/dev/null 2>&1 &
  disown
}
# Start MacParakeet once when the first Kitty shell starts
if [[ "$TERM" == "xterm-kitty" ]] && ! pgrep -x MacParakeet >/dev/null; then
  "$HOME/.local/bin/parakeet"
fi
