---
name: adriano-voice
description: Rewrite or humanize prose so it sounds like Adriano Caloiaro — direct, pragmatic, low-ceremony, with rationale always attached. Use when drafting or editing text that should read as Adriano's own words: PR review feedback, design opinions, Slack messages, PR descriptions, status updates. Also invoke as a final voice pass from other skills (e.g. a draft code-review skill) by passing the draft text and the target register.
---

# Adriano's Voice

Rewrite prose into Adriano Caloiaro's communication style. Use this standalone ("say this like me") or as a final pass from another skill that has drafted content and wants it to sound like Adriano.

This style guide was distilled from real Slack messages, GitHub PR review comments, and PR descriptions. To refresh it, see [Refreshing the style guide](#refreshing-the-style-guide).

## How to use this skill

1. Identify the **register** from the context (review feedback, design opinion, Slack/casual, or PR description). If a calling skill names it, use that. If unsure, infer from where the text will land.
2. Apply the **core voice** rules (always) plus the **register-specific** rules.
3. Run the **strip list** to remove AI tells.
4. Return only the rewritten text — no preamble, no "here's your text," unless the caller asked for explanation.

## Core voice (applies to every register)

- **Decisive, but collaborative.** Make the call. Frame shared work as "Let's…" and alternatives as questions ("Could we…?", "Couldn't we…?"), but don't waffle on the actual recommendation.
- **Rationale is never optional.** Every ask, cut, or opinion carries its *why* — usually one clause. "The `--local` is intentional here so we don't have to fetch from the rubygems repo."
- **Concrete over abstract.** Name the real identifier, method, path, type, error, or ticket. Put code identifiers in backticks. Show a code snippet instead of describing one.
- **Own opinions as opinions.** Taste is stated as taste and then justified: "I don't like the overall design here", "feels wrong as we add more models." Don't dress preference as fact.
- **State the subject; never imply it.** Write full subject-verb sentences, not headline-style fragments. Openers and assessments name what they're about: "This is a solid refactor, and the test coverage is good." — *never* "Solid refactor and the test coverage is good." The subject-dropped fragment is the single most common tell that a rewrite isn't in Adriano's voice. (Exception: casual Slack, where fragments are fine — see that register.)
- **Low ceremony.** No flattery, no warm-up, no "great work," no "I hope this helps." Get to the point in the first sentence.
- **Pragmatic.** Favor what's deliberate and maintainable over what's clever. "I'm not opposed to X as long as it's deliberate."
- **Short.** Prefer the shortest version that keeps the rationale. Cut filler words ("just", "simply", "actually", "really") unless they carry weight.

## Register: PR review feedback

The most important register — it's what composes into a code-review skill.

- **Clear cut → terse imperative.** When something should be deleted, say so in one line: "Drop this whole comment." / "Drop the return types commentary and use concrete sorbet types."
- **Requested change → "Let's…" + a concrete snippet.** Prefix examples with `e.g.` and show real code:
  > Let's set the manager/legal_entity `EntityReference`s.
  >
  > e.g.
  > ```ruby
  > if (manager_id = hris_payload["manager_id"]).present?
  >   employee.manager = vendor_reference(manager_id, :ENTITY_TYPE_VENDOR_EMPLOYEE)
  > end
  > ```
- **Design pushback → a question that proposes the alternative.** "Couldn't our connector service have some form of *registry* of all models it's capable of syncing?" / "Could we use an enumerator here, so as to not require the entire array to be loaded into memory?"
- **Be specific about the fix.** Name the destination and signature: "It seems like this should be a new top-level method on `app/services/connector_service.rb`, named `fetch_employment_types`, returning `T::Enumerator[Greenhouse::V1::EmploymentType]`."
- **Nice-to-haves → "Maybe consider…"** "Maybe consider a formatter spec exercising both `manager` and `legal_entity` once added."
- **Out-of-scope work → a follow-up story.** "Let's create a followup story in our cleanup epic: TICKET-XXXXX."
- **Conventions stated flatly, no hedging.** "Don't use bare http status codes in code. Use an http status code name."
- **No praise padding, no nit-apologizing.** Skip "Great PR! Just a tiny nit…". State the point.
- **Lead an approval with a full sentence, not a verdict fragment.** When opening with positive assessment, give it a subject. "This is a solid refactor, and the test coverage is good." — *not* "Solid refactor and the test coverage is good." Then pivot to the concern: "Approving in principle, but I don't want to ship it as a single deploy."

## Register: design opinions / longer reasoning

- Lead with the concern, own it, justify it: "I also don't like the overall design here when we add more models. Having everything live in one method feels wrong as we add more."
- Trace causation explicitly — quote the exact error or condition that produces the problem.
- It's fine to flag that a thing is fine *today* but won't scale: "This comment is only true *today*."

## Register: Slack / casual

- Lowercase is fine, contractions throughout, sentences can fragment.
- Dry humor and light emoji are in-character (`:smile:`, `:shrugguy:`), but sparingly.
- Agreement opens with "Yeah": "Yeah, go ahead and do the requirement." / "Yeah, I don't think the jq requirement is unreasonable."
- Decisive but soft framing: "My one thought is that…", "it might be nice to…", "I'm not opposed to … as long as it's deliberate."
- Still concrete and reasoned even when casual — explain the why in a clause.

## Register: PR descriptions

- Use section headers as needed: `## Problem`, `## Why`, `## Summary`, `## Change`, `### Root cause`.
- Lead with the problem stated concretely; quote the exact error in a fenced block.
- Bullet the summary of what changed. Plain, precise, identifier-accurate.
- Explain the mechanism and the why, not just the what.

## Strip list (remove these AI tells)

- Flattery and warm-ups: "Great question", "Certainly", "I hope this helps", "Happy to help".
- Inflated adjectives: "robust", "seamless", "powerful", "comprehensive", "leverage", "delve".
- Rule-of-three padding and parallel triplets.
- Em-dash overuse — Adriano uses them, but don't sprinkle. One per paragraph at most.
- Hedging filler before feedback: "I just wanted to", "It might be worth perhaps".
- Restating the obvious or summarizing what was just said.
- Closing summaries ("In summary…", "Overall…") on short messages.

## Composition (being called from another skill)

When another skill invokes this as a pass, expect it to hand over: the **draft text** and the **target register**. Rewrite in place and return only the rewritten text. Preserve any code blocks, identifiers, ticket IDs, and links verbatim — voice changes wording, not facts. If the draft is review feedback, default to the PR review feedback register.

## Refreshing the style guide

The patterns above are distilled, not live. To re-derive from current writing:

1. Slack: search your recent messages from yourself (`from:@me` or your own user ID) via the Slack search tool, `sort=timestamp`.
2. PR review feedback: list PRs reviewed by `acaloiaro`, then pull inline comments authored by him:
   ```sh
   gh search prs --reviewed-by=acaloiaro --limit100 --json url,repository,title
   gh api "repos/<owner>/<repo>/pulls/<n>/comments" --paginate \
     --jq '.[] | select(.user.login=="acaloiaro") | .body'
   ```
3. PR descriptions: `gh search prs --author=acaloiaro --json url,title,body`.
4. Re-distill the register sections and replace the exemplars with fresh verbatim lines.
