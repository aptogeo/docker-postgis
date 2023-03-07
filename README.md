# Postgis Docker Image

## Included

- PostgreSQL/PostGIS

## Build
```sh
~ docker build -t postgis .
```

## Run Postgis Docker Container
```sh
~ docker run --name "postgis" -p 5432:5432 -d -t postgis
```
