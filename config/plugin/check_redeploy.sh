#!/bin/bash
check_event= $( echo ./check_scheduledevent.sh -t Redeploy -s 1)
exit $?