# Display the computer's hostname
Write-Host "Computer Name: $env:COMPUTERNAME"

# Check for Administrator privileges
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Restarting script as Administrator..."
    $script = $MyInvocation.MyCommand.Definition
    $arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$script`""
    Start-Process powershell -Verb RunAs -ArgumentList $arguments
    exit
}

# Get all local user accounts and audit
$users = Get-LocalUser
foreach ($user in $users) {
    # Skip built-in accounts
    if ($user.Name -in @('Administrator', 'DefaultAccount', 'Guest', 'WDAGUtilityAccount')) { continue }

    $prompt = "Is '$($user.Name)' an Authorized User? [Y/n]: "
    $answer = Read-Host -Prompt $prompt

    if ($answer -eq '' -or $answer -match '^[Yy]$') {
        Write-Host "'$($user.Name)' kept."
    } elseif ($answer -match '^[Nn]$') {
        Write-Host "Deleting user '$($user.Name)'..."
        Remove-LocalUser -Name $user.Name
    } else {
        Write-Host "Invalid input. '$($user.Name)' kept."
    }
}

# Display the Windows version
Write-Host "Windows Version:"
Get-ComputerInfo | Select-Object -Property WindowsProductName, WindowsVersion, OsHardwareAbstractionLayer

# Define menu options
$menuOptions = @(
    "Document the system",
    "Enable updates",
    "User Auditing",
    "Exit"
)

# Define functions for each option
function Get-SystemDocument {
    Write-Host "`n--- Starting: Document the system ---`n"
}

function Enable-Updates {
    Write-Host "`n--- Starting: Enable updates ---`n"
}

function Get-UserAuditing {
    Write-Host "`n--- Starting: User Auditing ---`n"
}

# Menu loop
:menu do {
    Write-Host "`nSelect an option:`n"
    for ($i = 0; $i -lt $menuOptions.Count; $i++) {
        Write-Host "$($i + 1). $($menuOptions[$i])"
    }

    $selection = Read-Host "`nEnter the number of your choice"

    switch ($selection) {
        "1" { Get-SystemDocument }
        "2" { Enable-Updates }
        "3" { Get-UserAuditing }
        "4" { Write-Host "`nExiting..."; break menu }
        default { Write-Host "`nInvalid selection. Please try again." }
    }
} while ($true)
