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

#### 2. DenseDataCase

#### 3. LevelSetDemo2

#### 4. Poisson_StraussDemo

#### 5. UnconditionedMarkedSimulation

## References
1. Aydin, O., & Caers, J. K. (2017). Quantifying structural uncertainty on fault networks using a marked point process within a Bayesian framework. Tectonophysics, 712, 101-124.
