#!/bin/bash
#
#
# Check that the code style is honoured.
#
# Usage: .../check-style.sh [options] [<scan-root>]
#
# Run from top-level source directory.
#
# Options:
#   --fix   - Fix style issues (otherwise just report)
#
#
# For each source file in the git repository, style it according
# to the style guide and then check for differences.
#
# Requires 'astyle' to be installed.

set -e
fix=0

if [[ $1 == "--fix" ]]; then
    shift
    fix=1
fi

scanroot=$1
ignore_spec="$(dirname $0)/ignore_style.txt"

files=$(git ls-files $scanroot | grep -E '\.(c|h|cpp)$')

tmpdir=$(mktemp -d)

errcnt=0
errfiles=
if [[ $fix == 1 ]]; then
    echo "# Checking and fixing style.."
else
    echo "# Checking style.."
fi

for f in $files ; do
    if echo "$f" | grep -q -f "$ignore_spec"; then
        continue
    fi

    tmpfile="${tmpdir}//${f//\//__}"
    astyle --style=google --indent=spaces=8 < "$f" > "$tmpfile"
    if ! cmp -s "$f" "${tmpfile}" ; then
        errcnt=$(expr $errcnt + 1)
        errfiles="${errfiles} $f"
        echo -e "\033[31m########################################"
        echo "# Style mismatch in $f"
        echo -e "########################################\033[0m"
        (cat "$tmpfile" | diff -u "$f" -) || true
        if [[ $fix == 1 ]]; then
            echo -e "\033[33m# Fixing $f !\033[0m"
            cp "$tmpfile" "$f"
        fi
    fi
    rm -f "$tmpfile"
done

rmdir "$tmpdir"

if [[ $errcnt -gt 0 ]]; then
    echo -e "\033[31m########################################"
    echo "# $errcnt files with style mismatch:"
    for f in $errfiles; do
        echo "  $f"
    done
    echo "# ^ $errcnt files with style mismatch"
    echo -e "########################################\033[0m"
    if [[ $fix == 1 ]]; then
        echo -e "\033[33m# Style errors were automatically fixed.\033[0m"
    else
        echo "You can fix these issues automatically by running 'make fix-style'."
    fi
    exit 1
fi


exit 0
