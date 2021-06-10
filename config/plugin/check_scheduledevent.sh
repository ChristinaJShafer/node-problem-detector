#!/bin/bash

# This plugin queries the IMDS for all scheduled events and checks the response for presence of the event type passed into the plugin.
# If event type is not currently scheduled (not in IMDS response), it returns OK.
# If scheduled event of requested event type is found, it returns NOTOK and stdout message for nodeCondition.

readonly OK=0
readonly NOTOK=1
readonly UNKNOWN=2

# IMDS_COMMAND='./fakeIMDS.sh $EVENT_TYPE Scheduled'
# IMDS_COMMAND='./fakeIMDS.sh None None'
IMDS_COMMAND='curl -H Metadata:true --noproxy "*" "http://169.254.169.254/metadata/instance?api-version=2021-02-01"'

# parse which event type we are looking for
while getopts 't:' OPTION; do
  case "$OPTION" in
    t)
      EVENT_TYPE="$OPTARG"    
      ;;
    ?)
      echo "You must pass flag -t <eventType> (in title case) to plugin"
      exit $UNKNOWN   #event_type not passed
  esac
done

#filter for requested event type with nearest NotBefore time, add sleep time to stagger IMDS
case "$EVENT_TYPE" in
    "Preempt")
    content=$($IMDS_COMMAND) 
    eventWithCorrectType=$(echo $content | jq '[.Events[] | {EventType,EventStatus,NotBefore}| select(.EventType=="Preempt")] | sort_by(.EventStatus) | reverse | sort_by(.NotBefore)');;
    "Freeze")
    sleep 1
    content=$($IMDS_COMMAND) 
    eventWithCorrectType=$(echo $content | jq '[.Events[] | {EventType,EventStatus,NotBefore}| select(.EventType=="Freeze")] | sort_by(.EventStatus) | reverse | sort_by(.NotBefore)');;
    "Reboot") 
    sleep 2
    content=$($IMDS_COMMAND)
    eventWithCorrectType=$(echo $content | jq '[.Events[] | {EventType,EventStatus,NotBefore}| select(.EventType=="Reboot")] | sort_by(.EventStatus) | reverse | sort_by(.NotBefore)');; 
    "Redeploy") 
    sleep 3
    content=$($IMDS_COMMAND)
    eventWithCorrectType=$(echo $content | jq '[.Events[] | {EventType,EventStatus,NotBefore}| select(.EventType=="Redeploy")] | sort_by(.EventStatus) | reverse | sort_by(.NotBefore)');;
    "Terminate") 
    sleep 4
    content=$($IMDS_COMMAND)
    eventWithCorrectType=$(echo $content | jq '[.Events[] | {EventType,EventStatus,NotBefore}| select(.EventType=="Terminate")] | sort_by(.EventStatus) | reverse | sort_by(.NotBefore)');;
esac

# verify query connected
if [ $? -ne 0 ]; then
    echo "IMDS query failed"
    exit $UNKNOWN
fi

#if no scheduled events of requested type are found, return OK 
length=$(echo "$eventWithCorrectType" | jq length)
if [ $length -eq 0 ]; then
  echo "No VM $EVENT_TYPE scheduled event"
  exit $OK
fi

# capture EventType,EventStatus,EventNotBefore 
ev_type=$(echo "$eventWithCorrectType" | jq -r '[.[].EventType][0]')
ev_status=$(echo "$eventWithCorrectType" | jq -r '[.[].EventStatus][0]')
ev_notbefore=$(echo "$eventWithCorrectType" | jq -r '[.[].NotBefore][0]')


# Output and result when requested event type is scheduled 
if [ "$ev_type" = "$EVENT_TYPE" ]; then
  echo $ev_status ":" $ev_notbefore
  exit $NOTOK
else
  exit $OK
fi








