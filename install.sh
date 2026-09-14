#!/bin/bash
# Fresh-machine entry point: git clone && ./install.sh. Everything lives in bin/dot.
exec "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/bin/dot" install "$@"
