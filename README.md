# Get-PendingClients summary

<p>
  This report has been built with PowerShell, HTML and CSS
  
This application has been built to helo you find out why devices within your SCCM collections do not have a Configuration Manager client installed.</p>

## Workflow

![Alt text](Get-PendingClients.PNG?raw=true "Get-PendingClients Workflow")

## Installation
```
cd <Path to file>
.\Get-PendingClients.ps1
```

## Examples

### Execute a query against a single device collection
```
Get-PendingClients -SiteCode AB1 -ProviderMachineName "SCCMServer" -Collection "All AB1 Systems" -Export "C:\system center"
```
### Execute a query against multiple device collections
```
Get-PendingClients -SiteCode AB1 -ProviderMachineName "SCCMServer" -Collection "Example collection 1", "Example collection 2" -Export "C:\system center"
```

### Output result
![Alt text](Example-result.PNG?raw=true "HTML Report")

### Output result when a collection does not have missing clients
![Alt text](Example-Result2.PNG?raw=true "HTML Report")
