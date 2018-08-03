Function Get-PendingClients {
  <# 
.SYNOPSIS
    generate a report for all devices in a collection that does not have a client installed.

.DESCRIPTION
    This function has been designed to collate all clients without a client and export them into a report.

.EXAMPLE
    Get-PendingClients -SiteCode WM1 -ProviderMachineName "VM533008" -Collection "All WM1 Systems" -Export "C:\system center" 

.EXAMPLE
  
   Get-PendingClients -SiteCode WM1 -ProviderMachineName "VM533008" -Collection "All Swedish Workstations", "All Swedish Servers" -Export "C:\ExportPath"
    
.NOTES
    File Name : Get-PendingClients.ps1
    Author    : Sam Reece
    Requires  : System Center Configuration Manager
    Version   : 1.0.1
#>

  param
  (
      [Parameter(Mandatory=$true)][String]$SiteCode,
      [Parameter(Mandatory=$true)][String]$ProviderMachineName,
      [Parameter(Mandatory=$true)][String[]]$Collection,
      [Parameter(Mandatory=$true)][String[]]$Export
  )
  $Title = "Pending Clients"
  $Date = Get-Date -Format "dd-MM-yy "
  $Time = Get-Date -Format "HH:mm"
  $header = @"

<head>
<title>Watson Marlow Fluid Technology Group</title>
<style>
 body {
background-color: #ffffff;
font-family: "Roboto", helvetica, arial, sans-serif;
font-size: 10px;
font-weight: 400;
text-rendering: optimizeLegibility;
}

div.table-title {
 display: block;
margin: auto;
max-width: 600px;
padding:5px;
width: 100%;
}

.header {
    background-color: #292c2f;
    padding: 20px;
    text-align: center;
    color:  #8d9093;
    font-size: 16px;
    margin: 0;
}

.summary {
    padding-top: 30px;
    padding-right: 10px;
    padding-bottom: 10px;
    padding-left: 10px;
    height: 100px;
    width: 900px;
    position: relative;
    border-style:solid;
    border-color:lightgray;
    border-width: 1px;
    font-size: 14px;
    font-family: 'Open sans', sans-serif;
    color: #777777;
}

.table-title h3 {
 color: #fafafa;
 font-size: 20px;
 font-weight: 200;
 font-style:normal;
 font-family: "Roboto", helvetica, arial, sans-serif;
 text-shadow: -1px -1px 1px rgba(0, 0, 0, 0.1);
 text-transform:uppercase;
}

/*** Table Styles **/

.table-fill {
background: white;
border-radius:3px;
border-collapse: collapse;
height: 320px;
margin: auto;
max-width: 600px;
padding:5px;
width: 100%;
box-shadow: 0 5px 10px rgba(0, 0, 0, 0.1);
animation: float 5s infinite;
}

th {
color:#D5DDE5;;
background:#1b1e24;
border-bottom:4px solid #9ea7af;
border-right: 1px solid #343a45;
font-size:1810:52 26/07/2018px;
font-weight: 100;
padding:10px;
text-align:left;
text-shadow: 0 1px 1px rgba(0, 0, 0, 0.1);
vertical-align:middle;
}

th:first-child {
border-top-left-radius:3px;
}

th:last-child {
border-top-right-radius:3px;
border-right:none;
}

tr {
border-top: 1px solid #C1C3D1;
border-bottom-: 1px solid #C1C3D1;
color:#666B85;
font-size:12px;
font-weight:normal;
text-shadow: 0 1px 1px rgba(256, 256, 256, 0.1);
}

tr:hover td {
background:#4E5066;
color:#FFFFFF;
border-top: 1px solid #22262e;
border-bottom: 1px solid #22262e;
}

tr:first-child {
border-top:none;
}

tr:last-child {
border-bottom:none;
}

tr:nth-child(odd) td {
background:#EBEBEB;
}

tr:nth-child(odd):hover td {
background:#4E5066;
}

tr:last-child td:first-child {
border-bottom-left-radius:3px;
}

tr:last-child td:last-child {
border-bottom-right-radius:3px;
}

td {
background:#FFFFFF;
padding:20px;
text-align:left;
vertical-align:middle;
font-weight:300;
font-size:12px;
text-shadow: -1px -1px 1px rgba(0, 0, 0, 0.1);
border-right: 1px solid #C1C3D1;
}

td:last-child {
border-right: 0px;
}

th.text-left {
text-align: left;
}

th.text-center {
text-align: center;
}

th.text-right {
text-align: right;
}

td.text-left {
text-align: left;
}

td.text-center {
text-align: center;
}

td.text-right {
text-align: right;
}

/*** Footer styles ***/

.footer-basic-centered{
background-color: #292c2f;
box-shadow: 0 1px 1px 0 rgba(0, 0, 0, 0.12);
box-sizing: border-box;
width: 100%;
text-align: center;
font: normal 18px sans-serif;

padding: 45px;
margin-top: 80px;
}

.footer-basic-centered .footer-Department{
color:  #8d9093;
font-size: 24px;
margin: 0;
}

.footer-basic-centered .footer-Generated{
color:  #8f9296;
font-size: 14px;
margin: 0;
}

.footer-basic-centered .footer-links{
list-style: none;
font-weight: bold;
color:  #ffffff;
padding: 35px 0 23px;
margin: 0;
}

.footer-basic-centered .footer-links a{
display:inline-block;
text-decoration: none;
color: inherit;
}

</style>
"@
  $Report = '

  </style>
  <div class="header">
  <H1>Watson Marlow Fluid Technology Group</H1>
  </div>
  &nbsp;
  &nbsp;
  '
  $Report += "<H2>Report type: $Title</H2>"
  $Path    = (Test-Path -Path $Export)
  if (-Not $Export) {
    Write-host "$Export path does not exist" -ForegroundColor Red  
    break
  }
  # Connectivty and query code
  $initParams = @{}
  if((Get-Module ConfigurationManager) -eq $null) {
      Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" @initParams 
  }
  if((Get-PSDrive -Name $SiteCode -PSProvider CMSite -ErrorAction SilentlyContinue) -eq $null) {
      New-PSDrive -Name $SiteCode -PSProvider CMSite -Root $ProviderMachineName @initParams
  }
  Set-Location "$($SiteCode):\" @initParams

  Foreach ($DeviceCollection in $Collection) {
      $Name    = "<H3>$DeviceCollection</H3>"
      $Devices = (Get-CMDevice -CollectionName "$DeviceCollection")
      $Output  = New-Object System.Collections.ArrayList
      Foreach ($Device in $Devices) {
          if (-not $Device.ClientType) {
              $Deviceinfo = New-Object psobject 
              $Online     = (Test-NetConnection $Device.Name -Hops 1)
              if (-Not $Online.PingSucceeded) {
                  $RPC = $False
              }
              else { $RPC = Get-WMIObject -Class Win32_OperatingSystem -ComputerName $Device.Name }
              if (-Not [bool]$RPC) {
                    $WMI = $False
                   }
              else { $WMI = $True }
              $Deviceinfo | Add-Member -MemberType NoteProperty -Name "Computer"    -Value $Device.Name
              $Deviceinfo | Add-Member -MemberType NoteProperty -Name "Client"      -Value "No"
              $Deviceinfo | Add-Member -MemberType NoteProperty -Name "ICMP"        -Value "$($Online.PingSucceeded)"
              $Deviceinfo | Add-Member -MemberType NoteProperty -Name "WMI Enabled" -Value $WMI
              $Output    += $Deviceinfo
              $Conversion = $Output | ConvertTo-Html
          }
      }     
      $Report += $Name
      $Report += "&nbsp"
      if ($null -eq $Conversion) {
        $Report += '<b Style="font-size: 14px; color: green;">No data</b>'
        $Report += "&nbsp"
        $Report += "<h2> Report Summary for $Collection</h2>"
        $Report += "&nbsp"
        $Report += '<b Style="font-size: 14px; color: green;">All client machines in' + " $Collection have been installed </b>"
      }
      else {
          $ICMPCount = $Output."ICMP" | where {$_ -eq "False"}
          $WMICount  = $Output."WMI Enabled" | where {$_ -eq $False}
          $Report += $Conversion
          $Report += "&nbsp"
          $Report += "&nbsp"  
          $Report += "<h2> Report Summary:</h2>"
          $Report += '<p class="summary">' +"There are $($Output.Computer.Count) computers and servers in $Collection that do not have the System Center client installed on the host.`n<br>
                                             Of the $($Output.Computer.Count) devices in $Collection, $($ICMPCount.count) are unreachable by ping.`n<br>
                                             $($WMICount.Count) devices are unavailable by WMI (Remote Procedure Call) Turn off the firewall or redploy the group GPO</p>"}
  }
  $Report += @"
<footer class="footer-basic-centered">
<p class="footer-Department">Watson Marlow Fluid Technology Group IT</p>
<p class="footer-links">
  <a href="mailto:sam.reece@wmftg.com">Contact</a>
</p>
<p class="footer-Generated">Generated on: $Time $Date</p>
</footer>
"@
ConvertTo-Html -head $header -Body $Report | Out-File "$Export\$Collection - $Title.html"
Invoke-Item "$Export\$Collection - $Title.html"
}