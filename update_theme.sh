#!/bin/bash

# shellcheck source=./utils.sh

source ./utils.sh 
source switch_theme.sh

current_time=$(date --iso-8601=seconds)
day_time=$(is_day_time $current_time)
# day_time=true
if [ "$day_time" = true ]; then
    theme="light"
else
    theme="dark"
fi

switch_to $theme