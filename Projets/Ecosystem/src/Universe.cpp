#include "../include/Universe.h"
#include "../include/Sheep.h"
#include "../include/Wolf.h"
#include "../include/utils.h"
#include <iostream>
#include <algorithm>

Universe::Cell::Cell()
  : hasGrass(true), hasMinerals(false), mineralAge(0) {}


Universe::Universe(int rows, int cols, int sheepCount, int wolfCount)
  : rows_(rows), cols_(cols),
    grid_(rows, std::vector<Cell>(cols)),
    initialSheep_(sheepCount), initialWolves_(wolfCount)
{}

void Universe::initialize() {
    placeAnimals(initialSheep_, AnimalType::SheepType);
    placeAnimals(initialWolves_, AnimalType::WolfType);
}

void Universe::placeAnimals(int count, AnimalType type) {
    int placed = 0;
    while (placed < count) {
        int r = randint(0, rows_-1);
        int c = randint(0, cols_-1);
        // pas plus d’un animal par case au départ
        bool occupied = false;
        for (auto& a : animals_) {
            if (a->getRow() == r && a->getCol() == c) {
                occupied = true; break;
            }
        }
        if (!occupied) {
            Gender g = (randint(0,1)==0 ? Gender::Male : Gender::Female);
            if (type == AnimalType::SheepType)
                animals_.push_back(std::make_shared<Sheep>(r, c, g));
            else
                animals_.push_back(std::make_shared<Wolf>(r, c, g));
            placed++;
        }
    }
}

void Universe::addAnimal(std::shared_ptr<Animal> animal) {
    animals_.push_back(std::move(animal));
}

std::vector<std::pair<int,int>> Universe::getAdjacent(int r, int c) const {
    std::vector<std::pair<int,int>> adj;
    const int dr[4] = { -1, 1, 0, 0 };
    const int dc[4] = { 0, 0, -1, 1 };
    for (int i = 0; i < 4; ++i) {
        int nr = r + dr[i], nc = c + dc[i];
        if (nr >= 0 && nr < rows_ && nc >= 0 && nc < cols_)
            adj.emplace_back(nr, nc);
    }
    return adj;
}

void Universe::update() {
    auto snapshot = animals_; // Copie pour éviter les problèmes de modification pendant l'itération
    // 1) Chaque animal agit
    for (auto& a : snapshot) {
        a->update(*this);
    }
    // 2) On retire les morts
    cleanupDead();
    // 3) (Optionnel) repousse de l’herbe
    regrowGrass();
}

void Universe::cleanupDead() {
    animals_.erase(
        std::remove_if(animals_.begin(), animals_.end(),
            [](const std::shared_ptr<Animal>& a){ return a->isDead(); }),
        animals_.end()
    );
}

void Universe::regrowGrass() {
    // Simple version : chaque tour, chaque case sans herbe a 10% de chance d’en voir réapparaître.
    for (int i = 0; i < rows_; ++i) {
        for (int j = 0; j < cols_; ++j) {
            if (!grid_[i][j].hasGrass && randint(1,100) <= 10)
                grid_[i][j].hasGrass = true;
        }
    }
}

void Universe::display() const {
    // Prépare une grille de caractères
    std::vector<std::vector<char>> disp(rows_, std::vector<char>(cols_, ' '));
    // herbe = '.', pas d’herbe = ' '
    for (int i = 0; i < rows_; ++i)
        for (int j = 0; j < cols_; ++j)
            disp[i][j] = grid_[i][j].hasGrass ? '.' : ' ';

    // superpose animaux
    int sheepCount = 0, wolfCount = 0;
    for (auto& a : animals_) {
        char ch = (a->getType() == AnimalType::SheepType ? 'S' : 'W');
        disp[a->getRow()][a->getCol()] = ch;
        if (ch=='S') sheepCount++; else wolfCount++;
    }

    // affichage ASCII
    for (int i = 0; i < rows_; ++i) {
        for (int j = 0; j < cols_; ++j)
            std::cout << disp[i][j];
        std::cout << "\n";
    }
    std::cout << "Moutons: " << sheepCount
              << "  Loups: "   << wolfCount << "\n\n";
}

bool Universe::isDead() const {
    return animals_.empty();
}
