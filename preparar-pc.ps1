#requires -Version 5.1

# Solicita execução como administrador
$principal = New-Object Security.Principal.WindowsPrincipal(
    [Security.Principal.WindowsIdentity]::GetCurrent()
)

if (-not $principal.IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator
)) {
    if ([string]::IsNullOrWhiteSpace($PSCommandPath)) {
        Write-Host "Salve o script como arquivo .ps1 antes de executá-lo." `
            -ForegroundColor Red
        Read-Host "Pressione ENTER para sair"
        exit
    }

    Start-Process powershell.exe `
        -Verb RunAs `
        -ArgumentList @(
            "-NoProfile",
            "-ExecutionPolicy", "Bypass",
            "-File", "`"$PSCommandPath`""
        )

    exit
}

Clear-Host
$Host.UI.RawUI.WindowTitle = "Medisystems Toolkit"

function Type-Text {
    param(
        [string]$Text,
        [string]$Color = "Cyan",
        [int]$Speed = 15
    )

    foreach ($char in $Text.ToCharArray()) {
        Write-Host $char -NoNewline -ForegroundColor $Color
        Start-Sleep -Milliseconds $Speed
    }

    Write-Host
}

$logo = @'
███╗   ███╗███████╗██████╗ ██╗███████╗██╗   ██╗███████╗
████╗ ████║██╔════╝██╔══██╗██║██╔════╝╚██╗ ██╔╝██╔════╝
██╔████╔██║█████╗  ██║  ██║██║███████╗ ╚████╔╝ ███████╗
██║╚██╔╝██║██╔══╝  ██║  ██║██║╚════██║  ╚██╔╝  ╚════██║
██║ ╚═╝ ██║███████╗██████╔╝██║███████║   ██║   ███████║
╚═╝     ╚═╝╚══════╝╚═════╝ ╚═╝╚══════╝   ╚═╝   ╚══════╝
'@

function Mostrar-Cabecalho {
    Clear-Host
    Write-Host $logo -ForegroundColor Cyan
    Write-Host ""
    Write-Host "           TOOLKIT v2.0" -ForegroundColor White
    Write-Host "==============================================" `
        -ForegroundColor DarkCyan
    Write-Host ""
}

function Inicializar {
    Type-Text "Inicializando Medisystems Toolkit..." "Cyan" 10
    Start-Sleep -Milliseconds 300

    $frames = @("|", "/", "-", "\")
    $mensagens = @(
        "Carregando módulos",
        "Verificando sistema",
        "Preparando interface",
        "Importando funções",
        "Finalizando"
    )

    foreach ($mensagem in $mensagens) {
        for ($i = 0; $i -lt 18; $i++) {
            $frame = $frames[$i % $frames.Count]

            Write-Host "`r[$frame] $mensagem..." `
                -NoNewline `
                -ForegroundColor Yellow

            Start-Sleep -Milliseconds 70
        }

        Write-Host "`r[OK] $mensagem concluído.       " `
            -ForegroundColor Green
    }

    for ($i = 0; $i -le 100; $i++) {
        $preenchido = [int]($i / 2)
        $vazio = 50 - $preenchido

        $barra = ("█" * $preenchido) + (" " * $vazio)

        Write-Host "`r[$barra] $i%" `
            -NoNewline `
            -ForegroundColor Cyan

        Start-Sleep -Milliseconds 20
    }

    Write-Host
    Start-Sleep -Milliseconds 400
}

function Liberar-Espaco {
    Mostrar-Cabecalho

    Write-Host "A limpeza removerá arquivos temporários do usuário e do Windows."
    Write-Host "Arquivos em uso serão ignorados." -ForegroundColor Yellow
    Write-Host ""

    $confirmacao = Read-Host "Deseja continuar? (S/N)"

    if ($confirmacao -notmatch "^[Ss]$") {
        Write-Host "Operação cancelada." -ForegroundColor Yellow
        Start-Sleep -Seconds 2
        return
    }

    $pastas = @(
        $env:TEMP,
        "$env:WINDIR\Temp"
    ) | Sort-Object -Unique

    $removidos = 0
    $falhas = 0

    foreach ($pasta in $pastas) {
        if (-not (Test-Path -LiteralPath $pasta)) {
            continue
        }

        Write-Host "Limpando: $pasta" -ForegroundColor Cyan

        $itens = Get-ChildItem -LiteralPath $pasta `
            -Force `
            -ErrorAction SilentlyContinue

        foreach ($item in $itens) {
            try {
                Remove-Item -LiteralPath $item.FullName `
                    -Recurse `
                    -Force `
                    -ErrorAction Stop

                $removidos++
            }
            catch {
                $falhas++
            }
        }
    }

    Write-Host ""
    Write-Host "Limpeza concluída." -ForegroundColor Green
    Write-Host "Itens removidos: $removidos"
    Write-Host "Itens ignorados: $falhas" -ForegroundColor Yellow

    $lixeira = Read-Host "Deseja esvaziar a Lixeira? (S/N)"

    if ($lixeira -match "^[Ss]$") {
        try {
            Clear-RecycleBin -Force -ErrorAction Stop
            Write-Host "Lixeira esvaziada." -ForegroundColor Green
        }
        catch {
            Write-Host "Não foi possível esvaziar a Lixeira." `
                -ForegroundColor Yellow
        }
    }

    Read-Host "Pressione ENTER para voltar ao menu"
}

function Mostrar-Menu {
    do {
        Mostrar-Cabecalho

        Write-Host "[1] Liberar espaço" -ForegroundColor White
        Write-Host "[0] Sair" -ForegroundColor White
        Write-Host ""

        $opcao = Read-Host "Escolha uma opção"

        switch ($opcao) {
            "1" {
                Liberar-Espaco
            }

            "0" {
                Write-Host "Encerrando..." -ForegroundColor Cyan
                return
            }

            default {
                Write-Host "Opção inválida." -ForegroundColor Red
                Start-Sleep -Seconds 2
            }
        }
    }
    while ($true)
}

Inicializar
Mostrar-Menu