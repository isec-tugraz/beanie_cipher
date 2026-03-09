import argparse
from multiprocessing import Pool
import json
import beanie

from datetime import timedelta
from datetime import datetime

def get_edp(_):
    return beanie.edp(parameter.rounds, parameter.mask)

def edp():
    try:
        with open(f'edp_{parameter.rounds}.json', 'rb') as f:
            edp_experiments = json.load(f)
    except:
        edp_experiments = []

    start = datetime.now()
    with Pool(processes=parameter.threads) as pool:
        for (difference_frequency, key, tweak, mask, output_mask_max) in pool.imap_unordered(get_edp, [_ for _ in range(parameter.iterations)]):
            edp_experiments.append({'difference_frequency': difference_frequency,
                                    'key': key,
                                    'tweak': tweak,
                                    'input_mask': mask,
                                    'output_mask_max_count': output_mask_max})

            if (datetime.now() - start) > timedelta(minutes=10):
                with open(f'edp_{parameter.rounds}.json', 'w') as f:
                    json.dump(edp_experiments, f)

    with open(f'edp_{parameter.rounds}.json', 'w') as f:
        json.dump(edp_experiments, f)

def get_edp_mask(_):
    return beanie.edp_mask(parameter.rounds, parameter.mask, parameter.output_mask)

def edp_mask():
    try:
        with open(f'edp_fixed_mask_{parameter.rounds}.json', 'rb') as f:
            edp_experiments = json.load(f)
    except:
        edp_experiments = []

    start = datetime.now()
    with Pool(processes=parameter.threads) as pool:
        for (difference_count, key, tweak, input_mask, output_mask) in pool.imap_unordered(get_edp_mask, [_ for _ in range(parameter.iterations)]):
            edp_experiments.append({'difference_count': difference_count,
                                    'key': key,
                                    'tweak': tweak,
                                    'input_mask': input_mask,
                                    'output_mask': output_mask})

            if (datetime.now() - start) > timedelta(minutes=10):
                with open(f'edp_fixed_mask_{parameter.rounds}.json', 'w') as f:
                    json.dump(edp_experiments, f)

    with open(f'edp_fixed_mask_{parameter.rounds}.json', 'w') as f:
        json.dump(edp_experiments, f)

def get_elp(_):
    return beanie.elp(parameter.rounds, parameter.mask)

def elp():
    try:
        with open(f'elp_{parameter.rounds}.json', 'rb') as f:
            elp_experiments = json.load(f)
    except:
        elp_experiments = []

    start = datetime.now()
    with Pool(processes=parameter.threads) as pool:
        for (bias_frequency, key, tweak, mask, input_mask_max) in pool.imap_unordered(get_elp, [_ for _ in range(parameter.iterations)]):
            elp_experiments.append({'bias_frequency': bias_frequency,
                                    'key': key,
                                    'tweak': tweak,
                                    'output_mask': mask,
                                    'input_mask_max_count': input_mask_max})

            if (datetime.now() - start) > timedelta(minutes=10):
                with open(f'elp_{parameter.rounds}.json', 'w') as f:
                    json.dump(elp_experiments, f)

    with open(f'elp_{parameter.rounds}.json', 'w') as f:
        json.dump(elp_experiments, f)

def get_elp_mask(_):
    return beanie.elp_mask(parameter.rounds, parameter.mask, parameter.output_mask)

def elp_mask():
    try:
        with open(f'elp_fixed_mask_{parameter.rounds}.json', 'rb') as f:
            elp_experiments = json.load(f)
    except:
        elp_experiments = []

    start = datetime.now()
    with Pool(processes=parameter.threads) as pool:
        for (bias, key, tweak, input_mask, output_mask) in pool.imap_unordered(get_elp_mask, [_ for _ in range(parameter.iterations)]):
            elp_experiments.append({'bias': bias,
                                    'key': key,
                                    'tweak': tweak,
                                    'input_mask': input_mask,
                                    'output_mask': output_mask})

            if (datetime.now() - start) > timedelta(minutes=10):
                with open(f'elp_fixed_mask_{parameter.rounds}.json', 'w') as f:
                    json.dump(elp_experiments, f)

    with open(f'elp_fixed_mask_{parameter.rounds}.json', 'w') as f:
        json.dump(elp_experiments, f)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="EDP/ELP of BEANIE")
    parser.add_argument('-t', '--threads', action='store', default=1, type=int)
    parser.add_argument('-r', '--rounds', action='store', default=4, type=int)
    parser.add_argument('-i', '--iterations', action='store', default=1, type=int)
    parser.add_argument('-m', '--mask', action='store', default=0, type=int)
    parser.add_argument('-o', '--output_mask', action='store', default=0, type=int)
    parser.add_argument('-l','--linear', default=False, action='store_true')
    parameter = parser.parse_args()

    if parameter.linear:
        if parameter.output_mask != 0:
            elp_mask() 
        else:
            elp() 
    else:
        if parameter.output_mask != 0:
            edp_mask() 
        else:
            edp() 
