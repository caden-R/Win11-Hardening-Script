# 1. Display the computer's hostname
Write-Host "Computer Name: $env:COMPUTERNAME"

# 2. Check for Administrator privileges
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Restarting script as Administrator..."
    $script = $MyInvocation.MyCommand.Definition
    $arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$script`""
    Start-Process powershell -Verb RunAs -ArgumentList $arguments
    exit
}

# 3. Display the Windows version
Write-Host "`nWindows Version:"
$info = Get-ComputerInfo | Select-Object WindowsProductName, WindowsVersion, OsHardwareAbstractionLayer
$info | Format-List

# 4. Define menu options
$menuOptions = @(
    "Document the system",
    "Enable updates",
    "User Auditing",
    "Exit"
)

# 5. Define functions for menu options
function Get-SystemDocument {
    Write-Host "`n--- Starting: Document the system ---`n"
    # Add system documentation logic here
}

function Enable-Updates {
    Write-Host "`n--- Starting: Enable updates ---`n"
    # Add Windows update logic here
}

function Get-UserAuditing {
    Write-Host "`n--- Starting: User Auditing ---`n"

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
            $confirm = Read-Host "Are you sure you want to delete '$($user.Name)'? [Y/n]"
            if ($confirm -eq '' -or $confirm -match '^[Yy]$') {
                Write-Host "Deleting user '$($user.Name)'..."
                Remove-LocalUser -Name $user.Name
            } else {
                Write-Host "'$($user.Name)' kept."
            }
        } else {
            Write-Host "Invalid input. '$($user.Name)' kept."
        }
    }
}

# 6. Menu loop
while ($true) {
    Write-Host "`nSelect an option:`n"
    for ($i = 0; $i -lt $menuOptions.Count; $i++) {
        Write-Host "$($i + 1). $($menuOptions[$i])"
    }

    $selection = Read-Host "`nEnter the number of your choice"

    switch ($selection) {
        "1" { Get-SystemDocument }
        "2" { Enable-Updates }
        "3" { Get-UserAuditing }
        "4" { Write-Host "`nExiting..."; break }
        default { Write-Host "`nInvalid selection. Please try again." }
    }
}
