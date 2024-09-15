# Heimdall
[Heimdall⁠](https://github.com/linuxserver/docker-heimdall) is an elegant solution to organise all your web applications. It’s dedicated to this purpose so you won’t lose your links in a sea of bookmarks.

As the name suggests Heimdall Application Dashboard is a dashboard for all your web applications. It doesn't need to be limited to applications though, you can add links to anything you like.

# Usage
+ Create a folder for the heimdall⁠ files 
  + ```mkdir heimdall⁠```
+ Open heimdall⁠ folder
  + ```cd heimdall⁠```
+ Copy [deploy_heimdall⁠.sh](deploy_heimdall⁠.sh) to your heimdall⁠ folder
+ Edit [deploy_heimdall⁠.sh](deploy_heimdall⁠.sh) and change the values with your info
+ Make [deploy_heimdall⁠.sh](deploy_heimdall⁠.sh) executable
  + ```sudo chmod +x deploy_heimdall⁠.sh```
+ Run the script to deploy heimdall⁠
  + ```./deploy_heimdall⁠.sh```
+ Add domain to pihole local dns (NOTE: i use the root domain for heimdall⁠!!)
  + Domain: https://YOUR-DOMAIN-COM
  + IP Address: xx.xx.xx.xx (ip of docker server)
+ Open heimdall⁠ dashboard
  + https://YOUR-DOMAIN-COM