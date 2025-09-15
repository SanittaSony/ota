#!/bin/bash

LOW_MEM_THRESHOLD=5 # Megabytes
INTERVAL_TIME=60 # second
# LOGFILE_PATH=/home/root
LOGFILE_SIZE=100000 # bytes
PROCESS_NAME="atcmd"
SOCAT_PROCESS_NAME="socat"
MEMORY_THRESHOLD=10000 # 10MB in kilobytes
LOGFILE_PATH="/var/log" # Change the path as needed
LAST_RTC_UPDATE=0;
HW_CLK_SYNC_TIME=14400 # 4 * 3600s

log() {
    timestamp=$(date +"%Y-%m-%d %T")
    echo "[$timestamp] $1" >> "$LOGFILE_PATH/atcmd_monitor.log"
    # echo "[$timestamp] $1"
}

low_mem_action ()
{
    echo "--- Low memory --- "
    date | tee $LOGFILE_PATH/reboot_cause.log
    echo "Restart the system because of low memory" | tee -a $LOGFILE_PATH/reboot_cause.log
    reboot
}

check_log_size ()
{
    log_sz=$(ls -l $LOGFILE_PATH/mem_info.log  | awk '{ print $5 }')
    if [[ "$log_sz" -gt "$LOGFILE_SIZE" ]]
    then
        rm $LOGFILE_PATH/mem_info.log
    fi
}


check_process_memory() {
    ;;
    # process_id=$(pgrep -o "$PROCESS_NAME")

    # if [ -z "$process_id" ]; then
    #     log "Process $PROCESS_NAME not found. Restart it"
    #     /usr/bin/atcmd &> /dev/null &
    # fi

    # socat_process_id=$(pgrep -o "$SOCAT_PROCESS_NAME")

    # if [ -z "$socat_process_id" ]; then
    #     log "Process $SOCAT_PROCESS_NAME not found. Restart it"
    #     /etc/init.d/socat start
    # fi

    # mem_usage=$(pmap -x "$process_id" | tail -n 1 | awk '{print $3}')

    # #log "Memory usage of $PROCESS_NAME ($process_id): $mem_usage KB"

    # if [ "$mem_usage" -gt "$MEMORY_THRESHOLD" ]; then
    #     log "Memory usage exceeds $MEMORY_THRESHOLD KB. Restarting..."
    #     log "Killing process $process_id"
    #     kill -9 "$process_id"
    #     # Insert command to restart the process here
    #     log "Restarting $PROCESS_NAME..."
    #     /usr/bin/atcmd &> /dev/null &
    #     log "Process $PROCESS_NAME restarted."
    # fi
}

rtc_update_check()
{
    LAST_RTC_UPDATE=$((LAST_RTC_UPDATE + $INTERVAL_TIME))
    if [ $LAST_RTC_UPDATE -gt $HW_CLK_SYNC_TIME ]; then
        hwclock -w
        LAST_RTC_UPDATE=0
    fi
}


main ()
{
    # sim_cnt=1
    while [ true ]
    do
        # get_mem_info | tee -a $LOGFILE_PATH/mem_info.log
        # get_mem_info &> /dev/null &
        # check_log_size
        #check_process_memory
        sleep $INTERVAL_TIME
        rtc_update_check
        # simulate_ram_usage
    done
}

main
