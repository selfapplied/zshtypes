#!/usr/bin/env zsh
#
# Compatibility wrapper for zshtypes.
# Sources the core library from its new location in src/.
#

SOURCE=${0:a:h}
source "$SOURCE/src/lambda_core.zsh" 