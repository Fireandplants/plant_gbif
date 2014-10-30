#!/usr/bin/env python

## Dylan W. Schwilk

"""This script will split a large txt file into separate file chunks of n rows
each. The -o option determines the directory and name prefix for each chunk. The
-d option controls adding the header to each chunk. See `split-csv.py -h` for
options.

"""

__version__ =    '''0.1'''
__program__ =    '''split-csv.py'''
__author__  =    '''Dylan Schwilk'''
__usage__   =    '''split-csv.py [options] csv_file'''

import codecs
import logging
logging.basicConfig(format='%(levelname)s: %(message)s')
gbif_logger = logging.getLogger('split_csv_logger')

def writeChunk(chunk, filename, header=None):
    gbif_logger.info("writing file: %s" % filename)
    ofile = codecs.open(filename, 'w', "utf-8")
    if header : ofile.write(header)
    for item in chunk:
        ofile.write(item)
    ofile.close()

def main():
    '''Command line program.  '''
    import sys   
    from optparse import OptionParser
   
    parser = OptionParser(usage=__usage__, version ="%prog " + __version__)
    parser.add_option("-o", "--output", action="store", type="string",
                      dest="output", default="split-chunk-out-", 
                      help="Prefix name for output chunks")
    parser.add_option("-n", "--nrows", action="store", type="int",
                      dest="nrows", default=10000, help="Size of output chunks")
    parser.add_option("-d", "--header", action="store_true", dest="include_header", default=False,
                      help="Include header in each output chunk, default=%default")
    parser.add_option("-v", "--verbose", action="store_true", dest="verbose", default=False,
                      help="Print INFO messages to stdout, default=%default")    

    (options, args) = parser.parse_args()

    if options.verbose:
        gbif_logger.setLevel(logging.INFO)
    
    # read input file
    if len(args) == 1 :
        try :
            infile = codecs.open(args[0], "r", "utf-8")
        except IOError:
            gbif_logger.error('Error reading file, %s' % args[0])
            sys.exit()
    else:
        gbif_logger.error('No input file provided')
        sys.exit()

    # get the header and advance file iterator
    header = infile.next()
    if not options.include_header : header = None

    # set up counter and cycle through the big file
    n=0
    chunk = [""]*options.nrows
    for l in infile:
        chunk[n % options.nrows] = l
        n=n+1
        if n % options.nrows == 0 :
            filename =  "%s%i.csv" % (options.output, n)
            writeChunk(chunk, filename, header)
            chunk = [""]*options.nrows

    # write final chunk if nrows is not perfect muliple of n
    if n % options.nrows !=0 :
        filename =  "%s%i.csv" % (options.output, n)
        writeChunk(chunk, filename, header)


if __name__== "__main__":
    main()
