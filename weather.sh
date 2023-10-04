#!/bin/bash

l_location=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        -l|--location)
            shift
            l_location="$1"
            ;;
        *)
            echo "Invalid option: $1" >&2
            exit 1
            ;;
    esac
    shift
done


l_location=$(echo "$l_location" | sed 's/ /+/g')

geoLocation=$(curl -s "https://nominatim.openstreetmap.org/search.php?q=$l_location&format=jsonv2")

lat=$(echo "$geoLocation" | jq -r ".[0].lat")
lon=$(echo "$geoLocation" | jq -r ".[0].lon")

weather_data=$(curl -s "https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&hourly=temperature_2m,relativehumidity_2m,rain&current_weather=true&timezone=Europe%2FBerlin&forecast_days=1")
echo $weather_data | jq > data
current_weather=$(echo $weather_data | jq '.current_weather')

time=$(echo "$current_weather" | jq '.time')
hour=$(echo ${time#*T} | sed 's/"//g')
hour=${hour%:*}
((hour-=1))
humidity=$(echo $weather_data | jq ".hourly.relativehumidity_2m[$hour]")
rain=$(echo $weather_data | jq ".hourly.rain[$hour]")
timestamp=$(echo $time | sed 's/T/ /g' | sed 's/"//g')
temperature=$(echo "$current_weather" | jq -r '.temperature')
windspeed=$(echo "$current_weather" | jq -r '.windspeed')
winddirection=$(echo "$current_weather" | jq -r '.winddirection')
is_day=$(echo "$current_weather" | jq -r '.is_day')
weathercode=$(echo "$current_weather" | jq -r '.weathercode')

printf " ____${timestamp}___________\n"
printf "|                               |\n"
printf "| temperature: ${temperature}°C           |\n"
printf "| wind: ${windspeed} km/h               |\n"
if [[ $humidity != 100 ]]; then
    printf "| humidity: %s%%                 |\n" "$humidity"
else
    printf "| humidity: %s%%                |\n" "$humidity"
fi
printf "| rain: $rain mm                    |\n"