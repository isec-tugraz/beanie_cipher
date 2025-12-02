from minizinc import Instance, Model, Solver
import argparse
import math 
from datetime import timedelta


def optimize(NR, BP, iterations, limit):
    if parameter.differential:
        model = Model("./clustering_dif.mzn")
    else:
        model = Model("./clustering_lin.mzn")

    model["NR"] = NR
    model["BP"] = BP
    print(f'Left Branch: {BP}, Right Branch: {NR-BP}, Iterations: {iterations}')

    solver = Solver.lookup("cp-sat")
    main_instance = Instance(solver, model)

    with main_instance.branch() as instance_optimization:
        instance_optimization.add_string('solve minimize 3 * (sum(p0l) + sum(p0r)) + 2 * (sum(p1l) + sum(p1r));')

        for _ in range(iterations):
            result = instance_optimization.solve(processes=parameter.processes, verbose=True)
            if parameter.differential:
                print(f'Differential characteristic probability 2^-{result.objective}')
            else:
                print(f'Linear characteristic probability 2^-{result.objective}')
            # if result.objective >= limit:
            #     print(f'Probability too high for limit')
            #     break

            solver = Solver.lookup("cp-sat")
            instance_sat = Instance(solver, model)
            instance_sat.add_string(f'var int: probability;')
            instance_sat.add_string(f'constraint probability = 3 * (sum(p0l) + sum(p0r)) + 2 * (sum(p1l) + sum(p1r));')
            instance_sat.add_string(f'constraint probability < {result.objective + limit};')

            instance_sat.add_string(f'constraint x[0, 0..31] = array1d(0..31, {result.solution.x[0]});')
            if NR-BP == 0:
                instance_sat.add_string(f'constraint y[{NR-1}, 0..31] = array1d(0..31, {result.solution.y[NR-1]});')
            else:
                instance_sat.add_string(f'constraint xr[0, 0..31] = array1d(0..31, {result.solution.xr[0]});')

            # result_sat = instance_sat.solve(processes=parameter.processes, all_solutions=True, timeout=timedelta(minutes=1))
            result_sat = instance_sat.solve(processes=parameter.processes, all_solutions=True)

            # if len(result_sat) == 0:
            #     limit -= 2
            #     if limit < 1:
            #         limit = 1
            #     print(limit)
            print(f'Nr of Solutions: {len(result_sat)}')

            # for sol in result_sat:
            #     print(f'X: {sol.x}')
            # for sol in result_sat:
            #     print(f'Y: {sol.y}')
            # for sol in result_sat:
            #     print(f'W: {sol.w}')

            # for sol in result_sat:
            #     print(f'XR: {sol.xr}')
            # for sol in result_sat:
            #     print(f'YR: {sol.yr}')
            # for sol in result_sat:
            #     print(f'WR: {sol.wr}')

            # for sol in result_sat:
            #     print(f'P0L: {sol.p0l}')
            # for sol in result_sat:
            #     print(f'P1L: {sol.p1l}')
            # for sol in result_sat:
            #     print(f'P0R: {sol.p0r}')
            # for sol in result_sat:
            #     print(f'P1R: {sol.p1r}')


            probability = 0
            probability_dist = {}
            for r in result_sat:
                probability += 2**(-r.probability)
                probability_dist[r.probability] = probability_dist.get(r.probability, 0) + 1

            print(f'Probability distribution: {dict(sorted(probability_dist.items()))}')
            probability_impact = {}
            for key, val in probability_dist.items():
                probability_impact[key] = f'{math.log(2**(-key)*val, 2):.2f}'
            print(f'Probability impact: {dict(sorted(probability_impact.items()))}')
            if parameter.differential:
                print(f'Differential probability 2^{math.log(probability, 2):.2f}')
            else:
                print(f'Linear probability 2^{math.log(probability, 2):.2f}')
            print(f'Input Mask:  {result.solution.x[0]}')
            if NR-BP == 0:
                print(f'Output Mask: {result.solution.y[NR-1]}')
            else:
                print(f'Output Mask: {result.solution.xr[0]}')
            print()


            if NR-BP == 0:
                instance_optimization.add_string(f'constraint x[0, 0..31] != array1d(0..31, {result.solution.x[0]}) /\\ y[{NR-1}, 0..31] != array1d(0..31, {result.solution.y[NR-1]});')
            else:
                instance_optimization.add_string(f'constraint x[0, 0..31] != array1d(0..31, {result.solution.x[0]}) /\\ xr[0, 0..31] != array1d(0..31, {result.solution.xr[0]});')

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Clustering")
    parser.add_argument('-r' ,'--rounds', default=6, action='store', type=int)
    parser.add_argument('-b','--break', default=3, action='store', type=int)
    parser.add_argument('-i' ,'--iterations', default=1, action='store', type=int)
    parser.add_argument('-l','--limit', default=8, action='store', type=int)
    parser.add_argument('-d','--differential', default=False, action='store_true')
    parser.add_argument('-p','--processes', default=16, action='store', type=int)
    parameter = parser.parse_args()

    args = vars(parameter)

    optimize(args['rounds'], args['break'], args['iterations'], args['limit'])
