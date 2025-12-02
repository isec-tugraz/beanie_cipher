from minizinc import Instance, Model, Solver
import argparse

from sage.all_cmdline import *
# from sboxanalyzer import *
from sage.crypto import sboxes

F2 = GF(2)['x']; (x,) = F2._first_ngens(1)

sbox_candidates = {'PRESENT': sboxes.PRESENT,
                   # 'CRAFT': sboxes.CRAFT,
                   'SERPENT_S0': sboxes.SERPENT_S0,
                   # 'PRINCE': sboxes.PRINCE,
                   'G7': [0,4,2,0xB,0xA,0xC,9,8,5,0xF,0xD,3,7,1,6,0xE]
                   }

permutation_candidates = {
        '0011': [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 20, 21, 22, 23, 16, 17, 18, 19, 28, 29, 30, 31, 24, 25, 26, 27],
        '0101': [0, 1, 2, 3, 4, 5, 6, 7, 12, 13, 14, 15, 8, 9, 10, 11, 16, 17, 18, 19, 20, 21, 22, 23, 28, 29, 30, 31, 24, 25, 26, 27],
        '0110': [0, 1, 2, 3, 4, 5, 6, 7, 12, 13, 14, 15, 8, 9, 10, 11, 20, 21, 22, 23, 16, 17, 18, 19, 24, 25, 26, 27, 28, 29, 30, 31],
        '1001': [4, 5, 6, 7, 0, 1, 2, 3, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 28, 29, 30, 31, 24, 25, 26, 27],
        '1010': [4, 5, 6, 7, 0, 1, 2, 3, 8, 9, 10, 11, 12, 13, 14, 15, 20, 21, 22, 23, 16, 17, 18, 19, 24, 25, 26, 27, 28, 29, 30, 31],
        '1100': [4, 5, 6, 7, 0, 1, 2, 3, 12, 13, 14, 15, 8, 9, 10, 11, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31],
                          }

mcol_candidates = {'jean_inv': [x**4 +x+1 ,[[0x2, 0x1, 0x1, 0x9], [0x1, 0x4, 0xf, 0x1], [0xd, 0x9, 0x4, 0x1], [0x1, 0xd, 0x1, 0x2]]]}

def sbox_predicate(sbox='G7', linear=False):
    sa = SboxAnalyzer(sbox_candidates[sbox])
    # _, milp = sa.minimized_diff_constraints(subtable='star')
    if linear:
        _, milp, _ = sa.minimized_linear_constraints()
    else:
        _, milp, _ = sa.minimized_diff_constraints()

    # predicate = 'predicate sbox(var 0..1: a0, var 0..1: a1, var 0..1: a2, var 0..1: a3, var 0..1: b0, var 0..1: b1, var 0..1: b2, var 0..1: b3) =\n'
    predicate = 'predicate sbox(var 0..1: a0, var 0..1: a1, var 0..1: a2, var 0..1: a3, var 0..1: b0, var 0..1: b1, var 0..1: b2, var 0..1: b3, var 0..1: p0, var 0..1: p1) =\n'
    for clause in milp[:-1]:
        predicate += f'{clause} /\\\n'
    predicate += f'{milp[-1]}\n;\n\n'

    sa = SboxAnalyzer(sa.inverse())
    # _, milp = sa.minimized_diff_constraints(subtable='star')
    if linear:
        _, milp, _ = sa.minimized_linear_constraints()
    else:
        _, milp, _ = sa.minimized_diff_constraints()

    # predicate += 'predicate sbox_inv(var 0..1: a0, var 0..1: a1, var 0..1: a2, var 0..1: a3, var 0..1: b0, var 0..1: b1, var 0..1: b2, var 0..1: b3) =\n'
    predicate += 'predicate sbox_inv(var 0..1: a0, var 0..1: a1, var 0..1: a2, var 0..1: a3, var 0..1: b0, var 0..1: b1, var 0..1: b2, var 0..1: b3, var 0..1: p0, var 0..1: p1) =\n'
    for clause in milp[:-1]:
        predicate += f'{clause} /\\\n'
    predicate += f'{milp[-1]}\n;\n\n'
    
    return predicate

def mcol_predicate(mcol='jean_inv', linear=False):
    F = GF(2**4 , name='a', modulus= mcol_candidates[mcol][0], repr='int', names=('a',)); (a,) = F._first_ngens(1)

    M = Matrix(F, [[F._cache.fetch_int(bit)  for bit in row] for row in mcol_candidates[mcol][1]])
    M_bin = matrix(GF(2), Integer(16), Integer(16), lambda x, y: M[x/Integer(4), y/Integer(4)].matrix()[::-1,:][:,::-1][x%4, y%4])
    if linear:
        M_bin = M_bin.transpose()
        M_bin = M_bin.inverse()

    predicate = '''predicate mix_column( var 0..1: in00, var 0..1: in01, var 0..1: in02, var 0..1: in03,
                      var 0..1: in10, var 0..1: in11, var 0..1: in12, var 0..1: in13,
                      var 0..1: in20, var 0..1: in21, var 0..1: in22, var 0..1: in23,
                      var 0..1: in30, var 0..1: in31, var 0..1: in32, var 0..1: in33,
                      var 0..1: out00, var 0..1: out01, var 0..1: out02, var 0..1: out03,
                      var 0..1: out10, var 0..1: out11, var 0..1: out12, var 0..1: out13,
                      var 0..1: out20, var 0..1: out21, var 0..1: out22, var 0..1: out23,
                      var 0..1: out30, var 0..1: out31, var 0..1: out32, var 0..1: out33,
                      ) =\n'''

    for i in range(16):
        row = f'out{int(i/4)}{i%4} = (('
        for j in range(16):
            if M_bin[i, j] == 1:
              row += f'in{int(j/4)}{j%4} +'
        row = row[:-2]
        predicate += row + f') mod 2 = 1) /\\\n'
    predicate = predicate[:-3] + ';' 

    return predicate

def optimize(NR, BP, sbox, mcol, permutation, linear, exact):
    model = Model("./active_sbox_bit_template.mzn")

    model.add_string(sbox_predicate(sbox, linear))
    model.add_string(mcol_predicate(mcol, linear))

    if exact:
        # if (NR == BP):
        model.add_string('solve minimize 3 * (sum(p0l) + sum(p0r)) + 2 * (sum(p1l) + sum(p1r));')
        # else:
            # model.add_string('solve minimize 3 * (sum(r in 0..BP-2, i in 0..7) (p0l[r, i]) + sum(r in 0..BP-2, i in 0..7) (p0r[r, i])) + 2 * (sum(r in 0..NR-BP-2, i in 0..7) (p1l[r, i]) + sum(r in 0..NR-BP-2, i in 0..7) (p1r[r, i])) + 3 * (sum(i in 0..6) (p0l[BP-1, i]) + sum(i in 0..6) (p0r[BP-1, i])) + 2 * (sum(i in 0..6) (p1l[NR-BP-1, i]) + sum(i in 0..6) (p1r[NR-BP-1, i]));')
    else:
        # if (NR == BP):
        model.add_string(
                '''var 0..NR*8: active_sboxes;
constraint active_sboxes = sum(r in 0..BP-1, i in 0..7) (x[r, 4*i] + x[r, 4*i+1] + x[r, 4*i+2] + x[r, 4*i+3] > 0) + sum(r in 0..NR-BP-1, i in 0..7) (xr[r, 4*i] + xr[r, 4*i+1] + xr[r, 4*i+2] + xr[r, 4*i+3] > 0);
solve minimize active_sboxes;
                '''
                )
    #     else:
    #         model.add_string(
    #                 '''var 0..NR*8: active_sboxes;
    # constraint active_sboxes = sum(r in 0..BP-2, i in 0..7) (x[r, 4*i] + x[r, 4*i+1] + x[r, 4*i+2] + x[r, 4*i+3] > 0) + sum(r in 0..NR-BP-2, i in 0..7) (xr[r, 4*i] + xr[r, 4*i+1] + xr[r, 4*i+2] + xr[r, 4*i+3] > 0);
    # constraint active_sboxes = sum(i in 0..6) (x[BP-1, 4*i] + x[BP-1, 4*i+1] + x[BP-1, 4*i+2] + x[BP-1, 4*i+3] > 0) + sum(i in 0..6) (xr[NR-BP-1, 4*i] + xr[NR-BP-1, 4*i+1] + xr[NR-BP-1, 4*i+2] + xr[NR-BP-1, 4*i+3] > 0);
    # solve minimize active_sboxes;
    #                 '''
    #                 )

    solver = Solver.lookup("cp-sat")
    instance = Instance(solver, model)

    instance["NR"] = NR
    instance["BP"] = BP
    instance["round_permutation"] = permutation_candidates[permutation]

    result = instance.solve(processes=16, verbose=True)

    print(f'Rounds: {NR}, Break: {BP}, Mcol: {mcol}, SBox: {sbox}, Perm: {permutation}', end=' - ')
    if exact:
        print(f'Probability of characteristic: {result["objective"]}')
    else:
        print(f'Minimal Number of active S-Boxes: {result["objective"]}')

    print(result.solution)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Find minimum number of active S-Box")
    parser.add_argument('-r' ,'--rounds', action='store', type=int)
    parser.add_argument('-b','--break', action='store', type=int)
    parser.add_argument('-s', '--sbox', action='store', choices=sbox_candidates.keys(), type=str)
    parser.add_argument('-m', '--mcol', action='store', choices=mcol_candidates.keys(), type=str)
    parser.add_argument('-p', '--permutation', action='store', choices=permutation_candidates.keys(), type=str)
    parser.add_argument('-l', '--linear', default=False, action='store_true', help='Switch between differential and linear characteristics')
    parser.add_argument('-e', '--exact', default=False, action='store_true', help='If true then calculate exact probability, else count active S-Boxes')
    parameter = parser.parse_args()

    args = vars(parameter)
    print(args['permutation'])

    for NR in ([args['rounds']] if args['rounds'] is not None else [i for i in range(1, 10)]):
        for BP in ([args['break']] if args['break'] is not None else [i for i in range(1, NR+1)]):
            for mcol in ([args['mcol']] if args['mcol'] is not None else mcol_candidates.keys()):
                for sbox in ([args['sbox']] if args['sbox'] is not None else sbox_candidates.keys()):
                    for permutation in ([args['permutation']] if args['permutation'] is not None else permutation_candidates.keys()):
                        optimize(NR, BP, sbox, mcol, permutation, args['linear'], args['exact'])
