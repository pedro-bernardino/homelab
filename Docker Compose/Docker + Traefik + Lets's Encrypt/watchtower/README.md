# Watchtower
With [watchtower](https://github.com/containrrr/watchtower) you can update the running version of your containerized app simply by pushing a new image to the Docker Hub or your own image registry.

Watchtower will pull down your new image, gracefully shut down your existing container and restart it with the same options that were used when it was deployed initially.

# Usage
+ Create a folder for the watchtower files 
  + ```mkdir watchtower```
+ Open watchtower folder
  + ```cd watchtower```
+ Copy [deploy_watchtower.sh](deploy_watchtower.sh) to your watchtower folder
+ Edit [deploy_watchtower.sh](deploy_watchtower.sh) and change the values with your info
+ Make [deploy_watchtower.sh](deploy_watchtower.sh) executable
  + ```sudo chmod +x deploy_watchtower.sh```
+ Run the script to deploy watchtower
  + ```./deploy_watchtower.sh```
+ watchtower don't have a user interface.