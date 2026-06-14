---
name: brag-doc
description: Generate a brag document by gathering merged PRs and closed issues from GitHub plus optional Slack incident-channel activity over a date range, then interactively dialoguing about uncaptured work. Maintains a running doc across runs. Use when the user asks to build, update, or draft a brag doc / accomplishments doc / promo packet / self-review evidence.
user-invocable: true
---

# Brag Document Generator

Build a brag doc from hard data (merged GitHub PRs, closed issues, optional Slack incident activity) plus an interactive dialogue covering work that isn't visible in those sources (design docs, mentoring, talks, etc.).

Designed to be **run periodically**. State tracked in `~/brag-docs/.state.json` so each run extends the running doc rather than starting from scratch.

## Prerequisites

- `gh` authenticated. Confirm with `gh auth status`. GitHub login resolves via `@me` — no hard-coded usernames.
- (Optional) Slack MCP tools (`mcp__plugin_slack_slack__*`) for the incident-channel pull. Get the user's own Slack ID at runtime via `mcp__plugin_slack_slack__slack_search_users` (search for the user by name) — never hard-code it.

## Step 0: Read state

```bash
mkdir -p ~/brag-docs
test -f ~/brag-docs/.state.json && cat ~/brag-docs/.state.json
```

State file shape:

```json
{
  "last_run": "YYYY-MM-DD",
  "last_since": "YYYY-MM-DD",
  "orgs": ["..."],
  "running_doc": "~/brag-docs/brag-running.md",
  "history": [
    {"run": "YYYY-MM-DD", "since": "...", "until": "...", "prs": N, "issues": N}
  ]
}
```

If state exists, default the next run's **since** to `last_run` (incremental update). Always allow the user to override.

## Step 1: Confirm scope with the user

Ask via `AskUserQuestion`. **Always ask about orgs** — org membership grows over time, so re-confirm each run.

1. **Date range** — default: `last_run → today` if state exists, else 6 months back. Offer "since last run", "last 3/6/12 months", custom.
2. **Orgs / repos** — **always ask, no smart default.** Show last-run orgs as the suggested option but require confirmation. Offer "same as last run", "add new org", "all orgs I contribute to", custom list.
3. **Output mode** — default: append to running doc (`~/brag-docs/brag-running.md`). Offer "append to running doc", "new dated snapshot (`brag-YYYY-MM-DD.md`)", "both", "stdout only".
4. **Depth** — "quick list" (titles + links) vs "narrative" (group by theme, 1-2 sentences per item).

Skip any question the user already answered in their invocation.

## Step 2a: Pull GitHub data

Run in parallel:

```bash
SINCE=<from step 1>
OWNER_FLAGS="--owner=ORG"  # or comma-separated, or empty for all orgs

gh search prs --author=@me $OWNER_FLAGS --merged --merged-at=">=$SINCE" --limit 200 \
  --json repository,number,title,url,createdAt,labels,body \
  > /tmp/brag-prs.json

gh search issues --author=@me $OWNER_FLAGS --state=closed --closed=">=$SINCE" --limit 200 \
  --json repository,number,title,url,closedAt,labels,state \
  > /tmp/brag-issues-authored.json

gh search issues --assignee=@me $OWNER_FLAGS --state=closed --closed=">=$SINCE" --limit 200 \
  --json repository,number,title,url,closedAt,labels,state \
  > /tmp/brag-issues-assigned.json
```

**Note:** `gh search prs` exposes `createdAt` not `mergedAt`. Use createdAt as approximation — merge typically lands within hours of creation for active engineers.

Dedupe issues between authored/assigned lists by URL.

**Coverage check:** if any query hits 200, rerun month-by-month to avoid silent truncation:

```bash
for range in "YYYY-MM-01..YYYY-MM-DD" ...; do
  gh search prs --author=@me $OWNER_FLAGS --merged --merged-at="$range" --limit 200 \
    --json repository,number,title,url,createdAt,labels,body \
    > "/tmp/brag-prs-${range%%..*}.json"
done
jq -s 'add' /tmp/brag-prs-*.json > /tmp/brag-prs.json
```

## Step 2b: Pull Slack data (optional, opt-in)

Three-tier approach. Ask the user whether to run Slack pull — default **tier 2** if yes.

### Resolve user's Slack ID at runtime

```
mcp__plugin_slack_slack__slack_search_users — query: "<user's full name or email>"
```

Pick the matching ID (format `U...`). Cache it in `.state.json` as `slack_user_id` for subsequent runs.

### Tier 1 — Volume signal

Find channels where the user posted heavily since `$SINCE`. Use `mcp__plugin_slack_slack__slack_search_public_and_private`:

```
query: from:<@SLACK_USER_ID> after:YYYY-MM-DD
limit: 20
sort: timestamp, sort_dir: desc
```

Paginate up to ~5 pages (100 messages) to cap cost.

### Tier 2 — Incident channels (default)

Filter Tier 1 results to channels matching the project's incident-channel naming pattern. Ask the user what their org uses (e.g. `i-YYYY-MM-DD-<slug>`, `incident-*`, `inc-*`). Cache the pattern in `.state.json`.

For each matched channel:
1. Pull channel topic/purpose via `slack_search_channels` (include_archived=true, channel_types=public_channel,private_channel).
2. Search the user's messages in that channel: `from:<@SLACK_USER_ID> in:<#CHANNEL_ID>`. Note message count + grab 2-3 representative quotes.

Output: `channel | message_count | topic | role summary`.

### Tier 3 — Classified (opt-in)

Ask: "Run deep classification? Reads top messages per channel + LLM-grades each as 'led', 'helped', 'comms', 'debugged'. Slow + uses tokens."

If yes: for top 2-3 channels by message count, pull first 50 messages each and classify the user's role.

### Important caveats
- **Channel-name globs don't work in Slack search.** `in:#i-2026-*` returns 0 results. Must enumerate via `from:@me` + post-filter.
- **5-page cap may not reach back to `$SINCE`.** Note this in the output if so.
- **Private incident channels** may have legal/privilege markers (e.g. "Attorney-Client Privileged"). Preserve those labels in the output. Do not paste verbatim content from privileged channels into a synced/public location — summarize only.

## Step 3: Group and summarize

Group GitHub PRs by repo. Within each repo, identify themes by conventional commit scopes (`feat(scope):`, `chore(scope):`) — high-volume scopes become theme buckets. Drop noise (dependabot, renovate, routine reverts).

For "narrative" depth: read body of top ~10 PRs (sorted by impact signal — labels, non-`chore` prefix, larger diffs). Skip body for chore/deps PRs.

## Step 4: Interactive dialogue — uncaptured work

Show the user the grouped summary first. Ask **one question at a time** (open-ended categories):

1. **Incidents / on-call** — confirm Slack-surfaced incidents + ask about ones outside the window or in DMs.
2. **Design docs / RFCs / ADRs**
3. **Mentoring / interviews / hiring**
4. **Cross-team / customer work**
5. **Talks / writing / external** — also check for local dirs like `~/code/*/blog-draft.md`, `~/code/*-talk/`, etc.
6. **Other scope / impact**

For each answer: capture **what**, **when**, **impact**. If vague, prompt for one concrete detail. If user says "nothing"/"skip", move on.

**Attribution discipline:** Don't inflate verbs. "Updated the writeup" ≠ "authored". Group incident with multiple leads ≠ "led" (use "helped lead"). Ask before using "led", "owned", "authored", "designed" if source signal is only "updated", "contributed", "posted in channel."

## Step 5: Assemble the doc

Output structure:

```markdown
# Brag Doc — {{date range}}

_Generated {{today}}_

## Highlights
{{3-5 bullet points, top-impact items}}

## Shipped (Merged PRs)
### {{repo}} — N PRs
#### {{theme}} (N PRs)
- [{{date}}] [#{{n}} {{title}}]({{url}})
...

## Closed Issues
### {{repo}} (N)
- [{{date}}] [#{{n}} {{title}}]({{url}})
...

## Beyond the Code
### Incidents & On-Call
### Design & Decisions
### Mentoring & Hiring
### Cross-Team & Customer
### Talks, Writing, External
### Other

## Metrics
- PRs merged: {{n}} across {{m}} repos
- Issues closed: {{n}}
- Date range: {{since}} → {{until}}
- Top scope: {{repo}} — N PRs
- Largest initiative: {{theme}} — N PRs
```

### Running-doc mode

If user picked "append to running doc": don't overwrite — insert a new top-level section `# Update — YYYY-MM-DD` above prior content (newest-first). Keep old `Highlights` / `Metrics` per-run so quarterly views stay intact.

If user picked "new dated snapshot": write `~/brag-docs/brag-YYYY-MM-DD.md`. Don't touch the running doc.

If user picked "both": write the dated snapshot **and** insert a summary block (highlights + metrics only) into the running doc.

## Step 6: Update state + offer follow-ups

Write/update `~/brag-docs/.state.json`. Append to `history` array — audit trail.

Offer:
- "Extract a shorter version for self-review / promo packet?"
- "Schedule a recurring run?" — via `ScheduleWakeup` or cron.

## Notes

- **Privacy:** brag docs reference private repos + privileged incident channels. Default path `~/brag-docs/` is local. Confirm before writing to any synced/public location. Never paste verbatim privileged-channel content — summarize only.
- **Idempotency:** running doc gets a dated section per run; dated snapshots prompt before overwrite.
- **Truncation:** if `gh search` hits any 200-limit (per-query, not just total), the section is incomplete — state that explicitly in the doc footer. Use the month-by-month workaround.
- **State file is ground truth** for "what's already been captured." If the user blows it away, regenerate from scratch.
- **No hard-coded identifiers.** This skill is meant to be portable — resolve GitHub login via `@me`, Slack ID via runtime lookup. Org names, incident-channel patterns, and Slack user ID get cached in `.state.json` on first run.
