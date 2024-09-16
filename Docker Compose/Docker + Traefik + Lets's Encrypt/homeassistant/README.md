# Home Assistant
[Home Assistant](https://github.com/home-assistant/core) is an open source home automation that puts local control and privacy first. Powered by a worldwide community of tinkerers and DIY enthusiasts. Perfect to run on a Raspberry Pi or a local server.

# Usage
+ Create a folder for the homeassistant files 
  + ```mkdir homeassistant```
+ Open homeassistant folder
  + ```cd homeassistant```
+ Copy [deploy_homeassistant.sh](deploy_homeassistant.sh) to your homeassistant folder
+ Edit [deploy_homeassistant.sh](deploy_homeassistant.sh) and change the values with your info
+ Make [deploy_homeassistant.sh](deploy_homeassistant.sh) executable
  + ```sudo chmod +x deploy_homeassistant.sh```
+ Run the script to deploy homeassistant
  + ```./deploy_homeassistant.sh```
+ Add domain to pihole local dns
  + Domain: https://homeassistant.YOUR-DOMAIN-COM
  + IP Address: xx.xx.xx.xx (ip of docker server)
+ Open homeassistant dashboard
  + https://homeassistant.YOUR-DOMAIN-COM