

## script to cycle through entire huge gbif plantae data dump and check each

## name against tow alternative lookups, Jan Legin's synonym table via the gbif
## backbone phylogeny and our own expanded takname to gbif lookup created by
## fuzzy match
 
#import pandas as pd
import zipfile as zf
import synonymize
import codecs

legindFile =       codecs.open("../query_names/nescent_interpreted_names.csv", "r", "utf-8")
fuzzyMatchesFile = codecs.open("../query_names/gbif_tank_lookup_final.csv","r", "utf-8")
fieldsFile =       codecs.open("../query_names/gbif_fields.txt", "r", "utf-8")


## make tpl dicts
synonymize.make_tpl_dicts(codecs.open(synonymize.TPL_FILE, "r", "utf-8"))

## create lnames lookup table:
lnames = {}
legindFile.readline() # throw away header
for l in legindFile:
    fields = l.split(",")
    lnames[ fields[1][1:-1] ] = fields[0][1:-1] # lookup accepted to searched


## create fuzzy matches lookup table
fnames = {}
fuzzyMatchesFile.readline()
for l in fuzzyMatchesFile:
    fields = l.split(",")
    fnames[ fields[0][1:-1] ] = fields[1][1:-1] # lookup accepted to searched


gfields = fieldsFile.readlines()
gfields = map(lambda x: x.strip(), gfields)

gbif_header = u"""gbifID	abstract	accessRights	accrualMethod	accrualPeriodicity	accrualPolicy	alternative	audience	available	bibliographicCitation	conformsTo	contributor	coverage	created	creator	date	dateAccepted	dateCopyrighted	dateSubmitted	description	educationLevel	extent	format	hasFormat	hasPart	hasVersion	identifier	instructionalMethod	isFormatOf	isPartOf	isReferencedBy	isReplacedBy	isRequiredBy	isVersionOf	issued	language	license	mediator	medium	modified	provenance	publisher	references	relation	replaces	requires	rights	rightsHolder	source	spatial	subject	tableOfContents	temporal	title	type	valid	acceptedNameUsage	acceptedNameUsageID	associatedOccurrences	associatedReferences	associatedSequences	associatedTaxa	basisOfRecord	bed	behavior	catalogNumber	class	collectionCode	collectionID	continent	countryCode	county	dataGeneralizations	datasetID	datasetName	dateIdentified	day	decimalLatitude	decimalLongitude	disposition	dynamicProperties	earliestAgeOrLowestStage	earliestEonOrLowestEonothem	earliestEpochOrLowestSeries	earliestEraOrLowestErathem	earliestPeriodOrLowestSystem	endDayOfYear	establishmentMeans	eventDate	eventID	eventRemarks	eventTime	family	fieldNotes	fieldNumber	footprintSRS	footprintSpatialFit	footprintWKT	formation	genus	geodeticDatum	geologicalContextID	georeferencedDate	georeferenceProtocol	georeferenceRemarks	georeferenceSources	georeferenceVerificationStatus	georeferencedBy	group	habitat	higherClassification	higherGeography	higherGeographyID	highestBiostratigraphicZone	identificationID	identificationQualifier	identificationReferences	identificationRemarks	identificationVerificationStatus	identifiedBy	individualCount	individualID	infraspecificEpithet	institutionCode	institutionID	island	islandGroup	kingdom	latestAgeOrHighestStage	latestEonOrHighestEonothem	latestEpochOrHighestSeries	latestEraOrHighestErathem	latestPeriodOrHighestSystem	lifeStage	lithostratigraphicTerms	locality	locationAccordingTo	locationID	locationRemarks	lowestBiostratigraphicZone	materialSampleID	maximumDistanceAboveSurfaceInMeters	member	minimumDistanceAboveSurfaceInMeters	month	municipality	nameAccordingTo	nameAccordingToID	namePublishedIn	namePublishedInID	namePublishedInYear	nomenclaturalCode	nomenclaturalStatus	occurrenceDetails	occurrenceID	occurrenceRemarks	occurrenceStatus	order	originalNameUsage	originalNameUsageID	otherCatalogNumbers	ownerInstitutionCode	parentNameUsage	parentNameUsageID	phylum	pointRadiusSpatialFit	preparations	previousIdentifications	recordNumber	recordedBy	reproductiveCondition	samplingEffort	samplingProtocol	scientificName	scientificNameID	sex	specificEpithet	startDayOfYear	stateProvince	subgenus	taxonConceptID	taxonID	taxonRank	taxonRemarks	taxonomicStatus	typeStatus	verbatimCoordinateSystem	verbatimCoordinates	verbatimDepth	verbatimElevation	verbatimEventDate	verbatimLocality	verbatimSRS	verbatimTaxonRank	vernacularName	year	datasetKey	publishingCountry	lastInterpreted	coordinateAccuracy	elevation	elevationAccuracy	depth	depthAccuracy	distanceAboveSurface	mediaType	hasCoordinate	hasGeospatialIssues	taxonKey	kingdomKey	phylumKey	classKey	orderKey	familyKey	genusKey	subgenusKey	speciesKey	species	genericName	typifiedName	protocol	lastParsed	lastCrawled"""


gbif_header = gbif_header[:-1].split("\t")
hdict = {}
for i,h in enumerate(gbif_header) :
    hdict[h]=i

#print(hdict)

occurences = zf.ZipFile('/mnt/gis/gbif_plantae/0002274-140616093749225.zip').open("occurrence.txt", "r")
output_file = codecs.open('gbif-occurrences_extracted_140905.csv', 'w', "utf-8")
output_file.write("match_source\tsearchname\tgbifname\ttankname\t")
for h in gfields:
            output_file.write(h + "\t")
output_file.write("\n")
 
n = 0
nfound = 0
nnotfound = 0
for l in occurences:
    l = codecs.decode(l, "utf-8")
    n = n + 1 
    if n == 1 : 
        continue
        
    f = l[:-1].split("\t")
    found = False
    # check against Jan Legind's list
    name = f[hdict["species"]] 
    res =  lnames.get(name)
    if res :
        found = True
    #    print("found le: " + name + ", " + res)
        resline = "legind\t" + name + "\t" + res + "\t"
    else :
        res =  fnames.get(name)
        if res :
    #        print("found fm: " + name + ", " + res)
            found = True
            resline = "fmatch\t" + name + "\t" + res + "\t"
            
    if found :  # get all the needed fields
        if (n % 1000 == 0) : print(str(n) + ": " + resline)
        tankname = synonymize.bad2good(res)
        resline = resline + tankname + "\t"
        for h in gfields:
       #     print(h)
       #     print(hdict[h])
            resline = resline + f[hdict[h]] + "\t"
        output_file.write(resline + "\n")

#    if n > 20000 : break


