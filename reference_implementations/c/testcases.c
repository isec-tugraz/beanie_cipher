#include "beanie.h"
#include <stdio.h>


void init_prng() {
  unsigned int initial_seed = -1;
  srand(initial_seed);   // Initialization, should only be called once. int r = rand();
}

int main()
{
  init_prng();

  uint8_t NUMBER_OF_ROUNDS = 5;
  uint8_t NUMBER_OF_ROUNDS_TKS = 5;

  state_t k[NUMBER_OF_ROUNDS+1];
  state_t m, c;
  m.state = 0xffffffff;

  state_tk_t key = {.state = {0xffffffffffffffff, 0xffffffffffffffff}};
  state_tk_t t = {.state = {0xffffffffffffffff, 0xffffffffffffffff}};

  tweak_key_schedule(key, &t, NUMBER_OF_ROUNDS_TKS);

  key_expansion(k, &t, NUMBER_OF_ROUNDS+1);

  for (uint8_t i = 0; i < NUMBER_OF_ROUNDS+1; i++) {
    printf("%d. %-10s %08x\n", i, "R. Key", k[i].state);
  }
  printf("\n");

  // c = enc(m, k, NUMBER_OF_ROUNDS);
  // assert(dec(c, k, NUMBER_OF_ROUNDS).state == m.state);

  // printf("C. tex. %08x\n", c.state);
  // tests();

  c = enc(m, k, NUMBER_OF_ROUNDS);
  printf("C. tex. %08x\n", c.state);
  return 0;
}
