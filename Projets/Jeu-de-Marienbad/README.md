# Jeu de Marienbad (Nim) - Intelligence Artificielle

**Algorithmique Avancée – L3 Informatique**

[![Language](https://img.shields.io/badge/language-C-blue.svg)](https://en.wikipedia.org/wiki/C_(programming_language))
[![License](https://img.shields.io/badge/license-Academic-green.svg)](LICENSE)

> Implémentation d'une intelligence artificielle pour le jeu de Marienbad (variante du jeu de Nim) utilisant les algorithmes Minimax et Alpha-Beta avec élagage.


---

## 1. Objectif du projet

L'objectif de ce projet est d'implémenter une intelligence artificielle pour le jeu de Marienbad (variante du jeu de Nim à plusieurs tas), en utilisant les algorithmes **Minimax** puis **Minimax avec élagage Alpha-Beta**.

Le travail demandé consiste à :
- Modéliser le jeu et son arbre de décisions
- Implémenter les algorithmes de recherche
- Comparer expérimentalement leurs performances
- Analyser l'impact de l'élagage et de l'ordonnancement des coups

---

## 2. Installation et compilation

### 2.1. Prérequis

- GCC (compilateur C)
- Make

### 2.2. Compilation

```bash
# Cloner le repository
git clone [url-du-repo]
cd Jeu-de-Marienbad

# Compiler le projet
make

# L'exécutable 'marienbad' sera créé
```

### 2.3. Nettoyage

```bash
make clean
```

---

## 3. 💻 Utilisation

### 3.1. Jouer contre l'IA

```bash
./marienbad play <profondeur> <algorithme> <tas1> <tas2> <tas3> ...
```

**Paramètres :**
- `profondeur` : profondeur de recherche (ex: 6)
- `algorithme` : `mm` (Minimax) ou `ab` (Alpha-Beta)
- `tas1 tas2 ...` : tailles initiales des tas

**Exemple :**
```bash
./marienbad play 6 ab 3 4 5
```

### 3.2. Benchmark simple

```bash
./marienbad bench <profondeur> <tas1> <tas2> ...
```

**Exemple :**
```bash
./marienbad bench 8 3 4 5
```

### 3.3. Benchmark avec export CSV

```bash
./marienbad benchcsv <fichier.csv> <répétitions> <prof_min> <prof_max> <tas1> <tas2> ...
```

**Paramètres :**
- `fichier.csv` : nom du fichier de sortie
- `répétitions` : nombre de répétitions par test (ex: 30)
- `prof_min` / `prof_max` : plage de profondeurs à tester
- `tas1 tas2 ...` : configuration initiale des tas

**Exemple :**
```bash
./marienbad benchcsv results.csv 30 2 10 3 4 5
```

---

## 4. Règles du jeu et modélisation

### 4.1. Règles du jeu de Marienbad

Le jeu est composé de plusieurs tas d'allumettes. Deux joueurs jouent à tour de rôle selon les règles suivantes :

- À chaque tour, un joueur choisit un tas non vide
- Il retire au moins une allumette de ce tas
- Le joueur qui ne peut plus jouer (tous les tas sont vides) **perd**

Il s'agit d'un **jeu à somme nulle**, **déterministe**, à **information parfaite**.

---

### 4.2. Modélisation de l'état

Un état du jeu est représenté par :
- Un tableau d'entiers correspondant aux tailles des tas
- Un entier indiquant le nombre de tas utilisés

```c
typedef struct {
    int heaps[MAX_HEAPS];
    int n;
} State;
```

Un coup est défini par :
- L'indice du tas choisi
- Le nombre d'allumettes retirées

```c
typedef struct {
    int heap;
    int remove;
} Move;
```

L'arbre de jeu est implicite : les états fils sont générés dynamiquement lors de la recherche.

---

## 5. Algorithmes utilisés

### 5.1. Minimax

L'algorithme Minimax explore l'arbre de jeu en supposant que :

- Le joueur MAX cherche à maximiser le score
- Le joueur MIN cherche à le minimiser

Une profondeur maximale est fixée afin de limiter le coût de calcul.

Les états terminaux sont évalués de la manière suivante :

- Si l'état est terminal et que c'est au tour de MAX → MAX perd → score négatif
- Si l'état est terminal et que c'est au tour de MIN → MIN perd → score positif

---

### 5.2. Fonction d'évaluation (heuristique)

Lorsque la profondeur maximale est atteinte sans être dans un état terminal, une heuristique simple est utilisée.

Dans le jeu de Nim, une position est :
- **Perdante** si le XOR (nim-sum) de tous les tas est nul
- **Gagnante** sinon

L'heuristique repose donc sur cette propriété mathématique :

```text
heuristic(state) = +1 si nim_xor != 0
                   -1 sinon
```

Cette heuristique permet d'orienter la recherche sans implémenter explicitement la stratégie parfaite.

---

### 5.3. Alpha-Beta

L'algorithme Alpha-Beta est une optimisation de Minimax. Il introduit deux bornes :
- **alpha** : meilleure valeur trouvée pour MAX
- **beta** : meilleure valeur trouvée pour MIN

Lorsqu'une branche ne peut plus améliorer la décision finale, elle est **élaguée** (non explorée).

À profondeur égale, Alpha-Beta retourne exactement le même résultat que Minimax, mais explore généralement beaucoup moins de nœuds.

---

## 6. Ordonnancement des coups

L'efficacité de l'élagage Alpha-Beta dépend fortement de l'ordre dans lequel les coups sont explorés.

Un ordonnancement des coups a donc été implémenté :
- Les coups menant à un état où le nim_xor est nul pour le joueur suivant sont explorés en priorité
- Les coups terminaux (menant directement à la victoire) sont également favorisés

Cet ordonnancement permet :
- De resserrer plus rapidement les bornes alpha et beta
- D'augmenter significativement le nombre de coupes
- De réduire le nombre total de nœuds explorés

---

## 7. Structures de données et fonctions principales

### Structures

- **`State`** : représente un état du jeu
- **`Move`** : représente un coup
- **`Stats`** : compteur du nombre de nœuds explorés

---

### 7.1. Fonctions principales

Les principales fonctions implémentées dans le projet sont les suivantes :

| Fonction | Description |
|----------|-------------|
| `generate_moves` | Génère l'ensemble des coups légaux possibles à partir d'un état donné |
| `apply_move` | Applique un coup à un état en modifiant la taille du tas concerné |
| `minimax_rec` | Implémentation récursive de l'algorithme Minimax avec profondeur limitée |
| `alphabeta_rec` | Implémentation récursive de Minimax avec élagage Alpha-Beta |
| `order_moves` | Ordonne les coups avant leur exploration pour améliorer l'efficacité de l'élagage |
| `ai_best_move` | Sélectionne le meilleur coup à jouer pour l'intelligence artificielle |

Ces fonctions permettent de parcourir l'arbre de jeu de manière structurée et d'extraire une décision optimale ou quasi-optimale selon la profondeur choisie.

---

## 8. Protocole de test

Les tests ont été réalisés selon le protocole suivant :

- ✅ Utilisation des mêmes positions initiales pour Minimax et Alpha-Beta
- ✅ Profondeurs de recherche comprises entre 2 et 10
- ✅ Répétition de chaque test 30 fois afin de moyenner les mesures
- ✅ Mesure du **temps moyen d'exécution** (en millisecondes)
- ✅ Mesure du **nombre moyen de nœuds explorés**

Le temps est mesuré à l'aide de la fonction `clock_gettime` avec l'horloge `CLOCK_MONOTONIC`, garantissant une mesure indépendante des variations de charge du système.

Les résultats sont automatiquement exportés dans des fichiers CSV afin de faciliter leur analyse et leur réutilisation pour la rédaction du rapport et la préparation de la soutenance.

---

## 9. Résultats et analyse

Les résultats expérimentaux montrent que :

- L'algorithme Minimax voit son nombre de nœuds explorés croître très rapidement avec la profondeur de recherche
- L'algorithme Alpha-Beta explore significativement moins de nœuds à profondeur équivalente
- L'ordonnancement des coups améliore encore fortement l'efficacité de l'algorithme Alpha-Beta

Lorsque la profondeur augmente, la différence de performance devient de plus en plus marquée, aussi bien en temps d'exécution qu'en nombre de nœuds explorés.

Ces observations confirment l'intérêt de l'élagage Alpha-Beta pour les jeux à arbre de recherche large.

### 9.1. Fichiers de résultats

Le projet inclut plusieurs fichiers de résultats CSV :
- `results.csv` : résultats généraux
- `results_345.csv` : tests avec configuration 3-4-5
- `results_1357.csv` : tests avec configuration 1-3-5-7
- `results_4567.csv` : tests avec configuration 4-5-6-7

---

## 10. Structure du projet

```
Jeu-de-Marienbad/
├── src/
│   ├── main.c       # Point d'entrée du programme
│   ├── nim.c        # Logique du jeu de Nim
│   ├── nim.h        # Déclarations pour nim.c
│   ├── ai.c         # Algorithmes Minimax et Alpha-Beta
│   ├── ai.h         # Déclarations pour ai.c
│   ├── bench.c      # Fonctions de benchmark
│   └── bench.h      # Déclarations pour bench.c
├── Makefile         # Fichier de compilation
├── README.md        # Ce fichier
└── results*.csv     # Fichiers de résultats des benchmarks
```

---

## 11. Conclusion

Ce projet a permis de mettre en œuvre des algorithmes classiques de l'intelligence artificielle pour les jeux à deux joueurs, en particulier Minimax et Alpha-Beta.

L'ajout d'un ordonnancement des coups montre que des optimisations simples mais bien choisies peuvent avoir un impact très important sur les performances, sans modifier la qualité des décisions prises par l'algorithme.

Le jeu de Marienbad constitue un cadre particulièrement adapté pour illustrer ces concepts, grâce à sa structure simple et à ses propriétés mathématiques bien connues.

---

## 12. Références

- **Minimax Algorithm** : [Wikipedia](https://en.wikipedia.org/wiki/Minimax)
- **Alpha-Beta Pruning** : [Wikipedia](https://en.wikipedia.org/wiki/Alpha%E2%80%93beta_pruning)
- **Nim Game** : [Wikipedia](https://en.wikipedia.org/wiki/Nim)
- **Nim-sum (XOR)** : Propriété mathématique du jeu de Nim

---

## 👥 Auteur

**Xavier-Bonheur TOKO-PROUST**
Projet réalisé dans le cadre du cours d'Algorithmique Avancée en L3 Informatique.
