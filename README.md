

# Tippecanoe & auxiliary services docker image

This repo provides very basic tools to create mapbox vector tiles from either files on the internet (can be fetched with curl) or local files. It provides the following services as docker containers:

- curl
- ogr2ogr
- tippecanoe 

## Dependencies

Running examples in this repo requires:

- Docker-compose >= V2

## Usage

This is only meant to be use for quick and dirty work: 

__The file structure is extremelly important because host computer directories map to the corresponding directories in the container__
__Input data must be placed in `./data` and the script must be called from the root__

### Build

From the root of this project

```bash
.
|---- data
|---- scripts
|---- tiles
|---- docker
      |------ docker-compose.yml
      |------ ...
```

run the following:

```bash
chmod u+x ./docker/docker_build.sh
./docker/docker_build.sh
```


### Run 

Once the images are built. You can run either of the 3 bundled services:

- curl
- ogr2ogr
- tippecanoe 

__From the root of the project__, do the following:

(Optional) First download the data from the web (`$URL`) with curl and output to `./data/$OUTPUT_FILE_CURL`:

```
    docker compose -f docker/docker-compose.yml run curl \
        $URL \
        --output ./data/$OUTPUT_FILE_CURL \
        --insecure
```

(Optional) Next, select the geo data to use for mbtile creation and place that in `./data/`. The data needs to be transformed to geojson for tippecanoe. You can do that by running the `ogr2ogr` service. 

```
    docker compose -f docker/docker-compose.yml run ogr2ogr \
        -progress \
        -t_srs 'EPSG:3857' \
        -f "GeoJSON" \
        ./data/$OUTPUT_FILE_GDAL \
        ./data/$OUTPUT_FILE_CURL
```

Finally, call tippecanoe with the input geojson 

```
    docker compose -f docker/docker-compose.yml run tippecanoe \
        -s 'EPSG:3857' \
        -z10  \
        -o ./tiles/$OUTPUT_FILE_MBTILES \
        --extend-zooms-if-still-dropping  \
         ./data/$OUTPUT_FILE_GDAL
```





# Notes

See `./scripts/example_usage.sh` for a complete workflow example. 

See `https://github.com/felt/tippecanoe/tree/2.24.0` for more details on tippecanoe parameters + cookbook.


The tippecanoe image was tested by cloning tippecanoe @ `v2.24.0`. It would be possible to clone the repo within the container, but this often leads to git getting hung up indefinitely (probably because of ssl and even with --insecure)