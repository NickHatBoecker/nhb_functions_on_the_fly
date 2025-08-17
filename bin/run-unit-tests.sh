#!/usr/bin/env bash

set -a          # export all variables that are set
source .env     # load your .env file
set +a
"$GODOT_PATH" -gmaximize -gexit -ghide_orphans -s --path "$PWD" addons/gut/gut_cmdln.gd
