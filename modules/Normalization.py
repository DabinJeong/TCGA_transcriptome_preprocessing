import argparse
import pandas as pd 
import numpy as np

parser = argparse.ArgumentParser(description='Tool: normalization')
parser.add_argument('-i', '--input-file', dest='input', type=str,
                        help='Input file', required=True)
parser.add_argument('-geneLength',required=True,help='gene length file')
parser.add_argument('-o', '--output-file', dest='output', type=str,
                        help='Output file', required=True)
args = parser.parse_args()

df_inp = pd.read_csv(args.input,sep='\t',header=0).dropna()
df_length = pd.read_csv(args.geneLength,sep='\t')
dict_length = dict(zip(df_length['gene'],df_length['merged']))

df_readCounts = df_inp.loc[:,['gene','readCounts']].set_index('gene')

# TPM
df_TPM = df_readCounts.apply(lambda x:x/df_readCounts.index.map(dict_length)).dropna().apply(lambda x:x/sum(x)).map(lambda x:x*10**6).rename(columns = {"readCounts":'TPM'})

df_inp.set_index('gene').join(df_TPM).to_csv(args.output,sep='\t',header=True)
