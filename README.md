# PgHero

[View the docs](https://github.com/ankane/pghero)

## First ToDo 
edit Gemfile to specific build git repository 

gem "pghero", :git => "https://github.com/sapisuper/pghero.git"

## Build Dockerfile 
docker build --platform=linux/amd64 --no-cache -t pghero:v3.4.0-disablekill -f Dockerfile .

docker run -d --name pghero --restart always -e DATABASE_URL=postgres://user:password@hostname:5432/dbname -p 8080:8080 pghero:v3.4.0-disablekill

## push to github
docker tag pghero:v3.4.0-disablekill bangsat69/pghero:v3.4.0-disablekill

docker push bangsat69/pghero:v3.4.0-disablekill
