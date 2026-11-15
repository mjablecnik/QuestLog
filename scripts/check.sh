#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "${SCRIPT_DIR}")"
cd "${PROJECT_ROOT}"

echo "==> flutter analyze"
flutter analyze

echo "==> flutter test"
# `flutter test` exits non-zero when there are no test files at all, which would
# make a freshly scaffolded project fail its own check.
if [[ -n "$(find test -name '*_test.dart' -print -quit 2>/dev/null)" ]]; then
	flutter test
else
	echo "no test files yet, skipping"
fi

echo "==> check-structure.sh"
"${SCRIPT_DIR}/check-structure.sh"

echo "check.sh: all checks passed"
