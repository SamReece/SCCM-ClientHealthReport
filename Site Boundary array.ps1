$Collections = @(
    "WM1 - All Ilsfeld Workstations and Servers by Subnet 172.22.77.0"
    "WM1 - All Delden Workstations and Servers by Subnet 172.30.6.0 and 172.30.7.0"
    "WM1 - South African Workstations and Servers by Subnet 172.30.19.0"
    "WM1 - All Swedish Systems"
    "WM1 - All Denmark Workstations and Servers by Subnet 192.168.155.0"


)

foreach ($Collection in $Collections) {
    Get-PendingClients  -SiteCode WM1 -ProviderMachineName "VM533008" -Collection $Collection -Export "C:\System Center"
}