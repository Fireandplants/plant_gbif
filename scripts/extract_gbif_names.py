#!/usr/env python

import zipfile as zf
import codecs


gbif_header = u"""gbifID	abstract	accessRights	accrualMethod	accrualPeriodicity	accrualPolicy	alternative	audience	available	bibliographicCitation	conformsTo	contributor	coverage	created	creator	date	dateAccepted	dateCopyrighted	dateSubmitted	description	educationLevel	extent	format	hasFormat	hasPart	hasVersion	identifier	instructionalMethod	isFormatOf	isPartOf	isReferencedBy	isReplacedBy	isRequiredBy	isVersionOf	issued	language	license	mediator	medium	modified	provenance	publisher	references	relation	replaces	requires	rights	rightsHolder	source	spatial	subject	tableOfContents	temporal	title	type	valid	acceptedNameUsage	acceptedNameUsageID	associatedOccurrences	associatedReferences	associatedSequences	associatedTaxa	basisOfRecord	bed	behavior	catalogNumber	class	collectionCode	collectionID	continent	countryCode	county	dataGeneralizations	datasetID	datasetName	dateIdentified	day	decimalLatitude	decimalLongitude	disposition	dynamicProperties	earliestAgeOrLowestStage	earliestEonOrLowestEonothem	earliestEpochOrLowestSeries	earliestEraOrLowestErathem	earliestPeriodOrLowestSystem	endDayOfYear	establishmentMeans	eventDate	eventID	eventRemarks	eventTime	family	fieldNotes	fieldNumber	footprintSRS	footprintSpatialFit	footprintWKT	formation	genus	geodeticDatum	geologicalContextID	georeferencedDate	georeferenceProtocol	georeferenceRemarks	georeferenceSources	georeferenceVerificationStatus	georeferencedBy	group	habitat	higherClassification	higherGeography	higherGeographyID	highestBiostratigraphicZone	identificationID	identificationQualifier	identificationReferences	identificationRemarks	identificationVerificationStatus	identifiedBy	individualCount	individualID	infraspecificEpithet	institutionCode	institutionID	island	islandGroup	kingdom	latestAgeOrHighestStage	latestEonOrHighestEonothem	latestEpochOrHighestSeries	latestEraOrHighestErathem	latestPeriodOrHighestSystem	lifeStage	lithostratigraphicTerms	locality	locationAccordingTo	locationID	locationRemarks	lowestBiostratigraphicZone	materialSampleID	maximumDistanceAboveSurfaceInMeters	member	minimumDistanceAboveSurfaceInMeters	month	municipality	nameAccordingTo	nameAccordingToID	namePublishedIn	namePublishedInID	namePublishedInYear	nomenclaturalCode	nomenclaturalStatus	occurrenceDetails	occurrenceID	occurrenceRemarks	occurrenceStatus	order	originalNameUsage	originalNameUsageID	otherCatalogNumbers	ownerInstitutionCode	parentNameUsage	parentNameUsageID	phylum	pointRadiusSpatialFit	preparations	previousIdentifications	recordNumber	recordedBy	reproductiveCondition	samplingEffort	samplingProtocol	scientificName	scientificNameID	sex	specificEpithet	startDayOfYear	stateProvince	subgenus	taxonConceptID	taxonID	taxonRank	taxonRemarks	taxonomicStatus	typeStatus	verbatimCoordinateSystem	verbatimCoordinates	verbatimDepth	verbatimElevation	verbatimEventDate	verbatimLocality	verbatimSRS	verbatimTaxonRank	vernacularName	year	datasetKey	publishingCountry	lastInterpreted	coordinateAccuracy	elevation	elevationAccuracy	depth	depthAccuracy	distanceAboveSurface	mediaType	hasCoordinate	hasGeospatialIssues	taxonKey	kingdomKey	phylumKey	classKey	orderKey	familyKey	genusKey	subgenusKey	speciesKey	species	genericName	typifiedName	protocol	lastParsed	lastCrawled"""


gbif_header = gbif_header[:-1].split("\t")
hdict = {}
for i,h in enumerate(gbif_header) :
    hdict[h]=i


occurences = zf.ZipFile('/mnt/gis/gbif_plantae/0002274-140616093749225.zip').open("occurrence.txt", "r")
output_file = codecs.open('gbif-taxon_names_140905.csv', 'w', "utf-8")

res = set()
 
n = 0
nfound = 0
nnotfound = 0

sp_index = hdict["species"]

for l in occurences:
    l = codecs.decode(l, "utf-8")
    n = n + 1 
    if n == 1 : 
        continue
             
    f = l[:-1].split("\t")
    res.add(f[sp_index] )
    if n%10000 == 0 : print(n)



for i in res:
    output_file.write(i + "\n")

