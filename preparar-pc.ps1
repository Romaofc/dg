$ScriptURL = "https://is.gd/medisystems"

$CurrentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
$Principal = New-Object Security.Principal.WindowsPrincipal($CurrentUser)

$IsAdmin = $Principal.IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator
)

if (-not $IsAdmin) {
    try {
        $TempFile = Join-Path $env:TEMP (
            "Medisystems_" +
            [Guid]::NewGuid().ToString() +
            ".ps1"
        )

        Write-Host ""
        Write-Host "MEDISYSTEMS TOOLKIT" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Solicitando permissoes de administrador..." -ForegroundColor Yellow

        $Response = Invoke-WebRequest `
            -Uri $ScriptURL `
            -UseBasicParsing `
            -ErrorAction Stop

        $Response.Content | Set-Content `
            -Path $TempFile `
            -Encoding UTF8 `
            -Force

        $Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$TempFile`""

        Start-Process `
            -FilePath "powershell.exe" `
            -ArgumentList $Arguments `
            -Verb RunAs

        exit
    }
    catch {
        Write-Host ""
        Write-Host "ERRO AO SOLICITAR PERMISSOES DE ADMINISTRADOR." -ForegroundColor Red
        Write-Host ""
        Write-Host $_.Exception.Message -ForegroundColor Red
        Write-Host ""
        Read-Host "Pressione ENTER para sair"
        exit
    }
}

function Remove-TemporaryScript {
    $CurrentScript = $PSCommandPath

    if ([string]::IsNullOrWhiteSpace($CurrentScript)) {
        return
    }

    if (-not (Test-Path $CurrentScript)) {
        return
    }

    $DeleteCommand = "Start-Sleep -Seconds 2; Remove-Item -LiteralPath '$CurrentScript' -Force -ErrorAction SilentlyContinue"

    Start-Process `
        -FilePath "powershell.exe" `
        -ArgumentList "-NoProfile -WindowStyle Hidden -Command `"$DeleteCommand`"" `
        -WindowStyle Hidden
}

function Type-Text {
    param (
        [string]$Text,
        [int]$Delay = 20
    )

    foreach ($Character in $Text.ToCharArray()) {
        Write-Host -NoNewline $Character
        Start-Sleep -Milliseconds $Delay
    }

    Write-Host ""
}

Clear-Host

Write-Host ""
Write-Host "███╗   ███╗███████╗██████╗ ██╗███████╗██╗   ██╗███████╗████████╗███████╗███╗   ███╗███████╗" -ForegroundColor Cyan
Write-Host "████╗ ████║██╔════╝██╔══██╗██║██╔════╝╚██╗ ██╔╝██╔════╝╚══██╔══╝██╔════╝████╗ ████║██╔════╝" -ForegroundColor Cyan
Write-Host "██╔████╔██║█████╗  ██║  ██║██║███████╗ ╚████╔╝ █████╗     ██║   █████╗  ██╔████╔██║███████╗" -ForegroundColor Cyan
Write-Host "██║╚██╔╝██║██╔══╝  ██║  ██║██║╚════██║  ╚██╔╝  ██╔══╝     ██║   ██╔══╝  ██║╚██╔╝██║╚════██║" -ForegroundColor Cyan
Write-Host "██║ ╚═╝ ██║███████╗██████╔╝██║███████║   ██║   ███████╗   ██║   ███████╗██║ ╚═╝ ██║███████║" -ForegroundColor Cyan
Write-Host "╚═╝     ╚═╝╚══════╝╚═════╝ ╚═╝╚══════╝   ╚═╝   ╚══════╝   ╚═╝   ╚══════╝╚═╝     ╚═╝╚══════╝" -ForegroundColor Cyan

Write-Host ""
Write-Host "MEDISYSTEMS TOOLKIT" -ForegroundColor White
Write-Host ""

Type-Text "Inicializando sistema..." 25
Start-Sleep -Milliseconds 400

Type-Text "Verificando permissoes..." 20
Start-Sleep -Milliseconds 400

Type-Text "Carregando ferramentas..." 20
Start-Sleep -Milliseconds 400

Write-Host ""
Write-Host "Sistema pronto." -ForegroundColor Green
Start-Sleep -Milliseconds 700

function Clear-Junk {
    Clear-Host

    Write-Host ""
    Write-Host "MEDISYSTEMS TOOLKIT" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "LIBERANDO ESPACO..." -ForegroundColor Yellow
    Write-Host ""

    Write-Host "Limpando arquivos temporarios do usuario..." -ForegroundColor White

    try {
        Get-ChildItem `
            -Path $env:TEMP `
            -Force `
            -ErrorAction SilentlyContinue |
            Remove-Item `
                -Recurse `
                -Force `
                -ErrorAction SilentlyContinue

        Write-Host "OK" -ForegroundColor Green
    }
    catch {
        Write-Host "Alguns arquivos nao puderam ser removidos." -ForegroundColor Yellow
    }

    Write-Host "Limpando arquivos temporarios do Windows..." -ForegroundColor White

    try {
        Get-ChildItem `
            -Path "$env:WINDIR\Temp" `
            -Force `
            -ErrorAction SilentlyContinue |
            Remove-Item `
                -Recurse `
                -Force `
                -ErrorAction SilentlyContinue

        Write-Host "OK" -ForegroundColor Green
    }
    catch {
        Write-Host "Alguns arquivos nao puderam ser removidos." -ForegroundColor Yellow
    }

    Write-Host ""
    Write-Host "Deseja esvaziar a Lixeira? (S/N)" -ForegroundColor Yellow

    $RecycleChoice = Read-Host

    if ($RecycleChoice -match "^[Ss]$") {
        try {
            Clear-RecycleBin `
                -Force `
                -ErrorAction SilentlyContinue

            Write-Host "Lixeira esvaziada." -ForegroundColor Green
        }
        catch {
            Write-Host "Nao foi possivel esvaziar a Lixeira." -ForegroundColor Yellow
        }
    }

    Write-Host ""
    Write-Host "Limpeza concluida." -ForegroundColor Green
    Write-Host ""

    Read-Host "Pressione ENTER para voltar ao menu"
}

$ExitToolkit = $false

try {
    while (-not $ExitToolkit) {
        Clear-Host

        Write-Host ""
        Write-Host "MEDISYSTEMS TOOLKIT" -ForegroundColor Cyan
        Write-Host ""

        Write-Host "[1] " -NoNewline -ForegroundColor Green
        Write-Host "Liberar espaco"

        Write-Host "[0] " -NoNewline -ForegroundColor Red
        Write-Host "Sair"

        Write-Host ""

        $Option = Read-Host "Escolha uma opcao"

        switch ($Option) {
            "1" {
                Clear-Junk
            }

            "0" {
                $ExitToolkit = $true
            }

            default {
                Write-Host ""
                Write-Host "Opcao invalida." -ForegroundColor Red
                Start-Sleep -Seconds 1
            }
        }
    }
}
finally {
    Remove-TemporaryScript
}

Clear-Host

Write-Host ""
Write-Host "MEDISYSTEMS TOOLKIT encerrado." -ForegroundColor Cyan
Write-Host ""
Write-Host "O arquivo temporario sera removido automaticamente." -ForegroundColor DarkGray
Write-Host ""

Start-Sleep -Seconds 2