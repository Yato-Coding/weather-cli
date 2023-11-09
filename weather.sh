#!/bin/bash



l_location=""
no_flags=true

while [[ $# -gt 0 ]]; do
    case "$1" in
        -l|--location)
            shift
            l_location="$1"
            no_flags=false
            ;;
        *)
            echo "Invalid option: $1" >&2
            exit 1
            ;;
    esac
    shift
done

if $no_flags; then
    echo "----------------------------"
    echo " "
    echo "You have to enter a location"
    echo "You can do so using the -l/--location flag"
    echo " "
    echo "----------------------------"
    exit 1
fi


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
humidity+="%"
rain=$(echo $weather_data | jq ".hourly.rain[$hour]")
rain+=" mm"
timestamp=$(echo $time | sed 's/T/ /g' | sed 's/"//g')
temperature=$(echo "$current_weather" | jq -r '.temperature')
temperature+="°C"
windspeed=$(echo "$current_weather" | jq -r '.windspeed')
windspeed+=" km/h"
winddirection=$(echo "$current_weather" | jq -r '.winddirection')
is_day=$(echo "$current_weather" | jq -r '.is_day')

weathercode=$(echo "$current_weather" | jq -r '.weathercode')
declare -a weather_codes

while IFS=, read -r code meaning; do
    weather_codes["$code"]="$meaning"
done < weather_codes.csv

printf " ____${timestamp}_____________________________\n"
printf "|                                                 |\n"
printf "| Location:    %-34s%-s|\n" "$l_location" " "
printf "| Temperature: %-7s%-29s|\n" "$temperature" " "
printf "| Wind:        %-11s%-24s|\n" "$windspeed" " "
printf "| Humidity:    %-4s%-31s|\n" "$humidity" " "
printf "| Rain:        %-9s%-26s|\n" "$rain" " "
printf "| Weathercode: %-34s%-s|\n" "${weather_codes[weathercode]}" " "
printf "|_________________________________________________|\n"
