#### WSL Network Bootstrapper
# @author: https://github.com/sindrebilden
# @license: MIT
#
# The IP of WSL is reassigned on boot, this script lets you start processes in WSL and adds a hostname alias for the newly assigned IP.
# Sections marked with (CUSTOMIZABLE) indicates points of interest where adjustments might be neccesary.
#
# NB: Take a backup of your hostfile if it contains important adjustments e.g. hosts.bkp.
# The scripts creates a temporary backup but it will be replaced on next execution.
# 
# The script must run once per boot and with high privilege to edit the hostfile, this can be done with "Task Scheduler"
# https://superuser.com/questions/1582234/make-ip-address-of-wsl2-static
# 

##################### CONFIGURATION (CUSTOMIZABLE) #################################
# Hostname e.g. http://wslhost:80 
$wsl_host="wslhost"
# Hostfile path
$hostfile="c:\Windows\System32\Drivers\etc\hosts"
$hostfile_tmp="$hostfile.tmp"
$logpath="c:\.wsl"
####################################################################################

# Initializing logs
$timestamp = Get-Date -Format o | ForEach-Object { $_ -replace ":", "." }
$logfile="$logpath\wsl-bootstrap-$timestamp.log"
Set-Content -Path $logfile -Value "WSL-Bootstrap`nProcess started at $timestamp"

try {
  Add-Content -Path $logfile -Value "INFO: WSL processes started"

  ############################## INIT SERVICES ON WSL (CUSTOMIZABLE) ########################################
  # Add your desired services below e.g.
  # Run ssh on wsl (needs configuration on WSL)
  # wsl sudo /etc/init.d/ssh start
  ####################################################################################

  Add-Content -Path $logfile -Value "INFO: WSL processes finished"
} catch {
  Add-Content -Path $logfile -Value "ERROR: WSL processes did not finish properly"
}

## Determines ip of WSL
$wsl_ip_list = (wsl hostname -I).trim()
$wsl_ip = $wsl_ip_list.Split(" ")[0]

try {
  Add-Content -Path $logfile -Value "INFO: Writing WSL host mapping ($wsl_ip => $wsl_host) to $hostfile"

  ## Updates hostfile
  # Backup previous hostfile to a temporary file
  Copy-Item "$hostfile" -Destination "$hostfile_tmp"
  # Remove previous ip mapping, also removes excess empty lines
  Get-Content $hostfile_tmp | Where-Object {$_ -notmatch $wsl_host} | Where-Object {$_.trim() -ne "" } |  Set-Content $hostfile
  # Add new ip mapping
  Add-Content -Path $hostfile -Value "`n$wsl_ip`t$wsl_host" -Force

  Add-Content -Path $logfile -Value "INFO: WSL host mapping written"
} catch {
  Add-Content -Path $logfile -Value "ERROR: Writing WSL host mapping failed"
}

# This block is only neccesary if you want to run commands or start processes that rely on the host alias
#try {
#  Add-Content -Path $logfile -Value "INFO: User defined processes started"

  ############################## FINALIZING PROCESSES (CUSTOMIZABLE) ########################################
  # Add your desired services below e.g.
  # Port forward ssh
  # netsh interface portproxy add v4tov4 listenport=22 connectport=22 connectaddress=$wsl_host
  ####################################################################################

#  Add-Content -Path $logfile -Value "INFO: User defined processes finished"
#} catch {
#  Add-Content -Path $logfile -Value "ERROR: User defined processes did not finish properly"
#}
