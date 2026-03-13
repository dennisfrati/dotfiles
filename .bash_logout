#
# ~/.bash_logout
#

clear
#history -c && history -w

DATE=$(date '+%T %F' | tr -d '\n')
TTY=$(tty)

if [ -n "$SSH_TTY" ]; then
	if command -v telegram_send_msg.sh &>/dev/null; then
		SSH_MSG="[$DATE] [ALARM] user: $USER logout from ssh connection on $TTY."
		telegram_send_msg.sh "$SSH_MSG"
	fi
else
	if command -v telegram_send_msg.sh &>/dev/null; then
		LOCAL_MSG="[$DATE] [ALARM] user: $USER logout from local machine on $TTY."
		telegram_send_msg.sh "$LOCAL_MSG"
	fi
fi

echo "Session closed: $USER"
sleep 1
