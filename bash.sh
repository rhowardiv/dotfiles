#!/bin/bash
export HISTSIZE=10000
export HISTFILESIZE=10000
export HISTTIMEFORMAT="%Y-%m-%d %H:%M:%S "
export EDITOR=vim
# flush every command to history file immediately
export PROMPT_COMMAND='history -a'

# PEP 0370 (pip install --user ...)
export PATH="$HOME/.local/bin:$PATH"

PATH_HAS_HOME_BIN=$(echo "$PATH" | grep "\(^\|:\)$HOME/bin\($\|:\)")
if [ -z "$PATH_HAS_HOME_BIN" ]; then
	export PATH="$HOME/bin:$PATH"
fi

export PS1=$'\[\e[32m\][\[\e[31m\]\u@\H\[\e[34m\] \[\e[35m\]\A \[\e[33m\]\w\[\e[32m\]]\$ \[\e[0m\]'
if [ -n "$(which vcprompt 2>/dev/null)" ]; then
	export VCPROMPT_FORMAT=" %b%m%u"
	export PS1=$'\[\e[32m\][\[\e[31m\]\u@\H\[\e[34m\] \[\e[35m\]\A \[\e[33m\]\w\[\e[36m\]$(vcprompt)\[\e[32m\]]\$ \[\e[0m\]'
fi

urlencode() {
	xxd -plain | tr -d '\n' | sed 's/\(..\)/%\1/g'
}

urldecode() {
    local url_encoded="${1//+/ }"
    printf '%b' "${url_encoded//%/\\x}"
}

# No Screensaver -- one arg for seconds
ns() {
	xscreensaver-command -exit
	caffeinate sleep "$1" && xscreensaver -nosplash
}

rw() {
	# Random Word(s)
	# Why aren't the args working right?
	local sep=" "
	local c=1
	while getopts "ns:" opt; do
		case "$opt" in
			n)
				# No separator
				sep=""
				;;
			\?)
				echo "wat -$OPTARG"
				;;
		esac
	done
	shift $((OPTIND-1))
	if [[ -n "$1" ]]; then
		c="$1"
	fi
	#echo "count:$c"
	#echo "sep:'$sep'"
	for i in $(seq 1 "$c"); do
		echo -n "$(egrep -v 's$|'\' /usr/share/dict/words | shuf -n 1)"
		if [[ "$i" -ne "$c" ]]; then
			echo -n "$sep"
		fi
	done
	echo
}

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
		local BLACKLIST="Richard Howard\|Colonel Monocle"
		git shortlog -se --since="-1 month" \
			| cut -f 2- | sed 's/ <.*//' \
			| grep -v "$BLACKLIST" \
			| sort -u \
			| shuf \
			> .consume-committers
	fi
	committers="$(< .consume-committers)"
	echo "$committers" | head --lines=-1 > .consume-committers
	echo "$committers" | tail -n 1
}

glh() {
	# git linear history
	git log --first-parent "$@" | grep -v '^Merge\|^\s*$' | sed 's/Merge pull request/PR/'
}

hlh() {
	# hilighted linear history
	if [ -t 1 ]; then
		glh "$@" | sed 's/^ \{4\}[^P].*/\x1b[33m&\x1b[39;49m/' | less -R
	else
		glh "$@"
	fi
}

gup() {
	# git update from upstream, push to origin
	# or, if no upstream, just pull from origin
	BRANCH="${1:-master}"
	REV="$(git rev-parse "$BRANCH")"
	if [[ -z "$REV" ]]; then
		return $?;
	fi
	git remote | grep '^upstream$' >/dev/null
	if [[ $? -eq 0 ]]; then
		FROM=upstream
		PUSH_ORIGIN=push
	else
		FROM=origin
		PUSH_ORIGIN=
	fi
	if [[ "$(git rev-parse HEAD)" == "$REV" ]]; then
		# already on $BRANCH
		git pull --ff-only "$FROM" "$BRANCH"
	else
		git fetch "$FROM" "$BRANCH":"$BRANCH"
	fi
	local up_success=$?
	if [[ $up_success && -n "$PUSH_ORIGIN" ]]; then
		git push origin "$BRANCH":"$BRANCH"
	fi
	return $up_success
}

grabssh() {
	# stick SSH env vars in a sourceable file
	for x in SSH_CLIENT SSH_TTY SSH_AUTH_SOCK SSH_CONNECTION DISPLAY; do
		(eval echo $x=\$$x) | sed  's/=/="/
									s/$/"/
									s/^/export /'
	done 1>$HOME/.fixssh
}

grab() {
	grabssh
	screen -dRR
}

fixssh() {
	source $HOME/.fixssh
}

sshf() {
	fixssh
	ssh "$@"
}

gfm() {
	# git find merge: where was the first argument merged into [second argument|master]
	local target="${2:-master}"
	git rev-list $1..$target --ancestry-path | grep -f <(git rev-list $1..$target --first-parent) | tail -1
}
