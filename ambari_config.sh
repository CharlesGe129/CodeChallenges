#!/bin/bash
#------------------------------------------------------------------------------
# Customization script to associate a COS instance with an IAE
# cluster. It expects COS credentials in AWS style. Specifically these three
# arguments: <s3_endpoint> <s3_access_key> <s3_secret_key>
#------------------------------------------------------------------------------

# Helper functions

# Parse json and return value for the specified json path
parseJson ()
{
    jsonString=$1
    jsonPath=$2

    echo $(echo $jsonString | python -c "import json,sys; print json.load(sys.stdin)$jsonPath")
}

# Track progress using the call back returned by Ambari restart API
trackProgress ()
{
    response=$1
    # Extract call back to from response to track progress
    progressUrl=$(parseJson "$response" '["href"]')
    echo "Link to track progress: $progressUrl"

    # Progress tracking loop
    tempPercent=0
    while [ "$tempPercent" != "100.0" ]
    do
        progressResp=`curl -u $AMBARI_USER:$AMBARI_PASSWORD -H 'X-Requested-By:ambari' -X GET $progressUrl --silent`
        tempPercent=$(parseJson "$progressResp" '["Requests"]["progress_percent"]')
        echo "Progress: $tempPercent"
        sleep 5s
    done

    # Validate if restart has really succeeded
    if [ "$tempPercent" == "100.0" ]
    then
        # Validate that the request is completed
        progressResp=`curl -u $AMBARI_USER:$AMBARI_PASSWORD -H 'X-Requested-By:ambari' -X GET $progressUrl --silent`
        finalStatus=$(parseJson "$progressResp" '["Requests"]["request_status"]')
        if [ "$finalStatus" == "COMPLETED" ]
        then
            echo 'Restart of affected service succeeded.'
            exit 0
        else
            echo 'Restart of affected service failed'
            exit 1
        fi
    else
        echo 'Restart of affected service failed'
        exit 1
    fi
}

AMBARI_USER = "hello world"
echo $AMBARI_USER
echo $AMBARI_HOST
echo "End of test"

# Validate input
if [ $# -ne 3 ]
then
     echo "Usage: $0 <s3_endpoint> <s3_access_key> <s3_secret_key>"
else
    S3_ENDPOINT="$1"
    S3_ACCESS_KEY="$2"
    S3_SECRET_KEY="$3"
fi

# Actual customization starts here
if [ "x$NODE_TYPE" != "xmanagement-slave00" ]
then
    echo "Updating ambari config properties"
    #change mapreduce.map.memory to 8192mb
    /var/lib/ambari-server/resources/scripts/configs.sh -u $AMBARI_USER -p $AMBARI_PASSWORD -port $AMBARI_PORT -s set $AMBARI_HOST $CLUSTER_NAME mapred-site "mapreduce.map.memory.mb" "8192"
    /var/lib/ambari-server/resources/scripts/configs.sh -u $AMBARI_USER -p $AMBARI_PASSWORD -port $AMBARI_PORT -s set $AMBARI_HOST "HDFS" "Custom core-site" "fs.cos.CloudObjectStorageMatt.access.key" "abcdefg1234567890"
    # stop MAPREDUCE2 service
    curl -v --user $AMBARI_USER:$AMBARI_PASSWORD -H "X-Requested-By: ambari" -i -X PUT -d '{"RequestInfo": {"context": "Stop MAPREDUCE2"}, "ServiceInfo": {"state": "INSTALLED"}}' https://$AMBARI_HOST:$AMBARI_PORT/api/v1/clusters/$CLUSTER_NAME/services/MAPREDUCE2
    sleep 60
    # start MAPREDUCE2 service
    curl -v --user $AMBARI_USER:$AMBARI_PASSWORD -H "X-Requested-By: ambari" -i -X PUT -d '{"RequestInfo": {"context": "Start MAPREDUCE2"}, "ServiceInfo": {"state": "STARTED"}}' https://$AMBARI_HOST:$AMBARI_PORT/api/v1/clusters/$CLUSTER_NAME/services/MAPREDUCE2
fi

if [ "x$NODE_TYPE" == "xmanagement-slave2" ]
then    
    /var/lib/ambari-server/resources/scripts/configs.sh -u $AMBARI_USER -p $AMBARI_PASSWORD -port $AMBARI_PORT -s set $AMBARI_HOST $CLUSTER_NAME core-site "fs.cos.myprodservice.access.key" $S3_ACCESS_KEY
    /var/lib/ambari-server/resources/scripts/configs.sh -u $AMBARI_USER -p $AMBARI_PASSWORD -port $AMBARI_PORT -s set $AMBARI_HOST $CLUSTER_NAME core-site "fs.cos.myprodservice.endpoint" $S3_ENDPOINT
    /var/lib/ambari-server/resources/scripts/configs.sh -u $AMBARI_USER -p $AMBARI_PASSWORD -port $AMBARI_PORT -s set $AMBARI_HOST $CLUSTER_NAME core-site "fs.cos.myprodservice.secret.key" $S3_SECRET_KEY

    echo 'Restart affected services'
    response=`curl -u $AMBARI_USER:$AMBARI_PASSWORD -H 'X-Requested-By: ambari' --silent -w "%{http_code}" -X POST -d '{"RequestInfo":{"command":"RESTART","context":"Restart all required services","operation_level":"host_component"},"Requests/resource_filters":[{"hosts_predicate":"HostRoles/stale_configs=true"}]}' https://$AMBARI_HOST:$AMBARI_PORT/api/v1/clusters/$CLUSTER_NAME/requests`

    httpResp=${response:(-3)}
    if [[ "$httpResp" != "202" ]]
    then
        echo "Error initiating restart for the affected services, API response: $httpResp"
        exit 1
    else
        echo "Request accepted. Service restart in progress...${response::-3}"
        trackProgress "${response::-3}"
    fi
fi