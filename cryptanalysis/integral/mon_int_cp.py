from minizinc import Instance, Model, Solver, Result, Status
import argparse



def check_int(NR, BP):
    model = Model("./mon_int_u.mzn")

    solver = Solver.lookup("cp-sat")
    instance = Instance(solver, model)

    instance["NR"] = NR
    instance["BP"] = BP
    
    for i in range(32):
        for j in range(32):
            with instance.branch() as child_instance:
                print(f'{i*32+j}/{32*32}')
                child_instance["constant"] = i
                child_instance["balanced"] = j

                result: Result = child_instance.solve(processes=16, verbose=True)
                if result.status == Status.UNSATISFIABLE:
                    print(f'Constant Bit: {i}, Balanced Bit: {j}')
                    return True
    return False


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Find integral distinguisher with monomial prediction.")
    parser.add_argument('-r' ,'--rounds', action='store', default=7, type=int)
    parser.add_argument('-b','--break', action='store', default=2, type=int)
    # parser.add_argument('-s', '--sbox', action='store', choices=sbox_candidates.keys(), type=str)
    # parser.add_argument('-m', '--mcol', action='store', choices=mcol_candidates.keys(), type=str)
    # parser.add_argument('-p', '--permutation', action='store', choices=permutation_candidates.keys(), type=str)
    parameter = parser.parse_args()

    args = vars(parameter)
    if check_int(args['rounds'], args['break']):
        print(f'{args["break"]}/{args["rounds"]-args["break"]}: Integral Distinguisher')
    else:
        print(f'{args["break"]}/{args["rounds"]-args["break"]}: NO Integral Distinguisher')
    # print(args['permutation'])

    # for NR in ([args['rounds']] if args['rounds'] is not None else [i for i in range(1, 10)]):
    #     for BP in ([args['break']] if args['break'] is not None else [i for i in range(1, NR+1)]):
    #         for mcol in ([args['mcol']] if args['mcol'] is not None else mcol_candidates.keys()):
    #             for sbox in ([args['sbox']] if args['sbox'] is not None else sbox_candidates.keys()):
    #                 for permutation in ([args['permutation']] if args['permutation'] is not None else permutation_candidates.keys()):
    #                     optimize(NR, BP, sbox, mcol, permutation)
