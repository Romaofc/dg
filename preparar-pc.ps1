#requires -Version 5.1

============================================================

MEDISYSTEMS TOOLKIT

Execução:

irm https://is.gd/medisystems | iex

============================================================

------------------------------------------------------------

VERIFICAÇÃO DE ADMINISTRADOR

------------------------------------------------------------

$principal = New-Object Security.Principal.WindowsPrincipal(
[Security.Principal.WindowsIdentity]::GetCurrent()
)

$isAdmin = $principal.IsInRole(
[Security.Principal.WindowsBuiltInRole]::Administrator
)

if (-not $isAdmin) {

Clear-Host

Write-Host ""
Write-Host "==============================================" `
    -ForegroundColor DarkCyan

Write-Host "     MEDISYSTEMS TOOLKIT" `
    -ForegroundColor Cyan

Write-Host "==============================================" `
    -ForegroundColor DarkCyan

Write-Host ""
Write-Host "Solicitando permissões de administrador..." `
    -ForegroundColor Yellow

try {

    Start-Process powershell.exe `
        -Verb RunAs `
        -ArgumentList @(
            "-NoProfile",
            "-ExecutionPolicy", "Bypass",
            "-Command",
            "irm 'https://is.gd/medisystems' | iex"
        )

}
catch {

    Write-Host ""
    Write-Host "Não foi possível solicitar permissões de administrador." `
        -ForegroundColor Red

    Write-Host ""
    Read-Host "Pressione ENTER para sair"

}

exit

}

------------------------------------------------------------

CONFIGURAÇÃO

------------------------------------------------------------

Clear-Host

$Host.UI.RawUI.WindowTitle = "Medisystems Toolkit"

------------------------------------------------------------

EFEITO DE TEXTO

------------------------------------------------------------

function Type-Text {

param(
    [string]$Text,
    [string]$Color = "Cyan",
    [int]$Speed = 15
)

foreach ($char in $Text.ToCharArray()) {

    Write-Host $char `
        -NoNewline `
        -ForegroundColor $Color

    Start-Sleep -Milliseconds $Speed
}

Write-Host

}

------------------------------------------------------------

LOGO

------------------------------------------------------------

$logo = @'
███╗   ███╗███████╗██████╗ ██╗███████╗██╗   ██╗███████╗
████╗ ████║██╔════╝██╔══██╗██║██╔════╝╚██╗ ██╔╝██╔════╝
██╔████╔██║█████╗  ██║  ██║██║███████╗ ╚████╔╝ ███████╗
██║╚██╔╝██║██╔══╝  ██║  ██║██║╚════██║  ╚██╔╝  ╚════██║
██║ ╚═╝ ██║███████╗██████╔╝██║███████║   ██║   ███████║
╚═╝     ╚═╝╚══════╝╚═════╝ ╚═╝╚══════╝   ╚═╝   ╚══════╝
'@

------------------------------------------------------------

CABEÇALHO

------------------------------------------------------------

function Mostrar-Cabecalho {

Clear-Host

Write-Host $logo -ForegroundColor Cyan

Write-Host ""

Write-Host "           TOOLKIT v2.0" `
    -ForegroundColor White

Write-Host "==============================================" `
    -ForegroundColor DarkCyan

Write-Host ""

}

------------------------------------------------------------

INICIALIZAÇÃO

------------------------------------------------------------

function Inicializar {

Type-Text `
    "Inicializando Medisystems Toolkit..." `
    "Cyan" `
    10

Start-Sleep -Milliseconds 300

$frames = @(
    "|",
    "/",
    "-",
    "\"
)

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

    $barra = ("█" * $preenchido) +
             (" " * $vazio)

    Write-Host "`r[$barra] $i%" `
        -NoNewline `
        -ForegroundColor Cyan

    Start-Sleep -Milliseconds 20
}

Write-Host ""

Start-Sleep -Milliseconds 400

}

------------------------------------------------------------

LIBERAR ESPAÇO

------------------------------------------------------------

function Liberar-Espaco {

Mostrar-Cabecalho

Write-Host "LIBERAR ESPAÇO" `
    -ForegroundColor Cyan

Write-Host "----------------------------------------------" `
    -ForegroundColor DarkCyan

Write-Host ""

Write-Host "A limpeza removerá arquivos temporários"
Write-Host "do usuário e do Windows."

Write-Host ""

Write-Host "Arquivos que estiverem em uso serão ignorados." `
    -ForegroundColor Yellow

Write-Host ""

$confirmacao = Read-Host `
    "Deseja continuar? (S/N)"

if ($confirmacao -notmatch "^[Ss]$") {

    Write-Host ""

    Write-Host "Operação cancelada." `
        -ForegroundColor Yellow

    Start-Sleep -Seconds 2

    return
}


# --------------------------------------------------------
# PASTAS TEMPORÁRIAS
# --------------------------------------------------------

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

    Write-Host ""

    Write-Host "Limpando:" `
        -ForegroundColor Cyan

    Write-Host $pasta `
        -ForegroundColor Gray


    $itens = Get-ChildItem `
        -LiteralPath $pasta `
        -Force `
        -ErrorAction SilentlyContinue


    foreach ($item in $itens) {

        try {

            Remove-Item `
                -LiteralPath $item.FullName `
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


# --------------------------------------------------------
# RESULTADO
# --------------------------------------------------------

Write-Host ""

Write-Host "==============================================" `
    -ForegroundColor DarkCyan

Write-Host "              LIMPEZA CONCLUÍDA" `
    -ForegroundColor Green

Write-Host "==============================================" `
    -ForegroundColor DarkCyan

Write-Host ""

Write-Host "Itens removidos: " `
    -NoNewline

Write-Host $removidos `
    -ForegroundColor Green

Write-Host "Itens ignorados: " `
    -NoNewline

Write-Host $falhas `
    -ForegroundColor Yellow


# --------------------------------------------------------
# LIXEIRA
# --------------------------------------------------------

Write-Host ""

$lixeira = Read-Host `
    "Deseja esvaziar a Lixeira? (S/N)"


if ($lixeira -match "^[Ss]$") {

    try {

        Clear-RecycleBin `
            -Force `
            -ErrorAction Stop

        Write-Host ""

        Write-Host "Lixeira esvaziada." `
            -ForegroundColor Green

    }
    catch {

        Write-Host ""

        Write-Host "Não foi possível esvaziar a Lixeira." `
            -ForegroundColor Yellow
    }
}


Write-Host ""

Read-Host `
    "Pressione ENTER para voltar ao menu"

}

------------------------------------------------------------

MENU PRINCIPAL

------------------------------------------------------------

function Mostrar-Menu {

do {

    Mostrar-Cabecalho


    Write-Host "[1] Liberar espaço" `
        -ForegroundColor White

    Write-Host "[0] Sair" `
        -ForegroundColor White

    Write-Host ""


    $opcao = Read-Host `
        "Escolha uma opção"


    switch ($opcao) {

        "1" {

            Liberar-Espaco
        }


        "0" {

            Write-Host ""

            Write-Host "Encerrando Medisystems Toolkit..." `
                -ForegroundColor Cyan

            Start-Sleep -Milliseconds 500

            return
        }


        default {

            Write-Host ""

            Write-Host "Opção inválida." `
                -ForegroundColor Red

            Start-Sleep -Seconds 2
        }
    }

} while ($true)

}

------------------------------------------------------------

EXECUÇÃO

------------------------------------------------------------

Inicializar

Mostrar-Menu