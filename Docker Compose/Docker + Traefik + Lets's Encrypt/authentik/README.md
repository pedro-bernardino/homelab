# Authentik
[Authentik](https://github.com/linuxserver/docker-heimdall) is an open-source Identity Provider that emphasizes flexibility and versatility, with support for a wide set of protocols.

Authentik enterprise offer can also be used as a self-hosted replacement for large-scale deployments of Okta/Auth0, Entra ID, Ping Identity, or other legacy IdPs for employees and B2B2C use.

# Usage
+ Create a folder for the authentik files 
  + ```mkdir authentik```
+ Open authentik folder
  + ```cd authentik```
+ Copy [deploy_authentik.sh](deploy_authentik.sh) to your authentik folder
+ Edit [deploy_authentik.sh](deploy_authentik.sh) and change the values with your info
+ Make [deploy_authentik.sh](deploy_authentik.sh) executable
  + ```sudo chmod +x deploy_authentik.sh```
+ Run the script to deploy authentik
  + ```./deploy_authentik.sh```
+ Add domain to pihole local dns
  + Domain: https://authentik.YOUR-DOMAIN-COM
  + IP Address: xx.xx.xx.xx (ip of docker server)
+ Open authentik admin account creation
  + https://authentik.YOUR-DOMAIN-COM/if/flow/initial-setup/
+ Open authentik dashboard
  + https://authentik.YOUR-DOMAIN-COM