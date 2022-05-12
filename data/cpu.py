import pandas as pd
import glob

con = [1, 10, 20, 50, 100, 200, 300, 400]

def cpu_analysis(dirs):
    data = []
    for d in dirs:
        runtime = d.split('_')[1]
        time = [runtime]
        for c in con:
            fn = '{}/con_{:0>3d}/cpu.txt'.format(d, c)
            df = pd.read_table(fn, sep='\s+', header=None, index_col=None)
            time.append(df[0].mean() * 10 / c)
        data.append(time)
    df = pd.DataFrame(data, columns=['runtime', *con])
    df.to_csv('result/cpu.csv', index=False)

cpu_analysis(glob.glob('time_*'))
