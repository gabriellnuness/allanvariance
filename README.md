# Allan variance for accelerometer and gyroscopes

The objective is to use the same function to calculate noise levels from inertial sensors using the Allan variance.

## Inputs

- Sensor:

Acc or Gyro

- Units: 

  m/s $^2$ or $g$ for accelerometers;
  $\degree$/h or $\degree$/s for gyroscopes.
  
  The function will calculate the Allan variance, preferably by using a library, and then plot the Allan deviation to fit the curve in order to obtain the noise values from the sensor.
