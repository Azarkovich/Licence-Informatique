#include "nim.h"
#include <stdio.h>

void state_init(State *s, const int *heaps, int n) {
    s->n = n;
    for (int i = 0; i < n; i++) s->heaps[i] = heaps[i];
    for (int i = n; i < MAX_HEAPS; i++) s->heaps[i] = 0;
}

void state_print(const State *s) {
    printf("TAS: ");
    for (int i = 0; i < s->n; i++) {
        printf("[%d]%d ", i, s->heaps[i]);
    }
    printf("\n");
}

bool state_is_terminal(const State *s) {
    for (int i = 0; i < s->n; i++) {
        if (s->heaps[i] > 0) return false;
    }
    return true;
}

int state_total(const State *s) {
    int sum = 0;
    for (int i = 0; i < s->n; i++) sum += s->heaps[i];
    return sum;
}

bool move_is_legal(const State *s, Move m) {
    if (m.heap < 0 || m.heap >= s->n) return false;
    if (m.remove <= 0) return false;
    if (s->heaps[m.heap] < m.remove) return false;
    return true;
}

void apply_move(State *s, Move m) {
    s->heaps[m.heap] -= m.remove;
    if (s->heaps[m.heap] < 0) s->heaps[m.heap] = 0;
}

int generate_moves(const State *s, Move *out_moves, int max_out) {
    int k = 0;
    for (int i = 0; i < s->n; i++) {
        int h = s->heaps[i];
        for (int r = 1; r <= h; r++) {
            if (k >= max_out) return k;
            out_moves[k].heap = i;
            out_moves[k].remove = r;
            k++;
        }
    }
    return k;
}
