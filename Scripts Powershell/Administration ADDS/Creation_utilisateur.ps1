<#

Auteur : Alain Thomassigny
Date: 12/10/2022
Révisions :
    - 1.0 : Création
Description : Création d'utilisateurs dans l'AD et de leur dossier partagé 
#>

Import-Module ActiveDirectory
#declaration variables globales
$chemin_dossier = "E:\PartagesPersonnelsUtilisateurs"

#fonction de coloration du text sur un enregistrement
function color_text($txt) {

    Write-Host "Entrer le " -NoNewline
    Write-Host $txt -ForegroundColor "yellow" -NoNewline
    Write-Host " de l'utilisateur :" -NoNewline;
   
    return Read-Host
}

#fonction de création du dossier
function nouveau_dossier($nd) {

    Try 
    {
        New-Item -Name "$nd" -Path $chemin_dossier -ItemType Directory
        $effect = "OK";
        return $effect
    }
    catch {
        $effect =  $_;
        return $effect
    }
    
}

#Recuperation des infos actuels sur l'AD

Write-Host "`n-------------------------------------------------------------------------------------"
Write-Host "`t`tListe des uilisateurs actuels"
Write-Host "-------------------------------------------------------------------------------------"

$TotalUsers = (get-ADUser -Filter * | Select-Object -Property 'Name').count #Récupération du nombre d'utilisateurs

get-ADUser -Filter * | Select-Object -Property * | Sort-Object -Property Name, SamAccountName, UserPrincipalName | Format-Table Name, SamAccountName, UserPrincipalName
#Affichage des utilisateurs sous forme de tableau

Write-Host "Nombre Total d'Utilisateurs : $TotalUsers"

#insertion nouvel utilisateur=============================================================================

Write-Host "`n-------------------------------------------------------------------------------------"
Write-Host "`t`tAJOUTER DES UTILISATEURS DANS l'AD et de son dossier personnel partagé"
Write-Host "-------------------------------------------------------------------------------------"
$domaine = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain().Name #Recuperation du nom de domaine

$anotherone = "o" #Variable globale pour la boucle while


while ($anotherone -ne "n")
 {
    Try {
    Write-Host "`n"
#Ajout de l'utilisateur

    $gv = color_text 'Prénom'
    $sn = color_text 'Nom'
    $dp ="$gv $sn"
    $login = color_text 'Login'
    $mdp = color_text 'Mot de passe'
    New-ADUser  -DisplayName $dp -GivenName $gv -Surname $sn -Name $dp -SamAccountName $login -UserPrincipalName $login@$domaine -AccountPassword (ConvertTo-SecureString -AsPlainText $mdp -Force) -PasswordNeverExpires $true -Enabled $true

    Write-Host "`t`tL'utilisateur $name a été ajouté à l'AD avec succès !" -b "yellow" -foreground "black"

#creation du dossier personnel 
      
    $createdir =  nouveau_dossier $login   
    Write-Host "`t`tLe dossier $createdir a été crée avec succès !" -b "yellow" -foreground "black"  

#creation du partage administrateur 
        
    New-Smbshare -Name $login -Path $chemin_dossier\$login -FullAccess Administrateur 
    Grant-SmbshareAccess -Name $login -AccountName $login -AccessRight Full

#recommencer
    $anotherone = Read-Host "`nVoulez-vous ajouter un autre utilisateur ? [O/N]"
    }
    catch {

    Write-Host "`t`tErreur: $_" -b "red"

    }

} 