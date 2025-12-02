#include "beanie.h"

const state_tk_t ROUND_CONSTANTS[10] = {
  {.state = {0x0, 0x0000000000000000}},
  {.state = {0x0, 0x13198a2e03707344}},
  {.state = {0x0, 0xa4093822299f31d0}},
  {.state = {0x0, 0x082efa98ec4e6c89}},
  {.state = {0x0, 0x452821e638d01377}},
  {.state = {0x0, 0xbe5466cf34e90c6c}},
  {.state = {0x0, 0x7ef84f78fd955cb1}},
  {.state = {0x0, 0x85840851f1ac43aa}},
  {.state = {0x0, 0xc882d32f25323c54}},
  {.state = {0x0, 0x64a51195e0e3610d}}
};

const uint8_t SBox[] = {0, 4, 2, 11, 10, 12, 9, 8, 5, 15, 13, 3, 7, 1, 6, 14};
const uint8_t SBox_inv[] = {0, 13, 2, 11, 1, 8, 14, 12, 7, 6, 4, 3, 5, 10, 15, 9};

static inline state_t sbox(state_t state) { 
  uint8_t column;
  for (column = 0; column < 2;  ++column) {
    state.column[column] = (
      ((SBox[(state.column[column] >> 12) & 0xF]) << 12) |
      ((SBox[(state.column[column] >>  8) & 0xF]) <<  8) |
      ((SBox[(state.column[column] >>  4) & 0xF]) <<  4) |
      ((SBox[(state.column[column] >>  0) & 0xF]) <<  0)
    );
  }
  return state;
}

static inline state_t sbox_inv(state_t state) { 
  uint8_t column;
  for (column = 0; column < 2;  ++column) {
    state.column[column] = (
      ((SBox_inv[(state.column[column] >> 12) & 0xF]) << 12) |
      ((SBox_inv[(state.column[column] >>  8) & 0xF]) <<  8) |
      ((SBox_inv[(state.column[column] >>  4) & 0xF]) <<  4) |
      ((SBox_inv[(state.column[column] >>  0) & 0xF]) <<  0)
    );
  }
  return state;
}

static inline uint32_t shift(uint32_t state) { 
    uint32_t state_shifted = state & 0xf0f0f0f0;
    state_shifted |= ((state & 0x0f0f0000) >> 16);
    state_shifted |= ((state & 0x00000f0f) << 16);
    return state_shifted;
}

static inline uint8_t xtime(uint8_t x)
{
  return (0xf) & ((x<<1) ^ (((x>>3) & 1) * 0x3));
}

static inline uint8_t muliply(uint8_t x, uint8_t y)
{
  return (((y & 1) * x) ^
       ((y>>1 & 1) * xtime(x)) ^
       ((y>>2 & 1) * xtime(xtime(x))) ^
       ((y>>3 & 1) * xtime(xtime(xtime(x)))));
}

//GF(2^4) MDS matrix application
// Adapted from https://github.com/kokke/tiny-AES-c/blob/master/aes.c
static inline state_t mixColumns(state_t state)
{
  int i;
  uint8_t c0, c1, c2, c3;
  for (i = 0; i < 2; ++i)
  { 
    c0 = (state.column[i] >> 12) & 0xf;
    c1 = (state.column[i] >> 8)  & 0xf;
    c2 = (state.column[i] >> 4)  & 0xf;
    c3 = (state.column[i] >> 0)  & 0xf;

    state.column[i] = (
      ((muliply(c0, 0x2) ^ muliply(c1, 0x1) ^ muliply(c2, 0x1) ^ muliply(c3, 0x9)) << 12) |
      ((muliply(c0, 0x1) ^ muliply(c1, 0x4) ^ muliply(c2, 0xf) ^ muliply(c3, 0x1)) << 8 ) |
      ((muliply(c0, 0xd) ^ muliply(c1, 0x9) ^ muliply(c2, 0x4) ^ muliply(c3, 0x1)) << 4 ) |
      ((muliply(c0, 0x1) ^ muliply(c1, 0xd) ^ muliply(c2, 0x1) ^ muliply(c3, 0x2)) << 0 ) 
    );
  }
  return state;
}

state_t enc(state_t state, const state_t* key, uint8_t R)
{
  if (R == 0)
    return state;
  // assert(sizeof(key)/sizeof(state_t*) == R+1);
  int8_t round;

  #if PRINT_INTER
  printf("R%d %-10s %08x\n", 0, "Inital", state.state);
  #endif

  /* Perform all encryption rounds */
  for (round = 0; round < (R-1);  ++round) {
    state.state ^= key[round].state;
    #if PRINT_INTER
    printf("R%d %-10s %08x\n", round, "Key", state.state);
    #endif

    /* Apply the S-box to all nibbles in the state */
    state = sbox(state);
    #if PRINT_INTER
    printf("R%d %-10s %08x\n", round, "SBox", state.state);
    #endif

    /* Shift the rows */
    state.state = shift(state.state);
    #if PRINT_INTER
    printf("R%d %-10s %08x\n", round, "Shift", state.state);
    #endif

    /* Mix the columns */
    state = mixColumns(state);
    #if PRINT_INTER
    printf("R%d %-10s %08x\n", round, "MixColumns", state.state);
    #endif
  }

  state.state ^= key[R-1].state;
  #if PRINT_INTER
  printf("R%d %-10s %08x\n", round, "Key", state.state);
  #endif

  /* Apply the S-box to all nibbles in the state */
  state = sbox(state);
  #if PRINT_INTER
  printf("R%d %-10s %08x\n", round, "SBox", state.state);
  #endif

  /* Shift the rows */
  state.state = shift(state.state);
  #if PRINT_INTER
  printf("R%d %-10s %08x\n", round, "Shift", state.state);
  #endif

  state.state ^= key[R].state;
  #if PRINT_INTER
  printf("R%d %-10s %08x\n", round+1, "Key", state.state);
  #endif

  return state; 
}

state_t dec(state_t state, const state_t* key, uint8_t R)
{
  if (R == 0)
    return state;
  int8_t round;

  #if PRINT_INTER
  printf("R%d %-10s %08x\n", R, "Inital", state.state);
  #endif

  state.state ^= key[R].state;
  #if PRINT_INTER
  printf("R%d %-10s %08x\n", R, "Key", state.state);
  #endif

  /* Shift the rows */
  state.state = shift(state.state);
  #if PRINT_INTER
  printf("R%d %-10s %08x\n", R, "Shift", state.state);
  #endif

  /* Apply the inverse S-box to all nibbles in the state */
  state = sbox_inv(state);
  #if PRINT_INTER
  printf("R%d %-10s %08x\n", R-1, "SBox", state.state);
  #endif

  state.state ^= key[R-1].state;
  #if PRINT_INTER
  printf("R%d %-10s %08x\n", R-1, "Key", state.state);
  #endif

  /* Perform all decryption rounds */
  for (round = R-2; round >= 0;  --round) {
    /* Since mds matrix is involutive, we can  as in the encryption*/
    state = mixColumns(state);
    #if PRINT_INTER
    printf("R%d %-10s %08x\n", round, "MixColumns", state.state);
    #endif

    /* shift of the rows, again involutive */
    state.state = shift(state.state);

    #if PRINT_INTER
    printf("R%d %-10s %08x\n", round, "Shift", state.state);
    #endif

    /* Apply the inverse of the S-box to all bytes in the state */
    state = sbox_inv(state);
    #if PRINT_INTER
    printf("R%d %-10s %08x\n", round, "SBox", state.state);
    #endif

    state.state ^= key[round].state;
    #if PRINT_INTER
    printf("R%d %-10s %08x\n", round, "Key", state.state);
    #endif
  }

  return state; 
}


static inline state_tk_t sbox_tk(state_tk_t state) { 
  uint8_t column;
  for (column = 0; column < 8;  ++column) {
    state.column[column] = (
      ((SBox[(state.column[column] >> 12) & 0xF]) << 12) |
      ((SBox[(state.column[column] >>  8) & 0xF]) <<  8) |
      ((SBox[(state.column[column] >>  4) & 0xF]) <<  4) |
      ((SBox[(state.column[column] >>  0) & 0xF]) <<  0)
    );
  }
  return state;
}

static inline uint16_t prince_m_0(uint16_t column) {
  uint8_t c0, c1, c2, c3;
  c0 = (column >> 12) & 0xf;
  c1 = (column >> 8)  & 0xf;
  c2 = (column >> 4)  & 0xf;
  c3 = (column >> 0)  & 0xf;

  column = (
    (((c0 & 0b0111) ^ (c1 & 0b1011) ^ (c2 & 0b1101) ^ (c3 & 0b1110)) << 12) |
    (((c0 & 0b1011) ^ (c1 & 0b1101) ^ (c2 & 0b1110) ^ (c3 & 0b0111)) <<  8) |
    (((c0 & 0b1101) ^ (c1 & 0b1110) ^ (c2 & 0b0111) ^ (c3 & 0b1011)) <<  4) |
    (((c0 & 0b1110) ^ (c1 & 0b0111) ^ (c2 & 0b1011) ^ (c3 & 0b1101)) <<  0)
  );
  return column;
}

static inline uint16_t prince_m_1(uint16_t column) {
  uint8_t c0, c1, c2, c3;
  c0 = (column >> 12) & 0xf;
  c1 = (column >> 8)  & 0xf;
  c2 = (column >> 4)  & 0xf;
  c3 = (column >> 0)  & 0xf;

  column = (
    (((c0 & 0b1011) ^ (c1 & 0b1101) ^ (c2 & 0b1110) ^ (c3 & 0b0111)) << 12) |
    (((c0 & 0b1101) ^ (c1 & 0b1110) ^ (c2 & 0b0111) ^ (c3 & 0b1011)) <<  8) |
    (((c0 & 0b1110) ^ (c1 & 0b0111) ^ (c2 & 0b1011) ^ (c3 & 0b1101)) <<  4) |
    (((c0 & 0b0111) ^ (c1 & 0b1011) ^ (c2 & 0b1101) ^ (c3 & 0b1110)) <<  0)
  );
  return column;
}

static inline state_tk_t prince_m(state_tk_t state) { 
  // weird indecies to due endianess of union
  state.column[3] = prince_m_0(state.column[3]);
  state.column[2] = prince_m_1(state.column[2]);
  state.column[1] = prince_m_1(state.column[1]);
  state.column[0] = prince_m_0(state.column[0]);

  state.column[7] = prince_m_0(state.column[7]);
  state.column[6] = prince_m_1(state.column[6]);
  state.column[5] = prince_m_1(state.column[5]);
  state.column[4] = prince_m_0(state.column[4]);

  return state;
}

static inline uint64_t prince_shift(uint64_t state) {
  uint64_t shift_state = state & 0xF000F000F000F000;
  for (uint8_t i = 1; i < 4; ++i) {
      uint64_t row = state & (0xF000F000F000F000>>(4*i));
      shift_state |= (row<<i*16) | (row>>(64-i*16));
  }
  return shift_state & 0xffffffffffffffff;
}


static inline state_tk_t feistel(state_tk_t state) {
  // weird indecies to due endianess of union
  state_tk_t state_new = {.state = {0, 0}};

  state_new.column_double[0] = state.column_double[3];
  state_new.column_double[1] = state.column_double[1] ^ state.column_double[0];
  state_new.column_double[2] = state.column_double[1];
  state_new.column_double[3] = state.column_double[3] ^ state.column_double[2];

  return state_new;
}


static inline state_tk_t tks_shift(state_tk_t state) {
  state_tk_t state_new = {.state = {0, 0}};

  state_new.state[0] |= state.state[0] & 0xF000F000F000F000;
  state_new.state[1] |= state.state[1] & 0xF000F000F000F000;

  state_new.state[0] |= ((state.state[0] & 0x000000000F000F00) << 32) | ((state.state[1] & 0x0F000F0000000000) >> 32);
  state_new.state[1] |= ((state.state[1] & 0x000000000F000F00) << 32) | ((state.state[0] & 0x0F000F0000000000) >> 32);

  state_new.state[0] |= state.state[1] & 0x00F000F000F000F0;
  state_new.state[1] |= state.state[0] & 0x00F000F000F000F0;

  state_new.state[0] |= ((state.state[0] & 0x000F000F00000000) >> 32) | ((state.state[1] & 0x00000000000F000F) << 32);
  state_new.state[1] |= ((state.state[1] & 0x000F000F00000000) >> 32) | ((state.state[0] & 0x00000000000F000F) << 32);

  return state_new;
}


void tweak_key_schedule(state_tk_t key, state_tk_t* tweak, uint8_t R)
{
  if (R == 0)
    return;

  #if PRINT_INTER
  printf("R%d %-10s %016lx %016lx\n", 0, "Inital", tweak->state[0], tweak->state[1]);
  #endif

  for (int8_t round = 0; round < R;  ++round) {
    tweak->state[0] ^= key.state[0];
    tweak->state[1] ^= key.state[1];
    #if PRINT_INTER
    printf("R%d %-10s %016lx %016lx\n", round, "Key", tweak->state[0], tweak->state[1]);
    #endif

    tweak->state[0] ^= ROUND_CONSTANTS[round].state[0];
    tweak->state[1] ^= ROUND_CONSTANTS[round].state[1];
    #if PRINT_INTER
    printf("R%d %-10s %016lx %016lx\n", round, "RC", tweak->state[0], tweak->state[1]);
    #endif

    *tweak = sbox_tk(*tweak);
    #if PRINT_INTER
    printf("R%d %-10s %016lx %016lx\n", round, "SBox", tweak->state[0], tweak->state[1]);
    #endif

    *tweak = prince_m(*tweak);
    #if PRINT_INTER
    printf("R%d %-10s %016lx %016lx\n", round, "M Prince", tweak->state[0], tweak->state[1]);
    #endif
    
    tweak->state[0] = prince_shift(tweak->state[0]);
    tweak->state[1] = prince_shift(tweak->state[1]);
    #if PRINT_INTER
    printf("R%d %-10s %016lx %016lx\n", round, "Sh Prince", tweak->state[0], tweak->state[1]);
    #endif
    
    *tweak = feistel(*tweak);
    #if PRINT_INTER
    printf("R%d %-10s %016lx %016lx\n", round, "Feistel", tweak->state[0], tweak->state[1]);
    #endif

    *tweak = tks_shift(*tweak);
    #if PRINT_INTER
    printf("R%d %-10s %016lx %016lx\n", round, "Shift", tweak->state[0], tweak->state[1]);
    #endif
  }

  tweak->state[0] ^= key.state[0];
  tweak->state[1] ^= key.state[1];
  #if PRINT_INTER
  printf("R%d %-10s %016lx %016lx\n", R-1, "Key", tweak->state[0], tweak->state[1]);
  #endif

  tweak->state[0] ^= ROUND_CONSTANTS[R].state[0];
  tweak->state[1] ^= ROUND_CONSTANTS[R].state[1];
  #if PRINT_INTER
  printf("R%d %-10s %016lx %016lx\n", R, "RC", tweak->state[0], tweak->state[1]);
  #endif
}


void key_expansion(state_t* round_keys, state_tk_t* key, uint8_t nr_keys)
{
  assert(nr_keys > 3);
  
  // weird indecies to due endianess of union
  round_keys[0].state = key->column_double[1];
  round_keys[1].state = key->column_double[0];
  round_keys[2].state = key->column_double[3];
  round_keys[3].state = key->column_double[2];

  if (nr_keys > 4) {
    round_keys[4].state = round_keys[0].state ^ round_keys[1].state;
  }
  if (nr_keys > 5) {
    round_keys[5].state = round_keys[2].state ^ round_keys[3].state;
  }
  if (nr_keys > 6) {
    round_keys[6].state = round_keys[0].state ^ round_keys[2].state;
  }
  if (nr_keys > 7) {
    round_keys[7].state = round_keys[1].state ^ round_keys[3].state;
  }
  if (nr_keys > 8) {
    round_keys[8].state = round_keys[0].state ^ round_keys[3].state;
  }
  if (nr_keys > 9) {
    round_keys[9].state = round_keys[1].state ^ round_keys[2].state;
  }
}

void tests() { 
  state_t m;

  m.state = 0x12345678;
  assert(sbox(m).state == 0x42bac985);
  assert(sbox_inv(m).state == 0xd2b18ec7);
  assert(shift(m.state) == 0x16385274);
  assert(mixColumns(m).state == 0x1f43fd89);


  state_tk_t t = {.state = {0x0123456789abcdef, 0xfedcba9876543210}};
  assert(sbox_tk(t).state[0] == 0x042bac985fd3716e);
  assert(sbox_tk(t).state[1] == 0xe6173df589cab240);

  assert(prince_m(t).state[0] == 0x3012456789abfcde);
  assert(prince_m(t).state[1] == 0xcfedba9876540321);

  assert(prince_shift(t.state[0]) == 0x05af49e38d27c16b);

  assert(feistel(t).state[0] == 0x88888888fedcba98);
  assert(feistel(t).state[1] == 0x8888888801234567);

  assert(tks_shift(t).state[0] == 0x09d44d908e53ca17);
  assert(tks_shift(t).state[1] == 0xf62bb26f71ac35e8);

  state_t k[10];
  
  key_expansion(k, &t, 10);

  assert(k[0].state == 0x01234567);
  assert(k[1].state == 0x89abcdef);
  assert(k[2].state == 0xfedcba98);
  assert(k[3].state == 0x76543210);

  assert(k[4].state == 0x88888888);
  assert(k[5].state == 0x88888888);

  assert(k[6].state == 0xffffffff);
  assert(k[7].state == 0xffffffff);

  assert(k[8].state == 0x77777777);
  assert(k[9].state == 0x77777777);
}
