#!/usr/bin/env python

from simpledbf import Dbf5
import pandas as pd

dbf = Dbf5("t_103113_1.dbf")
phys1 = dbf.to_dataframe()
phys1.rename(columns = {"TG_DOC" : "doc"}, inplace = True)
phys1["geoid"] = (phys1.COUNTY + phys1.TRACT).astype(int)
phys1 = phys1[phys1.STATE.astype(int).isin([17, 18, 19, 26, 27, 29, 55])]
phys1 = phys1[["geoid", "doc"]]

dbf = Dbf5("t_103113_2.dbf")
phys2 = dbf.to_dataframe()
phys2.rename(columns = {"TP2I1" : "pop"}, inplace = True)
phys2["geoid"] = (phys2.COUNTY + phys2.TRACT).astype(int)
phys2 = phys2[["geoid", "pop"]]

phys = pd.merge(phys1, phys2, how = "inner")
# phys.set_index("geoid", inplace = True)

phys.astype(int).to_csv("doc_pop.csv", index = False)

