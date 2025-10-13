#include <iostream>
#include "../include/Universe.h"

int main() {
    int rows = 10, cols = 10;
    int sheepCount = 10;
    int wolfCount = 5;

    Universe u(rows, cols, sheepCount, wolfCount);
    u.initialize();

    int turn = 0;
    while (!u.isDead() && turn < 1000) {
        std::cout << "Tour " << turn << "\n";
        u.update();
        u.display();
        std::cin.get(); // Appuie sur Entrée pour passer au tour suivant
        turn++;
    }

    std::cout << "Simulation terminée après " << turn << " tours.\n";
    return 0;
}
