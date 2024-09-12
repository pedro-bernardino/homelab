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
+ Copy the [secrets](secrets) folder to your docker server
  + edit the files with your info and remove the ".template" 
+ Copy the [compose.yaml](compose.yaml) to your docker server (change port if needed)
  + run the command (inside the **compose.yaml** folder):
    + ***sudo docker compose up -d***

## Notifications
I use Telegram for notifications. Read the strutiny [documentation](https://github.com/AnalogJ/scrutiny?tab=readme-ov-file#notifications) for other services.

## Disks data
I use this container to monitor all my disk (HDDs and SSDs) on all my machines: Proxmox and Truenas.

To accomplish that, i run a data "collector" on each server that sends the data to the container. Instructions can be found [here](/Proxmox/ScrutinyCollector/README.md).
