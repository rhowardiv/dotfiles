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
		# ignore: self, non-canonical versions of Brett, Mary, Maxwell
		local BLACKLIST="Richard Howard\|Brett W\|^Mary$\|^Maxwell"
		git log --since="-1 month" \
			| sed -n -e "/^Author: /s/^Author: \([^<]\+\).*$/\1/p;" \
			| sed 's/ *$//' \
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
	if [[ $? && -n "$PUSH_ORIGIN" ]]; then
		git push origin "$BRANCH":"$BRANCH"
	fi
}
