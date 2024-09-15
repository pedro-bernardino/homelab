# ESPHome
[ESPHome](https://github.com/esphome/esphome) is a system to control your ESP8266/ESP32 by simple yet powerful configuration files and control them remotely through Home Automation systems.

# Usage
+ Create a folder for the esphome files 
  + ```mkdir esphome```
+ Open esphome folder
  + ```cd esphome```
+ Copy [deploy_esphome.sh](deploy_esphome.sh) to your esphome folder
+ Edit [deploy_esphome.sh](deploy_esphome.sh) and change the values with your info
+ Make [deploy_esphome.sh](deploy_esphome.sh) executable
  + ```sudo chmod +x deploy_esphome.sh```
+ Run the script to deploy esphome
  + ```./deploy_esphome.sh```
+ Add domain to pihole local dns
  + Domain: https://esphome.YOUR-DOMAIN-COM
  + IP Address: xx.xx.xx.xx (ip of docker server)
+ Open esphome dashboard
  + https://esphome.YOUR-DOMAIN-COM