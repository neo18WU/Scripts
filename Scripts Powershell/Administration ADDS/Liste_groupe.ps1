<#

Auteur : Alain Thomassigny
Date: 15/10/2022
Révisions :
    - 1.0 : Création
Description : Afficher et/ou exporter la liste des groupes AD d'un utilisateur
#>

Import-Module ActiveDirectory

#Declaration variables globales
$anotherone = "o"


#listes des fonctions====================================================================================


#lancement du programme =============================================================================

#affiche l'ensemble des groupe de l'AD
Write-Host "`n-------------------------------------------------------------------------------------"
Write-Host "`t`tListe des utilisateurs actuels"
Write-Host "-------------------------------------------------------------------------------------"

$TotalUsers = (get-ADUser -Filter * | Select-Object -Property 'Name').count 

get-ADUser -Filter * | Select-Object -Property * | Sort-Object -Property SamAccountName, Name | Format-Table SamAccountName, Name

Write-Host "Nombre Total d'Utilisateurs : $TotalUsers"

Write-Host "`n-------------------------------------------------------------------------------------"
Write-Host "`t`tAfficher et/ou exporter la liste des groupe d'un utilisateur"
Write-Host "-------------------------------------------------------------------------------------"
$nuser = ""
Do 
{
    $nuser = Read-Host  "Entrez le login (SamAccountName) de l'utilisateur"

    Try {
    $groups = Get-ADPrincipalGroupMemberShip -Identity $nuser #Récupération des groupes de l'utilisateur
        Foreach ($element in $groups)
        {
         Write-Output  "`n" $element.name  $element.distinguishedName 
        }
      
        $export = Read-Host "`nVoulez-vous exporter cette liste ? [O/N]"
            if($export -eq "o")
            {
                Try {
        
                    Add-Content -Path "C:\Scripts\Exports\GroupsOf_$nuser.txt" -Value "$nuser est membre des groupes suivants :`n"
                    Add-Content -Path "C:\Scripts\Exports\GroupsOf_$nuser.txt" -Value $groups.name
                    Add-Content -Path "C:\Scripts\Exports\GroupsOf_$nuser.txt" -value "`n"
                    #Add-Content -Path "C:\Scripts\Exports\GroupsOf_$nuser.txt" -Value $groups.distinguishedName

                    Write-Host "`t`tLe fichier C:\Scripts\Exports\GroupOf_$nuser.txt a été exporté avec succès !" -b "yellow" -foreground "black"
                    }
                    catch
                    {
                    Write-Host "`t`tErreur: $_" -b "red"
                    }
             }
        }
      catch
      {
       Write-Host "`t`tErreur: $_" -b "red"
      }
    
    $anotherone = Read-Host "`nVoulez-vous consulter un autre utilisateur ? [O/N]"

}
while ($anotherone -ne "n")
