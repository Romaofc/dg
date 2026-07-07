Clear-Host

$Host.UI.RawUI.WindowTitle = "Medisystems Toolkit"

function Type-Text {
    param(
        [string]$Text,
        [string]$Color = "Cyan",
        [int]$Speed = 15
    )

    foreach ($c in $Text.ToCharArray()) {
        Write-Host $c -NoNewline -ForegroundColor $Color
        Start-Sleep -Milliseconds $Speed
    }
    Write-Host
}

# Tela inicial
Type-Text "Inicializando Medisystems Toolkit..." "Cyan" 10
Start-Sleep -Milliseconds 300

$frames = @("|","/","-","\")
$mensagens = @(
    "Carregando módulos",
    "Verificando sistema",
    "Preparando interface",
    "Importando funções",
    "Finalizando"
)

foreach ($msg in $mensagens) {
    for ($i=0; $i -lt 18; $i++) {
        $frame = $frames[$i % $frames.Count]
        Write-Host "`r[$frame] $msg..." -NoNewline -ForegroundColor Yellow
        Start-Sleep -Milliseconds 70
    }
    Write-Host "`r[✔] $msg concluído.      " -ForegroundColor Green
}

Write-Host

for ($i=0; $i -le 100; $i++) {
    $bars = "█" * ($i/2)
    $spaces = " " * (50 - ($i/2))
    Write-Host "`r[$bars$spaces] $i%" -NoNewline -ForegroundColor Cyan
    Start-Sleep -Milliseconds 20
}

Start-Sleep -Milliseconds 400
Clear-Host

$logo = @'
███╗   ███╗███████╗██████╗ ██╗███████╗██╗   ██╗███████╗
████╗ ████║██╔════╝██╔══██╗██║██╔════╝╚██╗ ██╔╝██╔════╝
██╔████╔██║█████╗  ██║  ██║██║███████╗ ╚████╔╝ ███████╗
██║╚██╔╝██║██╔══╝  ██║  ██║██║╚════██║  ╚██╔╝  ╚════██║
██║ ╚═╝ ██║███████╗██████╔╝██║███████║   ██║   ███████║
╚═╝     ╚═╝╚══════╝╚═════╝ ╚═╝╚══════╝   ╚═╝   ╚══════╝
'@

Write-Host $logo -ForegroundColor Cyan
Write-Host ""
Write-Host "           TOOLKIT v2.0" -ForegroundColor White
Write-Host "==============================================" -ForegroundColor DarkCyan
Write-Host ""
Write-Host "[1] Liberar Espaço" -ForegroundColor White
Write-Host "[0] Sair" -ForegroundColor White
Write-Host ""

$opcao = Read-Host "Escolha uma opção"

switch ($opcao) {

    "1" {
        LiberarEspaco
    }

    "0" {
        exit
    }

    default {
        Write-Host "Opção inválida!" -ForegroundColor Red
        Start-Sleep 2
    }
}


function LiberarEspaco {

    Clear-Host
    Write-Host "==============================================" -ForegroundColor DarkCyan
    Write-Host "            LIBERAR ESPAÇO" -ForegroundColor Green
    Write-Host "==============================================" -ForegroundColor DarkCyan
    Write-Host ""

    Write-Host "[1/5] Limpando arquivos temporários..." -ForegroundColor Yellow
    Remove-Item "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue

    Write-Host "[2/5] Esvaziando a Lixeira..." -ForegroundColor Yellow
    Clear-RecycleBin -Force -ErrorAction SilentlyContinue

    Write-Host "[3/5] Limpando cache de miniaturas..." -ForegroundColor Yellow
    Remove-Item "$env:LOCALAPPDATA\Microsoft\Windows\Explorer\thumbcache_*" -Force -ErrorAction SilentlyContinue

    Write-Host "[4/5] Limpando Windows Update..." -ForegroundColor Yellow
    Stop-Service wuauserv -Force -ErrorAction SilentlyContinue
    Remove-Item "C:\Windows\SoftwareDistribution\Download\*" -Recurse -Force -ErrorAction SilentlyContinue
    Start-Service wuauserv -ErrorAction SilentlyContinue

    Write-Host "[5/5] Otimizando componentes..." -ForegroundColor Yellow
    DISM /Online /Cleanup-Image /StartComponentCleanup

    Write-Host ""
    Write-Host "Limpeza concluída!" -ForegroundColor Green
    Pause
}