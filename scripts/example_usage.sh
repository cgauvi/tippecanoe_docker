
#! /bin/bash 

# Author: Charles Gauvin
# Note: run this script from the root! ie docker/..


#
URL="https://www.donneesquebec.ca/recherche/dataset/5b1ae6f2-6719-46df-bd2f-e57a7034c917/resource/436c85aa-88d9-4e57-9095-b72b776a71a0/download/vdq-quartier.geojson"
OUTPUT_FILE_CURL=quebec_city.geojson
OUTPUT_FILE_GDAL=quebec_city_3857.geojson
OUTPUT_FILE_MBTILES=quebec_city_3857.mbtiles
OVERWRITE=""


# Curl
if [ ! -f ./data/$OUTPUT_FILE_CURL ] || [ ${#OVERWRITE} -ge 1 ] ; then 

    docker compose  -f docker/docker-compose.yml run curl \
        $URL \
        --output ./data/$OUTPUT_FILE_CURL \
        --insecure

    echo "successfully downloaded ./data/$OUTPUT_FILE_CURL"
else
    echo "./data/$OUTPUT_FILE_CURL already downloaded of OVERWRITE set to false"
fi


# Gdal reproject
if [ ! -f ./data/$OUTPUT_FILE_GDAL ] || [ ${#OVERWRITE} -ge 1  ] ; then 

    docker compose  -f docker/docker-compose.yml run ogr2ogr \
        -progress \
        -t_srs 'EPSG:3857' \
        -f "GeoJSON" \
        ./data/$OUTPUT_FILE_GDAL \
        ./data/$OUTPUT_FILE_CURL

    echo "successfully reprojected /data/$OUTPUT_FILE_CURL -> ./data/$OUTPUT_FILE_GDAL"
else
    echo "./data/$OUTPUT_FILE_GDAL already downloaded of OVERWRITE set to false"
fi


# Tippecanoe mbtiles 
if [ ! -f ./tiles/$OUTPUT_FILE_MBTILES ] || [ ${#OVERWRITE} -ge 1  ] ; then 

    docker compose  -f docker/docker-compose.yml  run tippecanoe \
        -s 'EPSG:3857' \
        -z10  \
        -o ./tiles/$OUTPUT_FILE_MBTILES \
        --extend-zooms-if-still-dropping  \
         ./data/$OUTPUT_FILE_GDAL

    echo "successfully created mbtiles ./tiles/$OUTPUT_FILE_MBTILES"
else
    echo "./tiles/$OUTPUT_FILE_MBTILES already exist of OVERWRITE set to false"
fi

