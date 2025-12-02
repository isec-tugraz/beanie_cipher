int: NR; % the length of distinguisher (total number of rounds) - it is inteded to be > BP
int: BP;


% Shift 2nd and 4th row by 1 cells
% array[0..31] of int: round_permutation = array1d(0..31, [0, 1, 2, 3, 4, 5, 6, 7, 12, 13, 14, 15, 8, 9, 10, 11, 16, 17, 18, 19, 20, 21, 22, 23, 28, 29, 30, 31, 24, 25, 26, 27]); % round permutation
array[0..31] of int: round_permutation; % round permutation


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


