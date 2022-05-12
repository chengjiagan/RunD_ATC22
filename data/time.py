import pandas as pd
import glob

con = [1, 10, 20, 50, 100, 200, 300, 400]
h = ['pod', 'start', 'end', 'latency']

def time_analysis(dirs):
    data = []
    for d in dirs:
        runtime = d.split('_')[1]
        time = [runtime]
        for c in con:
            l = [time_analysis_file('{}/con_{:0>3d}/client{:0>3d}.txt'.format(d, c, i), i)
                    for i in range(1, c+1)]
            df = pd.concat(l, ignore_index=True)
            time.append(time_analysis_all(df))
        data.append(time)
    df = pd.DataFrame(data, columns=['runtime', *con])
    df.to_csv('result/time.csv', index=False)

def time_analysis_file(fn, client):
    df = pd.read_csv(fn, sep='\s+', names=h, index_col=None)
    df['client'] = client
    df['round'] = range(1, len(df)+1)
    return df

def time_analysis_all(df):
    start = df.groupby(['round'])['start'].min()
    end = df.groupby(['round'])['end'].max()
    return (end - start).mean()
    # return df.groupby(['round'])['latency'].quantile(0.99, interpolation='lower').mean()

time_analysis(glob.glob('time_*'))
