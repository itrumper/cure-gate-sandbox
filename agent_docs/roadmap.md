# Roadmap: cure-gate-sandbox

Status: active
Goal: The sandbox the cure director's public-tier gate runs against. Its open `O1 case` issues are that gate's fixtures, not work (#11).
ADRs: none yet (`agent_docs/adr/` holds only the template).

The one living roadmap of this repo: the only agent_docs artifact edited and appended as work lands. The
planner scopes the next plan from it; the orchestrator ticks the plan's row at plan end. A goal that needs
several plans is a group of rows under its own `### <goal>` heading in Plans. Done rows stay one line.

## Outcomes

What the roadmap delivers, each with the oracle its acceptance test will cite (`<kind> <source>`, kinds in
workflow.md TDD > Oracles). Agents propose the oracles; the user approves the column in one batch.

| ID | Outcome | Oracle | Plan |
| -- | -- | -- | -- |
| R1 | `README.md` says what this repo is for: the sandbox the cure director's public-tier gate runs against, whose open issues #1–#9 (`O1 case` in their bodies) are that gate's fixtures, not work | `spec #11` | A |

## Plans

In order. A row becomes a plan (`agent_docs/plans/<n>-<slug>.md`) only when it is next.

Row letters and the Plan column: `agent_docs/agents/workflow.md`, Artifacts (Roadmap).

| Row | Plan | Scope | Exit criterion | Status |
| -- | -- | -- | -- | -- |
| A | #12 | One `README.md` sentence (R1). #1–#9 untouched. | R1 holds (`spec #11`); `git diff --name-only main...HEAD` lists nothing outside `README.md`, `agent_docs/roadmap.md` and `agent_docs/plans/` | active |

## Decision rights

Who decides what. The default below; change a row only with the user. Anything not listed goes one level up.

| Decision | Owner |
| -- | -- |
| How to implement an item inside its Files | worker |
| Split, CR triage, commit order, wave dispatch | orchestrator |
| Choose, add or reorder rows (`/roadmap next`), milestone acceptance within the plan | director |
| Merge a plan PR that `director/merge.sh` accepts | director |
| Security triggers, superseding an ADR, deviating from this roadmap, changing an oracle or acceptance test, adding a dependency, review disputes (a rejected CR the reviewer raises again, or a finding still open after its fix landed) and a review that trips the circuit breaker | user |

## Design references

What the UI must look like: screenshots, Figma or Design-canvas links, tokens, apps to match. Each UI
outcome names the baseline the user approves; that baseline is its oracle (`user <artifact>`).

| Outcome | Reference | Baseline |
| -- | -- | -- |
| - | no UI outcome on this roadmap | - |

## Kill criteria

Per row, the signal that makes the agent stop and ask the user whether to pivot. Measurable where possible.

| Row | Signal | Ask |
| -- | -- | -- |
| A | none: a one-sentence docs change | - |

## Shared tables

Anything several plans draw from and that changes as they land (a hook list, a unit order, a catalog
coverage table). Each row names the plan that delivers it.

None yet.

## Deferred

Open issues no row cites, each with what it waits for. `/roadmap next` rewrites this table at every pick;
it is the only record of a deferral (no issue comments), and `git log -p` is its history.

| Issue | Waits for | Since |
| -- | -- | -- |
| #1 | the user closes it (a fixture of the public-tier gate, not work: #11) | 2026-11-11 |
| #2 | the user closes it (a fixture of the public-tier gate, not work: #11) | 2026-11-11 |
| #3 | the user closes it (a fixture of the public-tier gate, not work: #11) | 2026-11-11 |
| #4 | the user closes it (a fixture of the public-tier gate, not work: #11) | 2026-11-11 |
| #5 | the user closes it (a fixture of the public-tier gate, not work: #11) | 2026-11-11 |
| #6 | the user closes it (a fixture of the public-tier gate, not work: #11) | 2026-11-11 |
| #7 | the user closes it (a fixture of the public-tier gate, not work: #11) | 2026-11-11 |
| #8 | the user closes it (a fixture of the public-tier gate, not work: #11) | 2026-11-11 |
| #9 | the user closes it (a fixture of the public-tier gate, not work: #11) | 2026-11-11 |

## Change log

One bullet per entry (bare lines render as one paragraph).

- 2026-11-11: `/roadmap next` (headless), the first pick on the bare seed (title, goal in #11's words, R1, Deferred filled in): picked A (#11, one README sentence saying what the repo is for), the only open issue that is work. Runner-up: none (with A done and no new issue, the roadmap is done). 9 issues deferred (#1–#9, the gate's fixtures).
- 2026-11-11: review (roadmap-reviewer, claude-opus-5-5)
  - 1: accepted
  - 2: accepted
  - 3: accepted
  - 4: accepted
  - 5: accepted
  - 6: accepted
  - 7: accepted
  - 8: accepted for the condition; rejected the one-range row: `/roadmap next` keeps one Deferred row per issue
