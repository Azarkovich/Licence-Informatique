# ----- Fichiers --------
Le projet se construit comme tel :

.ProjetFinal
├── include/
│   ├── Animal.h
│   ├── Sheep.h
│   ├── Wolf.h
│   ├── Universe.h
│   └── utils.h
├── src/
│   ├── Animal.cpp
│   ├── Sheep.cpp
│   ├── Wolf.cpp
│   ├── Universe.cpp
│   └── utils.cpp
├── main.cpp
└── README.md

# ----- Compilation & Exécution  --------
Selon les OS, le fichier se compile comme dessous ;
- Pour macOS
clang++ -std=c++17 -Iinclude src/*.cpp main.cpp -o <nomdufichier>

- Pour Linux
g++ -std=c++17 -Iinclude src/*.cpp main.cpp -o simulation

- L'exécution se fait :
./<nomdufichier>

# ----- Règles Du Jeu --------
- 🐑 Moutons
    - Vivent 50 tours maximum
    - Meurent s’ils ne mangent pas pendant 5 tours
    - Mangent de l’herbe
    - Se reproduisent s’ils ont 10+ tours, 10% de chance, avec un délai minimal entre 2 naissances

- 🐺 Loups
    - Vivent 60 tours maximum
    - Meurent s’ils ne mangent pas pendant 10 tours
    - Mangent les moutons sur leur case
    - Se déplacent vers les moutons proches
    - Se reproduisent comme les moutons mais avec 15% de chance

- 🌱 Herbe
    - Repousse 1 tour après la mort d’un animal sur une case sans herbe (grâce aux minéraux)
