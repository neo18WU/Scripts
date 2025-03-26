<#
Auteur : Alain Thomassigny
Date: 28/04/2023
Révisions :
    - 1.0 : Création
Description : Exécute un code applicatif
#>


$webClient = [System.Net.WebClient]::new()

$zip = $webClient.DownloadData('http://127.0.0.1/powershell/download/calculatrice.zip')

[System.Reflection.Assembly]::LoadWithPartialName('System.IO.Compression') | Out-Null

$entry = (New-Object System.IO.Compression.ZipArchive(New-Object System.IO.MemoryStream ( ,$zip))).GetEntry('calculatrice.ps1')

$b = [byte[]]::new($entry.Length)

$entry.Open().Read($b, 0, $b.Length)


$code = [System.Text.Encoding]::UTF8.GetString($b)

Write-Host $code
$code | Invoke-Expression



