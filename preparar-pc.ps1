Write-Host "====================================="
Write-Host "      SCRIPT DE PREPARAÇÃO DO PC"
Write-Host "====================================="
Write-Host ""

# Ativar usuário Administrador
Write-Host "Ativando usuario Administrador..."
net user Administrador /active:yes
net localgroup Administrators Administrador /add

Write-Host "Administrador ativado."
Write-Host ""

# Selecionar pasta com programas
Add-Type -AssemblyName System.Windows.Forms
$folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
$folderBrowser.Description = "Selecione a pasta onde estão os instaladores"

if ($folderBrowser.ShowDialog() -eq "OK") {

    $pasta = $folderBrowser.SelectedPath
    Write-Host "Pasta selecionada: $pasta"
    Write-Host ""

    $arquivos = Get-ChildItem $pasta -Filter *.exe

    foreach ($arquivo in $arquivos) {
        Write-Host "Instalando $($arquivo.Name)..."
        Start-Process $arquivo.FullName -Wait
    }

    Write-Host ""
    Write-Host "Instalação dos programas finalizada."
}
else {
    Write-Host "Nenhuma pasta selecionada."
}

Write-Host ""
Write-Host "Executando Windows Update..."

# Instalar módulo de Windows Update
Install-PackageProvider -Name NuGet -Force
Install-Module PSWindowsUpdate -Force

Import-Module PSWindowsUpdate

Get-WindowsUpdate
Install-WindowsUpdate -AcceptAll -AutoReboot

Write-Host ""
Write-Host "Processo finalizado."
Pause
