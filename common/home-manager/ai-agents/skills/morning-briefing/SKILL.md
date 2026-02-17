---
name: morning-briefing
description: Generate a comprehensive morning briefing by gathering information from multiple sources. Use when the user asks for a daily overview, morning summary, what's on deck, what's happening today, or similar requests to understand their workday context. Aggregates data from calendar, Slack, email, Jira, GitHub, Rollbar, CircleCI, and Confluence.
---

# Morning Briefing

Generate a comprehensive daily overview by querying multiple data sources in parallel.

## Data Sources

Query these sources using available MCPs and tools:

### Atlassian (MCP)

1. Get cloud ID via `atlassian_getAccessibleAtlassianResources`
2. Query Jira tickets: `assignee = currentUser() AND status NOT IN (Done, Verified, Released, Closed, Archived) ORDER BY updated DESC`

### GitHub (MCP)

1. Get user via `github_get_me`
2. Search open PRs authored: `author:{username} is:open`
3. Search PRs needing review: `review-requested:{username} is:open`

### Glean (MCP)

Use `glean_chat` for natural language queries (provides better context synthesis):

1. Calendar: "What meetings do I have on my calendar today and tomorrow? Include meeting titles, times, and attendees."
2. Slack: "Show me my recent Slack messages and mentions from the past 24 hours that need my attention, especially any discussions or questions directed at me."
3. Email: "What important emails have I received in the last 24 hours that may need my attention?"

Use `glean_search` for structured queries:

4. Confluence: `app: confluence`, `from: me`, `updated: past_week`

### Rollbar (MCP)

1. Get top items: `rollbar_get-top-items` for production environment
2. List active items assigned to user if available

### CircleCI (MCP)

1. Get latest pipeline status for main branch using project slug (e.g., `gh/org/repo`)
2. If main branch returns no results, try `master` branch
3. Check for any failed builds on user's recent branches if available

Note: CircleCI may return "Latest pipeline not found" if no recent builds exist. This is not an error.

## Execution

Run all independent queries in parallel to minimize latency. Group related queries:

**Batch 1 (auth/setup):**

- Atlassian resources + user info
- GitHub user info

**Batch 2 (data gathering):**

- Jira tickets
- GitHub PRs (authored + review requests)
- Glean searches (calendar, Slack, email, Confluence)
- Rollbar top items
- CircleCI status

## Output Format

Present results in this structure:

```markdown
## Today's Calendar (Day Month Date)

| Time  | Event      | Notes                         |
| ----- | ---------- | ----------------------------- |
| HH:MM | Event name | Cancellation/location/context |

---

## Slack Activity - Needs Attention

Summarize active threads and conversations needing attention.

**Prioritize and clearly flag:**

- Questions directed at the user awaiting response
- Active discussions where user's input was requested
- Blockers or decisions waiting on user

Mark conversations as "(Awaiting Response)" when the user was asked something and hasn't replied.

---

## Your Open PRs

### Ready for Review/Testing

PRs that are not drafts and are awaiting review or in testing:

| PR  | Title | Jira | Status |
| --- | ----- | ---- | ------ |

### Draft PRs

Work in progress. List with links and associated Jira tickets.

| PR  | Title | Jira |
| --- | ----- | ---- |

---

## PRs Needing Your Review

| PR  | Author | Title |
| --- | ------ | ----- |

---

## Jira Summary

### By Status

Group tickets by workflow state:

- Verified / Ready for Release
- In Testing
- In Progress
- Blocked
- Backlog/Planned

Include ticket key, summary, and priority indicators.

---

## Rollbar Alerts

List any active/recent errors in production that may need attention.

---

## CI/CD Status

Report any failing builds or pipelines.

---

## Recent Confluence Activity

List recently updated pages relevant to user's work.

---

## Suggested Focus

Based on gathered data, suggest 2-4 priority items in order of urgency:

1. **Conversations awaiting your response** - people are blocked waiting for you
2. **Items ready for release** - verified work that can ship today
3. **Blocked items** that may need unblocking actions
4. **Upcoming meetings** to prepare for (especially 1:1s)
```

## Handling Missing Data

If a source is unavailable or returns no data:

- Skip that section silently if empty
- Note connection issues only if the MCP fails entirely
- Never fabricate or assume data

## Follow-up

After presenting the briefing, the user may ask to:

- Elaborate on any specific item
- Take action on a ticket or PR
- Get more details about a meeting or thread

Handle these as normal conversation continuations.
