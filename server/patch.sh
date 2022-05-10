#!/bin/bash
set -x
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
ls "$SCRIPTPATH/patches" | while read x; do
    git apply < "$SCRIPTPATH/patches/$x" || exit 100
done

# This is just README for now, in the future we might add more
# If we add more, we need to use rsync.
cp $SCRIPTPATH/files/* ./