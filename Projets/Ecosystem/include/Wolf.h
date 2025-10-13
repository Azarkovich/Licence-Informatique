#ifndef WOLF_H
#define WOLF_H

#include "Animal.h"

/// Loup : vit 60 tours, meurt s’il ne mange pas en 10 tours :contentReference[oaicite:1]{index=1}.
class Wolf : public Animal {
public:
    static const int MAX_AGE = 60;
    static const int STARVE_LIMIT = 10;

    Wolf(int row, int col, Gender gender);

    void move(Universe& u) override;
    void eat(Universe& u) override;
    bool reproduce(Universe& u) override;
    bool isDead() const override;
};

#endif // WOLF_H
