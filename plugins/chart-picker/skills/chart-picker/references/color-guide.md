# Color methodology

Color is the last decision, not the first — it should express a "job" that the chosen chart form already implies, never be picked for its own sake.

## Two kinds of data, two families of palette

**Categorical (qualitative) data** — discrete items or groups with no intrinsic order (countries, products, teams). Use a qualitative palette:
- Balance lightness, hue, and saturation across the set so every color is roughly equally distinct from every other — the goal is that no two categories are confusable and none appears to outrank another just because it's darker or brighter.
- The more categories there are, the harder this gets. Once a palette would need more colors than a reader can hold in mind at a glance (roughly 8), stop adding hues — group the smallest categories into "Other," facet into multiple charts, or switch to a form that doesn't require one color per category (e.g. small multiples, or sorting/direct-labelling instead of color).
- Fix one order for the palette and always assign colors in that same order (first category always gets color 1, second always gets color 2, ...) instead of re-deriving assignments per chart. That consistency is what lets a viewer carry color meaning from one panel of a dashboard to the next.

**Numerical data** — use color as a low-to-high metaphor only when the axes alone don't already carry that information. Two scale shapes:
- **Sequential** — a single hue (or a few closely related hues) ramped from light to dark, light = low, dark = high. If a multi-hue sequential ramp is used, let *lightness* carry the magnitude message; reserve hue shifts for encoding a second, genuinely different proportional dimension, not for decoration.
- **Diverging** — two sequential ramps of different hues that share a light, near-neutral color at a meaningful midpoint (zero, a target, a baseline). The job is to emphasize the two extremes and de-emphasize the near-neutral middle, typically to compare a "below" and "above" state around that center.

## Status / semantic color
A small, fixed vocabulary (e.g. good / warning / serious / critical) reused identically everywhere it appears. Once red means "critical" and green means "good" anywhere in a dashboard, those two colors are reserved for that meaning and must not also double as arbitrary categorical colors elsewhere in the same interface — mixing the two creates false alarms or false reassurance. Don't build a status palette from scratch per dashboard; pick one fixed mapping and keep it everywhere.

## Don't repurpose colors that already mean something
A color that has a fixed meaning elsewhere in the product or brand (a specific "safety" color, a primary call-to-action color) should not be reused to encode arbitrary data values. Doing so creates an opportunity for the reader to misread a chart color as that other meaning.

## Accessibility
Roughly 8% of men and under 1% of women have some form of color vision deficiency, overwhelmingly red-green (reduced sensitivity to red = protan, to green = deutan; reduced blue sensitivity, tritan, is much rarer). Design and check every palette — categorical, sequential, or diverging — for the version of it a person with reduced red-green discrimination would actually see, not just for how it looks to normal (trichromatic) vision. Never encode meaning with a red/green pair alone; pair color with a second cue (position, direct label, icon, pattern) wherever the distinction matters.

## The distinguishability check
Before shipping any palette, verify that adjacent colors — neighbouring categorical hues, or adjacent steps of a sequential/diverging ramp — are perceptually distinct enough to tell apart at a glance, under both normal and color-deficient vision, and hold enough contrast against the chart's background (and enough text-on-color contrast for any labels drawn on top of a fill). As a rule of thumb: if two neighbouring colors are hard to tell apart on a quick look, the palette has one step too many — remove a step or a category rather than force it in. This matters in both a light and a dark presentation if the destination supports both; a palette validated only in light mode can silently fail in dark mode.
