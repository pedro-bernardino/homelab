import subprocess, time

#ups.status variables 
#https://networkupstools.org/docs/developer-guide.chunked/new-drivers.html#_status_data
UPS_ONLINE                  = 'OL' #On line (mains is present)
UPS_ON_BATTERY              = 'OB' #On battery (mains is not present)
UPS_LOW_BATTERY             = 'LB' #Low battery
UPS_HIGH_BATTERY            = 'HB' #High battery
UPS_REPLACE_BATTERY         = 'RB' #The battery needs to be replaced
UPS_CHARGING_BATTERY        = 'CHRG' #The battery is charging
UPS_DISCHARGING_BATTERY     = 'DISCHRG' #The battery is discharging (inverter is providing load power)
UPS_BYPASS_CIRCUIT          = 'BYPASS' #UPS bypass circuit is active -- no battery protection is available
UPS_PERFORMING_CALIBRATION  = 'CAL' #UPS is currently performing runtime calibration (on battery)
UPS_OFFLINE                 = 'OFF' #UPS is offline and is not supplying power to the load
UPS_OVERLOADED              = 'OVER' #UPS is overloaded
UPS_TRIMING                 = 'TRIM' #UPS is trimming incoming voltage (called "buck" in some hardware)
UPS_BOOSTING                = 'BOOST' #UPS is boosting incoming voltage
UPS_FORCED_SHUTDOWN         = 'FSD' #Forced Shutdown (restricted use, see the note below)

#servers variables
truenas_ip = 'xx.xx.xx.xx'
truenas_mac_address = 'xx:xx:xx:xx:xx:xx'

proxmox_ip = 'xx.xx.xx.xx'
proxmox_mac_address1 = 'xx:xx:xx:xx:xx:xx'
proxmox_mac_address2 = 'xx:xx:xx:xx:xx:xx'
proxmox_mac_address3 = 'xx:xx:xx:xx:xx:xx'
proxmox_mac_address4 = 'xx:xx:xx:xx:xx:xx'
proxmox_mac_address5 = 'xx:xx:xx:xx:xx:xx'
proxmox_mac_address6 = 'xx:xx:xx:xx:xx:xx'

#config variables
proxmox_wakeup_battery = 40 #turn on if battery is >40
truenas_wakeup_battery = 60 #turn on if battery is >60
ups_shutdown_battery = 18   #turn off ups if battery is <18 (not implemented yet!!)

#Debug print
debug = True
def debugprint(value):
  if debug:
    print(value)

def is_server_alive(serverIP):
  return subprocess.call(['ping', '-c', '1', serverIP], stdout=subprocess.DEVNULL, stderr=subprocess.STDOUT) == 0

def get_ups_battery_charge():
  return int(subprocess.run(['upsc', 'APC@localhost', 'battery.charge'], capture_output=True, text=True).stdout)

def get_ups_status():
  return subprocess.run(['upsc', 'APC@localhost', 'ups.status'], capture_output=True, text=True).stdout.strip()

def wakeup_server(macaddress):
  #debugprint('etherwake -b ' + macaddress)
  subprocess.Popen('etherwake -b ' + macaddress, shell=True, stdout=subprocess.PIPE)

def proxmox_wol():
    #test if proxmox is turned on
    if is_server_alive(proxmox_ip):
      debugprint('proxmox already on... skipping wol!')
    else:
      #proxmox off: wake up code (battery over 50%)
      debugprint('proxmox down...')
      if get_ups_battery_charge() >= proxmox_wakeup_battery:
        debugprint('battery_charge >= ' + proxmox_wakeup_battery + ', waking up proxmox')
        wakeup_server(proxmox_mac_address1)
        wakeup_server(proxmox_mac_address2)
        wakeup_server(proxmox_mac_address3)
        wakeup_server(proxmox_mac_address4)
        wakeup_server(proxmox_mac_address5)
        wakeup_server(proxmox_mac_address6)
        #debugprint('waiting boot - 90 secs')
        #time.sleep(90)
        #if is_server_alive(proxmox_ip):
        #  debugprint('proxmox wol success')
        #else:
        #  debugprint('proxmox wol failed - waiting next script to run')
      else:
        debugprint('battery_charge less than ' + proxmox_wakeup_battery + ', skipping wol!')

def truenas_wol():
    #test if proxmox (opnsense vm) is online. no point in wake the nas with no network...
    if is_server_alive(proxmox_ip):
      #test if truenas is turned on
      if is_server_alive(truenas_ip):
        debugprint('truenas already on... skipping wol!')
      else:
        #truenas off: wake up code
        debugprint('truenas down...')
        if get_ups_battery_charge() >= truenas_wakeup_battery:
          debugprint('battery_charge >= ' + truenas_wakeup_battery + ', waking up truenas: '+ truenas_mac_address)
          wakeup_server(truenas_mac_address)
          #debugprint('waiting boot - 90 secs')
          #time.sleep(90)
          #if is_server_alive(truenas_ip):
          #  debugprint('truenas wol success')
          #else:
          #  debugprint('truenas wol failed - waiting next script to run')
        else:
          debugprint('battery_charge less than ' + truenas_wakeup_battery + ', skipping wol!')
    else:
      debugprint('proxmox down... no network... no point in wakeup truenas!')

def shutdown_ups():
    #test if proxmox and truenas are off
    if not is_server_alive(proxmox_ip) and not is_server_alive(proxmox_ip):
      #test if the battery is very low...
      if get_ups_battery_charge() <= ups_shutdown_battery:
        #shutting down ups after all servers are off
        #TODO later
        pass

if __name__ == '__main__':
    #test if mains are present
    if get_ups_status().find(UPS_ONLINE) >= 0: 
      debugprint('ups online. Mains present')
      proxmox_wol()
      truenas_wol()
    else:
      debugprint('UPS in battery power -> lets the NUT server do their job.')
      shutdown_ups()