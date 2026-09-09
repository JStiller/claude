# Translating a form family to a real tool

This mapping is intentionally generic and best-effort, not a maintained reference for any specific product. BI and observability tool UIs change between versions — always confirm the actual current panel/visualization options in whichever tool is in use rather than assuming a menu path from here.

| Form family | Typical native panel/visualization concept | Where the color job usually gets applied |
|---|---|---|
| Change over time, few series | Line / time-series panel | Per-series color assignment, usually a palette setting plus optional per-series overrides |
| Magnitude or ranking, categorical comparison | Bar/column panel (horizontal orientation for long labels) | Categorical palette; keep the field→color mapping fixed if the field recurs across panels |
| Part-to-whole | Stacked bar/column, or a dedicated pie/donut panel type if the tool offers one | Categorical palette for the segments; drop the pie/donut type once segment count grows past a handful |
| Distribution | Histogram or heatmap-style panel where available; otherwise a manually bucketed bar chart | Sequential palette if a heatmap; categorical if a bucketed bar |
| Single current value against a threshold | Stat / gauge / single-value panel | Status/semantic color via the tool's threshold or value-mapping feature — not a manually picked hex per value |
| Deviation from a baseline or target | Bar chart with a fixed reference line, or a diverging-bar-capable panel type | Diverging palette anchored on the reference value |
| Spatial | A map/geo panel, if the tool has native geographic support | Choropleth by rate/ratio; sized markers by total |
| Flow / relationship | Sankey or node-graph panel if the tool offers one; otherwise fall back to a table or a simplified magnitude chart | Categorical palette for node/flow groups |

Most BI and observability tools expose a palette, color-mapping, or threshold configuration at the panel-editor level — that is where the color job chosen via `color-guide.md` gets applied. If the target tool lacks a clean equivalent for the recommended chart family, say so explicitly and suggest the closest available panel type rather than silently downgrading the recommendation.
