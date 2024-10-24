US Inland Harvest
================
Matthew Robertson
2024-09-16

# Overview

This is the code accompanying Robertson et al. (Submitted) where we
estimated that inland recreational fisheries in the US harvest 16 - 43
times more fish than are reported to the FAO.

<img src="results_comparison_updated.png"/>

# Code purpose and order

This code is intended to allow readers/reviewers the ability to repeat
analyses in the paper.

1.  The first script to run is `Preparing_CreelCat_Data`. This script
    will load the csv files downloaded from the [CreelCat
    database](https://rconnect.usgs.gov/CreelCat/) and then prepare them
    following methods described in detail from [Robertson et
    al. (2024)](https://doi.org/10.1111/fme.12650) to be used in the
    CreelCatch model.

2.  The second script to run is `Downloading_NHD_Data`. This script will
    load NHD data from every state and format it to be used for
    projections in a later script.

3.  The third script to run is `Running_CreelCatch_Model`. This script
    will use the CreelCat data within the `CreelCatch` model to estimate
    parameters relating fishing effort and catch, which will be used to
    project national harvest.

4.  Finally, the last script is `Projecting_US_Harvest`. This script
    will use model outputs and the NHD data to project effort, catch,
    and harvest across waterbodies in the US.
