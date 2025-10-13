# ---------------- Serveur Tchat - Système & Réseaux ------------------
Ce serverur en python implémente un protocole de tchat simple avec toutes les fonctionnalités demandées : 
- gestion de pseudonymes
- création et gestion de groupes
- messages public 
- messages privés 

# ---------------------- Prérequis ------------------------
- Python >= 3.6
- S'assureur que tous les fichiers sont dans le même dossier, à savoir: 
server.py
protocol.py
group_manager.py
client.py

# ---------------------- Commandes -------------------------
DISCLAIMER : Il se peut lors du lancement du serveur, que vous rencontriez une erreur (Errno48) qui indique que le port sur lequel nous voulons écouter est déjà en utilisation, dans ce cas veuillez taper : 

lsof -i 12345

puis 

kill -9 <PID>

ou modifiez "PORT" dans les fichiers server.py et client.py

Pour arrêter le serveur, utilisez 
Ctrl+C

# Test rapide 
Par défaut le serveur se lance en localhost sur le port 12345. 

- Lancer le serveur 
python3 server.py

- Dans un autre terminal ( 2fois au minimum )
python3 client.py 

- Connection 
clt: LOGIN <name>

- Commandes groupe
clt: CREAT <group>
clt: ENTER <group>
clt: LEAVE <group>

- Commandes message
clt: SPEAK <group>
clt: MSGPV <name>

# Liste des erreurs et leurs significations
Chaque erreur suit le format : srv: ERROR XX  
Voici la liste complète des codes et leur signification :

 Code      Signification                                  Quand elle apparaît                                                    
---------------------------------------------------------------------------------------------------------------------------------
 00    Erreur interne du serveur                      Bug inattendu ou problème côté serveur (ex. socket cassé)             
 01    Identification requise                         Le client envoie une commande avant LOGIN                           
 10    Argument invalide                              Message vide, champ manquant, ou syntaxe incorrecte                   
 11    Commande inconnue                              Ligne envoyée sans clt: ou commande non reconnue                    
 20    Pseudo invalide                                Ne respecte pas [a-zA-Z0-9_-]{1,16}                                  
 21    Pseudo inexistant                              Dans un MSGPV, le pseudo destinataire n’est pas connecté            
 23    Pseudo déjà pris                               Tentative de se connecter avec un pseudo déjà utilisé                 
 30    Nom de groupe invalide                         Ne respecte pas [a-zA-Z0-9_-]{1,16}                                  
 31    Groupe inexistant                              Tentative d’accéder à un groupe non créé                              
 33    Groupe déjà existant                           Tentative de création d’un groupe qui existe déjà                     
 34    L’utilisateur n’est pas dans le groupe         Par exemple LEAVE ou LSMEM d’un groupe non rejoint                
 35    L’utilisateur est déjà dans le groupe          Appel à ENTER alors qu’il est déjà membre                           
 36    Groupe plein (optionnel si limitation activée) Le groupe a atteint sa capacité maximale                              

