# Restic
[Restic](https://github.com/restic/restic) is a backup program that is fast, efficient and secure. It supports the three major operating systems (Linux, macOS, Windows) and a few smaller ones (FreeBSD, OpenBSD).

# Usage
+ Create a folder for the restic files 
  + ```mkdir restic```
+ Open restic folder
  + ```cd restic```
+ Copy [deploy_restic.sh](deploy_restic.sh) to your restic folder
+ Edit [deploy_restic.sh](deploy_restic.sh) and change the values with your info
+ Make [deploy_restic.sh](deploy_restic.sh) executable
  + ```sudo chmod +x deploy_restic.sh```
+ Run the script to deploy restic
  + ```./deploy_restic.sh```
+ Restic don't have a user interface.