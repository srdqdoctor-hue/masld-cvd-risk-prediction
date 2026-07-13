library(DBI)
library(RPostgres)
library(data.table)

mem_mb <- function() round(sum(gc()[,2]), 1)

kept <- read.csv('/tmp/lab_kept_codes.csv', stringsAsFactors = FALSE, encoding = 'UTF-8')
cat('kept dictionary codes:', nrow(kept), '\n')

cat('mem before load:', mem_mb(), '\n')
lab <- readRDS('/data/cleandata/lab.rds')
cat('mem after load:', mem_mb(), '\n')
cat('lab.rds sub-tables:', length(lab), '\n')

avail_codes <- intersect(kept$code, names(lab))
missing_codes <- setdiff(kept$code, names(lab))
cat('matched sub-tables found in lab.rds:', length(avail_codes), '\n')
cat('dictionary codes NOT found as sub-table names:', length(missing_codes), '\n')
if (length(missing_codes) > 0) cat('missing:', paste(missing_codes, collapse=', '), '\n')

lab_kept <- lab[avail_codes]
rm(lab); invisible(gc())
cat('mem after dropping unneeded sub-tables:', mem_mb(), '\n')

nrows <- sapply(lab_kept, nrow)
cat('total rows in kept subset:', sum(nrows), '\n')

dt <- rbindlist(lab_kept, idcol = 'lab_code', fill = TRUE)
rm(lab_kept); invisible(gc())
cat('mem after rbindlist:', mem_mb(), '\n')
cat('combined rows:', nrow(dt), '\n')
print(names(dt))

keep_cols <- intersect(c('PERSON_ID_NEW','lab_code','MEASUREMENT_NAME_NEW','SAMPLE_NAME_NEW',
                          'DETECT_TIME','UNIT_NEW','VALUE_AS_NUMBER_NEW','VALUE_AS_CATEGORY_NEW'),
                        names(dt))
dt <- dt[, ..keep_cols]
setnames(dt, tolower(names(dt)))

fwrite(dt, '/tmp/stg_lab_raw.csv')
cat('wrote /tmp/stg_lab_raw.csv, rows:', nrow(dt), '\n')


