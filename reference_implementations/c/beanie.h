#include <bits/types/stack_t.h>
#include <stdio.h>
#include <assert.h>
#include <stdlib.h>
#include <sys/random.h>
#include <stdint.h>

#define PRINT_INTER 0

typedef union
{
  uint16_t column[2];
  uint32_t state;
} state_t;

typedef union
{
  uint16_t column[8];
  uint32_t column_double[4];
  uint64_t state[2];   
} state_tk_t;

state_t enc(state_t state, const state_t* key, uint8_t R);
state_t dec(state_t state, const state_t* key, uint8_t R);

void tweak_key_schedule(state_tk_t key, state_tk_t* tweak, uint8_t R);

void key_expansion(state_t* round_keys, state_tk_t* key, uint8_t nr_keys);


void tests();
