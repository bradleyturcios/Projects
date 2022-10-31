import numpy as np
from scipy.sparse import coo_matrix
import matplotlib.pyplot as plt

img = np.genfromtxt('example.csv',delimiter=',').astype(int)
row =  img[:,0]
col = img[:,1]
data = np.ones(img.shape[0])

X=coo_matrix((data, (row, col)), shape=(100,100)).toarray()

#To plot the matrix as a black and white image
plt.gray()
plt.imshow(X)
plt.show()

