---
name: chart-picker
description: Decide which chart type and which color palette to use before building a dashboard panel or visualization — generic across BI/observability tools (Kibana, Grafana, New Relic, Datadog, or any other charting surface). Infers intent from context; asks only when the goal or audience is genuinely unclear.
when_to_use: Trigger whenever a chart, graph, panel, widget, or dashboard is being planned or built — "which chart type", "which color/palette", "dashboard panel", "visualization", "Kibana/Grafana/New Relic/Datadog panel", "how should I show/visualize X".
---

# Chart & Color Picker

A decision procedure for picking a chart type and a color scheme *before* touching any specific tool's UI. It's tool-agnostic by design — the same reasoning applies whether the destination is Kibana, Grafana, New Relic, Datadog, or something else entirely.

## Procedure

1. **Name the concept.** Which of the nine intent categories does the panel actually need to answer: deviation, correlation, ranking, distribution, change over time, magnitude, part-to-whole, spatial, or flow? Read `references/form-taxonomy.md` for what each category covers. Try to infer this from context first — a panel titled "error rate by service" is magnitude/ranking, "error rate over the last 24h" is change over time, "budget vs. actual" is deviation, and so on.

2. **Read the data shape.** How many variables, categorical vs. numeric vs. time series, and roughly how many series or categories will actually be plotted? This, together with the concept, narrows the family down to a specific chart type in `references/form-taxonomy.md` — including the pitfalls to avoid for that type (axis-zero rules, overplotting, smoothing, slice/series limits, etc.).

3. **Clarify only if genuinely unclear.** If the concept or the data shape can't be pinned down from context, or if the audience/urgency would change the recommendation and can't be inferred either, follow `references/clarifying-questions.md` and hand off to the `grill-me` skill to build shared understanding — one targeted question at a time, with a stated best guess as the default. If the context already makes the answer clear, skip straight past this step; don't ask out of habit.

4. **Pick the specific chart type.** From within the matched category in `references/form-taxonomy.md`, choose the type that fits the data shape and respect its listed constraints (e.g. a pie only works with a real whole and ~5 or fewer slices; a line chart caps around 5 series before it needs facetting; a bubble's size must scale by area, not diameter).

5. **Assign a color job.** Decide whether the color encodes categorical, sequential, diverging, or status/semantic information, then follow `references/color-guide.md` for how to build and validate that palette — balance and order for categorical sets, light-to-dark for sequential, a neutral midpoint for diverging, a fixed vocabulary for status colors, and a colorblind-safe distinguishability check in every case. Never reuse a color that already carries a fixed brand/UI meaning elsewhere.

6. **Translate to the target surface.** If a specific tool is named (or obvious from context), use `references/tool-mapping.md` to translate the chosen chart family and color job into that tool's native panel/visualization type and its palette/threshold configuration. If no tool is named, keep the recommendation tool-neutral and state it in terms any tool's panel editor would understand (chart family + color job), rather than guessing a specific product's menus.

7. **Sanity-check before finalizing.** Series/segment count within limits, axis starts at zero for magnitude comparisons, no gratuitous dual-axis pairing, no rainbow/unordered categorical palette, bubble area (not diameter) scaling, status colors used only for their fixed semantic meaning, palette checked for colorblind distinguishability.

## Output shape

State, briefly: the concept category, the chosen chart type and why, the color job and palette shape, and (if a tool is known) the concrete panel type + where color/threshold gets configured. Keep it actionable — this is a decision to act on, not a design essay.
