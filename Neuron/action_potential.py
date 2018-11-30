%matplotlib inline
#import mpld3
#mpld3.enable_notebook()
from neuron import h
import matplotlib.pyplot as plt

h.load_file('stdrun.hoc')

# Create the cell and define its geometry

#Create the soma section and define the default parameters
soma = h.Section(name='soma')
soma.diam = 200 #micrometers
soma.L = 100 #micrometers

# Define the cell's biophysics

soma.cm = 1.4884e-4/6.2832e-4 #uF

#Insert the Hodgkin-Huxley channels and define the conductances
soma.insert('hh')
soma.gnabar_hh = 0.12
soma.gkbar_hh = 0.012
soma.gl_hh = 2.0e-5
soma.el_hh = -70

#v_init = h.v_init= -60

# Inject the current
#Inject current in the middle of the soma

stim = h.IClamp(soma(0.5))
stim.delay = 100.0 #delay in ms
stim.dur = 150.0 #duration in ms
stim.amp = 0.03 #amplitude in nA

# define simulation parameters and run

tstop = h.tstop = 350   # how long to run the simulation in ms
h.dt = 0.025 # time step (resolution) of the simulation in ms

# define two vectors for recording variables
v0_vec = h.Vector() 
t_vec = h.Vector()

# record the voltage (_ref_v) and time (_ref_t) into the vectors we just created
v0_vec.record(soma(0.5)._ref_v)
t_vec.record(h._ref_t)

# run the simulation!
h.run()

# vizualize the results

plt.figure(figsize=(10,5))
plt.plot(t_vec, v0_vec,'b')
plt.xlim(0, tstop)
plt.xlabel('time (ms)')
plt.ylabel('mV')

plt.show()