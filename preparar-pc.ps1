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

Write-Host "1 - Teste"
Write-Host "5 - Atalhos"

$opcao = Read-Host "Escolha"

if ($opcao -eq "1") {
    Write-Host "Teste OK"
}

elseif ($opcao -eq "5") {

    $DesktopPublico = "$env:PUBLIC\Desktop"

    $WshShell = New-Object -ComObject WScript.Shell

    $AtalhoASN = $WshShell.CreateShortcut("$DesktopPublico\Departamentos (ASN).lnk")
    $AtalhoASN.TargetPath = "\\SVREP-ASN-001\Departamentos"
    $AtalhoASN.Save()

    $AtalhoTAG = $WshShell.CreateShortcut("$DesktopPublico\Departamentos (Tag).lnk")
    $AtalhoTAG.TargetPath = "\\SVREP-TAG-001\Departamentos"
    $AtalhoTAG.Save()

    Write-Host "Concluido"
}

Pause