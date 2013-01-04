export HISTSIZE=10000
export PS1=$'\[\e[32m\][\[\e[31m\]\u@\H\[\e[34m\] \[\e[35m\]\A \[\e[33m\]\w\[\e[32m\]]\$ \[\e[0m\]'
export EDITOR=vim
# flush every command to history file immediately
export PROMPT_COMMAND='history -a'

PATH_HAS_HOME_BIN=$(echo "$PATH" | grep "\(^\|:\)$HOME/bin\($\|:\)")
if [ -z "$PATH_HAS_HOME_BIN" ]; then
	export PATH="$HOME/bin:$PATH"
fi
