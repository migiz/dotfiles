# Auto Title agent icons: contribution plan

Research date: 2026-09-13. A local preview was subsequently implemented at the
user's request. The accepted local format is `[num] icon  title`, with exact
` | mikko` suffix removal, brighter sidebar text, and a separate heavier-icon
font recipe. No upstream issue or PR has been submitted. The initial research
and proposed contribution sequence below remain a plan, not an approved PR scope.

## Recommendation

Propose opt-in agent identity icons inside Auto Title's existing naming pipeline.
Use released Nerd Fonts 3.5+ brand glyphs when available, recognizable Unicode
symbols where there is useful precedent, and unique short text marks where a
single glyph would be an unsupported guess. Keep identity separate from agent
status and from the underlying model provider.

Treat the mapping below as a review shortlist, not an approved implementation.
Fifteen agents have symbol candidates; eight have provisional text marks. The
weaker symbols still need visual review and maintainer input. Distinctness alone
is not sufficient: an arbitrary unique pictogram can be harder to learn than a
short recognizable name.

## Coverage and identifiers

The installed Herdr 0.9.0 CLI lists 23 kinds. These match the current canonical
labels in [Herdr's detection source](https://github.com/herdrdev/herdr/blob/master/src/detect/mod.rs).
Use `agy`, `qodercli`, and `mastracode` as lookup keys, not their display names.
[Herdr's agent documentation](https://herdr.dev/docs/agents/) distinguishes
integration support from detection and marks Gemini and Cline less thoroughly
tested. An icon does not promise lifecycle integration support.

## Candidate mapping

`cod-*` and `md-*` below refer to Nerd Font glyph names. Ordinary characters
include codepoints so font substitution in a browser cannot hide the selection.

| Agent key | Candidate | Basis |
| --- | --- | --- |
| claude | cod-claude, U+EC82 | Released brand glyph |
| codex | cod-openai, U+EC81 | Released vendor glyph |
| cursor | cod-cursor, U+EC5C | Released brand glyph |
| copilot | cod-copilot, U+EC1E | Released brand glyph |
| gemini | ✦ U+2726 | Example; brand resemblance |
| pi | π U+03C0 | Multiple terminal tools |
| omp | ⌥ U+2325 | workmux default |
| agy | ⋂ U+22C2 | workmux default |
| opencode | ▣ U+25A3 | agents.tmux default |
| grok | 𝚇 U+1D687 | tmux-agent-tabs display |
| kiro | md-ghost, U+F02A0 | Mascot-based proposal |
| droid | md-robot, U+F06A9 | Provisional metaphor |
| amp | md-flash, U+F0241 | Provisional metaphor |
| hermes | ☤ U+2624 | Provisional metaphor |
| kimi | md-moon_waxing_crescent | Mascot-based proposal |
| devin | DV | Provisional text mark |
| cline | CL | Provisional text mark |
| mastracode | MC | Provisional text mark |
| kilo | KL | Provisional text mark |
| qodercli | QD | Provisional text mark |
| qwen | QW | Provisional text mark |
| maki | MK | Provisional text mark |
| muse | MU | Provisional text mark |

The Kimi moon candidate is U+F0F67. Use `?` as the unknown-agent fallback if
Droid gets the robot; otherwise every new agent would visually resemble Droid.
This fallback choice is proposed, not current behavior.

### Why these choices, and where they remain weak

- Claude: replace the existing generic asterisk with the actual available glyph.
- Codex: replace the generic robot with the OpenAI knot. This is a provider mark,
  not proof of a Codex-specific logo; the custom-font option below is more exact.
- Gemini: a four-point sparkle resembles its identity more closely than Google G.
  Its use in agents.tmux is an authoring example, not a shipped default.
- Pi and OMP: retain their distinction. Pi's π has several precedents; OMP's ⌥
  has a shipped precedent but can read as the Option key on macOS. A boxed Pi
  (`md-pi_box`, U+F0400) is an alternative to preview, not an established standard.
- OpenCode: the boxed square is a compact approximation, not the official logo.
- Grok: mathematical monospace X is a precedent, but can be confused with X the
  social network. Compare with plain X visually before settling it.
- Kiro: prefer a ghost over the unrelated diamond used by tmux-pane-tree.
- Kimi: moon imagery has a mascot precedent; KM would be more explicit than a
  moon if the current brand mark is the priority. The custom font uses K+dot.
- Hermes: the caduceus is a name-based metaphor and may look medical. A feather
  (`md-feather`, U+F06D3) or HM are alternatives; this is not settled.
- Droid and Amp: robot and lightning are intuitive but not verified brand logos.
- Remaining text marks are deliberately distinct. Do not claim these were found
  in other projects or are official icons. Their custom-font logos, where
  available, are better references for a future higher-fidelity option.

[Code Island's own mascot documentation](https://github.com/rifqiakrm/code-island/blob/main/CLAUDE.md#mascots)
uses Kiro ghost, Kimi lunar orb, Hermes winged helmet, Factory industrial bot,
and Qwen gem. These are graphical mascots, not terminal glyph defaults. Their
shapes inform proposals without establishing a terminal icon standard.

## Font compatibility

Compared released [Nerd Fonts 3.4.0 glyph metadata](https://github.com/ryanoasis/nerd-fonts/blob/v3.4.0/glyphnames.json)
with [3.5.0 metadata](https://github.com/ryanoasis/nerd-fonts/blob/v3.5.0/glyphnames.json)
and [3.5.1 metadata](https://github.com/ryanoasis/nerd-fonts/blob/v3.5.1/glyphnames.json).
Claude EC82, OpenAI EC81, and Cursor EC5C are absent in 3.4.0 and present in
3.5.0/3.5.1. Copilot EC1E is present in all three. Recommend documenting 3.5+
for the brand-glyph set. The latest release checked was 3.5.1.

Do not infer rendering support from the server's installed fonts: the terminal
may run on a different machine. Keep icons opt-in and make any text fallback or
per-agent overrides explicit. Avoid color-dependent differentiation, emoji
presentation sequences, or assuming every glyph occupies one terminal column.

Before calling choices final, preview the shortlist at actual tab sizes using
Nerd Font Mono variants on Linux and macOS, in dark/light themes and over SSH.
Measure rendered widths alongside Go's uniseg results. Check clipping, baseline,
legibility, lookalike pairs, tiny budgets, and adjacent icons/numbers. Native
terminal visual verification has not been performed during this planning pass.

## Contribution process and upstream interaction

The current [CONTRIBUTING.md](https://github.com/kryptamine/herdr-auto-title/blob/main/CONTRIBUTING.md)
requires an issue first for non-trivial changes and agreement on scope before
implementation. Later work should branch from main, use Conventional Commits,
include behavior tests and architecture rationale, and pass `make check` with
race-enabled tests. PRs are rebased; release/version files stay untouched.

Upstream main was `675d6f4e3cfcbcc5bd9d548dfeb0c1f8e3148c3c` when checked.
The current open work is [issue 64](https://github.com/kryptamine/herdr-auto-title/issues/64)
and [PR 65](https://github.com/kryptamine/herdr-auto-title/pull/65), for scrolling
long titles. PR head checked: `6ed42a68da8ab2f4a7ea5c0b79c6eec559fe496d`.
No separate icon proposal appeared in the current open issue/PR list; this is
not a claim that all historical discussions were searched.

PR 65 removes Numbered and introduces a single Fitted stage. If adopted, our
current outer Iconed truncation would need redesign: reserve width for the
static icon and position together, then fit or scroll only the remaining title.
Confirm the maintainer's preferred integration point before porting our patch.

## Proposed sequence and exit criteria

1. Review icon policy and shortlist locally. Exit: agreed font requirement,
   provisional versus approved choices, and whether small per-agent overrides
   belong in the first proposal.
2. Open an issue after the user authorizes proceeding. Suggested title:
   `Optional agent icons in Auto Title's tab labels`. Explain the one-writer
   motivation, show examples and sources, list defaults, and ask how this should
   compose with PR 65. Exit: maintainer agrees on scope and fitting design.
3. Implement against current upstream, keeping icons disabled by default.
   Preserve the existing context-pane selection and a single naming writer.
   Avoid adding custom font installation, new agent detectors, model-provider
   inference, status animation, or unrelated process-icon expansion.
   Exit: reviewed canonical-agent mapping and preserved live/manual title behavior.
4. Validate all 23 identifiers, unknown agents, agent-before-process priority,
   focus changes, existing non-agent behavior, and disabled-mode equivalence.
   Cover Unicode widths and scrolling with a fixed icon/number prefix if PR 65
   lands. Run make check and native terminal visual checks.
   Exit: tests and visual evidence support the proposed behavior.
5. Submit one focused PR with issue reference, evidence, and required conventions.
   No issue, fork, PR, commit, push, or live config update is part of this plan.

## Comparative source evidence

No consistent cross-project icon standard emerged. Real terminal tools either use
Unicode approximations or short labels, reuse a generic Nerd Font glyph, or supply
a custom font containing brand marks. A product/provider logo and a coding harness
logo are not necessarily the same thing (Codex versus OpenAI; OMP versus Pi).

### Herdr Agent Icons: directly relevant, actual logos in a custom font

Verified commit `5a87c6ab4e3fe2e0605af4af52b0328082dc31ac`:
https://github.com/moneycaringcoder/herdr-agent-icons/blob/5a87c6ab4e3fe2e0605af4af52b0328082dc31ac/agent_icons.py#L16-L42

Mappings are Claude E1A0, Codex E1A1, OpenCode E1A2, OMP E1A3, Cline E1A4,
MastraCode E1A5, Kimi E1A6, Kilo E1A7, Maki E1A8. These are private-use slots
in its own `Herdr Harness Logos` TTF, NOT Nerd Font glyphs. Plain-text fallbacks
are C, AI, OC, OMP, CL, MC, KIM, KIL, MAK. These use current official mark
geometries from named upstream repositories, normalized to monochrome. Kimi and
Maki raster originals were redrawn; licensing and source commits are recorded:
https://github.com/moneycaringcoder/herdr-agent-icons/blob/5a87c6ab4e3fe2e0605af4af52b0328082dc31ac/assets/THIRD_PARTY_NOTICES.md

Reports a `harness_logo` pane metadata token, never renames tabs. Clears token for
uncovered agents instead of guessing. Ghostty setup explicitly maps E1A0–E1A8 to
custom font; auto mode checks Fontconfig on host, with text fallback when absent.
macOS users may need to choose font mode after verifying rendering. A custom font
is a meaningful extra installation and portability cost, not just another mapping.
https://github.com/moneycaringcoder/herdr-agent-icons/blob/5a87c6ab4e3fe2e0605af4af52b0328082dc31ac/README.md#L18-L40

### agents.tmux: distinct ordinary Unicode shapes

Verified shipped config commit `39bbd42ce88b5daaebe97d3a271aa1a57be03800`:
https://github.com/nikitaclicks/agents.tmux/blob/39bbd42ce88b5daaebe97d3a271aa1a57be03800/config.toml#L94-L150

Claude ◆ U+25C6; Copilot ◇ U+25C7; Pi π U+03C0; Cursor ⌶ U+2336;
OpenCode ▣ U+25A3; Codex ◈ U+25C8. No Nerd Font dependency for these. Gemini ✦
appears in the project's agent-authoring examples, but is NOT a shipped default:
https://github.com/nikitaclicks/agents.tmux/blob/39bbd42ce88b5daaebe97d3a271aa1a57be03800/AGENTS.md

### tmux-pane-tree: generic Nerd Font, distinct Unicode option

Verified commit `f1a688b08a8abf1de144b05ba188e16bb36faddc`:
https://github.com/sandudorogan/tmux-pane-tree/blob/f1a688b08a8abf1de144b05ba188e16bb36faddc/scripts/ui/sidebar_ui_lib/icon_config.py#L18-L96

Nerd Font theme maps Claude/Codex/OpenCode/Cursor/Pi/Kiro ALL to U+F0D70
(nf-md-face_agent according to project README). Unicode theme uses Claude ◎
U+25CE, Codex ⌘ U+2318, OpenCode ◌ U+25CC, Cursor ▣ U+25A3, Pi π U+03C0,
Kiro ◆ U+25C6. The reused symbols have conflicting meanings across projects.
Per-agent user overrides exist. Host-side font detection is explicitly a hint,
not proof that a remote client terminal can render the glyphs.

### tmux-agent-tabs: provider marks, not harness mapping

Verified commit `10cae9e6f804f1969ec1992b3e83b4f174cf39a2`:
https://github.com/jhickner/tmux-agent-tabs/blob/10cae9e6f804f1969ec1992b3e83b4f174cf39a2/scripts/usage#L560-L579

Claude ✻ U+273B (orange); Codex ◎ U+25CE (teal); Grok 𝚇 U+1D687
(white). These are ordinary Unicode approximations in provider usage display,
not Nerd Font or actual logo assets. Claude ✻ is also part of the project's
Claude-style spinner sequence; do not confuse a static identity with status.

### workmux: short labels where a trustworthy compact logo is unavailable

Verified commit `eb2867fd3c58aa85763968092777a3dcdb739386`:
https://github.com/raine/workmux/blob/eb2867fd3c58aa85763968092777a3dcdb739386/src/agent_identity.rs#L74-L94

Claude CC, Codex CX, OpenCode OC, Gemini G, Antigravity ⋂ U+22C2, Pi π,
OMP ⌥ U+2325, Kiro K, Vibe V, Copilot CP, Grok GK. Agent-specific icon/color
overrides supported. Good precedent for readable unique monograms as fallbacks,
not for treating arbitrary shapes as official branding.
https://workmux.raine.dev/guide/sidebar/customization/

### Excluded misleading match: ccmux

Inspected commit `75b7fd3743c5bf4f3915df4f60c83f161ab8842b`:
https://github.com/epilande/ccmux/blob/75b7fd3743c5bf4f3915df4f60c83f161ab8842b/src/lib/icons.ts

Its configurable Nerd Font/emoji/dot icons represent lifecycle states, not agent
identity. Do not cite those as evidence for agent-logo defaults.

## Planning implications (recommendations, not established facts)

- Prefer released standard-font brand glyphs where available (root independently
  verified Nerd Fonts 3.5.1 Claude/OpenAI/Cursor/Copilot inventory).
- For Gemini prefer recognizable four-point sparkle over generic Google G; Pi π
  has repeated direct precedent. OMP must remain distinguishable from Pi; ⌥ has
  actual workmux precedent, while its custom-font logo offers better identity.
- For remaining agents do not claim consensus. Explicitly label approximations,
  use unique short labels if no convincing glyph exists, allow per-agent override.
- Unknown-agent generic fallback is useful, but must not collide with a supported
  named agent's supposedly unique mark.
- A preview sheet of chosen glyphs next to agent names, in actual Linux/macOS
  terminal fonts at narrow tab widths, is necessary before calling choices final.
- Optional custom-logo font integration is a separate scope decision. Existing
  Herdr metadata-token plugin could be a future source; do not ship another
  independent tab-name writer.

## Provisional per-agent shortlist for parent synthesis

Observed standard-brand candidates (Nerd Fonts inventory verified separately by root):
Claude `cod-claude` U+EC82; Codex `cod-openai` U+EC81 (OpenAI vendor logo, not
Codex-specific mark); Cursor `cod-cursor` U+EC5C; Copilot `cod-copilot` U+EC1E.

Observed ordinary-Unicode choices in actual configs/code: Pi π U+03C0;
OMP ⌥ U+2325 (workmux); AGY ⋂ U+22C2 (workmux); OpenCode ▣ U+25A3
(agents.tmux); Grok 𝚇 U+1D687 (tmux-agent-tabs); Kiro ◆ U+25C6
(tmux-pane-tree). Gemini ✦ U+2726 is an authoring example, not a shipped default.
These should be described as recognisable substitutes, not official logos.

Possible inferred options needing visual/semantic review: Kimi K or KM (actual
mark contains K+dot); Droid a robot glyph; Amp a lightning glyph. Hermes caduceus
☤ U+2624 is a name-derived possibility but likely reads as medicine; a short HM
label is safer than presenting it as a well-supported choice. Maki's logo really
is cat-in-cup per source provenance, but a cat glyph is only an approximation.

Fallback shortlist for low-confidence agents: Devin DV, Cline CL, MastraCode MC,
Kimi KM, Hermes HM, Kilo KL, Qoder QD, Qwen QW, Maki MK, Muse MU. These are
proposed distinct labels, not discovered community standards. One could use
pictographic metaphors for all of them, but that would sacrifice evidence and
recognition for numerical coverage. A selectable override keeps this revisable.
