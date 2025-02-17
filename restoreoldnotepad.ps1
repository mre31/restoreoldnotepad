# Check for administrator privileges
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "This script requires administrator privileges!"
    Write-Warning "Please run PowerShell as administrator."
    Break
}

try {
    # Get system UI language
    $systemLang = Get-WinSystemLocale
    
    # Define text document name based on language
    $textDocName = switch ($systemLang.Name) {
        "tr-TR" { "Metin Belgesi" }
        "de-DE" { "Textdokument" }
        "fr-FR" { "Document Texte" }
        "es-ES" { "Documento de Texto" }
        "it-IT" { "Documento di Testo" }
        "pt-BR" { "Documento de Texto" }
        "pt-PT" { "Documento de Texto" }
        "nl-NL" { "Tekstdocument" }
        "pl-PL" { "Dokument tekstowy" }
        "hu-HU" { "Szoveges dokumentum" }
        "cs-CZ" { "Textovy dokument" }
        "sv-SE" { "Textdokument" }
        "da-DK" { "Tekstdokument" }
        "fi-FI" { "Tekstitiedosto" }
        "nb-NO" { "Tekstdokument" }
        "ro-RO" { "Document text" }
        "hr-HR" { "Tekstualni dokument" }
        "id-ID" { "Dokumen Teks" }
        "ms-MY" { "Dokumen Teks" }
        default { "Text Document" }
    }
    
    # First remove the new Windows Store Notepad
    Get-AppxPackage Microsoft.WindowsNotepad | Remove-AppxPackage
    Write-Host "New Notepad version has been removed." -ForegroundColor Green
    
    # Wait for 2 seconds
    Start-Sleep -Seconds 2
    
    # Create shortcut to classic Notepad in Start Menu
    $WshShell = New-Object -comObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut("$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Notepad.lnk")
    $Shortcut.TargetPath = "C:\Windows\System32\notepad.exe"
    $Shortcut.Save()
    
    # Add classic Notepad to right-click context menu
    $txtRegPath = "HKLM:\SOFTWARE\Classes\.txt"
    if (!(Test-Path $txtRegPath)) {
        New-Item -Path $txtRegPath -Force | Out-Null
    }
    Set-ItemProperty -Path $txtRegPath -Name "(Default)" -Value "txtfile" -Force
    
    # Add ShellNew key
    $shellNewPath = "$txtRegPath\ShellNew"
    if (!(Test-Path $shellNewPath)) {
        New-Item -Path $shellNewPath -Force | Out-Null
    }
    New-ItemProperty -Path $shellNewPath -Name "NullFile" -Value "" -PropertyType String -Force | Out-Null
    
    # Configure txtfile association
    $txtfilePath = "HKLM:\SOFTWARE\Classes\txtfile"
    if (!(Test-Path $txtfilePath)) {
        New-Item -Path $txtfilePath -Force | Out-Null
    }
    Set-ItemProperty -Path $txtfilePath -Name "(Default)" -Value $textDocName -Force
    
    # Add command for text files
    $cmdPath = "$txtfilePath\shell\open\command"
    if (!(Test-Path $cmdPath)) {
        New-Item -Path $cmdPath -Force | Out-Null
    }
    Set-ItemProperty -Path $cmdPath -Name "(Default)" -Value "`"C:\Windows\System32\notepad.exe`" `"%1`"" -Force
    
    Write-Host "Classic Notepad has been fully restored with context menu integration." -ForegroundColor Green
    
    # Notify shell of the change
    Stop-Process -Name explorer -Force
    Start-Process explorer
} catch {
    Write-Error "An error occurred: $_"
} 