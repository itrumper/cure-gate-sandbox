# Plan #12: README says what this repo is for

Status: approved 2026-11-11
Branch: `plan/12-readme-purpose` PR: #<pr> Depends on: none Roadmap: `agent_docs/roadmap.md`, row A

## Problem

The README is one line (`# cure-gate-sandbox`), so a reader can't tell what this repo is for. It is the
sandbox the cure director's public-tier gate runs against, and its open `O1 case` issues (#1–#9) are that
gate's fixtures, not work. Without a sentence that says so, a person or an agent may mistake the fixtures for
a backlog (#11).

## Outcomes

What is observably true when this plan is done. Each one has an acceptance test.

Oracle: where the expected values come from, `<kind> <source>` (`agent_docs/agents/workflow.md`, Oracles).

The sentence (S), from #11's words:

> This repo is the sandbox the cure director's public-tier gate runs against: its open issues whose bodies start `O1 case` are that gate's fixtures, not work.

| ID | Outcome | Acceptance test (given / when / then) | Oracle | Test |
| -- | -- | -- | -- | -- |
| O1 | `README.md` says what this repo is for: the sandbox the cure director's public-tier gate runs against, whose open `O1 case` issues are that gate's fixtures, not work (R1) | given the plan branch, when you run the three M1 demo commands, then (1) `grep -cxF` of S in `README.md` prints `1` and `wc -l < README.md` prints `3` (heading, blank line, S); (2) the diff filter prints nothing; (3) the issue list prints the baseline below unchanged | `spec #11` | demo: the three M1 commands |

Issue baseline (2026-11-11), all nine open: #1, #3, #4, #5, #7, #9 carry `agent:approved`; #2, #6, #8 carry no label.

## Non-goals

- Closing, editing or relabelling #1–#9: they are the gate's fixtures (#11, roadmap Deferred).
- A test file or test runner for the README check: the exit criterion allows no file outside `README.md`, `agent_docs/roadmap.md` and `agent_docs/plans/`; the check is the O1 demo, whose commands print a wrong count or extra lines on failure.
- Filling in `CLAUDE.md`'s placeholders, a quickstart or links in the README: #11 asks for one sentence, docs only ("no other files").

## Existing issues

| Issue | Bucket (absorb / supersede / related) | Where or why |
| -- | -- | -- |
| #11 | absorb | delivered by the M1 work item; closes with the PR. Not reused as the item: reuse appends to its body, an edit after `agent:approved`, the case fixtures #4 and #7 exercise |
| #1–#9 | related | the public-tier gate's fixtures (`O1 case`), not work; stay open and untouched (roadmap Deferred) |

## Constraints and assumptions

- Docs only: #11 says "no code, no other files"; the roadmap's exit criterion lists the only paths the diff may touch.
- `README.md` is outside `SRC_RE` (`^src/` in `scripts/workflow.env`), so `scripts/check-tests-touched.sh` needs no test for it.
- The full gate (`scripts/check.sh`) builds the developer site (`zensical.toml`, `docs_dir = "dev_docs"`), which `README.md` is not part of; the gate is green before and after.
- `README.md` has no trailing newline today (19 bytes); the edit leaves it ending in one.
- The plan id is a new `plan` issue (`workflow.md`, Artifacts: "Plan issue ... Its number is the plan id"); row A's Plan column moves from #11 to it.

## Decisions

None: no ADR, no core change (`README.md` is not a Core path in `CLAUDE.md`).

## Milestones

### M1: the README sentence GitHub: `P12 M1: README sentence`

Demo, from the repo root on the plan branch (`<running copy>` as the director names it):

1. `grep -cxF "<S>" README.md` prints `1`; `wc -l < README.md` prints `3`
2. `git diff --name-only main...HEAD | grep -vE '^(README\.md|agent_docs/roadmap\.md|agent_docs/plans/)'` prints nothing
3. `<running copy>/director/issue-context.sh issues --state open --jq '.[] | select(.number <= 9) | "#\(.number) \(.labels | join(","))"'` prints the issue baseline (O1)

Proves: O1

| Issue | Work item | Approach | Files | Test | After |
| -- | -- | -- | -- | -- | -- |
| #13 | Add S under the `# cure-gate-sandbox` heading, after a blank line, file ending in a newline | one plain sentence in #11's words because #11 asks for exactly one sentence and `workflow.md`, Docs makes the README a one-paragraph front door; considered copying the roadmap's Goal line (`agent_docs/roadmap.md`, Goal), ruled out because it is two sentences, and a sentence linking #1–#9 or the gate's source, ruled out by #11 ("one sentence") and because issue numbers rot as fixtures change. Output: `cat README.md` prints `# cure-gate-sandbox`, a blank line, then S | `README.md` | M1 demo commands 1 and 2 | none |

No skipped-then-unskipped acceptance test: the one item is the milestone, and the O1 check is a demo,
not a test file (Non-goals; Change log).

## Risks and spikes

| Risk | Impact | Spike or mitigation |
| -- | -- | -- |
| The sentence drifts from S | O1 fails | demo command 1 matches S exactly (`grep -cxF`) |

## Change log

One bullet per entry (bare lines render as one paragraph).

- 2026-11-11 headless: plan row A from the roadmap and #11; no interview (headless); buckets #11 absorb, #1–#9 related (row: Choose, add or reorder rows (`/roadmap next`), milestone acceptance within the plan)
- 2026-11-11 headless: O1's acceptance test is three demo commands, not a skipped-then-unskipped test file, because the row's exit criterion allows no file outside `README.md`, `agent_docs/roadmap.md` and `agent_docs/plans/`; the oracle stays the roadmap's `spec #11` (row: Choose, add or reorder rows (`/roadmap next`), milestone acceptance within the plan)
- 2026-11-11 headless: #11 is absorbed by a new work-item issue, not reused, so its `agent:approved` body is never edited (row: Choose, add or reorder rows (`/roadmap next`), milestone acceptance within the plan)
- 2026-11-11 critique (plan critic, fable): accepted 1 (demo uses `issue-context.sh`, baseline recorded), 2 (one demo for O1), 4 (gate wording), 6 (risk now checked by the demo), 7 (mechanical demo), 8 (exact sentence S), 9 (Goal-line alternative named); rejected 3's `<n>` = 11, because `workflow.md`, Artifacts makes the plan id a `plan` issue and #11 is the goal's issue, not a plan
- 2026-11-11 headless: approved (row: Choose, add or reorder rows (`/roadmap next`), milestone acceptance within the plan)
