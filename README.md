# MCRC (Multiclass Cut followed by Recursive Cut)

The algorithm is designed to delineate individual trees from LiDAR point clouds. 

In current code, there are two different options:
1. spectral graph cut 
(mcnc_example.m)
2. Min-cut/Max-flow
(min_cut_max_flow_example.m)
Although both methods are called graph cut, they are very different methods. 

If you find the algorithm interesting, then please cite this paper: [A graph cut approach to 3D tree delineation, using integrated airborne LiDAR and hyperspectral imagery](https://arxiv.org/pdf/1701.06715.pdf)
