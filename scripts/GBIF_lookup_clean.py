## Purpose to clean up the output provided by the GBIF name lookup
## the uncleaned file is a jagged array

datafile = open('./query_names/GBIF_lookup.txt', 'r')
data = []
for row in datafile:
    data.append(row.strip().split('\t'))
data

## export as txt file

output_file = open('./query_names/GBIF_lookup-cleaned.txt', 'w')
for i in range(-1, len(data)):
    if i == -1:
        row = ['GBIF_id', 'kingdom', 'family', 'name', 'binomial', 'count']
    else: 
        if len(data[i]) == 1:
            row = ['NA', 'NA', 'NA', 'NA', data[i][0][12:], '0']
        else:
            row = data[i]
        if i == 0:
            row[0] = row[0][3:]
    out = str(row)[1:-1] + '\n'
    out = out.replace(',', '')
    output_file.write(out)

output_file.close()

