
# By default, remote address is set to 'LocalSubnet'; you don't want to overwrite it, but to add
# an IP of the management WAC VM (windowsmgmt VM)
Get-NetFirewallRule -Name 'winrm-http-in-tcp-public' | 
Get-NetFirewallAddressFilter |
Set-NetFirewallAddressFilter -RemoteAddress "LocalSubnet","192.168.2.4"