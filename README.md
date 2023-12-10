# preciceFSI

A Fluid-Structure Interaction Solver using the [preCICE](https://precice.org/index.html) library to couple [OpenFOAM](https://openfoam.org) and [CalculiX](http://www.calculix.de)

This docker image uses the following specific precompiled software versions
- [preCICE v2.50](https://github.com/precice/precice/releases/download/v2.5.0/)
- [OpenFOAM v2306](https://www.openfoam.com/news/main-news/openfoam-v2306)
- [Calculix w/ preCICE Adapter v2.20](https://github.com/precice/calculix-adapter/releases/download/v2.20.0/)

## Installing
Assuming you already have Docker installed and running.

```bash
 git clone https://github.com/yellowcub/preciceFSI.git
 cd preciceFSI
 docker build -t precicefoam .
 ```

## Testing
 The following can be run to test that the FSI runs correctly.
 
 ```bash
 docker build -t precicefoam .
 mkdir shared
 docker run -it -v ./shared:/shared precicefoam
 cp -r ./test /shared/test
 cd /shared/test
 ./clean.sh
 ./runFSI
 ```
 
 It may take several minutes to complete.  The results can be accessed outside the docker run from the shared folder.  Inspect the `fluid.log` and `solid.log` files for errors.  OpenFOAM solutions can be viewed using [ParaView](https://www.paraview.org).
