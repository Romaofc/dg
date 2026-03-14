```powershell
# ======================================
# Medisystems TOOLKIT
# ======================================

# Tema estilo MediSystems
$Host.UI.RawUI.BackgroundColor = "DarkBlue"
$Host.UI.RawUI.ForegroundColor = "White"
Clear-Host

Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

# ======================================
# LOGO
# ======================================

Write-Host "   ╭──────────────────────────────╮" -ForegroundColor Cyan
Write-Host "   │  ╭────────────────────────╮  │" -ForegroundColor Cyan
Write-Host "   │  │      /\        /\      │  │" -ForegroundColor Cyan
Write-Host "   │  │     /  \______/  \     │──┼───────────────────────────┬───┬──" -ForegroundColor Cyan
Write-Host "   │  │    /              \    │  │                           │   │" -ForegroundColor Cyan
Write-Host "   │  ╰────────────────────────╯  │                           │   │" -ForegroundColor Cyan
Write-Host "   ╰───────────────┬──────────────╯                           │   │" -ForegroundColor Cyan
Write-Host "                   │                                          │   │" -ForegroundColor Cyan
Write-Host "                  ─┴─                                         │   │" -ForegroundColor Cyan
Write-Host ""
Write-Host "                        MEDi" -ForegroundColor White
Write-Host "                     S Y S T E M S" -ForegroundColor White

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "           Medisystems TOOLKIT" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "1 - Preparar PC" -ForegroundColor White
Write-Host "2 - Especificações do sistema" -ForegroundColor White
Write-Host "3 - Fazer backup do usuário" -ForegroundColor White
Write-Host "4 - Restaurar backup" -ForegroundColor White
Write-Host "5 - Atualizar Windows para Pro" -ForegroundColor White
Write-Host ""

$opcao = Read-Host "Escolha uma opção"

# ====================================
# OPÇÃO 1 - PREPARAR PC
# ====================================

if ($opcao -eq "1") {

Write-Host ""
Write-Host "Preparando o PC..." -ForegroundColor Cyan

# ativar administrador
net user Administrador /active:yes
net localgroup Administradores Administrador /add

# verificar internet
Write-Host ""
Write-Host "Verificando conexão com internet..." -ForegroundColor Cyan

if (-not (Test-Connection google.com -Count 2 -Quiet)) {

Write-Host "Sem conexão com internet!" -ForegroundColor Red
Pause
exit

}

Write-Host "Internet OK." -ForegroundColor Green

# download ninite
Write-Host ""
Write-Host "Baixando instalador de programas..." -ForegroundColor Cyan

$niniteURL = "https://ninite.com/.net10-.net4.8.1-.net8-.net9-.neta10-.neta8-.neta9-.netx10-.netx8-.netx9-anydesk-chrome-googledrivefordesktop-teamviewer15-vcredist05-vcredist08-vcredist10-vcredist12-vcredist13-vcredist15-vcredistarm15-vcredistx05-vcredistx08-vcredistx10-vcredistx12-vcredistx13-vcredistx15-winrar/ninite.exe"

$ninitePath = "$env:TEMP\ninite.exe"

Invoke-WebRequest $niniteURL -OutFile $ninitePath

# barra de progresso fake (instalação)
for ($i=0; $i -le 100; $i+=5) {

Write-Progress -Activity "Instalando programas" -Status "$i% completo" -PercentComplete $i
Start-Sleep -Milliseconds 300

}

Start-Process $ninitePath -Wait

Write-Host ""
Write-Host "Programas instalados com sucesso." -ForegroundColor Green

# Windows Update
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
```
