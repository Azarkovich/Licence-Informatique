#include "ai.h"
#include <limits.h>

int nim_xor(const State *s) {
    int x = 0;
    for (int i = 0; i < s->n; i++) x ^= s->heaps[i];
    return x;
}

int heuristic(const State *s) {
    return (nim_xor(s) != 0) ? 1 : -1;
}

static int terminal_score(bool max_to_play) {
    return max_to_play ? -1000 : +1000;
}


static int move_key(const State *s, Move m, bool max_to_play) {
    State ns = *s;
    apply_move(&ns, m);


    if (state_is_terminal(&ns)) {
        // si MAX joue ce coup => énorme bonus, si MIN => énorme malus pour MAX
        return max_to_play ? +100000 : -100000;
    }

    // Critère Nim : nim_xor == 0 est perdant pour le joueur qui doit jouer (le suivant).
    int x = nim_xor(&ns);
    int good_for_current = (x == 0) ? 1 : 0;

    int tot = state_total(&ns);

    // On fabrique une clé numérique :
    // - MAX : veut les meilleurs coups d'abord => grande clé
    // - MIN : veut les pires pour MAX d'abord => petite clé
    // Ici "good_for_current" signifie bon pour le joueur courant.
    // Donc pour MAX : +, pour MIN : -.
    int base = good_for_current ? 1000 : 0;

    // tot petit = mieux pour finir vite (pour MAX), inverse pour MIN
    int tie = (max_to_play ? -tot : +tot);

    return (max_to_play ? (base * 10 + tie) : -(base * 10 + tie));
}

static void order_moves(const State *s, Move *moves, int nm, bool max_to_play) {
    // Insertion sort sur la clé
    for (int i = 1; i < nm; i++) {
        Move cur = moves[i];
        int curk = move_key(s, cur, max_to_play);

        int j = i - 1;
        while (j >= 0) {
            int jk = move_key(s, moves[j], max_to_play);
            // on veut ordre décroissant de clé
            if (jk >= curk) break;
            moves[j + 1] = moves[j];
            j--;
        }
        moves[j + 1] = cur;
    }
}

/* ----------------- MINIMAX ----------------- */
static int minimax_rec(const State *s, int depth, bool max_to_play, Stats *st) {
    st->nodes++;

    if (state_is_terminal(s)) return terminal_score(max_to_play);
    if (depth == 0) return heuristic(s);

    Move moves[512];
    int nm = generate_moves(s, moves, 512);

    if (max_to_play) {
        int best = INT_MIN;
        for (int i = 0; i < nm; i++) {
            State ns = *s;
            apply_move(&ns, moves[i]);
            int val = minimax_rec(&ns, depth - 1, false, st);
            if (val > best) best = val;
        }
        return best;
    } else {
        int best = INT_MAX;
        for (int i = 0; i < nm; i++) {
            State ns = *s;
            apply_move(&ns, moves[i]);
            int val = minimax_rec(&ns, depth - 1, true, st);
            if (val < best) best = val;
        }
        return best;
    }
}

/* ----------------- ALPHA-BETA (AVEC ORDRE DES COUPS) ----------------- */
static int alphabeta_rec(const State *s, int depth, bool max_to_play, int alpha, int beta, Stats *st) {
    st->nodes++;

    if (state_is_terminal(s)) return terminal_score(max_to_play);
    if (depth == 0) return heuristic(s);

    Move moves[512];
    int nm = generate_moves(s, moves, 512);

    order_moves(s, moves, nm, max_to_play);

    if (max_to_play) {
        int best = INT_MIN;
        for (int i = 0; i < nm; i++) {
            State ns = *s;
            apply_move(&ns, moves[i]);
            int val = alphabeta_rec(&ns, depth - 1, false, alpha, beta, st);
            if (val > best) best = val;
            if (best > alpha) alpha = best;
            if (alpha >= beta) break; // élagage
        }
        return best;
    } else {
        int best = INT_MAX;
        for (int i = 0; i < nm; i++) {
            State ns = *s;
            apply_move(&ns, moves[i]);
            int val = alphabeta_rec(&ns, depth - 1, true, alpha, beta, st);
            if (val < best) best = val;
            if (best < beta) beta = best;
            if (alpha >= beta) break; // élagage
        }
        return best;
    }
}

Move ai_best_move(const State *s, int depth, bool use_ab, Stats *st) {
    st->nodes = 0;

    Move moves[512];
    int nm = generate_moves(s, moves, 512);

    Move best_move = (Move){-1, 0};
    int best_val = INT_MIN;


    if (use_ab) order_moves(s, moves, nm, true);

    for (int i = 0; i < nm; i++) {
        State ns = *s;
        apply_move(&ns, moves[i]);

        int val;
        if (!use_ab) {
            val = minimax_rec(&ns, depth - 1, false, st);
        } else {
            val = alphabeta_rec(&ns, depth - 1, false, INT_MIN, INT_MAX, st);
        }

        if (val > best_val) {
            best_val = val;
            best_move = moves[i];
        }
    }
    return best_move;
}
