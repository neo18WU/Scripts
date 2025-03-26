<#
Auteur : Alain Thomassigny
Date: 28/11/2022
Révisions :
    - 1.0 : Création
Description : fPing Window
#>



for ($i=1; $i -le 254; $i++)
{
    $address = "192.168.1."+$i
    $result= Get-WmiObject Win32_pingstatus -Filter "address='$address'"

    if ($result.statuscode -eq 0)
    {
        Write-Host "$address up"
            $remoteNic = Get-WmiObject -Class Win32_networkAdapter -ComputerName $address | Where-Object {$_.netconnectionstatus -ne $null}
            $index = $remoteNic.index
        Write-Host "Statut de la connexion: $index"
    }
    else {
        Write-Host "$address down"
    }
}
Read-Host "stop"