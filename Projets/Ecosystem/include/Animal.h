#ifndef ANIMAL_H
#define ANIMAL_H

#include <memory>

class Universe;

enum class AnimalType { SheepType, WolfType };
enum class Gender { Male, Female };

/// Classe abstraite représentant un animal générique.
class Animal {
public:
    Animal(int row, int col, Gender gender);
    virtual ~Animal() = default;

    /// Actions élémentaires, appelées chaque tour
    virtual void move(Universe& u) = 0;
    virtual void eat(Universe& u) = 0;
    virtual bool reproduce(Universe& u) = 0;
    virtual bool isDead() const = 0;

    /// Met à jour âge, déplacement, alimentation et reproduction
    void update(Universe& u);

    AnimalType getType() const { return type_; }
    int getRow() const { return row_; }
    int getCol() const { return col_; }

protected:
    int row_, col_;
    int age_;
    int starvationCounter_;
    Gender gender_;
    AnimalType type_;
};
#endif // ANIMAL_H
