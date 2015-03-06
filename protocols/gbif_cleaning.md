GBIF data cleaning
==================

There has been ongoing discussion among all of the folks planning on using location data on how to best clean that data, deal with human impact, plantations, invasives, etc.
See comments in issue thread: https://github.com/Fireandplants/bigphylo/issues/1 and the email thread involving detailed all phylogeny group people.  The steps below are based on suggestions made by Sally, Caroline, Beth, Amy, Michelle, Dan and others.

Cleaning steps (in order)
-------------------------
1. Filter Location precision (lat/lon must have 2 decimal places).
2. Filter records in the ocean. 
3. Filter records within the 0.1 x 0.1 degree gride sell of the GBIF HQ, herbaria with >1,500,000 specimens, and all geopolitical centroids. 
4. Filter on landuse. Eliminate those records that fall in MODIS classes 12 and 13. URL: https://lpdaac.usgs.gov/products/modis_products_table/mcd12q1
5. Filter on human impact (method via Sally, Beth). Cutoff at 20. URL:  http://sedac.ciesin.columbia.edu/data/set/wildareas-v2-human-footprint-geographic
6. Preferentially use most recent records: For species with > 100 records in last 20 years use those records. For others, use all records.
7. Remove any duplicate records defined as a record that occurs at the same spatial coordinates for the same species name.
8. Highlight records in which the coordinate doesn't match the recorded country and continent as this could indicate an error in the coordinate
9. Highlight records that have < 100 occurances.
