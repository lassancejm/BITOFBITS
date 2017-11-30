import sys,os,argparse
parser = argparse.ArgumentParser(description='Process saguaro.cactus output')
parser.add_argument('infile',help='saguaro.cactus input file')
args = parser.parse_args()
with open(args.infile, "r") as infile:
    outdir=os.path.basename(infile.name)+'.output'
    os.makedirs(outdir,exist_ok=True)
    for line in infile:
        if "cactus" in line:
            filename=line.strip('\n')
            filename=filename+'.tab'
            filepath=os.path.join(outdir,filename)
            #remove file if created during previous run of the script"
            try:
                os.remove(filepath)
            except OSError:
                pass
        else:
            with open(filepath,'a') as outputfile:
                outputfile.write(line)
infile.close()
