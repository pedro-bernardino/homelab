# Vaultwarden
[Vaultwarden](https://github.com/dani-garcia/vaultwarden) Alternative implementation of the Bitwarden server API written in Rust and compatible with upstream Bitwarden clients*, perfect for self-hosted deployment where running the official resource-heavy service might not be ideal.

# Usage
+ Create a folder for the vaultwarden files 
  + ```mkdir vaultwarden```
+ Open vaultwarden folder
  + ```cd vaultwarden```
+ Copy [deploy_vaultwarden.sh](deploy_vaultwarden.sh) to your vaultwarden folder
+ Edit [deploy_vaultwarden.sh](deploy_vaultwarden.sh) and change the values with your info
+ Make [deploy_vaultwarden.sh](deploy_vaultwarden.sh) executable
  + ```sudo chmod +x deploy_vaultwarden.sh```
+ Run the script to deploy vaultwarden
  + ```./deploy_vaultwarden.sh```
+ Add domain to pihole local dns
  + Domain: https://vaultwarden.YOUR-DOMAIN-COM
  + IP Address: xx.xx.xx.xx (ip of docker server)
+ Open vaultwarden dashboard
  + https://vaultwarden.YOUR-DOMAIN-COM