# Portainer
[Portainer](https://github.com/portainer/portainer) Community Edition is a lightweight service delivery platform for containerized applications that can be used to manage Docker, Swarm, Kubernetes and ACI environments. It is designed to be as simple to deploy as it is to use. The application allows you to manage all your orchestrator resources (containers, images, volumes, networks and more) through a ‘smart’ GUI and/or an extensive API.

# Usage
+ Create a folder for the portainer files 
  + ```mkdir portainer```
+ Open portainer folder
  + ```cd portainer```
+ Copy [deploy_portainer.sh](deploy_portainer.sh) to your portainer folder
+ Edit [deploy_portainer.sh](deploy_portainer.sh) and change the values with your info
+ Make [deploy_portainer.sh](deploy_portainer.sh) executable
  + ```sudo chmod +x deploy_portainer.sh```
+ Run the script to deploy portainer
  + ```./deploy_portainer.sh```
+ Add domain to pihole local dns
  + Domain: https://portainer.YOUR-DOMAIN-COM
  + IP Address: xx.xx.xx.xx (ip of docker server)
+ Open portainer dashboard
  + https://portainer.YOUR-DOMAIN-COM