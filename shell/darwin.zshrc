#
# ~/.zshrc
#
#
# Yamada Hayao
# Twitter: @Hayao0819
# Email  : hayao@fascode.net
#
# (c) 2019-2021 Fascode Network.
#


#-- Alias --#
[[ -f .aliases ]] && source .aliases


#-- Completion --#
[ -e /usr/local/share/zsh-completions ] && fpath=(/usr/local/share/zsh-completions $fpath)
autoload -U compinit
compinit -u


#-- Archive settings --#
export ZIPINFOOPT=-OCP932
export UNZIPOPT=-OCP932


#-- Like fish prompt --#
source /opt/homebrew/share/zsh-history-substring-search/zsh-history-substring-search.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /opt/homebrew/share/zsh-history-substring-search/zsh-history-substring-search.zsh

if type brew &>/dev/null; then
    FPATH=$(brew --prefix)/share/zsh-completions:$FPATH

    autoload -Uz compinit
    compinit
fi

#-- Key --#
# create a zkbd compatible hash;
# to add other keys to this hash, see: man 5 terminfo
typeset -A key

key[Home]=${terminfo[khome]}

key[End]=${terminfo[kend]}
key[Insert]=${terminfo[kich1]}
key[Delete]=${terminfo[kdch1]}
key[Up]=${terminfo[kcuu1]}
key[Down]=${terminfo[kcud1]}
key[Left]=${terminfo[kcub1]}
key[Right]=${terminfo[kcuf1]}
key[PageUp]=${terminfo[kpp]}
key[PageDown]=${terminfo[knp]}

# setup key accordingly
[[ -n "${key[Home]}"     ]]  && bindkey  "${key[Home]}"     beginning-of-line
[[ -n "${key[End]}"      ]]  && bindkey  "${key[End]}"      end-of-line
[[ -n "${key[Insert]}"   ]]  && bindkey  "${key[Insert]}"   overwrite-mode
[[ -n "${key[Delete]}"   ]]  && bindkey  "${key[Delete]}"   delete-char
[[ -n "${key[Left]}"     ]]  && bindkey  "${key[Left]}"     backward-char
[[ -n "${key[Right]}"    ]]  && bindkey  "${key[Right]}"    forward-char
[[ -n "${key[PageUp]}"   ]]  && bindkey  "${key[PageUp]}"   beginning-of-buffer-or-history
[[ -n "${key[PageDown]}" ]]  && bindkey  "${key[PageDown]}" end-of-buffer-or-history

# Normal history display
if [[ -f "/usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh" ]]; then
    source "/usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh"
    [[ -n "${key[Up]}"       ]]  && bindkey  "${key[Up]}"       history-substring-search-up
    [[ -n "${key[Down]}"     ]]  && bindkey  "${key[Down]}"     history-substring-search-down
else
    [[ -n "${key[Up]}"       ]]  && bindkey  "${key[Up]}"       up-line-or-history
    [[ -n "${key[Down]}"     ]]  && bindkey  "${key[Down]}"     down-line-or-history
fi

# Finally, make sure the terminal is in application mode, when zle is
# active. Only then are the values from $terminfo valid.
if (( ${+terminfo[smkx]} )) && (( ${+terminfo[rmkx]} )); then
    function zle-line-init () {
        printf '%s' "${terminfo[smkx]}"
    }
    function zle-line-finish () {
        printf '%s' "${terminfo[rmkx]}"
    }
    zle -N zle-line-init
    zle -N zle-line-finish
fi


#-- Do not sound --#
setopt nolistbeep
setopt nolistbeep


#-- Save history. --#
HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
setopt share_history


#-- Make colors available --#
autoload -Uz colors
colors


#-- Pass to the path --#
if [[ -e "$HOME/.bin" ]]; then
    export PATH="$HOME/.bin:${PATH}"
fi


#-- PROMPT --#
if [[ ${TERM} = "linux" ]]; then
    PROMPT='%B%F{red}%(?..%? )%f%b%B%F{red}%n%f%b@%m %B%40<..<%~%<< %b%# '
else
    function powerline_precmd() {
        PS1="$(powerline-go -error $? -shell zsh)"
    }

    function install_powerline_precmd() {
        for s in "${precmd_functions[@]}"; do
            if [ "$s" = "powerline_precmd" ]; then
                return
            fi
        done
        precmd_functions+=(powerline_precmd)
    }

    install_powerline_precmd
fi

export OPENCV_LOG_LEVEL=ERROR

source "${HOME}/.aliases"

#-- 以下Mac用 --#

#shox 2> /dev/null || true
export GPG_TTY=$TTY
export PATH=$HOME/.composer/vendor/bin:$PATH

export LIMA_INSTANCE="archlinux"

export SNDCPY_HOME="$HOME/Applications/Android/sndcpy"
export SNDCPY_APK="$HOME/Applications/Android/sndcpy/sndcpy.apk"
export PATH="$SNDCPY_HOME/:$PATH"
alias sndcpy="sh sndcpy"
export GOPATH="$HOME/.gopath"
export PATH="$GOPATH/bin:$PATH"



export QT_HOMEBREW=true
export PATH="/Users/hayao/.bin/platform-tools:/opt/homebrew/opt/openjdk@17/bin:$PATH"
