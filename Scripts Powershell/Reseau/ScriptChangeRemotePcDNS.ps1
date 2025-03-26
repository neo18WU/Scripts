<#
Auteur : Alain Thomassigny
Date: 15/10/2022
Révisions :
    - 1.0 : Création
Description : Modification des adresses du DNS à distance sur les postes du réseau 
#>



function Get-fPing {

if($uniqIP -eq $true)
    {
    $computerlist = $plageIP
    }
    else
    {
     $computerlist = [Object[]]::new(254)

        for ($i=1; $i -le 254;$i++)
        {
            $computerlist[$i-1] = $plageIP+"."+$i
        }
    }
    
#resultat conectivité
    $connect = @(
        'Disconnected'
        'Connecting'
        'Connected'
        'Disconnecting'
        'Hardware Not Present'
        'Hardware Disabled'
        'Hardware Malfunction'
        'Media Disconnected'
        'Authenticating'
        'Authentication Succeeded'
        'Authentication Failed'
        'Invalid Address'
        'Credendials Required'
        'Other'
    )


    foreach ($address in $computerlist)
        {
             $result =  get-wmiobject win32_pingstatus -filter "address='$address'" #ping sur le réseau
     
     
              if ($result.statuscode -eq 0) #récupère le statut: 0 = success
	        {
                Write-Host "Waiting ... analyse in progress"
                Write-Host "`n $address is up"
        
                    $os = get-WmiObject -class Win32_OperatingSystem -computer $address 
 
                    if ($os.OSType -eq 18)
                    {
                        $name = $os.CSName #récupère nom
                        $version = $os.Caption #récupère statut version OS
                        Write-Host "$name : $version"

                        $remoteNic = get-wmiobject -class win32_networkadapter -computer $address | where-object {$_.netconnectionstatus -ne $null} #si une connxion existe
                        $index = $remotenic.index #récupère le statut de connexion 1 = connexion
                        if ($index -gt 12)
                            {$WriteIndex = $connect[13]} else {$WriteIndex = $connect[$index]}
                        Write-Host "Statut de connexion: $WriteIndex"
                        #recupère adresse DNS
                        $DNSlist = $(get-wmiobject win32_networkadapterconfiguration -computer $address -Filter ‘IPEnabled=true’ | where-object {$_.index -eq $index}).dnsserversearchorder
                        Write-Host "DNS actuel: $DNSlist"
                        #présence DHCP
                        $DHCPexist = $(Get-WmiObject win32_networkAdapterConfiguration -computer $address -Filter 'IPEnabled=true' | where-object {$_.index -eq $index}).dhcpenabled
                        if ($DHCPexist -eq $true)
                            {
                                Write-Host "DHCP actif sur ce poste"                          
                            }
                            else
                            {
                                Write-Host "DHCP inactif (l'adressage IP ne sera pas modifié)"     
                            }
                        #modification DNS
                        $priDNS = $DNSlist | select-object -first 1
                        Write-host "Mofification du DNS sur $address" -b "Yellow" -foregroundcolor "black"

                        $change = get-wmiobject win32_networkadapterconfiguration -computer $address | where-object {$_.index -eq $index}

                        $change.SetDNSServerSearchOrder($dnsservers) | out-null

                        $changes = $(get-wmiobject win32_networkadapterconfiguration -computer $address -Filter ‘IPEnabled=true’ | where-object {$_.index -eq $index}).dnsserversearchorder 
                        Write-host "Nouveau DNS configuré: $changes"
                  
                        Write-Host "`n"


                    }
                    else {
                        Write-Host "OS non Windows"
                    }
            }
            else {
                 Write-Host "$address is down"
            }
        }
}



Write-host "`n"
Write-host "------------------------------------------------------------------------------------------"
Write-Host "`t`tMODIFICATION DU DNS"
Write-host "------------------------------------------------------------------------------------------"


$dnsprimaire = read-host "`n Saisir le nouveau DNS primaire"
$dnssecondaire = read-host "Saisir le nouveau DNS secondaire"

[string[]]$dnsservers = @()
$dnsservers += $dnsprimaire
    if ($dnssecondaire.length -gt 0)
    {
        $dnsservers += $dnssecondaire
    }

#fpingclear

$choice1 = read-host "`n Modifier un poste [U]nique ou l'ensemble des [P]ostes  ?"
if ($choice1 -eq "P")
    {
    #implementaton plage IP
    $plageIP = read-Host "Plage IP Réseau CIDR 24 ( ex: 192.168.1 )"
    $uniqIP = $false
    } 
    else
    {
    $plageIP = read-Host "adresse IP complète du poste à modifier"
    $uniqIP = $true
    }

    Get-fPing


