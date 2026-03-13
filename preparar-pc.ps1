Clear-Host

Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

Write-Host "=====================================" -ForegroundColor DarkGray
Write-Host "           DG TOOLKIT" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor DarkGray
Write-Host ""

Write-Host "1 - Preparar PC"
Write-Host "2 - Especificações do sistema"
Write-Host "3 - Fazer backup do usuário"
Write-Host "4 - Restaurar backup"
Write-Host "5 - Atualizar Windows para Pro"
Write-Host ""

$opcao = Read-Host "Escolha uma opção"

# ====================================
# OPÇÃO 1 - PREPARAR PC
# ====================================

if ($opcao -eq "1") {

Write-Host ""
Write-Host "Preparando o PC..." -ForegroundColor Cyan

net user Administrador /active:yes
net localgroup Administradores Administrador /add

Add-Type -AssemblyName System.Windows.Forms

$folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
$folderBrowser.Description = "Selecione a pasta dos instaladores"

if ($folderBrowser.ShowDialog() -eq "OK") {

$pasta = $folderBrowser.SelectedPath

$arquivos = Get-ChildItem $pasta -Include *.exe,*.msi -Recurse

$processos = @()

foreach ($arquivo in $arquivos) {

$nomePrograma = [System.IO.Path]::GetFileNameWithoutExtension($arquivo.Name)

# detectar instalador do Office
if ($arquivo.Name -eq "setup.exe") {

$pastaOffice = Split-Path $arquivo.FullName
$config = Join-Path $pastaOffice "configuration.xml"

if (Test-Path $config) {

Write-Host "Iniciando instalação do Office..." -ForegroundColor Yellow

$p = Start-Process $arquivo.FullName -ArgumentList "/configure `"$config`"" -PassThru

$processos += $p
continue

}

}

Write-Host "Iniciando instalação de $nomePrograma..." -ForegroundColor Yellow

try {

if ($arquivo.Extension -eq ".msi") {

$p = Start-Process msiexec.exe -ArgumentList "/i `"$($arquivo.FullName)`" /qn /norestart" -PassThru

}
else {

$p = Start-Process $arquivo.FullName -ArgumentList "/S /silent /verysilent /qn /norestart" -PassThru

}

$processos += $p

}
catch {

Write-Host "Erro ao iniciar $nomePrograma" -ForegroundColor Red

}

}

Write-Host ""
Write-Host "Aguardando todas as instalações terminarem..." -ForegroundColor Cyan

$processos | Wait-Process

Write-Host ""
Write-Host "Todas as instalações concluídas." -ForegroundColor Green

}

Write-Host ""
Write-Host "Executando Windows Update..." -ForegroundColor Cyan

Install-PackageProvider -Name NuGet -Force -ErrorAction SilentlyContinue
Install-Module PSWindowsUpdate -Force -ErrorAction SilentlyContinue

Import-Module PSWindowsUpdate -ErrorAction SilentlyContinue

Install-WindowsUpdate -AcceptAll -AutoReboot -ErrorAction SilentlyContinue

Pause

}

# ====================================
# OPÇÃO 2 - ESPECIFICAÇÕES
# ====================================

elseif ($opcao -eq "2") {

Clear-Host

$nome = $env:COMPUTERNAME
$os = Get-CimInstance Win32_OperatingSystem
$cpu = Get-CimInstance Win32_Processor
$ram = Get-CimInstance Win32_PhysicalMemory
$gpu = Get-CimInstance Win32_VideoController

Write-Host "========== SISTEMA ==========" -ForegroundColor Cyan
Write-Host "Nome do dispositivo: $nome"
Write-Host "Sistema operacional: $($os.Caption)"
Write-Host "Versão do Windows: $($os.Version)"
Write-Host "Arquitetura: $($os.OSArchitecture)"

Write-Host ""
Write-Host "========== HARDWARE ==========" -ForegroundColor Cyan

$ramTotal = [math]::Round(($os.TotalVisibleMemorySize/1MB),2)

Write-Host "Processador: $($cpu.Name)"
Write-Host "Memória RAM total: $ramTotal GB"
Write-Host "Velocidade da RAM: $($ram[0].Speed) MHz"

Write-Host ""
Write-Host "========== GRÁFICO ==========" -ForegroundColor Cyan
Write-Host "Placa de vídeo: $($gpu[0].Name)"

Write-Host ""
Write-Host "========== ARMAZENAMENTO ==========" -ForegroundColor Cyan

$volumes = Get-Volume | Where-Object {$_.DriveLetter}

foreach ($volume in $volumes) {

$total = [math]::Round($volume.Size/1GB,2)
$livre = [math]::Round($volume.SizeRemaining/1GB,2)
$usado = 100 - (($livre / $total) * 100)

Write-Host ""
Write-Host "Disco $($volume.DriveLetter)"
Write-Host "Total: $total GB"
Write-Host "Livre: $livre GB"
Write-Host ("Uso: {0:N0}%" -f $usado)

}

Pause

}

# ====================================
# OPÇÃO 3 - BACKUP
# ====================================

elseif ($opcao -eq "3") {

Add-Type -AssemblyName System.Windows.Forms

$folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
$folderBrowser.Description = "Escolha onde salvar o backup"

if ($folderBrowser.ShowDialog() -eq "OK") {

$destinoBase = $folderBrowser.SelectedPath
$pc = $env:COMPUTERNAME
$destino = "$destinoBase\Backup-$pc"

New-Item -ItemType Directory -Path $destino -Force

$pastas = @("Desktop","Documents","Downloads","Pictures","Videos")

foreach ($pasta in $pastas) {

Write-Host "Copiando $pasta..." -ForegroundColor Yellow

$origem = "$env:USERPROFILE\$pasta"
$dest = "$destino\$pasta"

if (Test-Path $origem) {

Copy-Item $origem $dest -Recurse -Force

}

}

Write-Host ""
Write-Host "Backup concluído em: $destino" -ForegroundColor Green

}

Pause

}

# ====================================
# OPÇÃO 4 - RESTAURAR BACKUP
# ====================================

elseif ($opcao -eq "4") {

Add-Type -AssemblyName System.Windows.Forms

$folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
$folderBrowser.Description = "Selecione a pasta do backup"

if ($folderBrowser.ShowDialog() -eq "OK") {

$backup = $folderBrowser.SelectedPath

$pastas = Get-ChildItem $backup -Directory

foreach ($pasta in $pastas) {

Write-Host "Restaurando $($pasta.Name)..." -ForegroundColor Yellow

$destino = "$env:USERPROFILE\$($pasta.Name)"

Copy-Item $pasta.FullName $destino -Recurse -Force

}

Write-Host ""
Write-Host "Backup restaurado." -ForegroundColor Green

}

Pause

}

# ====================================
# OPÇÃO 5 - UPGRADE PARA PRO
# ====================================

elseif ($opcao -eq "5") {

Clear-Host

$os = Get-CimInstance Win32_OperatingSystem

Write-Host "Sistema atual: $($os.Caption)"

if ($os.Caption -match "Pro") {

Write-Host "O Windows já é Pro." -ForegroundColor Green

}
elseif ($os.Caption -match "Home") {

Write-Host "Iniciando upgrade para Pro..." -ForegroundColor Yellow

changepk.exe /ProductKey VK7JG-NPHTM-C97JM-9MPGT-3V66T

}
else {

Write-Host "Versão não identificada." -ForegroundColor Red

}

Pause

}