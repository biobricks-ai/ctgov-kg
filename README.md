# ctgov-kg

## Requirements

1. Docker (`docker`)
2. DVC (`dvc`)
3. PostgreSQL client (`psql`)
4. DuckDB client (`duckdb`)

## Build local database

1. Copy `.env.template` to `.env` and edit (note the `DOCKER_POSTGRES_DATA_DIR` variable).

2. Run the following to download the data:

```shell
dvc pull # or dvc repro
```

3. Start the PostgreSQL server and restore the database dumps.

```shell
make docker-compose-up docker-load-data
```

## SQL

```shell

make run-duckdb FILE=sql/mesh-coverage.duckdb.sql

```

---


```shell

# NOTE: `vd` is VisiData
make run-duckdb-csv FILE=sql/search-string-intervention.duckdb.sql | vd -f csv

```
