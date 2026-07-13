library(data.table)
mem_mb <- function() round(sum(gc()[,2]), 1)

cat('mem before load:', mem_mb(), '\n')
x <- readRDS('/data/cleandata/atc.rds')
cat('mem after load:', mem_mb(), '\n')

atc_list <- x$atc
rm(x); invisible(gc())
cat('mem after dropping sub.atc:', mem_mb(), '\n')
cat('number of ATC sub-tables:', length(atc_list), '\n')

dt <- rbindlist(atc_list, idcol = 'atc_code', fill = TRUE)
rm(atc_list); invisible(gc())
cat('mem after rbindlist:', mem_mb(), '\n')
cat('combined rows:', nrow(dt), '\n')
print(names(dt))

cat('---distinct ROUTE_NEW---\n'); print(table(dt$ROUTE_NEW, useNA='always'))
cat('---distinct DOSE_UNIT_NEW (top 20)---\n'); print(head(sort(table(dt$DOSE_UNIT_NEW), decreasing=TRUE), 20))
cat('---distinct MEDICATION_FREQUENCY_NEW (top 20)---\n'); print(head(sort(table(dt$MEDICATION_FREQUENCY_NEW), decreasing=TRUE), 20))

keep_cols <- intersect(c('PERSON_ID_NEW','atc_code','DRUG_NAME','DRUG_START_DATE','DRUG_END_DATE',
                          'DOSE','DOSE_UNIT_NEW','MEDICATION_FREQUENCY_NEW','ROUTE_NEW'), names(dt))
dt <- dt[, ..keep_cols]
setnames(dt, tolower(names(dt)))

fwrite(dt, '/tmp/stg_atc_raw.csv')
cat('wrote /tmp/stg_atc_raw.csv, rows:', nrow(dt), '\n')
cat('column order:', paste(names(dt), collapse=','), '\n')
