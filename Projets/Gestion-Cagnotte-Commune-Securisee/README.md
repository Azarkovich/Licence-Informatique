# Projet Académique Collaboratif
Licence Informatique 3 - Université Paris 8.


- Projet universitaire de sécurité / cryptographie (travail de groupe)
- Implémentation de :
  - Partage de secret de Shamir
  - Chiffrement symétrique (AES-GCM)
  - Architecture client / serveur
- Dépôt principal hébergé sur GitLab universitaire (UP8).

> ⚠️ Ce projet est intégré ici via un **Git submodule** afin de conserver
> l’historique complet et la structure du travail de groupe.
> Le contenu n’est pas directement navigable depuis GitHub.

## DECRIPTTION GÉNERALE

Le projet de **Cagnote Commune Sécurisée** vise à mettre en place une application **client-serveur** simulant la gestion d'une cagnotte partagée entre plusieurs utilisateurs (groupe prédéfini de 5 utilisateur(e)s).

Ce projet met en œuvre une **application client–serveur sécurisée** pour la gestion d’une **cagnotte commune**, dont le **mécanisme central repose sur le partage de secret de Shamir (k/n)**.

Chaque utilisateur peut :
- Créer un compte et s'authentifier.
- Effectuer un crédit.
- Initier un débit (ce dernier doit être validé collectivement ou majoritairement lors d'un vote).

Le principe est simple : **aucun utilisateur ne peut autoriser seul une dépense**. Lorsqu’un débit est demandé, celui-ci doit être validé collectivement. Chaque vote favorable s’accompagne de la transmission d’une **part du secret**, et le débit n’est exécuté que lorsque **un nombre minimal k de parts valides est réuni**, permettant la reconstruction du secret côté serveur.
Un **client malhonnête** a été créé pour tester la sécurité et la résistance du protocole mis en place.

Il est combiné à des mécanismes classiques comme :
- authentification par session,
- chiffrement et intégrité des échanges,
- protection contre les attaques par rejeu,
- résistance face à des clients malhonnêtes.

