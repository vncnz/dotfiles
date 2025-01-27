#!/bin/bash

# Malmö (Sweden): 55.60587, 13.00073
# Desenzano D/G: 45.457692 10.570684

url="https://api.open-meteo.com/v1/forecast?latitude="$2"&longitude="$3"&current=temperature_2m,apparent_temperature,is_day,precipitation,rain,weather_code,relative_humidity_2m&timezone=auto&forecast_days=1&daily=sunrise,sunset,daylight_duration"
# url="https://api.open-meteo.com/v1/forecast?latitude=45.457692&longitude=10.570684&current=temperature_2m,apparent_temperature,is_day,precipitation,rain,weather_code&timezone=auto&forecast_days=1&daily=sunrise,sunset,daylight_duration"

data=$(curl -s "$url")

nrows=$(echo $data | wc -l)
if [ $nrows -eq 0 ]; then
    echo '{"icon": "", "text": "No network", "temp": "", "temp_real": "" "temp_unit": "", "day": "0", "sunrise": "", "sunset": "", "sunrise_mins": 0, "sunset_mins": 0, "daylight": "", "locality": "'"$1"'"}'
else
    weather=$(jq -r '.current.weather_code' <<< $data)
    temp=$(echo $data | jq -r '.current.apparent_temperature' | awk '{print int($1+0.5)}')
    temp_real=$(echo $data | jq -r '.current.temperature_2m' | awk '{print int($1+0.5)}')
    humidity=$(echo $data | jq -r '.current.relative_humidity_2m') # | awk '{print int($1+0.5)}')
    temp_unit=$(echo $data | jq -r '.current_units.apparent_temperature' )
    day=$(echo $data | jq -r '.current.is_day' )
    sunrise=$(echo $data | jq -r '.daily.sunrise[0]' )
    sunset=$(echo $data | jq -r '.daily.sunset[0]' )
    daylight=$(echo $data | jq -r '.daily.daylight_duration[0]' )
    sunrise_mins=$(echo $sunrise | awk -F'T|:|-' '{print $4*60 + $5}')
    sunset_mins=$(echo $sunset | awk -F'T|:|-' '{print $4*60 + $5}')
    sunrise_time=$(echo $sunrise | awk -F'T|:|-' '{print $4":"$5}')
    sunset_time=$(echo $sunset | awk -F'T|:|-' '{print $4":"$5}')
    icon=''
    icon_name=''

    if [ $weather -eq 0 ] && [ $day -eq 1 ]; then
        icon='' # Clear sky
        text='Clear sky'
        icon_name='day_clear.svg'
    elif [ $weather -eq 0 ] && [ $day -eq 0 ]; then
        icon='' # Clear sky
        text='Clear sky'
        icon_name='night_clear.svg'
    elif [ $weather -eq 1 ] && [ $day -eq 1 ]; then
        icon='' # Mainly clear
        text='Mainly clear'
        icon_name='day_clear.svg'
    elif [ $weather -eq 1 ] && [ $day -eq 0 ]; then
        icon='' # Mainly clear
        text='Mainly clear'
        icon_name='night_clear.svg'
    elif [ $weather -eq 2 ] && [ $day -eq 1 ]; then
        icon='' # Partly cloudy
        text='Partly cloudy'
        icon_name='day_partial_cloud.svg'
    elif [ $weather -eq 2 ] && [ $day -eq 0 ]; then
        icon='' # Partly cloudy
        text='Partly cloudy'
        icon_name='night_partial_cloud.svg'
    elif [ $weather -eq 3 ]; then
        icon='󰖐' # Overcast
        text='Overcast'
        icon_name='overcast.svg'
    elif [ $weather -eq 45 ]; then
        icon='' # Fog
        text='Fog'
        icon_name='fog.svg'
    elif [ $weather -eq 48 ]; then
        icon='Depositing rime fog'
        text='Depositing rime fog'
        icon_name='mist.svg'
    elif [ $weather -eq 51 ]; then
        icon='1' # 'Drizzle (light)'
        text='Light drizzle'
    elif [ $weather -eq 53 ]; then
        icon='2' # 'Drizzle (moderate)'
        text='Moderate drizzle'
    elif [ $weather -eq 55 ]; then
        icon='3' # 'Drizzle (dense)'
        text='Dense drizzle'



    elif [ $weather -eq 56 ]; then
        icon='Freezing drizzle (light)'
        text='Freezing drizzle (light)'
    elif [ $weather -eq 57 ]; then
        icon='Freezing drizzle (dense)'
        text='Freezing drizzle (dense)'

    elif [ $weather -eq 61 ]; then
        icon='󱔇' # 'Rain (slight)'
        text='Rain (slight)'
        icon_name='rain.svg'
    elif [ $weather -eq 63 ]; then
        icon='󰸊' # 'Rain (moderate)'
        text='Rain (moderate)'
        icon_name='rain.svg'
    elif [ $weather -eq 65 ]; then
        icon='󱔋' # 'Rain (heavy)'
        text='Rain (heavy)'
        icon_name='rain.svg'

    elif [ $weather -eq 66 ]; then
        icon='Freezing rain (slight)'
        text='Freezing rain (slight)'
        icon_name='sleet.svg'
    elif [ $weather -eq 67 ]; then
        icon='Freezing rain (heavy)'
        text='Freezing rain (heavy)'
        icon_name='sleet.svg'

    elif [ $weather -eq 71 ]; then
        icon='1' # 'Snow (slight)'
        text='Snow (slight)'
        icon_name='snow.svg'
    elif [ $weather -eq 73 ]; then
        icon='2' # 'Snow (moderate)'
        text='Snow (moderate)'
        icon_name='snow.svg'
    elif [ $weather -eq 75 ]; then
        icon='3' # 'Snow (heavy)'
        text='Snow (heavy)'
        icon_name='snow.svg'

    elif [ $weather -eq 77 ]; then
        icon='Snow grains'
        text='Snow grains'

    elif [ $weather -eq 80 ]; then
        icon='1' # 'Rain showers (slight)'
        text='Rain showers (slight)'
        icon_name='rain.svg'
    elif [ $weather -eq 81 ]; then
        icon='2' # 'Rain showers (moderate)'
        text='Rain showers (moderate)'
        icon_name='rain.svg'
    elif [ $weather -eq 82 ]; then
        icon='3', # 'Rain showers (violent)'
        text='Rain showers (violent)'
        icon_name='rain.svg'
    elif [ $weather -eq 85 ]; then
        icon='Snow showers (slight)'
        text='Snow showers (slight)'
        icon_name='snow.svg'
    elif [ $weather -eq 86 ]; then
        icon='Snow showers (heavy)'
        text='Snow showers (heavy)'
        icon_name='snow.svg'

    elif [ $weather -eq 95 ]; then
        icon='' # 'Thunderstorm'
        text='Thunderstorm'
        icon_name='rain_thunder.svg'
    elif [ $weather -eq 96 ]; then
        icon='1' # 'Thunderstorm with slight hail'
        text='Thunderstorm with slight hail'
        icon_name='rain_thunder.svg'
    elif [ $weather -eq 99 ]; then
        icon='2' # 'Thunderstorm with heavy hail'
        text='Thunderstorm with heavy hail'
        icon_name='thunder.svg'
    # 95 *	Thunderstorm: Slight or moderate
    # 96, 99 *	Thunderstorm with slight and heavy hail
    else
        icon=$weather
        text=$weather
    fi

    # echo '' $temp$temp_unit
fi

echo '{"icon": "'"$icon"'", "text": "'"$text"'", "temp": "'"$temp"'", "temp_real": "'"$temp_real"'", "temp_unit": "'"$temp_unit"'", "day": "'"$day"'", "icon_name": "'"$icon_name"'", "sunrise": "'"$sunrise_time"'", "sunset": "'"$sunset_time"'", "sunrise_mins": '"$sunrise_mins"', "sunset_mins": '"$sunset_mins"', "daylight": "'"$daylight"'", "locality": "'"$1"'", "humidity": "'"$humidity"'"}'
