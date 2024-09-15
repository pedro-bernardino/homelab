# MotionEye
[MotionEye](https://github.com/motioneye-project/motioneye) is an online interface for the software motion, a video surveillance program with motion detection.

# Usage
+ Create a folder for the motionEye files 
  + ```mkdir motionEye```
+ Open motionEye folder
  + ```cd motionEye```
+ Copy [deploy_motionEye.sh](deploy_motionEye.sh) to your motionEye folder
+ Edit [deploy_motionEye.sh](deploy_motionEye.sh) and change the values with your info
+ Make [deploy_motionEye.sh](deploy_motionEye.sh) executable
  + ```sudo chmod +x deploy_motionEye.sh```
+ Run the script to deploy motionEye
  + ```./deploy_motionEye.sh```
+ Add domain to pihole local dns
  + Domain: https://motionEye.YOUR-DOMAIN-COM
  + IP Address: xx.xx.xx.xx (ip of docker server)
+ Open motionEye dashboard
  + https://motionEye.YOUR-DOMAIN-COM