#!/usr/env python

## Dylan W. Schwilk

## Split big csv file into chunks 


__version__ =    '''0.1'''
__program__ =    '''split-csv.py'''
__author__  =    '''Dylan Schwilk'''
__usage__   =    '''split-csv.py [options] csv_file'''


#import zipfile as zf
import codecs

import logging
logging.basicConfig(format='%(levelname)s: %(message)s')
gbif_logger = logging.getLogger('tpl_logger')


def writeChunk(chunk, filename, header):
    gbif_logger.info("writing file: %s" % filename)
    ofile = codecs.open(filename, 'w', "utf-8")
    ofile.write(header)
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
    parser.add_option("-v", "--verbose", action="store_true", dest="verbose", default=False,
                      help="Print INFO messages to stdout, default=%default")    

    (options, args) = parser.parse_args()

    if options.verbose:
        gbif_logger.setLevel(logging.INFO)
    
    if len(args) == 1 :
        try :
            infile = codecs.open(args[0], "r", "utf-8")
        except IOError:
            gbif_logger.error('Error reading file, %s' % args[0])
            sys.exit()
    else:
        # We can't use stdin as a fallback because we are not guaranteed stdin
        # to be utf on all platforms (python 3 fixes this)
        gbif_logger.error('No input file provided')
        sys.exit()


    file_iter = iter(infile)
    header = file_iter.next()

    n=0
    chunk = [""]*options.nrows
    for l in file_iter:
        chunk[n % options.nrows] = l
        n=n+1
        if n % options.nrows == 0 :
            filename =  "%s%i.csv" % (options.output, n)
            writeChunk(chunk, filename, header)
            chunk = [""]*options.nrows

    # write final chunk
    filename =  "%s%i.csv" % (options.output, n)
    writeChunk(chunk, filename, header, options.verbose)

        

if __name__== "__main__":
    main()
