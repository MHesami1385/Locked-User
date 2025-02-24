# Define the script path and task details
$scriptPath = "C:\scripts\Locked-User.ps1"
$taskName = "Run Script on Event 4740"
$taskDescription = "Runs a PowerShell script when Event ID 4740 (user account locked out) is triggered."

# Ensure the script path exists
if (-not (Test-Path $scriptPath)) {
    Write-Host "Script path '$scriptPath' does not exist. Please update the script path and try again." -ForegroundColor Red
    exit
}

# Define the event-based trigger (Event ID 4740 in the Security log)
$trigger = New-ScheduledTaskTrigger -AtStartup  # Temporary trigger, will be replaced
$trigger = New-ScheduledTaskTrigger -AtLogOn    # Temporary trigger, will be replaced

# Create an event-based trigger for Event ID 4740
$CIMTriggerClass = Get-CimClass -ClassName MSFT_TaskEventTrigger -Namespace Root/Microsoft/Windows/TaskScheduler
$trigger = New-CimInstance -CimClass $CIMTriggerClass -ClientOnly
$trigger.Subscription = @"
<QueryList>
  <Query Id="0" Path="Security">
    <Select Path="Security">*[System[EventID=4740]]</Select>
  </Query>
</QueryList>
"@
$trigger.Enabled = $true

# Define the action (run the PowerShell script)
$action = New-ScheduledTaskAction -Execute "powershell.exe" `
    -Argument "-ExecutionPolicy Bypass -File `"$scriptPath`""

# Define the principal (run with highest privileges)
$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest

# Register the scheduled task
Register-ScheduledTask -TaskName $taskName `
    -Description $taskDescription `
    -Trigger $trigger `
    -Action $action `
    -Principal $principal

# Output success message
Write-Host "Scheduled task '$taskName' created successfully!" -ForegroundColor Green