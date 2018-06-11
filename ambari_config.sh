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

echo $AMBARI_USER
echo $AMBARI_PASSWORD
echo $AMBARI_PORT
echo $AMBARI_HOST
echo $CLUSTER_NAME
