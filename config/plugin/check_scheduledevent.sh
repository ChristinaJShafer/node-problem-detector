#!/bin/bash

# This plugin checks for scheduled events by querying the IMDS. NodeCondition is updated with a scheduled event when NOTOK return status.
# NodeCondition Message field is updated with stdout.

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
      exit $UNKNOWN   #event_type not passed
  esac
done

#content= $('curl -H Metadata:true --noproxy "*" "http://169.254.169.254/metadata/instance?api-version=2021-02-01" ')
#for testing with fake data
content=$(./fakeIMDS.sh $EVENT_TYPE Scheduled | jq)
#for testing no data
#content=$(./fakeIMDS.sh None None)

#sort events by EventStatus descending, then NotBefore ascending
allevents=$(echo $content | jq '[.Events[] | {EventType,EventStatus,NotBefore}]  | sort_by(.EventStatus) | reverse | sort_by(.NotBefore)')
length=$(echo "$allevents" | jq length)

#if no events are found, return OK - NodeCondition will not be updated with a scheduled event
if [ $length -eq 0 ]; then
  echo "no events"
  exit $OK
fi

#capture nearest occuring event
ev_type=$(echo "$allevents" | jq -r '[.[].EventType][0]')
ev_status=$(echo "$allevents" | jq -r '[.[].EventStatus][0]')
ev_notbefore=$(echo "$allevents" | jq -r '[.[].NotBefore][0]')
#echo "Events received:"
#echo $allevents |jq .

#If nearest event is the type passed in, then trigger ScheduledEvent condition
if [ "$ev_type" = "$EVENT_TYPE" ]; then
  echo $ev_status ":" $ev_notbefore
  exit $NOTOK
else
  exit $OK
fi





#content=$(curl -H Metadata:true http://169.254.169.254/metadata/scheduledevents?api-version=2019-08-01 | jq .Events)
#echo "$content"







