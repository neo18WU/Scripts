<#

Auteur : Alain Thomassigny
Date: 15/10/2022
Révisions :
    - 1.0 : Création export txt format csv
    - 1.1 : Révision formatage tableau dans le fichier texte format txt
Description : Afficher et/ou exporter la liste des membres d'un groupe AD
#>

Import-Module ActiveDirectory

#Declaration variables globales
$anotherone = "o"


#listes des fonctions====================================================================================

function choice($gp) {

$choice = Read-Host  "Voulez-vous [A]fficher ou [E]xporter les membres du groupe $gp ?"
switch ($choice)
    {
    "a" {afficher $gp}
    "e" {exporter $gp}
    default {choice $gp}

    }
}

function afficher($gp) {
    
    Try {
    
    Get-ADGroupMember $gp | Format-Table name, SamAccountName #recupération et affichage des membres du groupe sélectionné
    $exp = Read-Host "Voulez-vous l'exporter ? [O/N]"
        if ($exp -eq "o")       
            {
            exporter $gp #vers fonction d'exportation du groupe sélectionné
            }
        else 
            {
            return
            }
    }
    catch {

    Write-Host "`t`tErreur: $_" -b "red"

    }
}

function exporter($gp) {
    Try {
    New-Item -Path "C:\Scripts\Exports\$gp.txt" -ItemType File -Force #création du nouveau fichier avec écrasement si existant
    add-content C:\Scripts\Exports\$gp.txt "Liste des membres du groupe: $gp" #ajout description
   
    $members = Get-ADGroupMember $gp | Select-Object name, SamAccountName #Récupération des membres du goupe
    $members | Format-Table Name, SamAccountName | Out-File C:\Scripts\Exports\$gp.txt -Append -Encoding Default #Mise en forme tableau et export txt
    
     
    
    Write-Host "`t`tLe fichier C:\Scripts\Exports\$gp.txt a été exporté avec succès !" -b "yellow" -foreground "black"
    }
    catch {

    Write-Host "`t`tErreur: $_" -b "red"

    }
}
#lancement du programme =============================================================================

#affiche l'ensemble des groupe de l'AD
Write-Host "`n-------------------------------------------------------------------------------------"
Write-Host "`t`tListe des groupes actuels"
Write-Host "-------------------------------------------------------------------------------------"

get-ADGroup -Filter * | Select-Object -Property * | Sort-Object -Property Name | Format-Table Name

#exportation des groupes
#get-ADGroup -Filter * | Select-Object -Property * | Sort-Object -Property Name | Format-Table Name | Out-File C:\Scripts\Exports\Groupes.txt -Append -Encoding Default

Write-Host "`n-------------------------------------------------------------------------------------"
Write-Host "`t`tAfficher et/ou exporter la liste des membres d'un de ces groupes de l'AD"
Write-Host "-------------------------------------------------------------------------------------"

while ($anotherone -ne "n")
{
    $gp = Read-Host  "Quel groupe de l'AD voulez-vous consulter ?"

    choice $gp
    $anotherone = Read-Host "`nVoulez-vous consulter un autre groupe ? [O/N]"

}

