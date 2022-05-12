import pandas as pd
import glob
import os

mem = [128, 256, 512, 1024, 2048, 4096]
con = [1, 10, 100, 500, 1000, 2000]

def mem_analysis(dirs):
    for d in dirs:
        mem_analysis_dir(d)

def mem_analysis_dir(d):
    data = []
    runtime = d.split('_')[1]
    for m in mem:
        result = [m]
        for c in con:
            fn = '{}/result_{}MB_{:0>4d}.txt'.format(d, m, c)
            result.append(mem_analysis_file(fn, c))
        data.append(result)
    df = pd.DataFrame(data, columns=['memory', *con])
    df.to_csv('result/mem_{}.csv'.format(runtime), index=False)

def mem_analysis_file(fn, con):
    if os.path.isfile(fn):
        df = pd.read_csv(fn, sep='\s+', header=0, index_col=None)
        result = df["PSS"].sum() / con
    else:
        result = None
    return result

mem_analysis(glob.glob('mem_*'))
