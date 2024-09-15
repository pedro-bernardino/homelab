# Trilium
[Trilium](https://github.com/zadam/trilium) Notes is a hierarchical note taking application with focus on building large personal knowledge bases.

# Usage
+ Create a folder for the trilium files 
  + ```mkdir trilium```
+ Open trilium folder
  + ```cd trilium```
+ Copy [deploy_trilium.sh](deploy_trilium.sh) to your trilium folder
+ Edit [deploy_trilium.sh](deploy_trilium.sh) and change the values with your info
+ Make [deploy_trilium.sh](deploy_trilium.sh) executable
  + ```sudo chmod +x deploy_trilium.sh```
+ Run the script to deploy trilium
  + ```./deploy_trilium.sh```
+ Add domain to pihole local dns
  + Domain: https://trilium.YOUR-DOMAIN-COM
  + IP Address: xx.xx.xx.xx (ip of docker server)
+ Open trilium dashboard
  + https://trilium.YOUR-DOMAIN-COM