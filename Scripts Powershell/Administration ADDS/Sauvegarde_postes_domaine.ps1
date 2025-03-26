<#
Auteur : Alain Thomassigny
Date: 07/11/2022
Révisions :
    - 1.0 : Création
    - 1.1 : Modification pour sauvegarde en fichiers compressés
Description : Sauvegarde des fichiers utilisateurs de chaques ordinateurs de l'AD
#>



Import-Module ActiveDirectory

$Date = (Get-Date -Format "ddMMyyyy") #Récuperation de la date
$nameServer = "name_of_the_machine"; #Exclusion du serveur

$computers = Get-ADComputer -Filter * -SearchBase 'DC=NAMEOFDC, DC=LOC'| Select -ExpandProperty name
#Récupération des ordinateurs de l'AD (modifier DC=NAMEOFDC avec DC du reseau)

foreach ($computer in $computers) #on teste chaque ordinateur pour voir s'il est connecté
{
  $Path = Test-Path "\\$computer\c$\Users"
  if($Path -eq $true) #si le PC est connecté
  { 
   if($computer -ne $nameServer ) #si le PC n'est pas le serveur
    {
     Write-Host "L'ordinateur $computer est connecté"
     Try 
     {
      Get-ChildItem \\$computer\c$\Users -Exclude *administrateur, Adm-local | Compress-Archive -DestinationPath \\$nameServer\Sauvegardes\$computer-$Date.zip -Update
      #Récupération des dossiers Utilisateurs de chaque poste et compression au format zip

      Write-Host "La sauvegarde de $computer s'est déroulée avec succès !`n" -b "yellow" -foreground "black"
     }
     catch #Récupération de l'erreur si le script n'a pas fonctionné
     {
      $erreur = $_
      $date = Get-Date 
      Add-Content  -Path \\$nameServer\sauvegardes\logErreurs_$computeur.txt -Value $date" "$erreur #enregistrement de l'erreur dans un fichier log
      Write-Host "`t`tErreur: $_" -b "red"
     }          
    }
   }
    else  
   { 
    Write-Host "L'ordinateur $computer est hors réseau"
   }   
}