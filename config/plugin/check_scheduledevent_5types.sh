#!/bin/bash

# This plugin queries the IMDS for all scheduled events and checks the response for presence of the event type passed into the plugin.
# If event type is not currently scheduled (not in IMDS response), it returns OK.
# If scheduled event of requested event type is found, it returns NOTOK and stdout message for nodeCondition.

readonly OK=0
readonly NOTOK=1
readonly UNKNOWN=2

# parse which event type we are looking for
while getopts 't:' OPTION; do
  case "$OPTION" in
    t)
      EVENT_TYPE="$OPTARG"
      #echo "The event type provided is $EVENT_TYPE"     
      ;;
    ?)
      echo "You must pass flag -t <eventType> to plugin"
      exit $UNKNOWN   #event_type not passed
  esac
done

#content= $('curl -H Metadata:true --noproxy "*" "http://169.254.169.254/metadata/instance?api-version=2021-02-01" ')
#for testing with fake data
content=$(./fakeIMDS.sh $EVENT_TYPE Started)
#for testing no data
#content=$(./fakeIMDS.sh None None)

#filter for requested event type with nearest NotBefore time, add sleep time to stagger IMDS
case "$EVENT_TYPE" in
    "Preempt") eventWithCorrectType=$(echo $content | jq '[.Events[] | {EventType,EventStatus,NotBefore}| select(.EventType=="Preempt")] | sort_by(.EventStatus) | reverse | sort_by(.NotBefore)');;
    "Freeze") eventWithCorrectType=$(echo $content | jq '[.Events[] | {EventType,EventStatus,NotBefore}| select(.EventType=="Freeze")] | sort_by(.EventStatus) | reverse | sort_by(.NotBefore)');;
    "Reboot") eventWithCorrectType=$(echo $content | jq '[.Events[] | {EventType,EventStatus,NotBefore}| select(.EventType=="Reboot")] | sort_by(.EventStatus) | reverse | sort_by(.NotBefore)');; 
    "Redeploy") eventWithCorrectType=$(echo $content | jq '[.Events[] | {EventType,EventStatus,NotBefore}| select(.EventType=="Redeploy")] | sort_by(.EventStatus) | reverse | sort_by(.NotBefore)');;
    "Terminate") eventWithCorrectType=$(echo $content | jq '[.Events[] | {EventType,EventStatus,NotBefore}| select(.EventType=="Terminate")] | sort_by(.EventStatus) | reverse | sort_by(.NotBefore)');;
esac

#if no events are found, return OK - NodeCondition will not be updated with a scheduled event
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








