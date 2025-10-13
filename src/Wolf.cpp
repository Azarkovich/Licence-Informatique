#include "../include/Wolf.h"
#include "../include/Universe.h"
#include "../include/utils.h"

Wolf::Wolf(int row, int col, Gender gender)
  : Animal(row, col, gender)
{
    type_ = AnimalType::WolfType;
}

void Wolf::move(Universe& u) {
    auto adj = u.getAdjacent(row_, col_);

    // 1. Cherche mouton autour
    for (auto [nr, nc] : adj) {
        for (auto& other : u.animals_) {
            if (other->getType() == AnimalType::SheepType &&
                other->getRow() == nr &&
                other->getCol() == nc) {
                row_ = nr;
                col_ = nc;
                return;
            }
        }
    }

    // 2. Sinon déplacement aléatoire
    auto [nr, nc] = adj[randint(0, adj.size()-1)];
    row_ = nr;
    col_ = nc;
}


void Wolf::eat(Universe& u) {
    for (auto it = u.animals_.begin(); it != u.animals_.end(); ) {
    if ((*it)->getType() == AnimalType::SheepType &&
        (*it)->getRow() == row_ &&
        (*it)->getCol() == col_) {
        it = u.animals_.erase(it);
        starvationCounter_ = 0;
        return;
    } else {
        ++it;
    }
}

    starvationCounter_++;
}

bool Wolf::reproduce(Universe& u) {
    if (age_ < 15) return false;
    if (randint(1, 100) > 15) return false;

    auto adj = u.getAdjacent(row_, col_);
    for (auto [r, c] : adj) {
        bool occupied = false;
        for (auto& other : u.animals_) {
            if (other->getRow() == r && other->getCol() == c) {
                occupied = true;
                break;
            }
        }
        if (!occupied) {
            Gender g = (randint(0, 1) == 0 ? Gender::Male : Gender::Female);
            u.addAnimal(std::make_shared<Wolf>(r, c, g));
            return true;
        }
    }
    return false;
}

bool Wolf::isDead() const {
    return age_ >= MAX_AGE || starvationCounter_ > STARVE_LIMIT;
}
