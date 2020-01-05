#!/bin/bash
set -e

exec gosu joinmarket bash -c "source jmvenv/bin/activate && cd scripts && $*"
