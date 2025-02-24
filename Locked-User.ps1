# Define your Telegram bot details
$botToken = ""  # Replace with your bot token
$chatId = ""      # Replace with your chat ID
$telegramApiUrl = "https://api.telegram.org/bot$botToken/sendMessage"

# Enforce TLS 1.2 for PowerShell and cURL
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Get the latest account lockout event (Event ID 4740)
$lockoutEvent = Get-WinEvent -FilterHashtable @{LogName='Security'; Id=4740} -MaxEvents 1

if ($lockoutEvent) {
    # Convert to XML
    $eventXml = [xml]$lockoutEvent.ToXml()

    # Extract the username and domain
    $lockedUser = $eventXml.Event.EventData.Data | Where-Object { $_.Name -eq "TargetUserName" } | Select-Object -ExpandProperty "#text"
    $domainName = $eventXml.Event.EventData.Data | Where-Object { $_.Name -eq "TargetDomainName" } | Select-Object -ExpandProperty "#text"

    if ($lockedUser -and $domainName) {
        $fullUserName = "$domainName\$lockedUser"
        $message = "ALERT: Windows account locked! User: $fullUserName"

        # Encode the message for URL
        $encodedMessage = [Uri]::EscapeDataString($message)
        $telegramApiUrl = "https://api.telegram.org/bot$botToken/sendMessage?chat_id=$chatId&text=$encodedMessage"

        # Send with retries and Tor stability fixes
        $maxRetries = 10
        $retryCount = 0
        $success = $false

        do {
            $response = curl.exe --tlsv1.2 --no-sessionid --connect-timeout 60 --max-time 120 --socks5-hostname 127.0.0.1:9050 $telegramApiUrl
            if ($LASTEXITCODE -eq 0) {
                $success = $true
                Write-Output "Message sent via Tor: $response"
            } else {
                $retryCount++
                Write-Warning "Attempt $retryCount failed. Retrying in 5 seconds..."
                Start-Sleep -Seconds 5
            }
        } while (-not $success -and $retryCount -lt $maxRetries)

        if (-not $success) {
            Write-Error "Failed to send message after $maxRetries attempts."
        }
    } else {
        Write-Output "Error: Could not extract user details. Check event log structure."
    }
} else {
    Write-Output "No recent account lockout events found."
}
