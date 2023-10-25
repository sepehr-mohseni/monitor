#!/bin/bash

SERVER="Server Name"
STORAGE_THRESHOLD=95
LOAD_THRESHOLD=40
MAX_MYSQL_CONNECTION_THRESHOLD=300
CURRENT_STORAGE=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')
CURRENT_LOAD=$(uptime | awk -F "load average: " '{print $2}' | awk -F"," '{print $1}' | awk -F"." '{print $1}')
MYSQL_MAX_CONNECTIONS=$(mysql -e "SHOW VARIABLES LIKE 'max_connections';" | grep -oP '\d+')
CURRENT_MYSQL_CONNECTIONS=$(mysql -e "SHOW PROCESSLIST;" | wc -l)
SEND=0
MSG="
**SERVER ALERT**
Server: $SERVER
Current Load: $CURRENT_LOAD
Current Storage: $CURRENT_STORAGE% / $STORAGE_THRESHOLD%
MySQL Connections: $CURRENT_MYSQL_CONNECTIONS / $MYSQL_MAX_CONNECTIONS
"
BOT_URL="https://example.com"


if [ "$CURRENT_LOAD" -ge "$LOAD_THRESHOLD" ]; then
    MSG="
    $MSG
PROBLEM: *LOAD*
    "
    SEND=1
fi

if [ "$CURRENT_STORAGE" -ge "$STORAGE_THRESHOLD" ]; then
    MSG="
    $MSG
PROBLEM: *STORAGE*
    "
    SEND=1
fi

if [ "$CURRENT_MYSQL_CONNECTIONS" -ge "$MAX_MYSQL_CONNECTION_THRESHOLD" ]; then
    MSG="
    $MSG
PROBLEM: *MYSQL*
    "
    SEND=1
fi

MSG="
$MSG
$TO_MENTION
"

REQUEST_BODY="$MSG"

if [ 1 -eq "$SEND" ]; then
    curl -X POST -H "Content-Type: text/plain" -d "$REQUEST_BODY" "$BOT_URL"
fi
