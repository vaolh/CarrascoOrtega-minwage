#################################################
############### Import Modules ##################
#################################################

import os
import warnings
import numpy as np
import pandas as pd
import geopandas as gpd
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors
from matplotlib.patches import Patch

warnings.filterwarnings("ignore", category=FutureWarning)

### REPLICATION FILE: sum-mapgini
### PYTHON VERSION: 3.10+
### AUTHORS: Matías Carrasco, Victor Ortega Le Hénanff
### DATE: 2026-03-03

#################################################
################ Configuration ##################
#################################################
plt.rcParams.update({
    "font.family": "serif",
    "axes.unicode_minus": False,
    "figure.dpi": 150,
})

#################################################
##################### Paths #####################
#################################################
OUTDIR   = os.path.join(os.path.dirname(__file__), "..", "..", "paper", "figures")
CACHEDIR = os.path.join(os.path.dirname(__file__), "..", "..", "data", "source", "gadm")
SHP_CACHE = os.path.join(CACHEDIR, "gadm41_MEX_1.json")
os.makedirs(OUTDIR, exist_ok=True)


#################################################
############## Download Shapefile ###############
#################################################
def get_mexico_shapefile():
    """Return a GeoDataFrame of Mexican states (admin level 1)."""
    if os.path.exists(SHP_CACHE):
        return gpd.read_file(SHP_CACHE)

    url = "https://geodata.ucdavis.edu/gadm/gadm4.1/json/gadm41_MEX_1.json"
    print(f"Downloading Mexico state shapefile from GADM …")
    gdf = gpd.read_file(url)
    gdf.to_file(SHP_CACHE, driver="GeoJSON")
    print(f"  Cached to {SHP_CACHE}")
    return gdf


#################################################
############# Weighted Gini Coeff ###############
#################################################
def weighted_gini(values, weights):
    """Compute the Gini coefficient with survey weights."""
    mask = np.isfinite(values) & np.isfinite(weights) & (weights > 0) & (values > 0)
    v, w = values[mask], weights[mask]
    if len(v) < 2:
        return np.nan
    sorter = np.argsort(v)
    v, w = v[sorter], w[sorter]
    cumw = np.cumsum(w)
    total_w = cumw[-1]
    # Weighted Gini: G = (2 * sum(w_i * rank_i * y_i)) / (total_w * sum(w_i * y_i)) - 1
    rank = (cumw - w / 2) / total_w  # midpoint ranks
    numerator = np.sum(w * rank * v)
    denominator = np.sum(w * v)
    return 2 * numerator / denominator - 1


#################################################
################## Load Data ####################
#################################################
print("Loading enigh-year.dta …")
input_path = os.path.join(os.path.dirname(__file__), "..", "..", "data", "clean", "enigh", "enigh-year.dta")
df = pd.read_stata(input_path)

# Ensure numeric year
df["year"] = pd.to_numeric(df["year"].astype(str), errors="coerce").astype(int)

# Compute state-level Gini for first and last year
year_start, year_end = 2016, 2024
gini_rows = []
for yr in [year_start, year_end]:
    sub = df.loc[df["year"] == yr]
    for ent_name, grp in sub.groupby("ent_name"):
        g = weighted_gini(grp["ictpc"].values, grp["factor"].values)
        gini_rows.append({"ent_name": ent_name, "year": yr, "gini": g})

gini_df = pd.DataFrame(gini_rows)
gini_start = gini_df.loc[gini_df["year"] == year_start].set_index("ent_name")["gini"]
gini_end   = gini_df.loc[gini_df["year"] == year_end].set_index("ent_name")["gini"]
gini_change = (gini_end - gini_start).reset_index()
gini_change.columns = ["ent_name", "gini_change"]

print(f"Gini change {year_start}→{year_end}: "
      f"min={gini_change['gini_change'].min():.4f}, "
      f"max={gini_change['gini_change'].max():.4f}")


#################################################
############### Load Shapefile ##################
#################################################
print("Loading Mexico shapefile …")
gdf = get_mexico_shapefile()

# Match state names — GADM uses NAME_1
merged = gdf.merge(gini_change, left_on="NAME_1", right_on="ent_name", how="left")

# Manual fallback for common mismatches
if merged["gini_change"].isna().sum() > 5:
    # Try stripping accents for a fuzzy match
    import unicodedata
    def strip_accents(s):
        return "".join(c for c in unicodedata.normalize("NFKD", s)
                       if not unicodedata.combining(c))
    gdf["name_ascii"] = gdf["NAME_1"].apply(strip_accents)
    gini_change["name_ascii"] = gini_change["ent_name"].apply(strip_accents)
    merged = gdf.merge(gini_change, on="name_ascii", how="left")


#################################################
################ Discrete Bins ##################
#################################################
def make_bins(vals, nbins=5):
    """Quantile-based bin edges, with fallback to equal-width."""
    quantiles = np.linspace(0, 100, nbins + 1)
    bins = np.unique(np.percentile(vals, quantiles))
    if len(bins) < nbins + 1:
        vmin, vmax = vals.min(), vals.max()
        bins = np.linspace(vmin if vmin != vmax else vmin - 0.5,
                           vmax if vmin != vmax else vmax + 0.5,
                           nbins + 1)
    return bins


vals = merged["gini_change"].dropna().values
bins = make_bins(vals, nbins=5)
ncolors = len(bins) - 1

#################################################
################ GnBu Colormap ##################
#################################################
CMAP = matplotlib.colormaps["GnBu"]
sample_pts = [0.15, 0.33, 0.52, 0.70, 0.82]
colors = [CMAP(sample_pts[j]) for j in range(min(ncolors, len(sample_pts)))]
cmap_disc = mcolors.ListedColormap(colors)
norm = mcolors.BoundaryNorm(bins, cmap_disc.N)


#################################################
##################### Plot ######################
#################################################
def _fmt(v):
    return f"{v:.3f}"


fig, ax = plt.subplots(1, 1, figsize=(12, 10))

merged.plot(
    column="gini_change",
    ax=ax,
    legend=False,
    cmap=cmap_disc,
    norm=norm,
    edgecolor="white",
    linewidth=0.5,
    missing_kwds={"color": "#f0f0f0"},
)

# Interval-notation legend (plotmaps.py style)
legend_patches = []
for j in range(ncolors):
    lo_v, hi_v = bins[j], bins[j + 1]
    if j == 0:
        label = f"[{_fmt(lo_v)}, {_fmt(hi_v)}]"
    else:
        label = f"({_fmt(lo_v)}, {_fmt(hi_v)}]"
    legend_patches.append(
        Patch(facecolor=colors[j], edgecolor="none", label=label)
    )

leg = ax.legend(
    handles=legend_patches,
    loc="lower left",
    fontsize=13,
    title="Gini Change",
    title_fontsize=14,
    frameon=False,
    handlelength=2.0,
    handleheight=2.0,
    handletextpad=0.5,
    labelspacing=0.08,
)
leg._legend_box.align = "left"

ax.set_axis_off()
ax.set_xlim(-118, -86)
ax.set_ylim(14, 33)

outpath = os.path.join(OUTDIR, "sum-gini-state-change.png")
fig.savefig(outpath, dpi=150, bbox_inches="tight", facecolor="white")
plt.close(fig)
print(f"\nDone — saved {outpath}")
