#!/usr/bin/env sh
# Fails when a change touches source without touching a test. TDD enforcement, not a suggestion.
# Usage: check-tests-touched.sh [<git range>]   (default: staged changes). Paths: scripts/workflow.env.
# A source file whose changed lines (`git diff -U0`) are all exempt needs no test. Exempt:
#   comment-only     every added and removed line of the hunk is blank or a `//` comment (`//`, `///`, `//!`);
#   test-module-only the hunk lies after the file's first column-0 `#[cfg(test)]` line that is directly
#                    followed by `mod <name> {`, and before the first column-0 `}` after that line (new side;
#                    old side too when lines were removed). Code after the module's closing `}` is not exempt.
#   python comment   a `.py` hunk in which every added and removed line is blank, a `#` comment, or inside the file's
#                    module docstring: the file's first statement, a `"""` block that starts at line 1 or after leading `#` /
#                    blank lines and ends at the first line that ends in `"""` (old blob for removed lines, new blob for added).
#                    Only the lines strictly between the delimiter lines are exempt, so moving the closing `"""` over code
#                    fails; the cost is a false fail on text edited in a closing `..."""` line (accepted, #719).
# A file passes when each of its hunks is exempt (a binary file never is); any other hunk (code, or code mixed with comments) fails as before.
# The comment-only exemption is line-based: a `//` line inside a multi-line string literal passes
# (#285, accepted: no such string exists, and tracking open strings is not worth the parser).
set -eu
cd "$(git rev-parse --show-toplevel)"
. scripts/workflow.env
range=${1:-}
# a merge commit passes: it brings in the other parent's whole diff, and CI skips merges (git rev-list --no-merges)
[ -n "$range" ] || [ ! -e "$(git rev-parse --git-dir)/MERGE_HEAD" ] || exit 0
# quotePath=false: a non-ASCII path comes out as itself, not quoted past TEST_RE
changed() { if [ -n "$range" ]; then git -c core.quotePath=false diff "$range" "$@"; else git -c core.quotePath=false diff --cached "$@"; fi; }
# a file as staged, as committed at an `a..b` range's end, or in the working tree for a single ref
blob() {
  case $range in
    '') git show ":$1" ;;
    *..*) end=${range##*..}; git show "${end:-HEAD}:$1" ;;
    *) cat "$1" ;;
  esac
}

# the old side of the diff: HEAD for staged changes, else the range's start
oldblob() {
  case $range in
    '') git show "HEAD:$1" ;;
    *..*) git show "${range%%..*}:$1" ;;
    *) git show "$range:$1" ;;
  esac
}
# "<start> <end>": the lines of a Python module docstring (the file's first statement, a `"""` block); nothing
# when there is none (stdin)
docstring_line() {
  awk '!start && /^[[:space:]]*(#.*)?$/ { next }
       !start { if ($0 !~ /^[rRuU]?"""/) exit; start = NR; rest = substr($0, index($0, "\"\"\"") + 3)
                if (rest ~ /"""[[:space:]]*$/) { print start, NR; exit }; next }
       /"""[[:space:]]*$/ { print start, NR; exit }'
}
# "<start> <end>": the line of the first column-0 `#[cfg(test)]` directly followed by `mod <name> {`, and the
# first column-0 `}` after it; nothing when there is no such module or no closing `}` (stdin)
testmod_line() {
  awk 'start && /^\}/ { print start, NR; exit }
       !start && prev && /^(pub(\([a-z]+\))? )?mod [A-Za-z0-9_]+ *\{/ { start = prev }
       { prev = ($0 ~ /^#\[cfg\(test\)\][[:space:]]*$/) ? NR : 0 }'
}
# exits 0 when every hunk of $1 is exempt (see the header)
only_exempt_lines() {
  # a binary file (numstat `-`) has no hunks to read, so it is never exempt
  changed --numstat -- "$1" | awk -F '\t' '$1 == "-" { f = 1 } END { exit !f }' && return 1
  new=$(blob "$1" 2>/dev/null | testmod_line || true)
  old=$(oldblob "$1" 2>/dev/null | testmod_line || true)
  tn=${new% *}; te=${new#* }; to=${old% *}; oe=${old#* }
  # a `.py` file: `#` comments, and the lines strictly inside its module docstring on each side, are exempt; else `//` comments
  cre='^[+-][[:space:]]*(\/\/.*)?$'; dn=; dnn=; do_=; doe=
  case $1 in *.py)
    cre='^[+-][[:space:]]*(#.*)?$'
    d=$(blob "$1" 2>/dev/null | docstring_line || true); [ -z "$d" ] || { dn=${d% *}; dnn=${d#* }; }
    d=$(oldblob "$1" 2>/dev/null | docstring_line || true); [ -z "$d" ] || { do_=${d% *}; doe=${d#* }; }
    tn=; to=;;
  esac
  # one line per hunk: old start, old count, new start, new count, 1 if it changes a line that is not blank or `//`
  changed -U0 -- "$1" | awk -v cre="$cre" -v dn="$dn" -v dnn="$dnn" -v dob="$do_" -v doe="$doe" '
    function flush() { if (h) print oa, ob, na, nb, code }
    /^@@ / { flush(); h = 1; code = 0
      o = $2; n = $3; sub(/^-/, "", o); sub(/^\+/, "", n)
      oa = o; ob = 1; if (index(o, ",")) { split(o, x, ","); oa = x[1]; ob = x[2] }
      na = n; nb = 1; if (index(n, ",")) { split(n, y, ","); na = y[1]; nb = y[2] }
      ol = oa; nl = na; next }
    h && /^-/ { l = ol++; if ($0 !~ cre && !(dob != "" && l > dob && l < doe)) code = 1 }
    h && /^\+/ { l = nl++; if ($0 !~ cre && !(dn != "" && l > dn && l < dnn)) code = 1 }
    END { flush() }' \
  | while read -r oa ob na nb code; do
      [ "$code" = 0 ] && continue
      [ "$nb" != 0 ] || [ "$ob" != 0 ] || exit 1
      if [ "$nb" != 0 ]; then [ -n "$tn" ] && [ "$na" -gt "$tn" ] && [ $((na + nb - 1)) -lt "$te" ] || exit 1; fi
      if [ "$ob" != 0 ]; then [ -n "$to" ] && [ "$oa" -gt "$to" ] && [ $((oa + ob - 1)) -lt "$oe" ] || exit 1; fi
    done
}

files=$(changed --name-only)

# every added test file names its oracle: a comment line `oracle: <kind> <source>` of a known kind.
# Data under tests/ can't carry one (its oracle is on the test that reads it): binary files (numstat `-`)
# and ORACLE_SKIP_RE matches (ignoring case) are skipped. Set ORACLE_SKIP_RE in workflow.env to override; empty skips none.
skip=${ORACLE_SKIP_RE-'\.(json|csv|tsv|txt|md|yaml|yml|toml|xml|snap)$'}
kinds='spec|paper|url|fixture|closed-form|property|metamorphic|reference|measurement|user'
bad=0
for t in $(changed --numstat --diff-filter=A | awk -F '\t' '$1 != "-" { print $3 }' | grep -E "$TEST_RE" | grep -viE "${skip:-^$}" || true); do
  lines=$(blob "$t" | grep -E '^[^[:alnum:]]*oracle:' || true)
  printf '%s\n' "$lines" | grep -qE "oracle: ($kinds) [^ ]" \
    && ! printf '%s\n' "$lines" | grep -vqE "oracle: ($kinds) [^ ]" && continue
  echo "check-tests-touched: $t needs one comment line 'oracle: <kind> <source>', kind one of: ${kinds}" >&2
  bad=1
done
[ "$bad" = 0 ] || { echo "See TDD > Oracles in agent_docs/agents/workflow.md." >&2; exit 1; }

src=$(printf '%s\n' "$files" | grep -E "$SRC_RE" | grep -vE "$TEST_RE" || true)
[ -z "$src" ] && exit 0

# a diff that adds no line (numstat `-` is binary: counts as adding) and removes no inline-test line passes:
# a removal can't add untested behaviour, and the remaining tests still run in the gate
if ! changed --numstat -- $src | awk -F '\t' '$1 != 0 { f = 1 } END { exit !f }' \
  && { [ -z "$INLINE_RE" ] || ! changed -- $src | grep -qE "^-.*($INLINE_RE)"; }; then exit 0; fi

# a test file changed
printf '%s\n' "$files" | grep -qE "$TEST_RE" && exit 0
# or a source diff adds an inline test (Rust #[cfg(test)], ...)
[ -n "$INLINE_RE" ] && changed -- $src | grep -qE "^\+.*($INLINE_RE)" && exit 0

# or every changed source file changes only comment lines or test-module lines
all_exempt=1
for f in $src; do only_exempt_lines "$f" || { all_exempt=0; break; }; done
[ "$all_exempt" = 1 ] && exit 0

echo "check-tests-touched: source changed without a test${range:+ in $range}:" >&2
printf '  %s\n' $src >&2
echo "Write the failing test first (agent_docs/agents/workflow.md). Do not use --no-verify." >&2
exit 1
