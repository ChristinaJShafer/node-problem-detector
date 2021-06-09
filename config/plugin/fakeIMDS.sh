#!/usr/bin/env python3

import argparse
import random
import json
from datetime import datetime,timedelta

parser = argparse.ArgumentParser()
parser.add_argument("EventType")
parser.add_argument("EventStatus")
args = parser.parse_args()

nowPlusTwenty=datetime.utcnow() + timedelta(minutes=20)
event_dict=dict()
scheduledEvent_dict=dict()
scheduledEvent_dict["DocumentIncarnation"]="IncarnationID"

def createRandomDict(): 
    new_event=dict()
    randomTime=datetime.utcnow() + timedelta(minutes=random.randint(5,45))
    event_list=["Freeze","Preempt","Reboot","Redeploy","Terminate"]
    new_event["EventID"]="Event " +str(random.randint(1, 100))
    new_event["EventType"] = event_list[random.randint(0, 4)]
    new_event["ResourceType"]="VirtualMachine"
    new_event["Resources"]=["resouce1","resource2"]
    new_event["EventStatus"] = "Scheduled"
    new_event["NotBefore"] = randomTime.strftime("%a, %d %b %Y %H:%M:%S GMT")
    new_event["Description"] = "Event Description"
    new_event["EventSource"] = "Platform"
    return new_event


if (args.EventType !="None"):
    event_dict["EventID"]="Event " +str(random.randint(1, 100))
    event_dict["EventType"] = args.EventType
    event_dict["ResourceType"]="VirtualMachine"
    event_dict["Resources"]=["resouce1","resource2"]
    event_dict["EventStatus"] = args.EventStatus
    event_dict["NotBefore"] = nowPlusTwenty.strftime("%a, %d %b %Y %H:%M:%S GMT")
    if (args.EventStatus=="Started"): event_dict["NotBefore"]=datetime.utcnow().strftime("%a, %d %b %Y %H:%M:%S GMT")
    event_dict["Description"] = "Event Description"
    event_dict["EventSource"] = "Platform"
    scheduledEvent_dict["Events"]=[event_dict, createRandomDict(), createRandomDict()]
event_json = json.dumps(scheduledEvent_dict)
print (event_json)


#print(f"{station}.{sensor} current value: {current_value}")