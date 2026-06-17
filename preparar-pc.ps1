Clear-Host

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