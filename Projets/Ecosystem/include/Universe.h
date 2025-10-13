#ifndef UNIVERSE_H
#define UNIVERSE_H

#include <vector>
#include <memory>
#include "Animal.h"

/// Chaque cellule peut contenir de l’herbe et éventuellement des sels minéraux.
class Universe {
public:
    struct Cell {
        bool hasGrass;      
        bool hasMinerals;  
        int mineralAge;    
    };

    Cell& getCell(int row, int col){
        return grid_[row][col];
    }

    std::vector<std::shared_ptr<Animal>> animals_;

    Universe(int rows, int cols, int sheepCount, int wolfCount);
    void initialize();              
    void update();                  
    void display() const;           
    bool isDead() const;            

    /// Pour que les animaux puissent s’ajouter lors de la reproduction
    void addAnimal(std::shared_ptr<Animal> animal);

    /// Renvoie la liste des positions adjacentes valides (4-voisinage)
    std::vector<std::pair<int,int>> getAdjacent(int r, int c) const;

    /// Dépose des minéraux sur une cellule
    void dropMinerals(int row, int col);

private:
    int rows_, cols_;
    std::vector<std::vector<Cell>> grid_;
    int initialSheep_, initialWolves_;

    void placeAnimals(int count, AnimalType type);
    void cleanupDead();             ///< retire les animaux morts
    void regrowGrass();             ///< gère la repousse de l’herbe
};

#endif // UNIVERSE_H
