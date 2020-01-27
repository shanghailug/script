#!/usr/bin/env bash

next_thursday() {
    fmt=$1
    for i in `seq 1 7`; do
        day="$(date +%F) +${i} days"
        if [ X$(date -d "$day" +%w) = X4 ]; then
            date -d "$day" "+${fmt}"
        fi
    done
}

h4_month=`next_thursday "%Y-%-m"`
h4_date=`next_thursday "%Y-%-m-%-d"`

# check holiday in list first
while IFS= read -r line; do
    #echo "Text read from file: $line"
    if [ "$line" = "$h4_date" ]; then
        echo 0
        exit
    fi
done < holiday_list

: ${JUHE_APPKEY:?"Need to set JUHE_APPKEY"}
url="http://v.juhe.cn/calendar/month?year-month="
url="$url$h4_month&key=$JUHE_APPKEY"
json=`curl $url | jq -rf jq_filter.jq`
if [ $? -ne 0 ]
then
	echo 1
	exit
fi

is_holiday=`echo $json | grep -w $h4_date | echo $?`

echo $is_holiday
