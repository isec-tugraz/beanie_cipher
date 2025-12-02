int: NR; % the length of distinguisher (total number of rounds) - it is inteded to be > BP
int: BP; % the length of distinguisher (total number of rounds) - it is inteded to be > BP
var 0..31: constant;
var 0..31: balanced;

% Skinny ShiftRows
%array[0..15] of int: round_permutation = array1d(0..15, [0, 1, 2, 3, 7, 4, 5, 6, 10, 11, 8, 9, 13, 14, 15, 12]); % round permutation

% Shift 2nd and 4th row by 2 cells
array[0..31] of int: round_permutation = array1d(0..31, [0, 1, 2, 3, 4, 5, 6, 7, 12, 13, 14, 15, 8, 9, 10, 11, 16, 17, 18, 19, 20, 21, 22, 23, 28, 29, 30, 31, 24, 25, 26, 27]); % round permutation

%array[0..15] of int: round_permutation = array1d(0..15, [0, 1, 2, 3, 4, 5, 6, 7, 10, 11, 8, 9, 14, 15, 12, 13]); % round permutation
%array[0..15] of int: round_permutation = array1d(0..15, [0, 1, 2, 3, 6, 7, 4, 5, 10, 11, 8, 9, 12, 13, 14, 15]); % round permutation


% ############################################################################################################################################                                                                                 
% Model Left Encryption
array[-1..BP-1, 0..31] of var bool: x;
array[0..BP-1, 0..31] of var bool: y;
array[-1..BP-1, 0..31] of var bool: k;
array[0..BP-1, 0..31] of var bool: z;
array[0..BP-2, 0..31] of var bool: w;

var 0..32: active_bits;
constraint sum(i in 0..31)(x[-1, i]) = active_bits;

constraint forall(i in 0..31)
(
  xor2(x[-1, i], k[-1, i], x[0, i])
);

constraint
(
forall(r in 0..BP-1, i in 0..7)
    (
        sbox(x[r,4*i],x[r,4*i+1],x[r,4*i+2],x[r,4*i+3], y[r,4*i], y[r,4*i+1], y[r,4*i+2], y[r,4*i+3]) 
    )
 );

constraint forall(r in 0..BP-1, i in 0..31)
(
  xor2(y[r, i], k[r, i], z[r, i])
);

constraint forall(r in 0..BP - 2, i in 0..31)
(
    w[r, i] = z[r, round_permutation[i]]
);

constraint forall(r in 0..BP - 2, i in 0..1)
(
  mix_column(
    [w[r, 4*i], w[r, 1+4*i], w[r, 2+4*i], w[r, 3+4*i],
    w[r, 8+4*i], w[r, 9+4*i], w[r, 10+4*i], w[r, 11+4*i],
    w[r, 16+4*i], w[r, 17+4*i], w[r, 18+4*i], w[r, 19+4*i],
    w[r, 24+4*i], w[r, 25+4*i], w[r, 26+4*i], w[r, 27+4*i]],
    [x[r+1, 4*i], x[r+1, 1+4*i], x[r+1, 2+4*i], x[r+1, 3+4*i],
    x[r+1, 8+4*i], x[r+1, 9+4*i], x[r+1, 10+4*i], x[r+1, 11+4*i],
    x[r+1, 16+4*i], x[r+1, 17+4*i], x[r+1, 18+4*i], x[r+1, 19+4*i],
    x[r+1, 24+4*i], x[r+1, 25+4*i], x[r+1, 26+4*i], x[r+1, 27+4*i]]
  )
);

% ############################################################################################################################################                                                                                 
% Model Right Encryption (Backwards)
array[0..NR-BP-1, 0..31] of var bool: xr;
array[0..NR-BP-1, 0..31] of var bool: yr;
array[0..NR-BP-1, 0..31] of var bool: kr;
array[0..NR-BP-1, 0..31] of var bool: zr;
array[0..NR-BP-2, 0..31] of var bool: wr;

constraint forall(r in 0..NR-BP - 2, i in 0..1)
(
  mix_column(
    [xr[r+1, 4*i], xr[r+1, 1+4*i], xr[r+1, 2+4*i], xr[r+1, 3+4*i],
    xr[r+1, 8+4*i], xr[r+1, 9+4*i], xr[r+1, 10+4*i], xr[r+1, 11+4*i],
    xr[r+1, 16+4*i], xr[r+1, 17+4*i], xr[r+1, 18+4*i], xr[r+1, 19+4*i],
    xr[r+1, 24+4*i], xr[r+1, 25+4*i], xr[r+1, 26+4*i], xr[r+1, 27+4*i]],
    [wr[r, 4*i], wr[r, 1+4*i], wr[r, 2+4*i], wr[r, 3+4*i],
    wr[r, 8+4*i], wr[r, 9+4*i], wr[r, 10+4*i], wr[r, 11+4*i],
    wr[r, 16+4*i], wr[r, 17+4*i], wr[r, 18+4*i], wr[r, 19+4*i],
    wr[r, 24+4*i], wr[r, 25+4*i], wr[r, 26+4*i], wr[r, 27+4*i]]
  )
);

constraint forall(r in 0..NR-BP - 2, i in 0..31)
(
    wr[r, i] = zr[r, round_permutation[i]]
);

constraint forall(r in 0..NR-BP-1, i in 0..31)
(
  xor2(zr[r, i], kr[r, i], yr[r, i])
);

constraint
(
forall(r in 0..NR-BP-1, i in 0..7)
    (
        sbox_inv(yr[r,4*i],yr[r,4*i+1],yr[r,4*i+2],yr[r,4*i+3], xr[r,4*i], xr[r,4*i+1], xr[r,4*i+2], xr[r,4*i+3]) 
    )
);

constraint forall(i in 0..31) (z[BP-1, i] = zr[NR-BP-1, i]);



% ############################################################################################################################################                                                                                 
% Define objective

%constraint exists(r in -1..NR-1, i in 0..31)(k[r, i] = 1);
constraint sum(i in 0..31) (xr[0, i]) <= 1;
constraint xr[0, balanced] = 1;
constraint active_bits = 31;
constraint x[-1, constant] = 0;
% solve satisfy;


% #############################################################################################################################################
% #############################################################################################################################################
% #############################################################################################################################################
%     _                 _  _  _                       _____                     _    _                    
%    / \   _   _ __  __(_)| |(_)  __ _  _ __  _   _  |  ___|_   _  _ __    ___ | |_ (_)  ___   _ __   ___ 
%   / _ \ | | | |\ \/ /| || || | / _` || '__|| | | | | |_  | | | || '_ \  / __|| __|| | / _ \ | '_ \ / __|
%  / ___ \| |_| | >  < | || || || (_| || |   | |_| | |  _| | |_| || | | || (__ | |_ | || (_) || | | |\__ \
% /_/   \_\\__,_|/_/\_\|_||_||_| \__,_||_|    \__, | |_|    \__,_||_| |_| \___| \__||_| \___/ |_| |_||___/
%                                             |___/       
% auxiliary functions

/*
% PRESENT SBox
predicate sbox(var 0..1: a0, var 0..1: a1, var 0..1: a2, var 0..1: a3, var 0..1: b0, var 0..1: b1, var 0..1: b2, var 0..1: b3) =
  - a1 - a3 + b0 + b1 + b2 >= -1 /\ 
  - a2 - a3 + b0 + b1 + b2 >= -1 /\ 
  - a0 - a1 - a2 + b0 + b3 >= -2 /\ 
  - a0 - a1 + a2 + a3 + b0 + b2 >= -1 /\ 
  - a0 + a1 + a2 - a3 + b1 + b2 >= -1 /\ 
  - a1 - a2 - a3 + b0 - b1 - b3 >= -4 /\ 
  - a0 - a2 - a3 - b0 + b1 - b3 >= -4 /\ 
  - a0 - a2 + a3 + b0 + b1 - b3 >= -2 /\ 
  - a0 - a1 - a3 + b1 - b2 - b3 >= -4 /\ 
  - a0 - a1 - a3 - b1 + b2 - b3 >= -4 /\ 
  - a0 - a1 + a3 - b0 + b1 + b3 >= -2 /\ 
  - a1 - a2 + a3 + b0 + b1 + b3 >= -1 /\ 
  - a1 + a2 + b0 - b1 - b2 + b3 >= -2 /\ 
  a0 - a2 + a3 + b0 + b2 + b3 >= 0 /\ 
  - a1 - a2 - a3 - b1 + b2 + b3 >= -3 /\ 
  - a1 - a2 - a3 - b0 + b1 - b2 + b3 >= -4 /\ 
  - a0 + a2 - a3 - b0 - b1 + b2 + b3 >= -3 /\ 
  a0 + a1 - a3 + b0 + b1 + b3 >= 0 /\ 
  a1 + a2 - a3 + b0 + b1 + b3 >= 0 /\ 
  a0 + a1 - a2 - a3 + b1 + b2 + b3 >= -1 /\ 
  - a2 - a3 - b0 - b1 - b2 + b3 >= -4 /\ 
  - a0 + a3 + b0 - b1 - b2 + b3 >= -2 /\ 
  - a0 - a2 + a3 - b0 + b2 + b3 >= -2 /\ 
  - a0 + b0 + b1 + b2 + b3 >= 0 /\ 
  - a0 - a2 - a3 + b0 + b2 - b3 >= -3 /\ 
  a0 + a1 - b0 - b1 - b3 >= -2 /\ 
  a0 + a1 + a3 - b0 - b2 >= -1 /\ 
  a1 + a2 - b1 - b2 - b3 >= -2 /\ 
  a0 - a1 + a2 + b1 + b3 >= 0 /\ 
  a0 + a2 - a3 + b0 + b3 >= 0 /\ 
  - a0 - a1 - a2 + b1 + b2 >= -2 /\ 
  a1 + a2 - b0 - b3 >= -1 /\ 
  a0 - b0 - b1 - b2 >= -2 /\ 
  a0 + a1 + a3 - b3 >= 0 /\ 
  a0 - b1 - b2 - b3 >= -2 /\ 
  a2 - b0 - b1 - b3 >= -2 /\ 
  a0 + a3 - b1 - b3 >= -1 /\ 
  a2 + a3 - b0 - b2 >= -1 /\ 
  a0 + a3 - b2 - b3 >= -1 /\ 
  a2 + a3 - b1 - b3 >= -1 /\ 
  a0 + a2 - b2 >= 0 
;

predicate sbox_inv(var 0..1: a0, var 0..1: a1, var 0..1: a2, var 0..1: a3, var 0..1: b0, var 0..1: b1, var 0..1: b2, var 0..1: b3) =
a0 - a2 + b0 + b1 + b2 >= 0 /\ 
- a0 - a1 - a2 + b1 + b3 >= -2 /\ 
- a0 - a2 + b1 + b2 + b3 >= -1 /\ 
- a0 + a1 - a2 + a3 - b0 + b1 >= -2 /\ 
- a0 - a1 - a2 + a3 + b0 + b2 >= -2 /\ 
a0 - a1 + a2 - a3 + b1 + b2 >= -1 /\ 
- a0 - a2 - a3 - b0 + b1 - b3 >= -4 /\ 
- a1 + a2 - a3 + b0 + b1 - b3 >= -2 /\ 
a1 - a2 - a3 + b0 + b2 - b3 >= -2 /\ 
- a0 - a1 - a3 - b1 + b2 - b3 >= -4 /\ 
- a2 + a3 + b0 - b1 + b2 - b3 >= -2 /\ 
a0 - a1 - a3 + b1 + b2 - b3 >= -2 /\ 
- a1 - a2 + a3 + b0 + b1 + b3 >= -1 /\ 
a0 + a1 - a2 - a3 - b2 + b3 >= -2 /\ 
- a1 - a2 - a3 - b0 - b2 + b3 >= -4 /\ 
- a1 - a2 - a3 - b1 - b2 + b3 >= -4 /\ 
- a1 - a2 + a3 - b0 + b2 + b3 >= -2 /\ 
- a1 + a2 + a3 + b0 + b2 + b3 >= 0 /\ 
- a0 - a1 - a3 - b0 + b1 - b2 + b3 >= -4 /\ 
a0 + a1 + a2 - a3 + b0 + b2 + b3 >= 0 /\ 
- a0 + a3 + b0 - b1 - b2 + b3 >= -2 /\ 
- a0 - a2 + a3 + b1 - b2 - b3 >= -3 /\ 
- a0 + a1 + a2 - a3 + b1 + b3 >= -1 /\ 
a0 + a1 - a2 + a3 + b0 + b2 >= 0 /\ 
- a0 - a1 + b0 - b1 - b2 + b3 >= -3 /\ 
a1 + a2 - b1 - b2 - b3 >= -2 /\ 
- a1 - a3 - b0 - b1 + b2 >= -3 /\ 
a1 + a2 + a3 - b0 - b1 >= -1 /\ 
- a0 - a1 + a3 + b1 + b2 + b3 >= -1 /\ 
a0 + a1 + a2 + a3 - b0 >= 0 /\ 
- a2 - a3 - b0 - b1 + b3 >= -3 /\ 
- a0 + a2 + b0 + b1 + b2 >= 0 /\ 
a2 - b0 - b1 - b3 >= -2 /\ 
a2 + a3 - b1 - b2 >= -1 /\ 
a0 + a2 - b2 - b3 >= -1 /\ 
a0 + a2 - b0 - b3 >= -1 /\ 
a0 + a2 + a3 - b2 >= 0 /\ 
- a0 - a1 - a2 - a3 + b0 >= -3
;
*/


/*
% Serpent S3 Sbox
predicate sbox(var bool: a0, var bool: a1, var bool: a2, var bool: a3, var bool: b0, var bool: b1, var bool: b2, var bool: b3) =
- a0 - a1 - a2 - a3 + b2 >= -3 /\ 
- a2 - a3 + b0 + b1 + b2 >= -1 /\ 
- a0 + b0 + b1 + b2 + b3 >= 0 /\ 
- a0 - a2 + a3 - b0 + b1 + b2 >= -2 /\ 
- a0 + a1 - a2 + b0 + b1 + b2 >= -1 /\ 
- a1 - a2 + a3 + b0 - b1 - b3 >= -3 /\ 
a1 - a2 - a3 + b0 + b1 - b3 >= -2 /\ 
- a0 - a1 - a3 + b0 - b2 - b3 >= -4 /\ 
- a0 - a2 - a3 + b0 + b2 - b3 >= -3 /\ 
- a0 - a1 + a2 + b0 - b1 + b3 >= -2 /\ 
a0 - a1 + a3 + b0 + b1 + b3 >= 0 /\ 
- a0 - a2 + a3 + b0 + b1 + b3 >= -1 /\ 
- a0 - a1 - a2 - b0 - b2 + b3 >= -4 /\ 
a0 - a2 - a3 + b1 - b2 + b3 >= -2 /\ 
- a0 - a2 - a3 - b0 + b2 + b3 >= -3 /\ 
a0 - a2 + a3 + b0 + b2 + b3 >= 0 /\ 
- a0 - a1 + a3 - b1 + b2 + b3 >= -2 /\ 
- a0 + a1 - a2 + a3 + b0 - b1 - b2 >= -3 /\ 
- a0 + a1 + a2 - a3 + b0 - b1 + b2 >= -2 /\ 
a0 - a1 + a2 - a3 - b1 + b2 + b3 >= -2 /\ 
- a1 - a2 - a3 - b0 - b1 + b2 + b3 >= -4 /\ 
- a0 - a1 - a3 - b0 + b1 - b2 + b3 >= -4 /\ 
- a1 - a2 + a3 + b1 + b2 + b3 >= -1 /\ 
a0 - a1 + a2 + b1 + b2 - b3 >= -1 /\ 
- a0 + a1 + a2 - a3 - b0 + b2 >= -2 /\ 
a0 + a1 - a2 - a3 + b1 - b3 >= -2 /\ 
- a0 - a3 - b0 - b1 + b2 - b3 >= -4 /\ 
- a1 - a2 - a3 + b0 - b2 + b3 >= -3 /\ 
a0 + a1 + a2 + a3 - b0 >= 0 /\ 
a0 + a1 + a3 - b1 >= 0 /\ 
- a2 - a3 - b0 + b1 - b2 >= -3 /\ 
- a3 + b0 + b1 + b2 + b3 >= 0 /\ 
a2 + a3 - b2 - b3 >= -1 /\ 
a0 + a2 + a3 - b3 >= 0 /\ 
a1 + a2 + a3 - b2 >= 0 /\ 
a0 + a3 - b1 - b3 >= -1 /\ 
a0 + a2 + a3 - b2 >= 0 /\ 
a3 - b0 - b1 - b2 >= -2
;

predicate sbox_inv(var bool: a0, var bool: a1, var bool: a2, var bool: a3, var bool: b0, var bool: b1, var bool: b2, var bool: b3) =
a0 + a1 + a2 - b1 >= 0 /\ 
a0 + a1 + a3 - b1 >= 0 /\ 
a2 + a3 - b0 - b1 >= -1 /\ 
a2 + a3 - b1 - b2 >= -1 /\ 
a0 + a2 - b1 - b3 >= -1 /\ 
a1 + a3 - b1 - b3 >= -1 /\ 
a1 - b0 - b1 - b3 >= -2 /\ 
a2 - b1 - b2 - b3 >= -2 /\ 
- a0 - a2 - a3 + b0 + b1 >= -2 /\ 
- a1 - a2 - a3 + b0 + b2 >= -2 /\ 
- a1 - a3 + b0 + b1 + b2 >= -1 /\ 
- a2 - a3 + b0 + b1 + b2 >= -1 /\ 
- a0 - a1 - a2 - a3 + b3 >= -3 /\ 
- a0 - a1 - a2 + b2 + b3 >= -2 /\ 
- a0 + b0 + b1 + b2 + b3 >= 0 /\ 
- a2 + b0 + b1 + b2 + b3 >= 0 /\ 
- a0 - a1 + a2 + a3 + b0 - b2 >= -2 /\ 
- a0 - a2 + a3 - b0 + b1 + b2 >= -2 /\ 
- a0 - a1 + a2 + a3 + b0 - b3 >= -2 /\ 
- a0 - a1 - a2 - b0 + b1 - b3 >= -4 /\ 
- a0 - a1 - a3 + b0 - b2 - b3 >= -4 /\ 
- a1 + a2 - a3 - b0 + b2 - b3 >= -3 /\ 
- a0 - a2 - a3 - b1 + b2 - b3 >= -4 /\ 
- a0 - a1 - a3 - b0 + b1 + b3 >= -3 /\ 
- a0 + a1 - a2 + b0 + b1 + b3 >= -1 /\ 
a0 + a1 - a3 + b0 + b1 + b3 >= 0 /\ 
a1 - a2 - b0 - b1 - b2 + b3 >= -3 /\ 
- a0 + a3 + b0 - b1 - b2 + b3 >= -2 /\ 
a2 - a3 - b0 + b1 - b2 + b3 >= -2 /\ 
- a0 + a1 + a2 + a3 + b2 + b3 >= 0 /\ 
a0 - a2 - b0 - b1 + b2 + b3 >= -2 /\ 
a0 - a1 + a2 - a3 + b1 - b2 + b3 >= -2 /\ 
a0 + a1 - a2 - a3 - b0 + b2 + b3 >= -2 /\ 
a0 - a1 + a2 + a3 + b0 + b2 + b3 >= 0 /\ 
a0 - a1 - a2 + a3 - b0 + b3 >= -2 /\ 
- a1 - a2 - a3 + b0 + b1 - b3 >= -3 /\ 
a0 - b0 - b1 - b2 - b3 >= -3 /\ 
a0 + a3 - b1 - b3 >= -1 /\ 
a1 - b0 - b2 - b3 >= -2 /\ 
a1 + a2 - b1 - b2 >= -1 /\ 
a0 + a1 + a2 - b2 >= 0 /\ 
a0 + a1 + a3 - b3 >= 0 /\ 
a1 + a2 + a3 - b0 >= 0 /\ 
a1 + a2 - b0 - b1 >= -1
;
*/

% S = SboxAnalyzer([0,4,2,0xB,0xA,0xC,9,8,5,0xF,0xD,3,7,1,6,0xE])
predicate sbox(var bool: a0, var bool: a1, var bool: a2, var bool: a3, var bool: b0, var bool: b1, var bool: b2, var bool: b3) =
a0 + a1 + a2 - b0 >= 0 /\ 
a0 + a1 + a3 - b0 >= 0 /\ 
a1 + a2 + a3 - b0 >= 0 /\ 
a1 + a2 + a3 - b2 >= 0 /\ 
a3 - b0 - b1 - b2 >= -2 /\ 
a0 + a3 - b2 - b3 >= -1 /\ 
a3 - b0 - b2 - b3 >= -2 /\ 
- a0 - a1 - a2 - a3 + b1 >= -3 /\ 
a1 - a2 + a3 + b0 - b3 >= -1 /\ 
- a1 - a2 - a3 + b2 - b3 >= -3 /\ 
- a1 - a2 + a3 + b0 + b3 >= -1 /\ 
- a2 + a3 - b1 - b2 + b3 >= -2 /\ 
a0 - a1 + b0 + b2 + b3 >= 0 /\ 
- a0 - a2 + b0 + b2 + b3 >= -1 /\ 
- a3 + b0 + b1 + b2 + b3 >= 0 /\ 
- a0 + a1 - a2 - b0 + b1 - b2 >= -3 /\ 
- a0 - a1 + a2 + a3 - b1 + b2 >= -2 /\ 
a1 - a2 - a3 - b0 - b1 + b2 >= -3 /\ 
- a1 + a2 - a3 + b0 + b1 - b3 >= -2 /\ 
- a0 - a1 + a3 + b1 + b2 - b3 >= -2 /\ 
- a0 + a2 + a3 + b0 + b1 + b3 >= 0 /\ 
a0 + a1 - a3 + b0 - b2 + b3 >= -1 /\ 
- a0 - a2 - a3 + b1 - b2 + b3 >= -3 /\ 
- a0 - a1 - a3 - b0 - b1 + b2 + b3 >= -4 /\ 
- a0 - a1 - a3 - b0 + b1 - b2 + b3 >= -4 /\ 
- a1 - a2 - a3 - b0 - b2 + b3 >= -4 /\ 
a1 + a2 - a3 + b0 + b2 - b3 >= -1 /\ 
- a1 - a3 + b0 - b1 - b2 >= -3 /\ 
a0 + a2 - a3 + b1 + b2 >= 0 /\ 
a0 - a2 + a3 + b2 + b3 >= 0 /\ 
a0 - b1 - b3 >= -1 /\ 
a0 + a2 - b3 >= 0 /\ 
a0 - b1 - b2 >= -1 /\ 
a0 + a3 - b1 >= 0
;

predicate sbox_inv(var bool: a0, var bool: a1, var bool: a2, var bool: a3, var bool: b0, var bool: b1, var bool: b2, var bool: b3) =
a1 - a2 - a3 + b1 + b2 >= -1 /\ 
- a0 - a1 - a2 - b0 + b3 >= -3 /\ 
a1 - a3 - b1 - b2 + b3 >= -2 /\ 
- a0 + b0 + b1 + b2 + b3 >= 0 /\ 
- a1 + a2 - a3 + b0 + b1 + b2 >= -1 /\ 
- a1 - a2 + b0 - b1 - b2 - b3 >= -4 /\ 
- a0 - a1 - a3 + b0 - b1 + b3 >= -3 /\ 
a0 + a1 + a3 + b0 - b1 + b3 >= 0 /\ 
a1 + a2 - a3 + b0 + b1 + b3 >= 0 /\ 
- a1 - a2 + a3 + b0 + b1 + b3 >= -1 /\ 
a0 + a1 - a3 + b0 - b2 + b3 >= -1 /\ 
a0 - a2 + b0 + b1 + b2 + b3 >= 0 /\ 
- a0 - a1 + a2 - a3 - b0 - b1 - b2 >= -5 /\ 
- a0 + a1 + a2 - a3 - b0 + b1 - b2 >= -3 /\ 
a0 - a1 - a2 + a3 + b1 - b2 - b3 >= -3 /\ 
- a0 - a1 - a3 - b0 + b1 - b2 - b3 >= -5 /\ 
a0 - a1 - a2 - b0 + b1 + b2 - b3 >= -3 /\ 
- a1 - a2 - a3 - b0 + b1 - b2 + b3 >= -4 /\ 
- a0 + a1 - a2 + b0 - b1 + b2 + b3 >= -2 /\ 
- a1 + a2 + a3 - b1 + b2 >= -1 /\ 
- a0 + a1 - a3 + b0 + b2 - b3 >= -2 /\ 
a0 - a1 + a2 + b1 + b3 >= 0 /\ 
- a0 - a2 + a3 + b1 + b3 >= -1 /\ 
a1 - b0 - b1 - b2 >= -2 /\ 
- a0 - a1 - a2 - a3 + b2 >= -3 /\ 
- a0 - a1 - a2 + b0 + b1 >= -2 /\ 
a0 - b1 - b2 - b3 >= -2 /\ 
a0 + a3 - b1 - b3 >= -1 /\ 
a0 + a1 + a3 - b3 >= 0 /\ 
a2 + a3 - b0 >= 0 /\ 
a0 + a2 - b2 >= 0 /\ 
a1 + a3 - b0 >= 0
;

predicate xor2(var bool: a0, var bool: a1, var bool: b) =
  a0 + a1 - b = 0
;

array[0..15, 0..15] of var bool: M = array2d(0..15,0..15,
    [
 false, true, false, false, true, false, false, false, true, false, false, false, false, false, false, true, false, false, true, false, false, true, false, false, false, true, false, false, true, false, false, false, true, false, false, true, false, false, true, false, false, false, true, false, false, true, false, false, true, false, false, false, false, false, false, true, false, false, false, true, false, false, true, true, true, false, false, false, false, false, true, false, false, true, true, true, true, false, false, false, false, true, false, false, true, false, false, true, false, false, true, true, false, true, false, false, false, false, true, false, true, true, false, false, false, false, false, true, false, false, true, false, false, false, false, true, false, true, false, false, true, true, true, true, false, false, false, true, false, false, true, true, false, false, false, true, false, false, true, false, true, false, false, false, false, false, false, true, true, false, false, false, true, false, false, true, false, true, false, false, true, false, false, false, false, true, false, false, true, true, false, false, false, false, true, false, false, true, true, true, false, false, true, true, false, true, false, false, false, false, false, true, true, false, false, false, false, false, true, true, true, false, false, false, false, true, false, false, false, true, false, false, false, false, false, true, false, true, false, false, false, false, true, false, false, false, true, false, true, false, false, false, false, false, true, false, true, false, false, true, false, false, false, true, false, true, true, true, false, false, false, true, true, false, false, false 
    ]);


predicate mix_column(array[1..16] of var bool: x, array[1..16] of var bool: y) =
  let{array[0..15, 0..15] of var bool: M_inv} in
  sum(x) = sum(y) /\
  forall(i in 0..15, j in 0..15)(
    if (i = j) then
      y[i+1] = xorall(k in 0..15)(
        M[i, k] /\ y[i+1] /\ x[k+1] /\ M_inv[k, j]
      )
    else
      0 = xorall(k in 0..15)(
        M[i, k] /\ y[i+1] /\ x[k+1] /\ M_inv[k, j]
      )
    endif
  )
;
