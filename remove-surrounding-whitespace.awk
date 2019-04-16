#!/usr/bin/awk -f

{q=p;p=$0}NR>1{print q}END{ORS = ""; print p}