#ifndef AI_H
#define AI_H

#include "nim.h"
#include <stdint.h>
#include <stdbool.h>

typedef struct {
    uint64_t nodes;   // nb de nœuds visités
} Stats;

int  nim_xor(const State *s);

// Heuristique utilisée quand depth == 0
int  heuristic(const State *s);

// Choix du meilleur coup pour le joueur "max"
// depth: profondeur max de recherche
// use_ab: false => minimax, true => alphabeta
Move ai_best_move(const State *s, int depth, bool use_ab, Stats *st);

#endif
