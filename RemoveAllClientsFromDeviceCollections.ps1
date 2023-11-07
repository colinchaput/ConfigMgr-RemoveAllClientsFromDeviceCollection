# Array of SCCM device collection names
$CollectionNames = @"
devicecollection1
devicecollection2
devicecollection3
devicecollection4
"@

#Determines script run location in order to find config files
$path = $MyInvocation.MyCommand.Path
if (!$path) { $path = $psISE.CurrentFile.Fullpath }
if ( $path) { $path = split-path $path -Parent }

# Imports site config values from config file
$config = Get-Content (Join-Path -Path $path -ChildPath "config.json") | ConvertFrom-Json

# Site connection information
$SiteCode = $config.SiteCode # Site code 
$ProviderMachineName = $config.ProviderMachineName # SMS Provider machine name (primary site server)

# Customizations
$initParams = @{}
#$initParams.Add("Verbose", $true) # Uncomment this line to enable verbose logging
#$initParams.Add("ErrorAction", "Stop") # Uncomment this line to stop the script on any errors

# Do not change anything below this line

# Import the ConfigurationManager.psd1 module 
if ($null -eq (Get-Module ConfigurationManager)) {
    Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" @initParams 
}

# Connect to the site's drive if it is not already present
if ($null -eq (Get-PSDrive -Name $SiteCode -PSProvider CMSite -ErrorAction SilentlyContinue)) {
    New-PSDrive -Name $SiteCode -PSProvider CMSite -Root $ProviderMachineName @initParams
}

# Set the current location to be the site code.
Set-Location "$($SiteCode):\" @initParams


# Import the Configuration Manager module
Import-Module ($Env:SMS_ADMIN_UI_PATH.Substring(0, $Env:SMS_ADMIN_UI_PATH.Length - 5) + '\ConfigurationManager.psd1')


$Collection = $CollectionNames -split "`n" | ForEach-Object { $_.Trim() }


# Iterate through the collection names and remove devices
foreach ($collectionName in $Collection) {
    $collection = Get-CMDeviceCollection -Name $collectionName

    if ($null -ne $collection) {
        Write-Host "Processing collection: $($collection.Name)"
        
        # Get devices in the collection
        $devicesInCollection = Get-CMDevice -CollectionId $collection.CollectionID
        
        # Remove each device from the collection
        foreach ($device in $devicesInCollection) {
            Write-Host "Removing device $($device.Name) from collection $($collection.Name)" -ForegroundColor Yellow
            Remove-CMDeviceCollectionDirectMembershipRule -CollectionId $collection.CollectionID -ResourceId $device.ResourceID -Force -Confirm:$false
        }
    }
    else {
        Write-Host "Collection not found: $collectionName"
    }
}


