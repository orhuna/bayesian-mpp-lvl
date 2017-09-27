# Bayesian Framework for Modeling Subsurface Fault Distributions Using Marked Point Processes
Code base for work presented in Aydin and Caers (2017) for modelling fault network uncertainty using marked point process to represent spatial distribution of faults.

## Overview
Faults are one of the building-blocks for subsurface modeling studies. Incomplete observations of subsurface fault networks lead to uncertainty pertaining to location, geometry and existence of faults. In practice, gaps in incomplete fault network observations are filled based on tectonic knowledge and interpreter's intuition pertaining to fault relationships. Modeling fault network uncertainty with realistic models that represent tectonic knowledge is still a challenge. A rigorous approach to quantifying fault network uncertainty is . Fault pattern and intensity information are expressed by means of a marked point process, marked Strauss point process. Fault network information is constrained to fault surface observations (complete or partial) within a Bayesian framework. Fault pattern and intensity information are expressed by means of a marked point process. A structural prior model is defined to quantitatively express fault patterns, geometries and relationships within the Bayesian framework. Structural relationships between faults, in particular fault abutting relations, are represented with a level-set based approach. A Markov Chain Monte Carlo sampler is used to sample posterior fault network realizations that reflect tectonic knowledge and honor fault observations.

## Table of Contents
1.*data*: Folder containing .mat data files for fault network realizations and conditioning data   
2. *src*: Folder containing source code including demos and jupyter notebooks
3. *src/demo*: Folder containing demos explaining Markov Chain Monte Carlo simulation of fault networks using marked point Processes

### Demos
#### 1. [ConvergenceDisplay](https://github.com/orhuna/bayesian-mpp-lvl/blob/master/src/demos/ConvergenceDisplay.m)

Demo for displaying Markov Chain convergence for Metropolis-Hastings-Green sampler. Modified Hausdorff distance is used as the dissimilarity measure between states.

#### 2. [DenseDataCase](https://github.com/orhuna/bayesian-mpp-lvl/blob/master/src/demos/DenseDataCase.m)

Demo for conditioning a fault network to dense fault data. Level-sets are used to resolve 3-D surface intersections and patterns are modeled using Marked Strauss Point Process as the prior model.

#### 3. [LevelSetDemo2](https://github.com/orhuna/bayesian-mpp-lvl/blob/master/src/demos/LevelSetDemo2.m)

Demo for detecting 3D surface intersections and imposing abutting relationships on surfaces.

#### 4. [Poisson_StraussDemo](https://github.com/orhuna/bayesian-mpp-lvl/blob/master/src/demos/Poisson_Strauss_Demo.m)

Demo depicting different point and marked-point processes. Variables for the Marked Strauss Point process can be altered to observe the effect of input parameters on the resulting point pattern.

#### 5. [UnconditionedMarkedSimulation](https://github.com/orhuna/bayesian-mpp-lvl/blob/master/src/demos/UnconditionedMarkedSimulation.m)
Demo for generating prior realizations of the fault network. Components in this demo is used to assess prior-data conflict.

## References
1. Aydin, O., & Caers, J. K. (2017). Quantifying structural uncertainty on fault networks using a marked point process within a Bayesian framework. Tectonophysics, 712, 101-124.
