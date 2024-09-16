# Scrutiny
[Scrutiny](https://github.com/AnalogJ/scrutiny)  is a Hard Drive Health Dashboard & Monitoring solution, merging manufacturer provided S.M.A.R.T metrics with real-world failure rates.

Features:
+ Web UI Dashboard - focused on Critical metrics
+ smartd integration (no re-inventing the wheel)
+ Auto-detection of all connected hard-drives
+ S.M.A.R.T metric tracking for historical trends
+ Customized thresholds using real world failure rates
+ Temperature tracking
+ Provided as an all-in-one Docker image (but can be installed manually)
+ Configurable Alerting/Notifications via Webhooks
+ (Future) Hard Drive performance testing & tracking

# Usage
+ Create a folder for the scrutiny files 
  + ```mkdir scrutiny```
+ Open scrutiny folder
  + ```cd scrutiny```
+ Copy [deploy_scrutiny.sh](deploy_scrutiny.sh) to your scrutiny folder
+ Edit [deploy_scrutiny.sh](deploy_scrutiny.sh) and change the values with your info
+ Make [deploy_scrutiny.sh](deploy_scrutiny.sh) executable
  + ```sudo chmod +x deploy_scrutiny.sh```
+ Run the script to deploy scrutiny
  + ```./deploy_scrutiny.sh```
+ Add domain to pihole local dns
  + Domain: https://scrutiny.YOUR-DOMAIN-COM
  + IP Address: xx.xx.xx.xx (ip of docker server)
+ Open scrutiny dashboard
  + https://scrutiny.YOUR-DOMAIN-COM


## Notifications
I use Telegram for notifications. Read the strutiny [documentation](https://github.com/AnalogJ/scrutiny?tab=readme-ov-file#notifications) for other services.

Teste notifications:
+ ```sudo docker exec -it scrutiny bash```
+ ```curl -X POST http://localhost:8080/api/health/notify```
  
## Disks data
I use this container to monitor all my disk (HDDs and SSDs) on all my machines: Proxmox and Truenas.

To accomplish that, i run a data "collector" on each server that sends the data to the container. Instructions can be found [here](/Proxmox/ScrutinyCollector/README.md).
