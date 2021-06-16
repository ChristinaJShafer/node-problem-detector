#!/bin/bash
check_event= $( echo ./check_scheduledevent.sh -t Freeze -s 3)
exit $?