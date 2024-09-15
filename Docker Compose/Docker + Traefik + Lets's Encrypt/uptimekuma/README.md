# Uptime Kuma
[Uptime Kuma](https://github.com/louislam/uptime-kuma) is an easy-to-use self-hosted monitoring tool.

# Usage
+ Create a folder for the uptimekuma files 
  + ```mkdir uptimekuma```
+ Open uptimekuma folder
  + ```cd uptimekuma```
+ Copy [deploy_uptimekuma.sh](deploy_uptimekuma.sh) to your uptimekuma folder
+ Edit [deploy_uptimekuma.sh](deploy_uptimekuma.sh) and change the values with your info
+ Make [deploy_uptimekuma.sh](deploy_uptimekuma.sh) executable
  + ```sudo chmod +x deploy_uptimekuma.sh```
+ Run the script to deploy uptimekuma
  + ```./deploy_uptimekuma.sh```
+ Add domain to pihole local dns
  + Domain: https://uptimekuma.YOUR-DOMAIN-COM
  + IP Address: xx.xx.xx.xx (ip of docker server)
+ Open uptimekuma dashboard
  + https://uptimekuma.YOUR-DOMAIN-COM