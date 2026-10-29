#!/bin/bash
# Boot every example in PCSX-Redux and grade each on its BOOK-PASS line,
# never on the absence of a failure.
#
#   ci/run-examples.sh <pcsx-redux or its AppRun> <openbios.bin>
#
# Run from the repository root after building the examples with
# BOOK_CI=true. Every examples/*/ directory has to be listed below, so a new
# example cannot be left out of the run by accident.

set -u

if [ -z "${DISPLAY:-}" ]; then
    exec xvfb-run -a "$0" "$@"
fi

EMU=${1:?usage: $0 <pcsx-redux> <openbios.bin>}
BIOS=${2:?usage: $0 <pcsx-redux> <openbios.bin>}
TIMEOUT=${TIMEOUT:-60}

# name;success regex
EXAMPLES=(
    "frames;^BOOK-PASS frames count=[0-9]+ rate=(50|60)$"
)

fail=0
declare -A known
for e in "${EXAMPLES[@]}"; do known[${e%%;*}]=1; done
for d in examples/*/; do
    d=$(basename "$d")
    if [ -z "${known[$d]:-}" ]; then
        echo "UNLISTED: examples/$d is not in $0"
        fail=1
    fi
done

LOGS=$(mktemp -d)
for e in "${EXAMPLES[@]}"; do
    IFS=';' read -r name token <<< "$e"
    exe="examples/$name/$name.ps-exe"
    if [ ! -f "$exe" ]; then
        echo "MISSING: $exe was not built"
        fail=1
        continue
    fi
    log="$LOGS/$name.log"
    home="$LOGS/home-$name"
    mkdir -p "$home"
    HOME="$home" XDG_CONFIG_HOME="$home/.config" timeout -k 10 "$TIMEOUT" "$EMU" -no-ui -run -stdout -testmode \
        -interpreter -bios "$BIOS" -loadexe "$exe" > "$log" 2>&1
    rc=$?
    line=$(sed 's/\x1b\[[0-9;]*m//g' "$log" | tr -d '\r' | grep -aE "$token" | tail -1)
    if [ $rc -eq 0 ] && [ -n "$line" ]; then
        echo "PASS $name: $line"
    else
        echo "FAIL $name: exit $rc, no success line"
        sed 's/\x1b\[[0-9;]*m//g' "$log" | tail -40 | sed 's/^/    /'
        fail=1
    fi
done

[ $fail -eq 0 ] && echo "all ${#EXAMPLES[@]} example(s) passed"
exit $fail
