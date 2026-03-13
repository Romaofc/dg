Clear-Host

Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

Write-Host "=====================================" -ForegroundColor DarkGray
Write-Host "        DG TOOLKIT - SISTEMA" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor DarkGray
Write-Host ""

Write-Host "1 - Preparar PC" -ForegroundColor Yellow
Write-Host "2 - Especificações do sistema" -ForegroundColor Yellow
Write-Host "3 - Fazer backup do usuário" -ForegroundColor Yellow
Write-Host "4 - Restaurar backup" -ForegroundColor Yellow
Write-Host "5 - Atualizar Windows para Pro" -ForegroundColor Yellow
Write-Host ""

$opcao = Read-Host "Escolha uma opção"

# FUNÇÃO PARA DETECTAR PROGRAMAS INSTALADOS
function Get-InstalledPrograms {

$paths = @(
"HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
"HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
)

$programas = foreach ($path in $paths) {

Get-ItemProperty $path -ErrorAction SilentlyContinue |
Where-Object {$_.DisplayName} |
Select-Object -ExpandProperty DisplayName

}

return $programas

}

# =============================
# OPÇÃO 1 - PREPARAR PC
# =============================

if ($opcao -eq "1") {

Write-Host ""
Write-Host "Preparando o PC..." -ForegroundColor Cyan
Write-Host ""

net user Administrador /active:yes
net localgroup Administradores Administrador /add

$programasInstalados = Get-InstalledPrograms

Add-Type -AssemblyName System.Windows.Forms

$folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
$folderBrowser.Description = "Selecione a pasta dos instaladores"

if ($folderBrowser.ShowDialog() -eq "OK") {

$pasta = $folderBrowser.SelectedPath

$arquivos = Get-ChildItem $pasta -Include *.exe,*.msi -Recurse

$total = $arquivos.Count
$i = 0

foreach ($arquivo in $arquivos) {

$i++
$percent = [int](($i / $total) * 100)

$nomePrograma = [System.IO.Path]::GetFileNameWithoutExtension($arquivo.Name)

if ($programasInstalados -like "*$nomePrograma*") {

Write-Host "$nomePrograma já instalado [$percent%]" -ForegroundColor Green
continue

}

Write-Host "Instalando $nomePrograma [$percent%]" -ForegroundColor Yellow

if ($arquivo.Extension -eq ".msi") {

Start-Process "msiexec.exe" -ArgumentList "/i `"$($arquivo.FullName)`" /qn /norestart" -Wait

}
else {

Start-Process $arquivo.FullName -ArgumentList "/S /silent /quiet /qn /norestart" -Wait

}

}

Write-Host ""
Write-Host "Processo de instalação finalizado." -ForegroundColor Green

}

Write-Host ""
Write-Host "Executando Windows Update..." -ForegroundColor Cyan

Install-PackageProvider -Name NuGet -Force -ErrorAction SilentlyContinue
Install-Module PSWindowsUpdate -Force -ErrorAction SilentlyContinue

Import-Module PSWindowsUpdate -ErrorAction SilentlyContinue

Install-WindowsUpdate -AcceptAll -AutoReboot -ErrorAction SilentlyContinue

Pause

}

# =============================
# OPÇÃO 2 - ESPECIFICAÇÕES
# =============================

elseif ($opcao -eq "2") {

Clear-Host

Write-Host "========== SISTEMA ==========" -ForegroundColor Cyan

$nome = $env:COMPUTERNAME
$os = Get-CimInstance Win32_OperatingSystem
$cpu = Get-CimInstance Win32_Processor
$ram = Get-CimInstance Win32_PhysicalMemory
$gpu = Get-CimInstance Win32_VideoController

Write-Host "Nome do dispositivo: $nome"
Write-Host "Sistema: $($os.Caption)"
Write-Host "Versão: $($os.Version)"
Write-Host "Arquitetura: $($os.OSArchitecture)"

Write-Host ""
Write-Host "========== HARDWARE ==========" -ForegroundColor Cyan

$ramTotal = [math]::Round(($os.TotalVisibleMemorySize/1MB),2)

Write-Host "Processador: $($cpu.Name)"
Write-Host "Memória RAM: $ramTotal GB"
Write-Host "Velocidade RAM: $($ram[0].Speed) MHz"

Write-Host ""
Write-Host "========== GRÁFICOS ==========" -ForegroundColor Cyan

Write-Host "GPU: $($gpu[0].Name)"

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

# =============================
# OPÇÃO 3 - BACKUP
# =============================

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

$total = $pastas.Count
$i = 0

foreach ($pasta in $pastas) {

$i++
$percent = [int](($i / $total) * 100)

Write-Host "Copiando $pasta [$percent%]" -ForegroundColor Yellow

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

# =============================
# OPÇÃO 4 - RESTAURAR BACKUP
# =============================

elseif ($opcao -eq "4") {

Add-Type -AssemblyName System.Windows.Forms

$folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
$folderBrowser.Description = "Selecione a pasta do backup"

if ($folderBrowser.ShowDialog() -eq "OK") {

$backup = $folderBrowser.SelectedPath

$pastas = Get-ChildItem $backup -Directory

$total = $pastas.Count
$i = 0

foreach ($pasta in $pastas) {

$i++
$percent = [int](($i / $total) * 100)

Write-Host "Restaurando $($pasta.Name) [$percent%]" -ForegroundColor Yellow

$destino = "$env:USERPROFILE\$($pasta.Name)"

Copy-Item $pasta.FullName $destino -Recurse -Force

}

Write-Host ""
Write-Host "Backup restaurado." -ForegroundColor Green

}

Pause

}

# =============================
# OPÇÃO 5 - WINDOWS PRO
# =============================

elseif ($opcao -eq "5") {

Clear-Host

Write-Host "Atualização para Windows Pro" -ForegroundColor Cyan

$os = Get-CimInstance Win32_OperatingSystem
$versao = $os.Caption

Write-Host "Sistema atual: $versao"

if ($versao -match "Pro") {

Write-Host "O Windows já é Pro." -ForegroundColor Green

}
elseif ($versao -match "Home") {

Write-Host "Iniciando upgrade..." -ForegroundColor Yellow

changepk.exe /ProductKey VK7JG-NPHTM-C97JM-9MPGT-3V66T

}
else {

Write-Host "Versão do Windows não identificada." -ForegroundColor Red

}

Pause

}