#ifndef SHEEP_H
#define SHEEP_H

#include "Animal.h"

/// Mouton : vit 50 tours, meurt s’il ne mange pas en 5 tours :contentReference[oaicite:0]{index=0}.
class Sheep : public Animal {
public:
    static const int MAX_AGE = 50;
    static const int STARVE_LIMIT = 5;

    Sheep(int row, int col, Gender gender);

    void move(Universe& u) override;
    void eat(Universe& u) override;
    bool reproduce(Universe& u) override;
    bool isDead() const override;
};

#endif // SHEEP_H
