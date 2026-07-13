library(DatabaseConnector)
library(Achilles)

connectionDetails <- createConnectionDetails(
  dbms = "postgresql",
  server = "broadsea-atlasdb/postgres",
  user = Sys.getenv("BROADSEA_POSTGRES_USER", "postgres"),
  password = Sys.getenv("BROADSEA_POSTGRES_PASSWORD"),
  port = 5432
)

result <- achilles(
  connectionDetails = connectionDetails,
  cdmDatabaseSchema = "t2d_cdm",
  vocabDatabaseSchema = "omop_vocab",
  resultsDatabaseSchema = "t2d_cdm",
  scratchDatabaseSchema = "t2d_cdm",
  sourceName = "T2D Study CDM",
  cdmVersion = "5.4",
  createTable = TRUE,
  smallCellCount = 5,
  createIndices = TRUE,
  numThreads = 1,
  optimizeAtlasCache = TRUE,
  defaultAnalysesOnly = TRUE,
  outputFolder = "/tmp/achilles_output"
)

cat("Achilles run complete\n")


