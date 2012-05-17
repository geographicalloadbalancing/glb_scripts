GLB Matlab scripts
====

Matlab scripts for plotting and visualization of our simulations of geographical load balancing.

Authors
----
Scripts were initially written by [Minghong Lin](http://users.cms.caltech.edu/~mhlin/) and front-ends by [Zhenhua Liu](http://users.cms.caltech.edu/~zliu2/).

Blah blah blah @@@@

Organization of the code
----
* `geo_*.m` are front-end code (code to generate a particular plot for a paper). These have lots of duplicated code.

### Back-end solvers
* `hetero_opt.m`: the optimal solution
* `rhc.m`: receding horizon control
* `afhc.m`: averaging fixed horizon control.

#### Miscellaneous
* `validate_params.m: checks for correct dimensions
* `cost.m`: Evaluates the cost given a proposed solution.

@@@@@Put more stuff here
====
The algorithms currently take a few hours to run.