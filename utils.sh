#!/bin/bash

# Function to get location from IPinfo
get_location() {
    local response
    local latitude
    local longitude
    response=$(curl -s https://ipinfo.io/json)
    latitude=$(echo "$response" | jq -r '.loc' | cut -d ',' -f1)
    longitude=$(echo "$response" | jq -r '.loc' | cut -d ',' -f2)
    echo "$latitude $longitude"
}

get_timezone() {
    local timezone
    timezone=$(timedatectl | grep 'Time zone' | awk '{print $3}')
    echo "$timezone"
}

get_sun_times() {
    local latitude
    local longitude
    local today_date
    local api_response
    local sunrise
    local sunset

    latitude=$1
    longitude=$2

    today_date=$(date '+%Y-%m-%d')
    api_response=$(curl -s "https://api.sunrise-sunset.org/json?lat=${latitude}&lng=${longitude}&date=${today_date}&formatted=0")
    #TODO: handle bad response

    sunrise=$(echo "$api_response" | jq -r '.results.sunrise')
    sunset=$(echo "$api_response" | jq -r '.results.sunset')

    echo "$sunrise" "$sunset"
}

# Function to determine if current time is past day time (past sunset or before sunrise)
is_day_time() {
    local check_time
    local times
    local sunrise
    local sunset

    check_time=$1
    check_time=$(date -d "$check_time" "+%s")

    # Get latitude and longitude from the location function
    read latitude longitude <<< "$(get_location)"

    # Get sunrise and sunset time using latitude and longitude
    times=$(get_sun_times "$latitude" "$longitude")

    sunrise=$(echo "$times" | cut -d ' ' -f1)
    sunset=$(echo "$times" | cut -d ' ' -f2)

    sunrise=$(date -d "$sunrise" "+%s")
    sunset=$(date -d "$sunset" "+%s")

    # Compare current time with sunrise and sunset times
    if [[ "$check_time" -lt "$sunrise" || "$check_time" -ge "$sunset" ]]; then
        echo "false"
    else
        echo "true"
    fi
}

export -f get_location
export -f get_timezone
export -f get_sun_times
export -f is_day_time

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    test_flag=0  # Flag is initially not set
    # Loop through all arguments
    for arg in "$@"; do
        if [[ "$arg" == "--test" ]]; then
            test_flag=1  # Set the flag if --test is found
            break
        fi
    done

    if [ $test_flag -eq 1 ]; then
        read latitude longitude <<< "$(get_location)"
        echo -e "Latitude\t $latitude"
        echo -e "Longitude\t $longitude"

        echo "======================"

        current_timezone=$(get_timezone)
        echo "Current timezone $current_timezone"

        echo "======================"

        sun_times=$(get_sun_times "$latitude" "$longitude")
        sunrise=$(echo "$sun_times" | cut -d " " -f1)
        sunset=$(echo "$sun_times" | cut -d " " -f2)
        sunrise=$(TZ=$current_timezone date -d "$sunrise" --iso-8601=seconds)
        sunset=$(TZ=$current_timezone date -d "$sunset" --iso-8601=seconds)
        echo -e "Sunrise\t $sunrise"
        echo -e "Sunset\t $sunset"

        echo "======================"

        current_time=$(date --iso-8601=seconds)
        # current_time=$(TZ=$current_timezone date -d "19:44:20" --iso-8601=seconds)
        # current_time=$sunrise
        echo -e "Current\t $current_time"
        result=$(is_day_time "$current_time")
        echo "Is day time? $result"
    fi
fi