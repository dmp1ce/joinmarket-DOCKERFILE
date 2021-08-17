#!/bin/sh
set -e

UID=${UID:-1000}
GID=${GID:-1000}

mkdir -p /home/joinmarket/.joinmarket

if [ "$UID" -eq 0 ]; then
    chown -R "$_UID":"$_GID" /home/joinmarket
    exec bash -c "cd /jm/clientserver/scripts && python3 $*"
else
    _UID=$(id -u joinmarket)
    _GID=$(id -g joinmarket)

    if [ -n "$UID" ] && [ "$UID" != "$_UID" ]; then
        _UID="$UID"
        usermod -u "$_UID" joinmarket
    fi

    if [ -n "$GID" ] && [ "$GID" != "_GID" ]; then
        _GID="$GID"
        groupmod -g "$_GID" joinmarket
    fi

    # Fix permissions according to the host user UID and GID
    chown -R "$_UID":"$_GID" /home/joinmarket

    exec gosu joinmarket bash -c "cd /jm/clientserver/scripts && python3 $*"
fi
