int: NR; % the length of distinguisher (total number of rounds) - it is inteded to be > BP
int: BP;


% Shift 2nd and 4th row by 1 cells
array[0..31] of int: round_permutation = array1d(0..31, [0, 1, 2, 3, 4, 5, 6, 7, 12, 13, 14, 15, 8, 9, 10, 11, 16, 17, 18, 19, 20, 21, 22, 23, 28, 29, 30, 31, 24, 25, 26, 27]); % round permutation


% ############################################################################################################################################                                                                                 
% Model Left Encryption
array[0..BP-1, 0..31] of var 0..1: x;
array[0..BP-1, 0..31] of var 0..1: y;
array[0..BP-2, 0..31] of var 0..1: w;
array[0..BP-1, 0..7] of var 0..1: p0l;
array[0..BP-1, 0..7] of var 0..1: p1l;

constraint sum(i in 0..31)(x[0, i]) !=0;  

constraint
(
forall(r in 0..BP-1, i in 0..7)
    (
        sbox(x[r,4*i],x[r,4*i+1],x[r,4*i+2],x[r,4*i+3], y[r,4*i], y[r,4*i+1], y[r,4*i+2], y[r,4*i+3], p0l[r, i], p1l[r, i]) 
    )
 );

constraint forall(r in 0..BP - 2, i in 0..31)
(
    w[r, i] = y[r, round_permutation[i]]
);

constraint forall(r in 0..BP - 2, i in 0..1)
(
  mix_column(
    w[r, 4*i], w[r, 1+4*i], w[r, 2+4*i], w[r, 3+4*i],
    w[r, 8+4*i], w[r, 9+4*i], w[r, 10+4*i], w[r, 11+4*i],
    w[r, 16+4*i], w[r, 17+4*i], w[r, 18+4*i], w[r, 19+4*i],
    w[r, 24+4*i], w[r, 25+4*i], w[r, 26+4*i], w[r, 27+4*i],
    x[r+1, 4*i], x[r+1, 1+4*i], x[r+1, 2+4*i], x[r+1, 3+4*i],
    x[r+1, 8+4*i], x[r+1, 9+4*i], x[r+1, 10+4*i], x[r+1, 11+4*i],
    x[r+1, 16+4*i], x[r+1, 17+4*i], x[r+1, 18+4*i], x[r+1, 19+4*i],
    x[r+1, 24+4*i], x[r+1, 25+4*i], x[r+1, 26+4*i], x[r+1, 27+4*i],
  )
);

% ############################################################################################################################################                                                                                 
% Model Right Encryption
array[0..NR-BP-1, 0..31] of var 0..1: xr;
array[0..NR-BP-1, 0..31] of var 0..1: yr;
array[0..NR-BP-2, 0..31] of var 0..1: wr;
array[0..NR-BP-1, 0..7] of var 0..1: p0r;
array[0..NR-BP-1, 0..7] of var 0..1: p1r;

constraint forall(r in 0..NR-BP - 2, i in 0..1)
(
  mix_column(
    xr[r+1, 4*i], xr[r+1, 1+4*i], xr[r+1, 2+4*i], xr[r+1, 3+4*i],
    xr[r+1, 8+4*i], xr[r+1, 9+4*i], xr[r+1, 10+4*i], xr[r+1, 11+4*i],
    xr[r+1, 16+4*i], xr[r+1, 17+4*i], xr[r+1, 18+4*i], xr[r+1, 19+4*i],
    xr[r+1, 24+4*i], xr[r+1, 25+4*i], xr[r+1, 26+4*i], xr[r+1, 27+4*i],
    wr[r, 4*i], wr[r, 1+4*i], wr[r, 2+4*i], wr[r, 3+4*i],
    wr[r, 8+4*i], wr[r, 9+4*i], wr[r, 10+4*i], wr[r, 11+4*i],
    wr[r, 16+4*i], wr[r, 17+4*i], wr[r, 18+4*i], wr[r, 19+4*i],
    wr[r, 24+4*i], wr[r, 25+4*i], wr[r, 26+4*i], wr[r, 27+4*i],
  )
);

constraint forall(r in 0..NR-BP - 2, i in 0..31)
(
    wr[r, i] = yr[r, round_permutation[i]]
);

constraint
(
forall(r in 0..NR-BP-1, i in 0..7)
    (
        sbox_inv(yr[r,4*i],yr[r,4*i+1],yr[r,4*i+2],yr[r,4*i+3], xr[r,4*i], xr[r,4*i+1], xr[r,4*i+2], xr[r,4*i+3], p0r[r, i], p1r[r, i])
    )
 );

constraint if(NR-BP >0) then forall(i in 0..31) (y[BP-1, i] = yr[NR-BP-1, i]) endif;

% solve minimize 3 * (sum(p0l) + sum(p0r)) + 2 * (sum(p1l) + sum(p1r));
% constraint 3 * (sum(p0l) + sum(p0r)) + 2 * (sum(p1l) + sum(p1r)) < 33;

% 5, 3
% constraint x[0, 0..31] = array1d(0..31, [0, 0, 0, 0, 0, 1, 0, 1, 0, 0,  0,  1,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  1,  0,  1,  0,  0,  0,  0]);
% constraint xr[0, 0..31] = array1d(0..31, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  0,  0,  0,  0,  0,  1,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  1,  1,  1,  1]);

% 6, 3
% constraint x[0, 0..31] = array1d(0..31, [1, 1, 0, 1, 0, 0, 0, 0, 0, 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  1,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  1,  1]);
% constraint xr[0, 0..31] = array1d(0..31, [1, 1, 0, 1, 0, 0, 0, 0, 0, 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  1,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  1,  1]);

% 6, 4
% constraint x[0, 0..31] = array1d(0..31, [0, 0, 0, 0, 1, 1, 0, 1, 1, 1,  1,  1,  0,  0,  0,  1,  0,  1,  0,  1,  0,  0,  0,  1,  1,  1,  1,  1,  0,  0,  0,  1]);
% constraint xr[0, 0..31] = array1d(0..31, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  0,  0,  1,  1,  0,  1,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  1,  1,  1,  1]);

% 5, 1: 1sol
% constraint x[0, 0..31] = array1d(0..31, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  1,  1,  0,  0,  0,  0,  0,  1,  0,  1,  0,  0,  0,  1,  0,  0,  0,  0,  1,  0,  1,  1]);
% constraint xr[0, 0..31] = array1d(0..31, [0, 0, 0, 0, 1, 0, 1, 1, 0, 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0]);


% ############################################################################################################################################                                                                                 
% Predicates

predicate sbox(var 0..1: a0, var 0..1: a1, var 0..1: a2, var 0..1: a3, var 0..1: b0, var 0..1: b1, var 0..1: b2, var 0..1: b3, var 0..1: p0, var 0..1: p1) =
- p0 - p1 >= -1 /\
- a2 + b2 + p0 >= 0 /\
a0 - a1 + b0 + p0 >= 0 /\
- a1 - b0 - b1 + p0 >= -2 /\
- a2 - a3 - b3 + p0 >= -2 /\
a0 + b0 - b3 + p0 >= 0 /\
- a0 - a3 + b3 + p0 >= -1 /\
a0 - b0 + b3 + p0 >= 0 /\
a1 + a2 + b0 + b1 - b2 >= 0 /\
a0 + a2 - b1 - b2 - b3 >= -2 /\
a2 + a3 + b1 + b2 - b3 >= 0 /\
- a0 - a1 + b1 + b2 + b3 >= -1 /\
a0 + a1 + a2 + a3 - p0 >= 0 /\
- a0 - a2 - b0 - b1 + p0 >= -3 /\
a0 + a2 - a3 + b1 + p0 >= 0 /\
- a0 + a2 + a3 + b1 + p0 >= 0 /\
a1 + b0 - b1 + b2 + p0 >= 0 /\
- a0 - a1 + b1 - b3 + p0 >= -2 /\
a2 + b0 - b2 - b3 + p0 >= -1 /\
- a3 - b1 - b2 - b3 + p0 >= -3 /\
a3 + b0 - b2 + b3 + p0 >= 0 /\
a1 + a3 + b1 + p0 - p1 >= 0 /\
a0 + a1 - a2 - a3 - b0 - b1 >= -3 /\
- a0 - a1 - a2 + a3 + b0 + b1 >= -2 /\
- a0 - a1 + a2 - a3 - b1 - b2 >= -4 /\
- a0 + a1 + a2 - a3 - b0 + b2 >= -2 /\
a0 - a1 + a3 + b0 - b1 + b2 >= -1 /\
a0 - a1 + a2 - a3 - b0 - b3 >= -3 /\
- a1 - a2 - a3 + b0 - b1 - b3 >= -4 /\
- a0 - a1 - a3 - b0 - b2 - b3 >= -5 /\
a0 - a3 - b0 - b1 - b2 - b3 >= -4 /\
- a0 - a2 - b0 + b1 - b2 - b3 >= -4 /\
- a0 - a1 + a3 - b0 + b2 - b3 >= -3 /\
a0 + a1 + a3 - b0 + b2 - b3 >= -1 /\
- a0 + a1 - a2 + b0 + b2 - b3 >= -2 /\
a1 + a2 - a3 - b1 + b2 - b3 >= -2 /\
a0 - a2 + a3 - b1 + b2 - b3 >= -2 /\
a0 - a1 + a2 + b1 + b2 - b3 >= -1 /\
- a0 + a2 + a3 - b0 - b2 + b3 >= -2 /\
- a0 + a1 + a2 - b1 + b2 + b3 >= -1 /\
a2 + a3 - b0 - b1 + b2 + b3 >= -1 /\
- a0 + a1 + a2 - a3 + b1 + p1 >= -1 /\
a0 + a1 + a3 - b0 - b2 + p1 >= -1 /\
a1 + a3 - b1 - b2 - b3 + p1 >= -2 /\
a0 + a1 - a2 - a3 + b3 + p1 >= -1 /\
- a0 - a1 + a2 + b0 + b3 + p1 >= -1 /\
a0 + b0 - b1 - b2 + b3 + p1 >= -1 /\
- a0 - a1 + b0 + b2 + b3 + p1 >= -1 /\
b0 + b1 + b2 + b3 - p0 + p1 >= 0 /\
a0 - a1 - a2 + a3 - b0 - b2 - b3 >= -4 /\
- a1 - a2 - a3 - b0 + b1 - b2 + b3 >= -4 /\
a0 + a1 - a2 - a3 + b0 + b1 + p1 >= -1 /\
- a0 + a1 - a2 + b0 - b1 - b2 + p1 >= -3 /\
a0 - a2 - a3 + b0 + b1 - b2 + p1 >= -2 /\
- a0 - a1 + a2 + b0 - b1 + b2 + p1 >= -2 /\
- a0 - a2 + a3 + b0 - b2 - b3 + p1 >= -3 /\
a0 + a2 - b0 + b1 - b2 - b3 + p1 >= -2 /\
- a0 + a1 + a2 - b0 + b2 - b3 + p1 >= -2 /\
- a0 - a2 + a3 - b0 + b1 + b3 + p1 >= -2 /\
a1 - a2 - a3 + b0 - b2 + b3 + p1 >= -2 /\
- a1 - a2 + a3 - b0 - b1 - b2 + b3 - p0 + p1 >= -5 /\
a1 - a3 - b0 - b1 + b2 + b3 >= -2
;

predicate sbox_inv(var 0..1: a0, var 0..1: a1, var 0..1: a2, var 0..1: a3, var 0..1: b0, var 0..1: b1, var 0..1: b2, var 0..1: b3, var 0..1: p0, var 0..1: p1) =
a2 - b2 - p1 >= -1 /\
- b0 + p0 + p1 >= 0 /\
- b1 + p0 + p1 >= 0 /\
- b2 + p0 + p1 >= 0 /\
- b3 + p0 + p1 >= 0 /\
- a0 - a1 - b1 - p1 >= -3 /\
- a0 + a3 + b1 - p1 >= -1 /\
a1 - b1 - b3 - p1 >= -2 /\
b0 - b1 - b3 - p1 >= -2 /\
a0 + b0 + b3 - p1 >= 0 /\
a3 + b0 + b3 - p1 >= 0 /\
a1 + a2 + a3 - b0 - b1 >= -1 /\
a0 + a1 + a3 - b0 + b2 >= 0 /\
a0 + a1 - a2 + b1 + b2 >= 0 /\
- a1 - a3 + b0 + b1 + b2 >= -1 /\
- a1 - a2 - a3 - b1 - b3 >= -4 /\
a1 + a2 - a3 + b2 + b3 >= 0 /\
- a0 + b0 + b1 + b2 + b3 >= 0 /\
a0 + a1 + a2 + a3 - p0 >= 0 /\
a0 - a2 + a3 - b0 - p1 >= -2 /\
a1 - a2 - a3 - b2 - p1 >= -3 /\
- a1 - a3 + b1 - b3 - p1 >= -3 /\
a1 + b0 + b2 - b3 - p1 >= -1 /\
a0 - a2 + b2 + b3 - p1 >= -1 /\
a1 - b0 + b2 + b3 - p1 >= -1 /\
- a1 - a2 + a3 - b0 - b1 + b2 >= -3 /\
a1 + a2 - a3 + b0 - b1 + b2 >= -1 /\
a0 + a2 + a3 - b0 - b1 - b3 >= -2 /\
a0 + a1 + a3 - b0 + b1 - b3 >= -1 /\
a0 - a2 + b0 - b1 - b2 - b3 >= -3 /\
- a0 - a3 + b0 - b1 + b2 - b3 >= -3 /\
a1 + a3 - b0 + b1 + b2 - b3 >= -1 /\
a1 - a2 + a3 - b0 + b2 + b3 >= -1 /\
a0 - a1 - a2 + a3 + b0 - p0 >= -2 /\
a0 + a1 + a2 - b0 + b1 - p0 >= -1 /\
- a0 - a1 - a3 + b0 + b1 - p0 >= -3 /\
- a0 - a2 - a3 + b0 + b2 - p0 >= -3 /\
a0 + a2 + a3 - b1 + b3 - p0 >= -1 /\
a2 - b0 - b1 + b2 + b3 - p0 >= -2 /\
a0 - a1 + a2 + b1 + b2 - p1 >= -1 /\
a3 + b0 + b1 - b2 - b3 + p1 >= -1 /\
a2 - b0 + b1 + b2 - b3 + p1 >= -1 /\
- a0 - a2 - a3 + b0 + b3 + p1 >= -2 /\
- a0 - a2 + b0 + b1 + b3 + p1 >= -1 /\
- a0 - a3 + b0 + b1 + b3 + p1 >= -1 /\
a1 - b0 - b1 - b2 + b3 + p1 >= -2 /\
- a1 + a2 + a3 + b2 + b3 + p1 >= 0 /\
a0 - a1 + b0 + b2 + b3 + p1 >= 0 /\
a0 - a1 + a2 - a3 + b0 - b1 - b2 >= -3 /\
- a0 + a1 + a2 - a3 - b0 + b1 + b2 >= -2 /\
- a0 + a1 - a2 + a3 - b1 - b2 - b3 >= -4 /\
- a0 - a1 + a2 - a3 - b1 - b2 + b3 >= -4 /\
- a0 - a2 - a3 - b0 + b1 - b2 + b3 >= -4 /\
a0 - a1 - a2 - b0 + b1 - b2 - p0 >= -4 /\
- a0 + a1 - a2 - a3 - b0 - b3 - p0 >= -5 /\
a0 - a1 + a2 - a3 - b0 - b3 - p0 >= -4 /\
a0 + a1 + b0 + b1 - b2 - b3 - p0 >= -2 /\
a0 - a2 - a3 - b0 + b1 + b3 - p0 >= -3 /\
a0 - a2 - a3 - b0 - b2 + b3 - p0 >= -4 /\
- a0 + a1 + a3 - b0 - b2 + b3 - p0 >= -3 /\
a0 - a1 - a3 + b1 - b2 + b3 - p0 >= -3 /\
- a0 - a1 - b0 + b1 + b2 + b3 - p0 >= -3 /\
- a0 - a1 - a2 + a3 - b1 - b2 + b3 - p0 + p1 >= -5 /\
- a0 - a1 + a2 + a3 + b1 - b3 >= -2
;


predicate mix_column( var 0..1: in00, var 0..1: in01, var 0..1: in02, var 0..1: in03,
                      var 0..1: in10, var 0..1: in11, var 0..1: in12, var 0..1: in13,
                      var 0..1: in20, var 0..1: in21, var 0..1: in22, var 0..1: in23,
                      var 0..1: in30, var 0..1: in31, var 0..1: in32, var 0..1: in33,
                      var 0..1: out00, var 0..1: out01, var 0..1: out02, var 0..1: out03,
                      var 0..1: out10, var 0..1: out11, var 0..1: out12, var 0..1: out13,
                      var 0..1: out20, var 0..1: out21, var 0..1: out22, var 0..1: out23,
                      var 0..1: out30, var 0..1: out31, var 0..1: out32, var 0..1: out33,
                      ) =
out00 = ((in01 +in10 +in20 +in33) mod 2 = 1) /\
out01 = ((in02 +in11 +in21 +in30) mod 2 = 1) /\
out02 = ((in00 +in03 +in12 +in22 +in31) mod 2 = 1) /\
out03 = ((in00 +in13 +in23 +in32 +in33) mod 2 = 1) /\
out10 = ((in00 +in12 +in21 +in22 +in23 +in30) mod 2 = 1) /\
out11 = ((in01 +in10 +in13 +in22 +in23 +in31) mod 2 = 1) /\
out12 = ((in02 +in10 +in11 +in23 +in32) mod 2 = 1) /\
out13 = ((in03 +in11 +in20 +in21 +in22 +in23 +in33) mod 2 = 1) /\
out20 = ((in02 +in03 +in13 +in22 +in30) mod 2 = 1) /\
out21 = ((in03 +in10 +in20 +in23 +in31) mod 2 = 1) /\
out22 = ((in00 +in11 +in20 +in21 +in32) mod 2 = 1) /\
out23 = ((in01 +in02 +in03 +in12 +in13 +in21 +in33) mod 2 = 1) /\
out30 = ((in00 +in12 +in13 +in20 +in31) mod 2 = 1) /\
out31 = ((in01 +in13 +in21 +in32) mod 2 = 1) /\
out32 = ((in02 +in10 +in22 +in30 +in33) mod 2 = 1) /\
out33 = ((in03 +in11 +in12 +in13 +in23 +in30) mod 2 = 1) ;
