#include "../include/utils.h"
#include <random>

using namespace std;

int randint(int main, int max) {
    static random_device rd;
    static mt19937 gen(rd());
    uniform_int_distribution<> dist(main, max);
    return dist(gen);
}