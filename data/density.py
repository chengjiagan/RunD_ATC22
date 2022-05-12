import pandas as pd
import glob
import os

density = [100, 200, 500, 1000]
con = [1, 10, 100, 200]
h = ['pod', 'start', 'end', 'latency']

def density_analysis(dirs):
    for d in dirs:
        density_analysis_dir(d)

def density_analysis_dir(d):
    data = []
    runtime = d.split('_')[1]
    for m in density:
        result = [m]
        for c in con:
            if not os.path.isdir('{}/density_{:0>4d}/con_{:0>3d}/'.format(d, m, c)):
                result.append(None)
                continue
            l = [density_analysis_file('{}/density_{:0>4d}/con_{:0>3d}/client{:0>3d}.txt'.format(d, m, c, i), i)
                    for i in range(1, c+1)]
            df = pd.concat(l, ignore_index=True)
            # df.to_csv('density/{}_density{:0>4d}_con{:0>3d}.csv'.format(runtime, m, c), index=False)
            result.append(density_analysis_all(df))
        data.append(result)
    df = pd.DataFrame(data, columns=['density', *con])
    df.to_csv('result/density_{}.csv'.format(runtime), index=False)

def density_analysis_file(fn, client):
    df = pd.read_csv(fn, sep='\s+', names=h, index_col=None)
    df['client'] = client
    df['round'] = range(1, len(df)+1)
    return df

def density_analysis_all(df):
    start = df.groupby(['round'])['start'].min()
    end = df.groupby(['round'])['end'].max()
    return (end - start).mean()
    # return df.groupby(['round'])['latency'].quantile(0.99, interpolation='lower').mean()

density_analysis(glob.glob('density_*'))
