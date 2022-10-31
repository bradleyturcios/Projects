import numpy as np
from scipy.sparse import coo_matrix
import matplotlib.pyplot as plt
from gurobipy import *
import math

'''
#np array
img = np.genfromtxt('Images/T0.csv', delimiter=',').astype(int)
real = np.genfromtxt('Images/S0.csv', delimiter=',').astype(int)
=======
img = np.genfromtxt('Images/T2.csv',delimiter=',').astype(int)
>>>>>>> 3fa7543dba5a6e0ac2e6f184135a6df71d0be47b
#two coordinates : and 0 .
# : is for the entire column from csv. index zero means first column, all the rows
#x values aka row value are in the index 0 of csv
#y values aka col values are in the index 1 of csv
#row contains x values. col contains y values of locations of white pizels
row = img[1:,0]
col = img[1:,1]

#img.shape is dimensions of matrix. index 0 is rows.
# np.ones creates an array of ones

data = np.ones(img.shape[0]-1)

X = coo_matrix((data, (row, col)), shape=(100,100)).toarray()


m = Model('recognize')


#To plot the matrix as a black and white image
plt.gray()

plt.imshow(X)
plt.show()
'''

'''
def image_optimizer(test_image, real_image):
    # Note we use [1:,] because the data starts in the second row, the first row, row 0, is a header

    # Split data into x and y, aka row and column coordinates
    test_row = test_image[1:, 0]
    test_col = real_image[1:, 1]

    real_row = test_image[1:, 0]
    real_col = real_image[1:, 1]

    # create a matrix full of ones 1 x i, where i is the amount of white pixels
    test_data = np.ones(test_image.shape[0] - 1)
    real_data = np.ones(real_image.shape[0] - 1)

    # combine
    test_matrix = coo_matrix((test_data, (test_row, test_col)), shape=(100, 100)).toarray()
    real_matrix = coo_matrix((real_data, (real_row, real_col)), shape=(100, 100)).toarray()

    m = Model('recognize')
'''
def image_load(img):
    # two coordinates : and 0 .
    # : is for the entire column from csv. index zero means first column, all the rows
    # x values aka row value are in the index 0 of csv
    # y values aka col values are in the index 1 of csv
    # row contains x values. col contains y values of locations of white pizels
    real_row = img[:, 0]
    real_col = img[:, 1]


    # img.shape is dimensions of matrix. index 0 is rows.
    # np.ones creates an array of ones
    
    real_data = np.ones(img.shape[0])
    real_matrix = coo_matrix((real_data, (real_row, real_col)), shape=(100, 100)).toarray()


    return real_matrix

real_0 = np.genfromtxt('Images/S0.csv',delimiter=',').astype(int)[1:,:]

fake_0 = np.genfromtxt('Images/T0.csv',delimiter=',').astype(int)[1:,:]


x= image_load(real_0)
y = image_load(fake_0)
plt.gray()
plt.imshow(x)
plt.show()

plt.imshow(y)
plt.show()

def errors(real, checking):
    errors = []
    ind = []
    for i in range(len(real)):
            x = real[i][0]-checking[i][0]
            y = real[i][1]-checking[i][1]
            errors.append([x,y])
    norm = np.linalg.norm(errors, np.inf)

    for i in range(len(errors)):
         if abs(errors[i][0]) + abs(errors[i][1]) == norm:
             ind.append(i)
    return ind



def optimize(real, checking):
    m = Model("image_check")
    pixel = errors(real, checking)
    rot1 = m.addVar(vtype=GRB.CONTINUOUS, name = "rot1")
    transx = m.addVar(vtype=GRB.CONTINUOUS, name="transx")
    transy = m.addVar(vtype=GRB.CONTINUOUS, name="transy")
    rot2 = m.addVar(vtype=GRB.CONTINUOUS, name="rot2")
    rot4 = m.addVar(vtype=GRB.CONTINUOUS, name="rot3")
    rot3 = m.addVar(vtype=GRB.CONTINUOUS, name="rot4")

    # real_pix = real[pixel]
    #
    #
    # m.addConstr((real_pix[0]*rot1 + real_pix[1]*rot3) + transx == x)
    # m.addConstr((real_pix[0]*rot2 + real_pix[1]*rot4) + transy == y)
    #
    #
    #
    # for i in range(len(real)):
    #     m.addConstr(x_error <= 99)
    #     m.addConstr(y_error <= 99)
    #     m.addConstr(x_error >= 0)
    #     m.addConstr(y_error >= 0)


    # objExpr = LinExpr()
    # varsx = []
    # varsy = []
    # varsmax = []
    # for i in range(len(real)):
    #     varsx.append(m.addVar(vtype=GRB.CONTINUOUS))
    #     varsy.append(m.addVar(vtype=GRB.CONTINUOUS))
    #     m.addConstr(checking[i][0] - (real[i][0]*rot1 + real[i][1]*rot3 + transx) == varsx[i])
    #     m.addConstr(checking[i][1] - (real[i][0]*rot2 + real[i][1]*rot4 + transy) == varsy[i])
    #     varsmax.append(m.addVar(vtype=GRB.CONTINUOUS))
    #     m.addConstr( varsmax[i] == max_(varsx[i],varsy[i]))


    objExpr = LinExpr()
    varsx = []
    varsy = []
    #varsx and vary contain variables for the new values of tranformed x and y
    #
    for i in range(len(real)):
        varsx.append(m.addVar(vtype=GRB.CONTINUOUS))
        varsy.append(m.addVar(vtype=GRB.CONTINUOUS))
        #real[i][0] = X
        #real[i][1] = Y
        m.addConstr((real[i][0]*rot1 + real[i][1]*rot2 + transx) == varsx[i])
        m.addConstr((real[i][0]*rot3 + real[i][1]*rot4)  + transy == varsy[i])


    varsxp = []

    varsyp = []

    #gets the absolute value of the difference between the checking file and the transformed variable
    #adds that difference together to form all error, and minimize that
    for i in range(len(real)):
        varsxp.append(m.addVar(vtype=GRB.CONTINUOUS))
        varsyp.append(m.addVar(vtype=GRB.CONTINUOUS))
        m.addConstr(checking[i][0] - varsx[i] <= varsxp[i])
        m.addConstr((checking[i][0] -varsx[i])*-1 <= varsxp[i])
        m.addConstr(checking[i][1] -varsy[i] <= varsyp[i])
        m.addConstr((checking[i][1] - varsy[i])*-1 <= varsyp[i])
        objExpr.add(varsxp[i])
        objExpr.add(varsyp[i])


    m.setObjective(objExpr, GRB.MINIMIZE)

    m.optimize()

    t = {}
    for v in m.getVars():
        t[v.varName] =  v.x

    #returns all optmized variables
    return t

def convert(values, real):
    new_coor = []
    #loops through the original image and transforms it with the optimized values appending new coordinats to list
    for i in range(len(real)):
        new_coor.append([math.floor(real[i][0]*values["rot1"] + real[i][1]*values["rot2"] + values["transx"]), math.floor(real[i][0]*values["rot3"] + real[i][1]*values["rot4"] + values["transy"])])
    arrayified = np.array(new_coor)

    print(arrayified)
    #displays the image with new coordinates
    z = image_load(arrayified)
    plt.gray()
    plt.imshow(z)
    plt.show()

u = optimize(real_0,fake_0)
convert(u, real_0)



