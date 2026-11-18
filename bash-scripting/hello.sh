#!/usr/bin/env bash
#
# hello.sh - First Bash script: shebang, variables, arguments,
#            user input, conditionals and a loop.
#
# Usage:
#   ./hello.sh                 -> greets "World"
#   ./hello.sh Alice           -> greets "Alice"
#   ./hello.sh Alice 3         -> greets "Alice" 3 times
#
# Make executable first:  chmod +x hello.sh

# ---------- Variables and arguments ----------
# $1 = first argument, $2 = second argument.
# ${1:-World} means "use $1, or 'World' if it is empty".
name="${1:-World}"
count="${2:-1}"

# ---------- Validate input ----------
# The count must be a positive whole number.
if ! [[ "$count" =~ ^[0-9]+$ ]] || [ "$count" -lt 1 ]; then
    echo "Error: count must be a positive number." >&2
    echo "Usage: $0 [name] [count]" >&2
    exit 1
fi

# ---------- Command substitution ----------
today="$(date '+%A, %d %B %Y')"
now="$(date '+%H:%M:%S')"
user="$(whoami)"
host="$(hostname)"

# ---------- Greeting (loop) ----------
for ((i = 1; i <= count; i++)); do
    echo "Hello, $name! (greeting $i of $count)"
done

# ---------- Output ----------
echo
echo "Script    : $0"
echo "Run by    : $user on $host"
echo "Date      : $today"
echo "Time      : $now"

# ---------- Conditional on time of day ----------
hour="$(date +%H)"
if [ "$hour" -lt 12 ]; then
    echo "Have a great morning!"
elif [ "$hour" -lt 18 ]; then
    echo "Have a great afternoon!"
else
    echo "Have a great evening!"
fi

# ---------- Interactive input (only when run in a terminal) ----------
if [ -t 0 ]; then
    read -r -p "What are you learning today? " topic
    if [ -n "$topic" ]; then
        echo "Nice, $topic is a great thing to learn."
    fi
fi

# ---------- Exit status ----------
# 0 means success. Check it after running with: echo $?
exit 0
