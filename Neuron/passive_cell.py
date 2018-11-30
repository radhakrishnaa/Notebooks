from neuron import h
from matplotlib import pyplot
# We use this package for visualization
import matplotlib.pyplot as plt

h.load_file('stdrun.hoc')

#Create the soma section and define the default parameters
soma = h.Section(name='soma')
soma.diam = 200 #default is micrometers
soma.L = 100 #um

soma.cm = 1.4884e-4/6.2832e-4 #uF

#Insert the Hodgkin-Huxley channels and define the conductances
soma.insert('hh')

#We're making the active conductances zero because we want to model a passive cell
soma.gnabar_hh = 0.0 
soma.gkbar_hh = 0.0
soma.gl_hh = 2.0e-5
soma.el_hh = -70

v_init = h.v_init= -60

#Inject current in the middle of the soma
stim = h.IClamp(soma(0.5))
stim.delay = 100.0 #ms
stim.dur = 500.0 #ms
stim.amp = 1.0 #nA



tstop = h.tstop = 800   #ms
h.dt = 0.025

v0_vec = h.Vector()
t_vec = h.Vector()

v0_vec.record(soma(0.5)._ref_v)
t_vec.record(h._ref_t)

h.run()

plt.figure()
plt.plot(t_vec, v0_vec,'b')
plt.xlim(0, tstop)
plt.xlabel('time (ms)')
plt.ylabel('mV')

plt.show()

