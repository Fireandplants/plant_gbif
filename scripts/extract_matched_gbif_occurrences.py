## script to cycle through entire huge gbif plantae data dump and check each
## name against the fuzzy match table (expanded tank et al names to gbif names
## lookup).

## Note that rather than using the "merge" action provided by the command line
## synonymize.py script, this script imports synonymize and uses some functions
## directly. This is in the interest of speed: it takes along time to go
## through 132 million gbif records, let's only do it once and get the
## canonical name while we are visiting each record.

import zipfile as zf
import synonymize
import codecs

fuzzyMatchesFile = codecs.open("../query_names/gbif_tank_lookup_final.csv","r", "utf-8")
fieldsFile =       codecs.open("../query_names/gbif_fields.txt", "r", "utf-8")

TANKNAMES= codecs.open("../../bigphylo/species/big-phylo-leaves.txt", "r", "utf-8")
goodnames = synonymize.read_names(TANKNAMES)
goodnames = set(goodnames)

## make tpl dicts
synonymize.make_tpl_dicts(codecs.open(synonymize.TPL_FILE, "r", "utf-8"))

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
output_file = codecs.open('../data/gbif-occurrences_extracted_140906.csv', 'w', "utf-8")
output_file.write("gbifname\texpandedname\ttankname\t")
for h in gfields:
            output_file.write(h + "\t")
output_file.write("\n")
 
n = 0
nmatches=0
for l in occurences:
    l = codecs.decode(l, "utf-8")
    n = n + 1 
    
    f = l[:-1].split("\t")
    # first check if lat and lon exist 
    if not f[hdict["decimalLatitude"]] or not f[hdict["decimalLongitude"]]:
        continue

    name = f[hdict["species"]] 
    res =  fnames.get(name)
    if res :
        nmatches = nmatches+1
        # print("found fm: " + name + ", " + res)
        resline = name + "\t" + res + "\t"
        
        # get all the needed fields
        if (nmatches % 1000 == 0) : print(str(n) + "\t" + str(nmatches) +": " + resline)
        tankname = synonymize.bad2good(res, goodnames)
        resline = resline + tankname + "\t"
        for h in gfields:
       #     print(h)
       #     print(hdict[h])
            resline = resline + f[hdict[h]] + "\t"
        output_file.write(resline + "\n")

#    if n > 10000 : break


