Fall 2019 Foundations of Optimization

An interesting project to learn linear programming. Given MNIST like images, can we use linear programming to recognize a digit.
It was simplified for this project, such that a nice looking digit (that we were given) was purposely translated, rotated, and skewed. Performing these transformations on a matrix requires mathematically manipulating the images(as matrices) with constants. For example translation would include adding or subtracting a constant to the position of all pixels. This idea was used to create a linear program. Python, specifically the Gurobi library, was used to implement and optimize the linear program.

Note: Gurobi requires a licence to run.
Note2: Teacher was kind enough to provide the images as sparse matrices converted to a csv file. An example is provided along with code to view the image.