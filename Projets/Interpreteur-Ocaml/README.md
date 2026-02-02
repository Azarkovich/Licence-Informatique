# Interpréteur et Mini-Compilateur en OCaml

## 🎓 Contexte académique
Ce projet a été réalisé en **L3 Informatique (Université Paris 8)** dans le cadre du cours  
**Interprétation et Compilation**.

L’objectif était de concevoir et implémenter un **mini langage de programmation**, en couvrant
l’ensemble de la chaîne de traitement, depuis l’analyse syntaxique jusqu’à l’exécution
(interprétation) et la génération de code bas niveau.

---

## 🎯 Objectifs du projet
- Concevoir un langage simple mais structuré
- Comprendre le fonctionnement interne d’un interpréteur / compilateur
- Implémenter une chaîne de compilation complète en OCaml
- Manipuler des concepts fondamentaux :
  - Arbre de Syntaxe Abstraite (AST)
  - Environnements et portées
  - Analyse sémantique
  - Piles et gestion du flot de contrôle
  - Génération de code assembleur

---

## 🧠 Architecture générale

Le projet suit une **architecture classique de compilateur** :

```text
Code source
   ↓
Analyse lexicale (lexer.mll)
   ↓
Analyse syntaxique (parser.mly)
   ↓
AST – Arbre de Syntaxe Abstraite (ast.ml)
   ↓
Analyse sémantique (semantics.ml)
   ↓
Interprétation / Compilation (compiler.ml)
   ↓
Code assembleur MIPS (mips.ml)
```

---

## 🗂️ Organisation du projet

```
.
├── ast.ml            # Définition de l’AST
├── lexer.mll         # Analyse lexicale
├── parser.mly        # Analyse syntaxique
├── semantics.ml      # Analyse sémantique et gestion des environnements
├── baselib.ml        # Fonctions primitives du langage
├── compiler.ml       # Logique d’interprétation / compilation
├── mips.ml           # Génération de code assembleur MIPS
├── main.ml           # Point d’entrée du programme
├── tests/            # Jeux de tests automatisés
├── dune
├── dune-project
└── run_test.sh       # Script d’exécution des tests
```

---

## 🧪 Tests

Le projet inclut une **suite de tests automatisés** permettant de valider :
- les expressions arithmétiques
- les expressions booléennes
- les comparaisons
- les structures de contrôle
- les appels aux fonctions primitives

Ces tests garantissent la cohérence entre :
- la syntaxe
- la sémantique
- le comportement à l’exécution

---

## 📌 État du projet
- ✅ Fonctionnel
- 🎓 Projet académique validant les notions clés d’interprétation et de compilation
- 📚 Support d’apprentissage pour la compréhension des langages et compilateurs

---

## 👤 Auteur
**Xavier-Bonheur TOKO-PROUST**  
L3 Informatique – Université Paris 8