#ifndef BENCH_H
#define BENCH_H

#include "nim.h"

double now_ms(void);

void bench_once(const State *s, int depth);

// Ecrit un CSV avec comparaison minimax vs alphabeta sur plusieurs profondeurs
// reps = nombre de répétitions (pour moyenner)
// depth_min..depth_max inclus
int bench_to_csv(const char *filename, const State *s, int reps, int depth_min, int depth_max);

#endif
