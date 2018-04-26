#!/usr/bin/env python 

import matplotlib.pyplot as plt

def map_format(ax, on = False):

    plt.subplots_adjust(top = 1, bottom = 0, right = 1, left = 0, hspace = 0, wspace = 0)
    plt.margins(0,0)
    ax.xaxis.set_major_locator(plt.NullLocator())
    ax.yaxis.set_major_locator(plt.NullLocator())

    if not on:
        ax.set_axis_off()
        ax.set_axis_on()
        for a in ["bottom", "top", "right", "left"]:
            ax.spines[a].set_linewidth(0)

    return ax



import pandas    as  pd
import geopandas as gpd
from glob import glob

gdf = gpd.read_file("data/tracts.geojson")
gdf.geoid = gdf.geoid.astype(int)
gdf.set_index("geoid", inplace = True)

sdf = gdf.dissolve((gdf.index // 1000000000))
sdf = sdf.set_geometry(sdf.boundary)
sdf = sdf[sdf.index.isin([17, 18, 19, 27, 55])]

for f in glob("test_*.csv"):

  print(f)
  df = pd.read_csv(f, names = ["geoid", "cost"], index_col = "geoid", header = None)

  # df = df[(df.index // 1000000) == 17031]
  
  merged = gdf.join(df, how = "inner")
  ax = merged.plot(column = "cost", cmap = "coolwarm", vmin = 0, vmax = 4, 
                   legend = True, figsize = (5, 5))
  map_format(ax)

  sdf.plot(color = "white", linewidth = 0.5, ax = ax)

  ax.figure.savefig(f.replace('csv', 'png'), bbox_inches='tight', pad_inches = 0.3, dpi = 300)
  ax.figure.savefig(f.replace('csv', 'pdf'), bbox_inches='tight', pad_inches = 0.3, dpi = 300)

  plt.close("all")


