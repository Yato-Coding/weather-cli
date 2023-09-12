#!/bin/bash

source .gitignore/api-key.sh

echo "Enter a location: "
read geoInput

geoLocation=$(curl -s "https://nominatim.openstreetmap.org/search.php?q=$geoInput&format=jsonv2")

lat=$(echo "$geoLocation" | jq -r ".[0].lat")
lon=$(echo "$geoLocation" | jq -r ".[0].lon")

weather_data=$(curl -s "https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&hourly=temperature_2m&current_weather=true&timezone=Europe%2FBerlin&forecast_days=1")
echo "$weather_data" | jq '.current_weather'
