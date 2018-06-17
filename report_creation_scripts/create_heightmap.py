import pandas as pd
from os import path
import matplotlib.pylab as plt

blocks = pd.read_csv(path.join('..', '..', 'worlds', 'Techfest', 'export.txt'),
	names = ['x', 'y', 'z', 'type'])
blocks = blocks[blocks['type'] != 'air']
height_map = blocks.groupby(['x', 'z'])['y'].max().reset_index().pivot('x', 'z', 'y')
plt.xticks([])
plt.yticks([])
plt.xlim([115, 270])
plt.ylim([180, 300])
plt.contour(height_map.values)
plt.axes().set_aspect('equal', 'datalim')
plt.savefig("outline.png")
