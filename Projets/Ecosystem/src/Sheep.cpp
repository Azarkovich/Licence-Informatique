#include "../include/Sheep.h"
#include "../include/Universe.h"
#include "../include/utils.h"

Sheep::Sheep(int row, int col, Gender gender)
  : Animal(row, col, gender)
{
    type_ = AnimalType::SheepType;
}

void Sheep::move(Universe& u) {
    auto adj = u.getAdjacent(row_, col_);
    auto [nr, nc] = adj[randint(0, adj.size()-1)];
    row_ = nr; col_ = nc;
}

void Sheep::eat(Universe& u) {
    auto& cell = u.getCell(row_, col_);
    if (cell.hasGrass) {
        cell.hasGrass = false;
        starvationCounter_ = 0;
    } else {
        starvationCounter_++;
    }
}

bool Sheep::reproduce(Universe& u) {
    if (age_ < 10) return false;
    if (randint(1, 100) > 20) return false;

    for (auto [r, c] : u.getAdjacent(row_, col_)) {
        bool occupied = false;
        for (auto& other : u.animals_) {
            if (other->getRow() == r && other->getCol() == c) {
                occupied = true;
                break;
            }
        }
        if (!occupied) {
            Gender g = (randint(0, 1) == 0 ? Gender::Male : Gender::Female);
            u.addAnimal(std::make_shared<Sheep>(r, c, g));
            return true;
        }
    }
    return false;
}

bool Sheep::isDead() const {
    return age_ >= MAX_AGE || starvationCounter_ > STARVE_LIMIT;
}
