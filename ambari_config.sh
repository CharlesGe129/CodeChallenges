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
        echo $progressUrl
        echo $finalStatus
        if [ "$finalStatus" == "COMPLETED" ]
        then
            echo 'Restart of affected service succeeded.'
            exit 0
        else
            echo 'Restart of affected service failed'
            exit 1
        fi
    else
        echo 'Restart of affected service failed 222'
        exit 1
    fi
}

echo $AMBARI_USER
echo $AMBARI_PASSWORD
echo $AMBARI_PORT
echo $AMBARI_HOST
echo $CLUSTER_NAME

# Actual customization starts here
if [ "x$NODE_TYPE" != "xmanagement-slave00" ]
then
    echo "Updating ambari config properties"
    /var/lib/ambari-server/resources/scripts/configs.py -u $AMBARI_USER -p $AMBARI_PASSWORD -s "https" -t $AMBARI_PORT -a "set" -l $AMBARI_HOST -n $CLUSTER_NAME -c "mapred-site" -k "mapreduce.map.memory.mb" -v "5190"
    #/var/lib/ambari-server/resources/scripts/configs.py -u $AMBARI_USER -p $AMBARI_PASSWORD -s "https" -t $AMBARI_PORT -a "set" -l $AMBARI_HOST -n $CLUSTER_NAME -c "core-site" -k "fs.cos.CloudObjectStorageMatt.access.key" -v "abcdefg1234567890"
    #/var/lib/ambari-server/resources/scripts/configs.py -u $AMBARI_USER -p $AMBARI_PASSWORD -s "https" -t $AMBARI_PORT -a "set" -l $AMBARI_HOST -n $CLUSTER_NAME -c "core-site" -k "fs.cos.impl" -v "aaaaa22222222"
    #/var/lib/ambari-server/resources/scripts/configs.py -u $AMBARI_USER -p $AMBARI_PASSWORD -s "https" -t $AMBARI_PORT -a "set" -l $AMBARI_HOST -n $CLUSTER_NAME -c "core-site" -k "fs.s3a.buffer.dir" -v "bbborecuroecu2333333333333"
    #/var/lib/ambari-server/resources/scripts/configs.py -u $AMBARI_USER -p $AMBARI_PASSWORD -s "https" -t $AMBARI_PORT -a "set" -l $AMBARI_HOST -n $CLUSTER_NAME -c "core-site" -k "fs.s3a.impl" -v "anocuiaro444444444444444"

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
