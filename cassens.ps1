Import-Module -Name PushBullet

$APIKey = "PUSHBULLET_API_KEY"
$Title = "Outback Order"

$uri_vin     = "https://www.cassens.com/FileStorageService/FileStorageService"
$uri_receipt = "https://www.cassens.com/FileStorageService/DeliveryReceiptServlet"
$headers = @{   "Sec-Fetch-Mode"="cors"; `
                "Sec-Fetch-Site"="same-origin"; `
                "Origin"="https://www.cassens.com"; `
                "Accept-Encoding"="gzip, deflate, br"; `
                "Accept-Language"="en-US,en;q=0.9,ceb;q=0.8"; `
                "User-Agent"="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/77.0.3865.120 Safari/537.36"; `
                "Accept"="application/json, text/javascript, */*; q=0.01"; `
                "Referer"="https://www.cassens.com/pages/tracking/"; `
                "X-Requested-With"="XMLHttpRequest"; `
                "Cookie"="PHPSESSID=cqogun8ia7esg9oiprd3ikbrf5"}
$content_type   = "application/x-www-form-urlencoded; charset=UTF-8"
$body_vin       = "module=Tracking&inputParam=%7B%22vin%22%3A%224S4BTGKD6L3121123%22%2C%22dlr_code%22%3A%22070844%22%7D"
$body_receipt   = "module=DeliveryReceipts&inputParam=%7B%22from%22%3A%222019-10-12%22%2C%22to%22%3A%222019-10-20%22%2C%22mfgname%22%3A%22SU%22%2C%22value%22%3A%22070844%22%2C%22type%22%3A%22dealer_code%22%2C%22search_first%22%3A%22no%22%2C%22remember%22%3A%22false%22%7D"

$APICredential      = New-Object System.Management.Automation.PSCredential ($APIKey, (ConvertTo-SecureString $APIKey -AsPlainText -Force))
$vin_response       = Invoke-WebRequest -Uri $uri_vin     -Method "POST" -Headers $headers -ContentType $content_type -Body $body_vin
$delivery_receipt   = Invoke-WebRequest -Uri $uri_receipt -Method "POST" -Headers $headers -ContentType $content_type -Body $body_receipt

$pretty_vin = ConvertFrom-Json -InputObject $vin_response
$pretty_receipt = ConvertFrom-Json -InputObject $delivery_receipt

do {
    Clear-Host    
    Write-Host "$(Get-Date)"
    $pretty_vin.details | Format-Table -AutoSize
    $pretty_receipt.details | Format-Table -AutoSize
    Start-Sleep -Seconds 120
}while ([string]::IsNullOrWhiteSpace($pretty_vin.details.shpdt))

$Body = @{
        type = "note"
        title = $Title
        body = "$($pretty_vin.details | Format-Table -AutoSize | Out-String)  `n $($pretty_receipt.details | Format-Table -AutoSize | Out-String )"
        }

Invoke-RestMethod -Method POST -Uri "https://api.pushbullet.com/v2/pushes" -Credential $APICredential -Body $Body
