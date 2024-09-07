# Network UPS Tools (NUT) Configs
## NUT Server
I use a [raspbery py 3 b+](https://www.raspberrypi.com/products/raspberry-pi-3-model-b-plus/) connected to the [APC Back-UPS Pro RS 900G](https://www.apc.com/pt/pt/product/BR900G-RS/backups-pro-da-apc-900va-avr-230v-cis/) via USB

Configuration of the NUT server can be found [here](/NUT%20Configs/Server/README.md).

I wrote a python [script](/NUT%20Configs/Server/etherwake%20script/README.md) to manage the Wake-on-LAN (WOL) of the Server 1 (Proxmox) and Server 2 (Truenas) based in the UPS battery charging percentage.

## My setup works like this

On Battery power (no mains present):
| Battery   | Proxmox   | Truenas                       |
| :-------: | :-------: | :-------:                     |
| 100%      | ON        | waits 60 secs before shutdown |
| 90%       | ON        | OFF                           |
| 80%       | ON        | OFF                           |
| 70%       | ON        | OFF                           |
| 60%       | ON        | OFF                           |
| 50%       | ON        | OFF                           |
| 40%       | ON        | OFF                           |
| 30%       | ON        | OFF                           |
| 20%       | Shutdown  | OFF                           |
| 10%       | OFF       | OFF                           |
| 0%        | OFF       | OFF                           |

On Mains power (battery charging):
| Battery   | Proxmox       | Truenas       |
| :-------: | :-------:     | :-------:     |
| 0%        | OFF           | OFF           |
| 10%       | OFF           | OFF           |
| 20%       | OFF           | OFF           |
| 30%       | OFF           | OFF           |
| 40%       | Wake-on-lan   | OFF           |
| 50%       | ON            | OFF           |
| 60%       | ON            | Wake-on-lan   |
| 70%       | ON            | ON            |
| 80%       | ON            | ON            |
| 90%       | ON            | ON            |
| 100%      | ON            | ON            |
