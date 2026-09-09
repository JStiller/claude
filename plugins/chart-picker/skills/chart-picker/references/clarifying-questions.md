# Clarifying only when needed

Three questions decide the chart form; two more shape the color. Try to answer all five from context before asking the person anything.

## The three form-deciding questions
1. **What concept is the reader trying to understand?** — which of the nine intent categories (deviation, correlation, ranking, distribution, change over time, magnitude, part-to-whole, spatial, flow) is the actual point of the panel?
2. **What's the data shape?** — how many variables, categorical vs. numeric vs. time series, and how many series/categories will realistically be plotted at once?
3. **Does change over time matter to the story**, or is a single snapshot the point?

## The two color-shaping questions
4. **Who's reading this, and how urgently?** — an ops/alerting audience scanning for a problem implies status-semantic color and a bias toward instant scannability; a management/report audience tolerates more categorical nuance, annotation, and narrative framing.
5. **Does this value need to be compared across other panels?** — if yes, the category→color mapping and the axis scale must be fixed once and reused identically everywhere that category appears, not re-derived per panel.

## Where to look for the answer before asking
- The title or description of the panel/dashboard/ticket being built.
- The underlying data source's fields — are they categorical, numeric, a rate, a count, a timestamp?
- The name of the folder/dashboard this panel will live in (an "Alerts" or "SLO" dashboard implies status color and magnitude/deviation forms; an "Executive Summary" implies different defaults).
- Earlier turns in the conversation — a described goal, a prior similar panel, a stated audience.
- A neighbouring panel already built for the same dashboard, which often fixes the pattern (color mapping, chart family) the new one should follow.

## The gate
Ask only when, after actually checking the sources above, question 1 or 2 remains genuinely ambiguous (e.g. "show me something useful about X" with no other signal), or when the answer to 4 or 5 would change the recommendation and there's truly no way to infer it. If the context already implies clear answers, proceed straight to picking the chart and color — do not ask out of habit or to be thorough.

## How to ask
When a gate does trigger, hand off to the `grill-me` skill rather than firing off a checklist:
- Go one question at a time, starting with whichever unknown blocks the most downstream decisions — usually concept (1), then data shape (2), then audience/comparability (4/5).
- State your best guess as a default with each question so the person can just confirm or correct it, instead of answering from a blank page.
- Stop as soon as the remaining unknowns are resolved — don't keep asking once there's enough to make a confident recommendation.
