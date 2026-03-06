#include "./../../reference_implementations/c/beanie.h"
#include <math.h>

#include <sys/random.h>

void init_prng() {
  unsigned int initial_seed = -1;
  getrandom(&initial_seed, sizeof(initial_seed), 0);
  srand(initial_seed);   // Initialization, should only be called once. int r = rand();
}

#define ITERATIONS pow(2, 24)

// Probability 1:
// #define ALPHA_TRUNCATED 1
// #define LEFT 2
// #define RIGHT 2
// #define ALPHA 0xf0f00f0f
// #define BETA  0x0f0ff0f0

// Probability ~2^-13.6:
#define ALPHA_TRUNCATED 1
#define LEFT 3
#define RIGHT 2
#define ALPHA 0x0000000f
#define BETA 0x0000000f

// Probability ~2^-27:
// #define ALPHA_TRUNCATED 1
// #define LEFT 3
// #define RIGHT 3
// #define ALPHA 0x00000f00
// #define BETA 0x000f0000

uint32_t get_rand() {
  return (uint32_t)(((uint16_t)rand() << 17) + ((uint16_t)rand() << 2) + ((uint16_t)rand()>>13));
}

int main()
{
  init_prng();

  state_t k_left[LEFT+1];
  state_t k_right[RIGHT+1];
  state_t p_1, p_2, p_3, p_4, c_1, c_2, c_3, c_4;

  double count = 0;

  for (uint64_t i=0; i < ITERATIONS; ++i) { 
    k_left[0].state = 0;
    for (uint8_t j = 1; j < LEFT+1; j++) {
      k_left[j].state = get_rand();
    }
    k_right[0].state = 0;
    for (uint8_t j = 1; j < RIGHT+1; j++) {
      k_right[j].state = get_rand();
    }

    p_1.state = get_rand();
    uint32_t delta = ALPHA;
    if (!ALPHA_TRUNCATED) {
      delta = 0;
      while (delta == 0) {
        delta = (rand() & ALPHA);
      }
    }
    p_2.state = p_1.state ^ delta;

    c_1 = enc(p_1, k_left, LEFT);
    c_1 = dec(c_1, k_right, RIGHT);

    c_2 = enc(p_2, k_left, LEFT);
    c_2 = dec(c_2, k_right, RIGHT);

    c_3.state = c_1.state ^ BETA;
    c_4.state = c_2.state ^ BETA;

    p_3 = enc(c_3, k_right, RIGHT);
    p_3 = dec(p_3, k_left, LEFT);

    p_4 = enc(c_4, k_right, RIGHT);
    p_4 = dec(p_4, k_left, LEFT);

    if (ALPHA_TRUNCATED) {
      if (((p_3.state ^ p_4.state) & ~ALPHA) == 0) {
        count++;
      }
    } else {
      if ((p_3.state ^ p_4.state) == ALPHA ) {
        count++;
      }
    }
  }
  printf("%d\n", (int)count);
  printf("Boomerang Distinguisher Probability: 2^%.2f\n", log2(count/ITERATIONS));
  return 0;
}
