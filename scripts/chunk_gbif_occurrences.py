from os import makedirs
import zipfile as zf
import codecs


makedirs('./data/gbif_chunk')

GBIF_ZIP_FILE = './data/gbif-occurrences_extracted_141026.zip'
OUTPUT_FILE = './data/gbif_chunk/gbif_1.csv'

occurences = zf.ZipFile(GBIF_ZIP_FILE).open("gbif-occurrences_extracted_141026.csv", "r")
output_file = codecs.open(OUTPUT_FILE, 'w', "utf-8")

chunksize = 10e6
filenum = 1
n = 0

for l in occurences:
    l = codecs.decode(l, "utf-8")
    n += 1
    if n % chunksize == 0:
        filenum += 1
        OUTPUT_FILE = './data/gbif_chunk/gbif' + filenum + '.csv'
    ## add code to output and append this row to the output file.
