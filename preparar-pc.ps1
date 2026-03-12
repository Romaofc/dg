Write-Host "====================================="
Write-Host "        FERRAMENTA DE SUPORTE"
Write-Host "====================================="
Write-Host ""
Write-Host "1 - Preparar PC"
Write-Host "2 - Especificações do sistema"
Write-Host ""

$opcao = Read-Host "Escolha uma opção"

# OPÇÃO 1 - PREPARAR PC
if ($opcao -eq "1") {

Write-Host ""
Write-Host "====================================="
Write-Host "      PREPARAÇÃO DO PC"
Write-Host "====================================="
Write-Host ""

# Ativar administrador
Write-Host "Ativando usuario Administrador..."
net user Administrador /active:yes
net localgroup Administrators Administrador /add
Write-Host "Administrador ativado."
Write-Host ""

# Selecionar pasta de instaladores
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

Install-PackageProvider -Name NuGet -Force
Install-Module PSWindowsUpdate -Force
Import-Module PSWindowsUpdate

Get-WindowsUpdate
Install-WindowsUpdate -AcceptAll -AutoReboot

Write-Host ""
Write-Host "Processo finalizado."

}

# OPÇÃO 2 - ESPECIFICAÇÕES DO SISTEMA
elseif ($opcao -eq "2") {

Write-Host ""
Write-Host "====================================="
Write-Host "      ESPECIFICAÇÕES DO SISTEMA"
Write-Host "====================================="
Write-Host ""

# SISTEMA
$os = Get-CimInstance Win32_OperatingSystem

Write-Host "Sistema operacional:" $os.Caption
Write-Host "Versão do Windows:" $os.Version
Write-Host "Arquitetura:" $os.OSArchitecture
Write-Host ""

# HARDWARE
$cpu = Get-CimInstance Win32_Processor
$ram = Get-CimInstance Win32_PhysicalMemory
$ramTotal = [math]::Round(($ram.Capacity | Measure-Object -Sum).Sum / 1GB,2)
$ramVelocidade = $ram[0].Speed
$slotsUsados = $ram.Count

# Tipo de RAM (simplificado)
$ramTipo = $ram[0].SMBIOSMemoryType

switch ($ramTipo) {
24 {$ramTipo = "DDR3"}
26 {$ramTipo = "DDR4"}
27 {$ramTipo = "DDR5"}
default {$ramTipo = "Desconhecido"}
}

Write-Host "Processador:" $cpu.Name
Write-Host "Memória RAM total:" $ramTotal "GB"
Write-Host "Tipo da RAM:" $ramTipo
Write-Host "Velocidade da RAM:" $ramVelocidade "MHz"
Write-Host "Slots de RAM usados:" $slotsUsados
Write-Host ""

# GPU
$gpu = Get-CimInstance Win32_VideoController
Write-Host "Placa de vídeo:" $gpu[0].Name
Write-Host ""

# DISCOS
$discos = Get-PhysicalDisk
Write-Host "Quantidade de discos:" $discos.Count
Write-Host ""

$volumes = Get-Volume | Where-Object {$_.DriveType -eq "Fixed"}

foreach ($volume in $volumes) {

$total = [math]::Round($volume.Size / 1GB,2)
$livre = [math]::Round($volume.SizeRemaining / 1GB,2)
$usado = [math]::Round((($volume.Size - $volume.SizeRemaining) / $volume.Size) * 100,2)

$tipo = ($discos | Select-Object -First 1).MediaType

Write-Host "Disco:" $volume.DriveLetter
Write-Host "Tipo:" $tipo
Write-Host "Espaço total:" $total "GB"
Write-Host "Espaço livre:" $livre "GB"
Write-Host "Porcentagem usada:" $usado "%"
Write-Host ""

}

}

else {

Write-Host ""
Write-Host "Opção inválida."

}

Pause
