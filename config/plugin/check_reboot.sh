#!/bin/bash
check_event= $( echo ./check_scheduledevent.sh -t Reboot -s 2)
exit $?