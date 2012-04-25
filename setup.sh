# source this to install dotfiles

DOTFILES="$HOME/dotfiles"

ls "$DOTFILES" | grep -v '\.sh' | while read DOTFILE; do
	echo -n "Symlink to $DOTFILE..."
	if [ -a "$HOME/.$DOTFILE" ]; then
		if [ -h "$HOME/.$DOTFILE" ]; then
			echo " exists."
		else
			echo " is not a symlink!"
			echo "You should probably fix that."
			exit 1
		fi
	else
		echo " creating..."
		ln -s "$DOTFILES/$DOTFILE" "$HOME/.$DOTFILE"
	fi
done

BP="$HOME/.bashrc"
echo "Looking for $BP..."
SO_BASH="source $DOTFILES/bash.sh"

HAS_SO_BASH=""
if [ -a "$BP" ]; then
	echo "Found. Looking for source call..."
	HAS_SO_BASH=$(grep "$SO_BASH" "$BP")
fi

if [ -z "$HAS_SO_BASH" ]; then
	echo "Adding source call to $BP..."
	echo "$SO_BASH" >> "$BP"
else
	echo "Not needed."
fi

echo "Done."
