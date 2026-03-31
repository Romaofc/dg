# ======================================
# Medisystems TOOLKIT PRO
# ======================================

$Host.UI.RawUI.BackgroundColor = "DarkBlue"
$Host.UI.RawUI.ForegroundColor = "White"
Clear-Host

try {
    Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force -ErrorAction Stop
} catch {}

# ======================================
# MENU
# ======================================

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "      Medisystems TOOLKIT PRO" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "1 - Preparar PC COMPLETO"
Write-Host "2 - Especificações do sistema"
Write-Host "3 - Backup"
Write-Host "4 - Restaurar backup"
Write-Host "5 - Upgrade Windows Pro"
Write-Host ""

$opcao = Read-Host "Escolha uma opção"

# ====================================
# OPÇÃO 1 - PREPARAÇÃO COMPLETA
# ====================================

if ($opcao -eq "1") {

    Write-Host "`nPreparando PC..." -ForegroundColor Cyan

    # Admin
    net user Administrator /active:yes 2>$null
    net user Administrador /active:yes 2>$null

    # Internet
    if (-not (Test-Connection "8.8.8.8" -Count 2 -Quiet)) {
        Write-Host "Sem internet!" -ForegroundColor Red
        Pause
        exit
    }

    Write-Host "Internet OK" -ForegroundColor Green

    # ====================================
    # PROGRAMAS (NINITE)
    # ====================================

    Write-Host "`nInstalando programas..." -ForegroundColor Cyan

    $niniteURL = "https://ninite.com/chrome-anydesk-teamviewer15-winrar/ninite.exe"
    $ninitePath = "$env:TEMP\ninite.exe"

    Invoke-WebRequest $niniteURL -OutFile $ninitePath
    Start-Process $ninitePath -Wait

    Write-Host "Programas instalados!" -ForegroundColor Green

    # ====================================
    # MICROSOFT 365
    # ====================================

    Write-Host "`nInstalando Microsoft 365..." -ForegroundColor Cyan

    $odtUrl = "https://officecdn.microsoft.com/pr/wsus/setup.exe"
    $odtPath = "$env:TEMP\office_setup.exe"

    Invoke-WebRequest $odtUrl -OutFile $odtPath

    $configXml = "$env:TEMP\config.xml"

@"
<Configuration>
  <Add OfficeClientEdition="64" Channel="Current">
    <Product ID="O365ProPlusRetail">
      <Language ID="pt-br" />
    </Product>
  </Add>
  <Display Level="None" AcceptEULA="TRUE" />
</Configuration>
"@ | Out-File -Encoding UTF8 $configXml

    Start-Process $odtPath -ArgumentList "/configure $configXml" -Wait

    Write-Host "Microsoft 365 instalado!" -ForegroundColor Green

    # ====================================
    # WINDOWS UPDATE
    # ====================================

    Write-Host "`nAtualizando Windows..." -ForegroundColor Cyan

    try {
        Install-PackageProvider -Name NuGet -Force -ErrorAction SilentlyContinue
        Install-Module PSWindowsUpdate -Force -ErrorAction SilentlyContinue
        Import-Module PSWindowsUpdate

        Get-WindowsUpdate -Install -AcceptAll -IgnoreReboot
    } catch {
        Write-Host "Erro no Windows Update" -ForegroundColor Red
    }

    # ====================================
    # FINAL
    # ====================================

    Write-Host "`n✔ CONFIGURAÇÃO FINALIZADA!" -ForegroundColor Green
    Write-Host "➡ Agora basta abrir o Office e fazer login com uma conta Microsoft." -ForegroundColor Yellow

    Pause
}

# ====================================
# OPÇÃO 2 - ESPECIFICAÇÕES
# ====================================

elseif ($opcao -eq "2") {

    Clear-Host

    $os = Get-CimInstance Win32_OperatingSystem
    $cpu = Get-CimInstance Win32_Processor
    $ram = Get-CimInstance Win32_PhysicalMemory
    $gpu = Get-CimInstance Win32_VideoController

    $ramTotal = [math]::Round(($os.TotalVisibleMemorySize/1MB),2)

    Write-Host "===== SISTEMA =====" -ForegroundColor Cyan
    Write-Host "Nome: $env:COMPUTERNAME"
    Write-Host "Windows: $($os.Caption)"
    Write-Host "Versão: $($os.Version)"

    Write-Host "`n===== HARDWARE =====" -ForegroundColor Cyan
    Write-Host "CPU: $($cpu.Name)"
    Write-Host "RAM: $ramTotal GB"
    Write-Host "Velocidade RAM: $($ram[0].Speed) MHz"

    Write-Host "`n===== GPU =====" -ForegroundColor Cyan
    Write-Host "$($gpu[0].Name)"

    Pause
}

# ====================================
# BACKUP
# ====================================

elseif ($opcao -eq "3") {

    $destino = Read-Host "Caminho do backup"

    if (!(Test-Path $destino)) {
        New-Item -ItemType Directory -Path $destino | Out-Null
    }

    $pastas = @("Desktop","Documents","Downloads","Pictures","Videos")

    foreach ($pasta in $pastas) {
        $origem = Join-Path $env:USERPROFILE $pasta
        $dest = Join-Path $destino $pasta

        robocopy $origem $dest /E /R:1 /W:1 | Out-Null
    }

    Write-Host "Backup concluído!" -ForegroundColor Green
    Pause
}

# ====================================
# RESTAURAR
# ====================================

elseif ($opcao -eq "4") {

    $backup = Read-Host "Caminho do backup"

    if (!(Test-Path $backup)) {
        Write-Host "Pasta não encontrada!" -ForegroundColor Red
        Pause
        exit
    }

    $pastas = Get-ChildItem $backup -Directory

    foreach ($pasta in $pastas) {
        $destino = Join-Path $env:USERPROFILE $pasta.Name
        robocopy $pasta.FullName $destino /E /R:1 /W:1 | Out-Null
    }

    Write-Host "Backup restaurado!" -ForegroundColor Green
    Pause
}

# ====================================
# UPGRADE PRO
# ====================================

elseif ($opcao -eq "5") {

    $os = Get-CimInstance Win32_OperatingSystem

    if ($os.Caption -match "Home") {
        Write-Host "Atualizando para Pro..." -ForegroundColor Yellow
        changepk.exe /ProductKey VK7JG-NPHTM-C97JM-9MPGT-3V66T
    } else {
        Write-Host "Já é Pro ou não compatível." -ForegroundColor Green
    }

    Pause
}