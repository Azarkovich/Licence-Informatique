#include "../include/Animal.h"
#include "../include/Universe.h"

Animal::Animal(int row, int col, Gender gender)
  : row_(row), col_(col),
    age_(0), starvationCounter_(0),
    gender_(gender),
    type_(AnimalType::SheepType) 
{}

void Animal::update(Universe& u) {
    age_++;
    move(u);
    eat(u);
    if (!isDead()) {
        reproduce(u);
    }
}
