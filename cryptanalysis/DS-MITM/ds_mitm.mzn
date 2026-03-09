int: NR = 6; % the length of distinguisher (total number of rounds) - it is inteded to be > BP
int: BP = 3; % the length of distinguisher (total number of rounds) - it is inteded to be > BP

array[0..7] of int: round_permutation = array1d(0..7, [0, 1, 3, 2, 4, 5, 7, 6]); % round permutation

% ############################################################################################################################################                                                                                 
% Model Propagation
array[0..BP-1, 0..7] of var 0..1: xu;
array[0..BP-2, 0..7] of var 0..1: wu;

constraint sum(i in 0..7)(xu[0, i]) !=0;  

constraint forall(r in 0..BP - 2, i in 0..7)
(
    wu[r, i] = xu[r, round_permutation[i]]
);

constraint forall(r in 0..BP - 2, i in 0..1)
(
  mix_column(
    wu[r, i],
    wu[r, 2+i],
    wu[r, 4+i],
    wu[r, 6+i],
    xu[r+1, i],
    xu[r+1, 2+i],
    xu[r+1, 4+i],
    xu[r+1, 6+i]
  )
);


array[0..BP-1, 0..7] of var 0..1: xl;
array[0..BP-2, 0..7] of var 0..1: wl;

constraint forall(r in 0..BP - 2, i in 0..1)
(
  mix_column(
    xl[r+1, i],
    xl[r+1, 2+i],
    xl[r+1, 4+i],
    xl[r+1, 6+i],
    wl[r, i],
    wl[r, 2+i],
    wl[r, 4+i],
    wl[r, 6+i],
  )
);

constraint forall(r in 0..BP - 2, i in 0..7)
(
    wl[r, i] = xl[r, round_permutation[i]]
);


array[0..NR-BP-1, 0..7] of var 0..1: xur;
array[0..NR-BP-2, 0..7] of var 0..1: wur;

constraint sum(i in 0..7)(xur[0, i]) !=0;  

constraint forall(r in 0..NR-BP - 2, i in 0..7)
(
    wur[r, i] = xur[r, round_permutation[i]]
);

constraint forall(r in 0..NR-BP - 2, i in 0..1)
(
  mix_column(
    wur[r, i],
    wur[r, 2+i],
    wur[r, 4+i],
    wur[r, 6+i],
    xur[r+1, i],
    xur[r+1, 2+i],
    xur[r+1, 4+i],
    xur[r+1, 6+i]
  )
);

constraint forall(i in 0..7) (xl[BP-1, i] = xur[NR-BP-1, i]);


array[0..NR-BP-1, 0..7] of var 0..1: xlr;
array[0..NR-BP-2, 0..7] of var 0..1: wlr;

constraint forall(r in 0..NR-BP - 2, i in 0..1)
(
  mix_column(
    xlr[r+1, i],
    xlr[r+1, 2+i],
    xlr[r+1, 4+i],
    xlr[r+1, 6+i],
    wlr[r, i],
    wlr[r, 2+i],
    wlr[r, 4+i],
    wlr[r, 6+i],
  )
);

constraint forall(r in 0..NR-BP - 2, i in 0..7)
(
    wlr[r, i] = xlr[r, round_permutation[i]]
);

constraint forall(i in 0..7) (xu[BP-1, i] = xlr[NR-BP-1, i]);
% ############################################################################################################################################                                                                                 
% Define objective
var 0..NR*32: bits_to_guess;

constraint bits_to_guess = 4*sum(r in 0..BP-1, i in 0..7) (bool2int((xu[r, i] + xl[r, i]) = 2)) + 4*sum(r in 1..NR-BP-2, i in 0..7) (bool2int((xur[r, i] + xlr[r, i]) = 2));

%constraint bits_to_guess < 80;

solve minimize bits_to_guess;


% #############################################################################################################################################
% #############################################################################################################################################
% #############################################################################################################################################
%     _                 _  _  _                       _____                     _    _                    
%    / \   _   _ __  __(_)| |(_)  __ _  _ __  _   _  |  ___|_   _  _ __    ___ | |_ (_)  ___   _ __   ___ 
%   / _ \ | | | |\ \/ /| || || | / _` || '__|| | | | | |_  | | | || '_ \  / __|| __|| | / _ \ | '_ \ / __|
%  / ___ \| |_| | >  < | || || || (_| || |   | |_| | |  _| | |_| || | | || (__ | |_ | || (_) || | | |\__ \
% /_/   \_\\__,_|/_/\_\|_||_||_| \__,_||_|    \__, | |_|    \__,_||_| |_| \___| \__||_| \___/ |_| |_||___/
%                                             |___/       

% MDS matrix
predicate mix_column( var 0..1: diff_in1,
                      var 0..1: diff_in2,
                      var 0..1: diff_in3,
                      var 0..1: diff_in4,
                      var 0..1: diff_out1,
                      var 0..1: diff_out2,
                      var 0..1: diff_out3,
                      var 0..1: diff_out4,
                      ) =
  if diff_in1 + diff_in2 + diff_in3 + diff_in4 > 0 then
    diff_out1 = 1 /\
    diff_out2 = 1 /\
    diff_out3 = 1 /\
    diff_out4 = 1
  else
    diff_out1 + diff_out2 + diff_out3 + diff_out4 = 0
  endif
;
