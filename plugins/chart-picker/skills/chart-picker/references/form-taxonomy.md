# Chart form taxonomy

Nine families, grouped by the question a chart is meant to answer. Pick the family from the question first, then the specific type from the notes below — the notes carry the pitfalls that actually cause bad charts.

## Deviation
Emphasises +/- variation from a fixed reference point (zero, a target, a long-run average), or sentiment (positive/neutral/negative).

- **Diverging bar** — a standard bar chart that handles both negative and positive magnitude around a shared baseline.
- **Diverging stacked bar** — good for survey-style sentiment (disagree/neutral/agree) where each response option gets its own segment on either side of neutral.
- **Spine chart** — splits a single value into two contrasting components (e.g. male/female breakdown of a total).
- **Surplus/deficit filled line** — a shaded area between a series and a baseline (or between two series), useful when the balance itself is the story.

## Correlation
Shows the relationship between two or more variables. Readers tend to assume causation even when a chart only shows correlation — be mindful of that in labelling/framing.

- **Scatterplot** — the standard way to show the relationship between two continuous variables. Watch for overplotting; switch to a density heatmap or 2D histogram once points overlap enough that individual dots stop being informative.
- **Bubble chart** — extends a scatterplot to three numeric variables via marker size. Always scale the bubble's **area**, never its diameter/radius, to the value — scaling by diameter makes a value twice as large look four times bigger. Limit the number of points and use transparency once overlap becomes common.
- **Connected scatterplot** — shows how the relationship between two variables has changed over time by connecting points in sequence.
- **Column + line (dual encoding)** — an amount (columns) plotted against a rate (line) on a shared time axis. Use with care: pairing two series with different, unrelated units on one chart (especially with two y-axes) is easy to misread — only do it when the relationship between the two is itself the point.
- **XY heatmap** — a grid coloured by a value across two categorical axes; effective for showing fine differences in amounts across many category combinations.

## Ranking
Use when an item's position in an ordered list matters more than its absolute or relative value.

- **Ordered bar/column** — sort by value rather than alphabetically unless the categories have an intrinsic order (e.g. days of the week) — sorted bars are far easier to scan than unsorted ones.
- **Dot strip plot / dot plot** — a space-efficient way to lay out ranks across many categories without the visual weight of full bars.
- **Slope chart** — ideal for showing how rank or value changed between two points in time; keeps to 2–3 points before it gets busy.
- **Bump chart** — shows changing rankings across more than two time points; for large datasets, group lines by colour rather than trying to label every one.
- **Lollipop chart** — draws more attention to the endpoint value than a plain bar/column while still preserving rank and magnitude.

## Distribution
Shows the values in a dataset and how often they occur; shape and skew reveal concentration or inequality.

- **Histogram** — the standard way to show a statistical distribution. Keep bar gaps small so the overall shape reads clearly; bin width matters more than exact bar count.
- **Boxplot** — summarises a distribution by its median and spread; good for comparing many groups side by side.
- **Violin plot** — like a boxplot but shows the actual shape of the distribution; use it when a distribution is multi-modal or otherwise not well summarised by a median and a box.
- **Population pyramid** — a back-to-back histogram, classically age/sex, for comparing two mirrored distributions; group into wider bins for large datasets.
- **Barcode / dot strip plot** — shows every individual value in a distribution rather than a summarised shape; useful when individual outliers matter, becomes cluttered once many values share the same position.

## Change over time
Gives emphasis to trends, whether short intraday movements or extended multi-year series.

- **Line chart** — the standard way to show a changing time series. Cap around five lines before it turns into an unreadable tangle unless the lines are well-separated in value. Never smooth a line between real data points — a smoothed curve implies measurements that don't exist and distorts how steep or sudden a change actually was.
- **Column/bar over time** — works well when there's a single series and/or long category labels; for irregular data, discrete markers communicate the actual measurement points better than a continuous line.
- **Column + line timeline** — an amount (columns) shown together with a rate (line) over time; same dual-encoding caution as under Correlation.
- **Area chart** — combines a line and a bar chart to show one or more series changing over time, with the area between the line and baseline shaded. A stacked area chart tracks both the total and each series' contribution to it, but makes it hard to read how any single component changed in isolation — use it when the total matters as much as the parts.
- **Sparkline** — a small, unlabeled line built to sit inline with text or in a table row; shows only the shape of change. Pair it with a start/end or min/max statistic next to it since it carries no axis labels of its own.
- **Slope chart, connected scatterplot, calendar heatmap, candlestick** — specialised variants for a two-point comparison, a paired time series, a periodic (daily/weekly/monthly) pattern, and day-to-day open/close/high/low data respectively.

## Magnitude
Shows size comparisons — usually counted quantities, not rates or percentages.

- **Column/bar** — the standard way to compare sizes across categories. The axis must start at zero; a truncated axis exaggerates differences and misleads.
- **Grouped/paired column or bar** — compares two categorical variables at once, using position for one and colour for the other.
- **Stacked column/bar** — adds decomposition on top of a magnitude comparison, but makes both the primary totals and any single sub-segment (beyond two or three) harder to compare precisely. Order sub-categories from largest to smallest unless they have an intrinsic order.
- **Isotype / pictogram** — represents whole-number counts as repeated icons; never slice off part of an icon to represent a decimal or fraction.
- **Radar chart / parallel coordinates** — space-efficient for comparing many variables at once, but only useful when the variables are ordered so that the resulting shape is itself meaningful to the reader, not an arbitrary arrangement.

## Part-to-whole
Shows how a single entity breaks down into its component parts. If only the components' sizes matter — not their relationship to a whole — use Magnitude instead.

- **Stacked column/bar** — simple, but hard to read accurately once there are more than a handful of components.
- **Pie / donut** — appropriate only when there is a genuine whole divided into distinct parts, and the point is each slice's share of that whole rather than comparing slices to each other. Keep it to about five slices or fewer; order slices largest-to-smallest starting from a cardinal direction (12 o'clock reads most intuitively) unless the categories have an inherent order. A donut is the same chart with the centre freed up for a summary statistic.
- **Treemap** — for large hierarchical datasets under space constraints, when a quick high-level read of similarities and anomalies across many nodes matters more than precise pairwise comparison, and when drill-down into sub-levels is useful.
- **Waterfall** — shows how a starting value is transformed by a sequence of positive and negative contributions into an ending value.
- **Marimekko/mosaic, Voronoi, arc/gridplot, Venn** — less common part-to-whole layouts for two-dimensional proportions, spatially subdivided proportions, seat-style counts, or set overlap. Reach for these deliberately for the specific shape of data they suit, not as a default.

## Spatial
Use only when precise location or a genuinely geographic pattern is the point — not simply because the data happens to have a location field.

- **Choropleth map** — colour regions by a rate or ratio, never a raw total; a large region will otherwise dominate the map purely because of its size, not its value.
- **Proportional symbol map** — plots totals as sized markers; better suited than a choropleth when the value really is a total.
- **Flow map, dot density map, heat map, cartogram** — for movement between places, individual event locations, spatial intensity, and area distorted to represent a value, respectively.

## Flow
Shows the volume or intensity of movement between states, stages, or locations.

- **Sankey diagram** — a many-to-many mapping between two domains, or multiple paths through a sequence of stages; link width encodes volume.
- **Waterfall** — sequential positive/negative contributions to a running total (see also Part-to-whole).
- **Chord diagram / network diagram** — relationships or connection strength between entities. Powerful but easy to overload visually — keep the node count low enough that the diagram stays legible rather than becoming a "hairball."
