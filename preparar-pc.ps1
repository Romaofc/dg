Clear-Host

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

# =========================================
# OPÇÃO 1 - PREPARAR PC
# =========================================

if ($opcao -eq "1") {

Write-Host ""
Write-Host "Preparando o PC..." -ForegroundColor Cyan
Write-Host ""

net user Administrador /active:yes
net localgroup Administrators Administrador /add

Add-Type -AssemblyName System.Windows.Forms
$folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
$folderBrowser.Description = "Selecione a pasta onde estão os instaladores"

if ($folderBrowser.ShowDialog() -eq "OK") {

$pasta = $folderBrowser.SelectedPath
$arquivos = Get-ChildItem $pasta -Filter *.exe

$total = $arquivos.Count
$i = 0

foreach ($arquivo in $arquivos) {

$i++

Write-Progress -Activity "Instalando programas" `
-Status "$($arquivo.Name)" `
-PercentComplete (($i / $total) * 100)

Start-Process $arquivo.FullName -Wait

}

Write-Host ""
Write-Host "Programas instalados." -ForegroundColor Green

}
else {

Write-Host "Nenhuma pasta selecionada." -ForegroundColor Red

}

Write-Host ""
Write-Host "Executando Windows Update..." -ForegroundColor Cyan

Install-PackageProvider -Name NuGet -Force
Install-Module PSWindowsUpdate -Force
Import-Module PSWindowsUpdate

Install-WindowsUpdate -AcceptAll -AutoReboot

}

# =========================================
# OPÇÃO 2 - ESPECIFICAÇÕES
# =========================================

elseif ($opcao -eq "2") {

Clear-Host

Write-Host "========== SISTEMA ==========" -ForegroundColor Cyan

$nome = $env:COMPUTERNAME
$os = Get-CimInstance Win32_OperatingSystem
$cpu = Get-CimInstance Win32_Processor
$ram = Get-CimInstance Win32_PhysicalMemory
$gpu = Get-CimInstance Win32_VideoController
$discos = Get-PhysicalDisk
$volumes = Get-Volume | Where-Object {$_.DriveLetter}

Write-Host "Nome do dispositivo: $nome"
Write-Host "Sistema operacional: $($os.Caption)"
Write-Host "Versão do Windows: $($os.Version)"
Write-Host "Arquitetura: $($os.OSArchitecture)"

Write-Host ""
Write-Host "========== HARDWARE ==========" -ForegroundColor Cyan

$ramTotal = [math]::Round(($os.TotalVisibleMemorySize/1MB),2)

Write-Host "Processador: $($cpu.Name)"
Write-Host "Memória RAM total: $ramTotal GB"

$ramTipo = switch ($ram[0].SMBIOSMemoryType) {
20 {"DDR"}
21 {"DDR2"}
24 {"DDR3"}
26 {"DDR4"}
34 {"DDR5"}
default {"Desconhecido"}
}

Write-Host "Tipo da RAM: $ramTipo"
Write-Host "Velocidade da RAM: $($ram[0].Speed) MHz"

Write-Host ""
Write-Host "========== GRÁFICO ==========" -ForegroundColor Cyan

Write-Host "Placa de vídeo: $($gpu[0].Name)"

Write-Host ""
Write-Host "========== ARMAZENAMENTO ==========" -ForegroundColor Cyan

$discosFisicos = Get-Disk
Write-Host "Quantidade de discos: $($discosFisicos.Count)"
Write-Host ""

foreach ($volume in $volumes) {

$total = [math]::Round($volume.Size/1GB,2)
$livre = [math]::Round($volume.SizeRemaining/1GB,2)
$usado = 100 - (($livre / $total) * 100)

Write-Host "Disco $($volume.DriveLetter):"
Write-Host "Espaço total: $total GB"
Write-Host "Espaço livre: $livre GB"
Write-Host ("Porcentagem usada: {0:N0}%" -f $usado)
Write-Host ""

}

Pause

}

# =========================================
# OPÇÃO 3 - BACKUP
# =========================================

elseif ($opcao -eq "3") {

Add-Type -AssemblyName System.Windows.Forms

$folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
$folderBrowser.Description = "Selecione onde salvar o backup"

if ($folderBrowser.ShowDialog() -eq "OK") {

$destinoBase = $folderBrowser.SelectedPath
$pc = $env:COMPUTERNAME
$destino = "$destinoBase\Backup-$pc"

New-Item -ItemType Directory -Path $destino -Force

$pastas = @(
"Desktop",
"Documents",
"Downloads",
"Pictures",
"Videos"
)

$total = $pastas.Count
$i = 0

foreach ($pasta in $pastas) {

$i++

Write-Progress -Activity "Fazendo backup..." `
-Status "$pasta" `
-PercentComplete (($i / $total) * 100)

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

# =========================================
# OPÇÃO 4 - RESTAURAR BACKUP
# =========================================

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

Write-Progress -Activity "Restaurando backup..." `
-Status "$($pasta.Name)" `
-PercentComplete (($i / $total) * 100)

$destino = "$env:USERPROFILE\$($pasta.Name)"

Copy-Item $pasta.FullName $destino -Recurse -Force

}

Write-Host ""
Write-Host "Backup restaurado com sucesso." -ForegroundColor Green

}

Pause

}

# =========================================
# OPÇÃO 5 - UPGRADE WINDOWS
# =========================================

elseif ($opcao -eq "5") {

Clear-Host

Write-Host "=====================================" -ForegroundColor DarkGray
Write-Host "        ATUALIZAR WINDOWS PARA PRO" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor DarkGray
Write-Host ""

$os = Get-CimInstance Win32_OperatingSystem
$versao = $os.Caption

Write-Host "Sistema atual: $versao"
Write-Host ""

if ($versao -match "Pro") {

Write-Host "Este sistema já está na versão Pro." -ForegroundColor Green

}

elseif ($versao -match "Home") {

Write-Host "Atualizando para Windows Pro..." -ForegroundColor Yellow
Write-Host "O computador poderá reiniciar." -ForegroundColor Yellow

Start-Sleep 3

changepk.exe /ProductKey VK7JG-NPHTM-C97JM-9MPGT-3V66T

}

else {

Write-Host "Não foi possível determinar a versão do Windows." -ForegroundColor Red

}

Pause

}