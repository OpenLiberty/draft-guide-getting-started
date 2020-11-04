
#!/bin/bash
set -euxo pipefail

##############################################################################
##
##  GitHub Actions test script
##
##############################################################################

mvn -q clean package

docker pull openliberty/open-liberty:kernel-java8-openj9-ubi

docker build -t openliberty-getting-started:1.0-SNAPSHOT .

docker run -d --name gettingstarted-app -p 9080:9080 openliberty-getting-started:1.0-SNAPSHOT

sleep 60

docker exec -it gettingstarted-app cat /logs/messages.log | grep product
docker exec -it gettingstarted-app cat /logs/messages.log | grep java

status="$(curl --write-out "%{http_code}\n" --silent --output /dev/null "http://localhost:9080/system/properties")" 
if [ "$status" == "200" ]
then 
  echo ENDPOINT OK
else 
  echo "$status" 
  echo ENDPOINT NOT OK
  exit 1
fi

docker stop gettingstarted-app && docker rm gettingstarted-app