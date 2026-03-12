Clear-Host

Write-Host "=====================================" -ForegroundColor DarkGray
Write-Host "        MEDISYSTEMS TOOLKIT" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor DarkGray
Write-Host ""
Write-Host "1 - Preparar PC" -ForegroundColor Yellow
Write-Host "2 - Especificações do sistema" -ForegroundColor Yellow
Write-Host "3 - Backup do usuário" -ForegroundColor Yellow
Write-Host ""

$opcao = Read-Host "Escolha uma opção"

# ================================
# OPÇÃO 1 - PREPARAR PC
# ================================

if ($opcao -eq "1") {

    Clear-Host
    Write-Host "=====================================" -ForegroundColor DarkGray
    Write-Host "         PREPARAÇÃO DO PC" -ForegroundColor Cyan
    Write-Host "=====================================" -ForegroundColor DarkGray
    Write-Host ""

    Write-Host "► Ativando usuário Administrador..." -ForegroundColor Yellow
    net user Administrador /active:yes
    net localgroup Administrators Administrador /add
    Write-Host "Administrador ativado." -ForegroundColor Green
    Write-Host ""

    Add-Type -AssemblyName System.Windows.Forms
    $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
    $folderBrowser.Description = "Selecione a pasta com os instaladores"

    if ($folderBrowser.ShowDialog() -eq "OK") {

        $pasta = $folderBrowser.SelectedPath
        Write-Host ""
        Write-Host "Pasta selecionada:" -ForegroundColor Yellow -NoNewline
        Write-Host " $pasta" -ForegroundColor White
        Write-Host ""

        $arquivos = Get-ChildItem $pasta -Filter *.exe
        foreach ($arquivo in $arquivos) {
            Write-Host "Instalando:" -ForegroundColor Yellow -NoNewline
            Write-Host " $($arquivo.Name)" -ForegroundColor White
            Start-Process $arquivo.FullName -Wait
        }

        Write-Host ""
        Write-Host "Instalação dos programas finalizada." -ForegroundColor Green
    }
    else {
        Write-Host "Nenhuma pasta selecionada." -ForegroundColor Red
    }

    Write-Host ""
    Write-Host "► Executando Windows Update..." -ForegroundColor Yellow
    Install-PackageProvider -Name NuGet -Force
    Install-Module PSWindowsUpdate -Force
    Import-Module PSWindowsUpdate
    Get-WindowsUpdate
    Install-WindowsUpdate -AcceptAll -AutoReboot
    Write-Host ""
    Write-Host "Processo finalizado." -ForegroundColor Green
}

# ================================
# OPÇÃO 2 - ESPECIFICAÇÕES
# ================================

elseif ($opcao -eq "2") {

    Clear-Host
    Write-Host "=====================================" -ForegroundColor DarkGray
    Write-Host "      ESPECIFICAÇÕES DO SISTEMA" -ForegroundColor Cyan
    Write-Host "=====================================" -ForegroundColor DarkGray
    Write-Host ""

    # SISTEMA
    $os = Get-CimInstance Win32_OperatingSystem
    Write-Host "SISTEMA" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Sistema operacional:" -ForegroundColor Yellow -NoNewline
    Write-Host " $($os.Caption)" -ForegroundColor White
    Write-Host "Versão do Windows:" -ForegroundColor Yellow -NoNewline
    Write-Host " $($os.Version)" -ForegroundColor White
    Write-Host "Arquitetura:" -ForegroundColor Yellow -NoNewline
    Write-Host " $($os.OSArchitecture)" -ForegroundColor White
    Write-Host ""

    # CPU e RAM
    $cpu = Get-CimInstance Win32_Processor
    Write-Host "HARDWARE" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Processador:" -ForegroundColor Yellow -NoNewline
    Write-Host " $($cpu.Name)" -ForegroundColor White

    $ram = Get-CimInstance Win32_PhysicalMemory
    $ramTotal = [math]::Round(($ram.Capacity | Measure-Object -Sum).Sum / 1GB,2)
    $ramVelocidade = $ram[0].Speed
    Write-Host "Memória RAM:" -ForegroundColor Yellow -NoNewline
    Write-Host " $ramTotal GB" -ForegroundColor Green
    Write-Host "Velocidade da RAM:" -ForegroundColor Yellow -NoNewline
    Write-Host " $ramVelocidade MHz" -ForegroundColor White
    Write-Host ""

    # GPU
    $gpus = Get-CimInstance Win32_VideoController
    $gpuDedicada = $gpus | Where-Object { $_.Name -match "NVIDIA|AMD|Radeon" }
    Write-Host "GRÁFICO" -ForegroundColor Cyan
    Write-Host ""
    if ($gpuDedicada) {
        Write-Host "Placa de vídeo:" -ForegroundColor Yellow -NoNewline
        Write-Host " $($gpuDedicada.Name)" -ForegroundColor Magenta
    } else {
        Write-Host "Placa de vídeo:" -ForegroundColor Yellow -NoNewline
        Write-Host " $($gpus[0].Name)" -ForegroundColor Magenta
    }
    Write-Host ""

    # DISCOS
    $discos = Get-PhysicalDisk
    Write-Host "ARMAZENAMENTO" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Quantidade de discos:" -ForegroundColor Yellow -NoNewline
    Write-Host " $($discos.Count)" -ForegroundColor White
    Write-Host ""

    foreach ($disco in $discos) {
        $tamanho = [math]::Round($disco.Size / 1GB,2)
        Write-Host "Disco:" -ForegroundColor Yellow -NoNewline
        Write-Host " $($disco.FriendlyName)" -ForegroundColor White
        Write-Host "Tipo:" -ForegroundColor Yellow -NoNewline
        Write-Host " $($disco.MediaType)" -ForegroundColor Green
        Write-Host "Tamanho total:" -ForegroundColor Yellow -NoNewline
        Write-Host " $tamanho GB" -ForegroundColor White
        Write-Host ""
    }
}

# ================================
# OPÇÃO 3 - BACKUP
# ================================

elseif ($opcao -eq "3") {

    Clear-Host
    Write-Host "=====================================" -ForegroundColor DarkGray
    Write-Host "           BACKUP DO USUÁRIO" -ForegroundColor Cyan
    Write-Host "=====================================" -ForegroundColor DarkGray
    Write-Host ""

    Add-Type -AssemblyName System.Windows.Forms
    $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
    $folderBrowser.Description = "Selecione a pasta onde o backup será salvo"

    if ($folderBrowser.ShowDialog() -eq "OK") {

        $destinoBase = $folderBrowser.SelectedPath
        $nomePC = $env:COMPUTERNAME
        $destinoBackup = Join-Path $destinoBase "Backup-$nomePC"

        if (!(Test-Path $destinoBackup)) { New-Item -ItemType Directory -Path $destinoBackup | Out-Null }

        Write-Host "Backup será salvo em:" -ForegroundColor Yellow -NoNewline
        Write-Host " $destinoBackup" -ForegroundColor White
        Write-Host ""

        $pastas = @("Desktop","Documents","Downloads","Pictures","Videos")
        $userPath = [Environment]::GetFolderPath("UserProfile")

        foreach ($pasta in $pastas) {
            $origem = Join-Path $userPath $pasta
            $destino = Join-Path $destinoBackup $pasta

            if (Test-Path $origem) {

                if (!(Test-Path $destino)) { New-Item -ItemType Directory -Path $destino | Out-Null }

                $arquivos = Get-ChildItem $origem -Recurse -Force
                $totalArquivos = $arquivos.Count
                $arquivoContador = 0

                foreach ($arquivo in $arquivos) {
                    $destinoArquivo = Join-Path $destino ($arquivo.FullName.Substring($origem.Length + 1))
                    $destinoDir = Split-Path $destinoArquivo

                    if (!(Test-Path $destinoDir)) { New-Item -ItemType Directory -Path $destinoDir | Out-Null }

                    Copy-Item $arquivo.FullName $destinoArquivo -Force

                    $arquivoContador++
                    $percent = [int](($arquivoContador / $totalArquivos) * 100)
                    Write-Progress -Activity "Copiando $pasta" -Status "$percent% concluído" -PercentComplete $percent
                }

            }
        }

        Write-Progress -Activity "Backup concluído" -Completed
        Write-Host ""
        Write-Host "Backup finalizado com sucesso!" -ForegroundColor Green

    } else {
        Write-Host "Nenhuma pasta selecionada." -ForegroundColor Red
    }

}

else {
    Write-Host ""
    Write-Host "Opção inválida." -ForegroundColor Red
}

Pause