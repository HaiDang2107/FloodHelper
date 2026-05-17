#!/bin/bash

# Tab 1: Chạy Ngrok
gnome-terminal --tab --title="Ngrok" -- bash -c "ngrok http 3000; exec bash"

# Tab 2: Chạy Backend
gnome-terminal --tab --title="Backend" --working-directory="$HOME/Desktop/FloodHelper/backend" -- bash -c "npm run start:dev; exec bash"

# Tab 3: Chạy MQTT Client (Dùng môi trường Conda)
gnome-terminal --tab --title="MQTT" --working-directory="$HOME/Desktop/FloodHelper/MqttClient" -- bash -ic "conda activate mqtt_client && python3 main.py; exec bash"

echo "Đã khởi động tất cả các services!"