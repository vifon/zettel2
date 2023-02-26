#!/usr/bin/env bash

SCRIPTDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" > /dev/null 2>&1 && pwd)"

set -o errexit -o nounset -o pipefail

emacs -Q --batch \
      -l ~/.emacs.d/straight/repos/package-lint/package-lint.el \
      -L . \
      --eval '(setq package-lint-main-file "zettel2.el")' \
      --eval "(advice-add 'package-lint--check-packages-installable :override #'always)" \
      -f package-lint-batch-and-exit \
      ./*.el
