#!/bin/sh
set -e

_UID=$(id -u joinmarket)
_GID=$(id -g joinmarket)

# shellcheck disable=SC2039
if [ -n "$UID" ] && [ "$UID" != "$_UID" ]; then
    _UID="$UID"
    usermod -u "$_UID" joinmarket
fi

# shellcheck disable=SC2153
if [ -n "$GID" ] && [ "$GID" != "_GID" ]; then
    _GID="$GID"
    groupmod -g "$_GID" joinmarket
fi

# Fix permissions according to the host user UID and GID
chown -R "$_UID":"$_GID" /home/joinmarket/.joinmarket
chown -R "$_UID":"$_GID" /jm/clientserver/scripts/logs

exec gosu joinmarket bash -c "cd /jm/clientserver/scripts && python3 $*"
