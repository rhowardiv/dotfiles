export HISTSIZE=10000
export HISTFILESIZE=10000
export HISTTIMEFORMAT="%Y-%m-%d %H:%M:%S "
export PS1=$'\[\e[32m\][\[\e[31m\]\u@\H\[\e[34m\] \[\e[35m\]\A \[\e[33m\]\w\[\e[32m\]]\$ \[\e[0m\]'
if [ -n "$(which vcprompt 2>/dev/null)" ]; then
	export VCPROMPT_FORMAT=" %b%m%u"
	export PS1=$'\[\e[32m\][\[\e[31m\]\u@\H\[\e[34m\] \[\e[35m\]\A \[\e[33m\]\w\[\e[36m\]$(vcprompt)\[\e[32m\]]\$ \[\e[0m\]'
fi
export EDITOR=vim
# flush every command to history file immediately
export PROMPT_COMMAND='history -a'

PATH_HAS_HOME_BIN=$(echo "$PATH" | grep "\(^\|:\)$HOME/bin\($\|:\)")
if [ -z "$PATH_HAS_HOME_BIN" ]; then
	export PATH="$HOME/bin:$PATH"
fi

ipr() {
	# issue pull request
	REPO="$(git remote -v | grep origin | head -n 1 | sed 's/^[^:]\+:\([^\/]\+\)\/\([^ \.]*\).*$/\1\/\2/')"
	ON_BRANCH=$(git branch | grep '^* ' | sed 's/^* //')
	xdg-open "https://github.com/$REPO/compare/$ON_BRANCH" > /dev/null 2>&1
}

rr() {
	# random recent committer
	git status >/dev/null 2>&1
	if [[ $? -ne 0 ]]; then
		echo "Not a git repo"
		return 128
	fi
	if [[ ! -s .consume-committers ]]; then
		git log --since="-1 month" | sed -n -e "/^Author: /s/Author: //p;" \
			| grep -v 'Richard Howard' | sort -u | shuf > .consume-committers
	fi
	committers="$(< .consume-committers)"
	echo "$committers" | head --lines=-1 > .consume-committers
	echo "$committers" | tail -n 1
}
