## 
import pandas as pd
import zipfile as zf

legindFile =       "../query_names/nescent_interpreted_names.csv"
fuzzyMatchesFile = "../query_names/gbif_tank_lookup_final.csv"
fieldsFile =       "../query_names/gbif_fields.txt"

lnames = pd.read_csv(legindFile, dtype=str)
fnames = pd.read_csv(fuzzyMatchesFile, dtype=str)
fields = open(fieldsFile).readlines()
fields = map(lambda x: x.strip(), fields)

gbif_header = """gbifID	abstract	accessRights	accrualMethod	accrualPeriodicity	accrualPolicy	alternative	audience	available	bibliographicCitation	conformsTo	contributor	coverage	created	creator	date	dateAccepted	dateCopyrighted	dateSubmitted	description	educationLevel	extent	format	hasFormat	hasPart	hasVersion	identifier	instructionalMethod	isFormatOf	isPartOf	isReferencedBy	isReplacedBy	isRequiredBy	isVersionOf	issued	language	license	mediator	medium	modified	provenance	publisher	references	relation	replaces	requires	rights	rightsHolder	source	spatial	subject	tableOfContents	temporal	title	type	valid	acceptedNameUsage	acceptedNameUsageID	associatedOccurrences	associatedReferences	associatedSequences	associatedTaxa	basisOfRecord	bed	behavior	catalogNumber	class	collectionCode	collectionID	continent	countryCode	county	dataGeneralizations	datasetID	datasetName	dateIdentified	day	decimalLatitude	decimalLongitude	disposition	dynamicProperties	earliestAgeOrLowestStage	earliestEonOrLowestEonothem	earliestEpochOrLowestSeries	earliestEraOrLowestErathem	earliestPeriodOrLowestSystem	endDayOfYear	establishmentMeans	eventDate	eventID	eventRemarks	eventTime	family	fieldNotes	fieldNumber	footprintSRS	footprintSpatialFit	footprintWKT	formation	genus	geodeticDatum	geologicalContextID	georeferencedDate	georeferenceProtocol	georeferenceRemarks	georeferenceSources	georeferenceVerificationStatus	georeferencedBy	group	habitat	higherClassification	higherGeography	higherGeographyID	highestBiostratigraphicZone	identificationID	identificationQualifier	identificationReferences	identificationRemarks	identificationVerificationStatus	identifiedBy	individualCount	individualID	infraspecificEpithet	institutionCode	institutionID	island	islandGroup	kingdom	latestAgeOrHighestStage	latestEonOrHighestEonothem	latestEpochOrHighestSeries	latestEraOrHighestErathem	latestPeriodOrHighestSystem	lifeStage	lithostratigraphicTerms	locality	locationAccordingTo	locationID	locationRemarks	lowestBiostratigraphicZone	materialSampleID	maximumDistanceAboveSurfaceInMeters	member	minimumDistanceAboveSurfaceInMeters	month	municipality	nameAccordingTo	nameAccordingToID	namePublishedIn	namePublishedInID	namePublishedInYear	nomenclaturalCode	nomenclaturalStatus	occurrenceDetails	occurrenceID	occurrenceRemarks	occurrenceStatus	order	originalNameUsage	originalNameUsageID	otherCatalogNumbers	ownerInstitutionCode	parentNameUsage	parentNameUsageID	phylum	pointRadiusSpatialFit	preparations	previousIdentifications	recordNumber	recordedBy	reproductiveCondition	samplingEffort	samplingProtocol	scientificName	scientificNameID	sex	specificEpithet	startDayOfYear	stateProvince	subgenus	taxonConceptID	taxonID	taxonRank	taxonRemarks	taxonomicStatus	typeStatus	verbatimCoordinateSystem	verbatimCoordinates	verbatimDepth	verbatimElevation	verbatimEventDate	verbatimLocality	verbatimSRS	verbatimTaxonRank	vernacularName	year	datasetKey	publishingCountry	lastInterpreted	coordinateAccuracy	elevation	elevationAccuracy	depth	depthAccuracy	distanceAboveSurface	mediaType	hasCoordinate	hasGeospatialIssues	taxonKey	kingdomKey	phylumKey	classKey	orderKey	familyKey	genusKey	subgenusKey	speciesKey	species	genericName	typifiedName	protocol	lastParsed	lastCrawled"""


gbif_header = gbif_header[:-1].split("\t")
hdict = {}
for i,h in enumerate(gbif_header) :
    hdict[h]=i



occurences = zf.ZipFile('/mnt/gis/gbif_plantae/0002274-140616093749225.zip').open("occurrence.txt")
output_file = open('gbif-data.csv', 'w')
output_file.write("match_source\ttankname\tgbifname\t")
for h in fields:
            output_file.write(h + "\t")
output_file.write("\n")
 
n = 0
for l in occurences:
    n = n + 1 
    if n == 1 : 
        continue

   # output_file.write(l)
   # if n > 10 : break
   # continue
    f = l[:-1].split("\t")
    found = False
    # check against Jan Legind's list
    res =  lnames[lnames.accepted_species ==  f[hdict["species"]] ]
    if res.any().accepted_species :
        found = True
        print("found le: " + res.searched_species.iget(0))
        output_file.write("legind\t" + res.searched_species.iget(0) + "\t" + res.accepted_species.iget(0) + "\t")
    else :
        res =  fnames[ fnames.gbif == f[hdict["species"]] ]
        if res.any().tank :
            print("found fm: " + res.tank.item())
            found = True
            output_file.write("fmatch\t" + res.tank.item() + "\t" + res.gbif.item() + "\t")
    
    if found :
        for h in fields:
            output_file.write(f[hdict[h]] + "\t")
        output_file.write("\n")

    #if n > 1000 : break


