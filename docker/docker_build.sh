 #! bin/bash 
 
if [ ! -d ./docker/tippecanoe ]; then
    git clone --depth 1 --branch 2.24.0 https://github.com/felt/tippecanoe.git ./docker/tippecanoe
else
    echo "Already cloned repo.."
fi

docker compose -f ./docker/docker-compose.yml build
