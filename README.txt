16-bit IEEE Standard Floating Point Adder
by Jacob Mercado

This project was created for the final project of our EE271 Digital System Design course. This project was developed using
Quartus Prime Lite and the DE10-Lite FPGA board. Constraints for this project were generated using terasic system builder.
A video demonstration of the final project can be seen here: https://youtu.be/edvVPU_9ZEA.

Perripheral Description:
-6 Seven Segment Displays used to display the current numbers being input as well as the final result of the addition.
-2 Push buttons for resetting the FSM and incrementing through it.
-2 Arduino IO Ports to interface with an external microcontroller which was used to interface a 16x2 LCD.
-8 GPIO ports used to detect the input from an external 4x4 membrane keypad.

Design Description:
-4 main states: Reset, input 1, input 2, floating point calculation.
-States are encoded in gray code.
-Reset state is the default state in which there are no inputs to the floating point adder and nothing is displayed on any
of the seven segment displays. This state can be reached at any point using the reset button.
-In input 1 state users can input their first 16-bit number one hex character at a time using the 4x4 keypad and increment button. As
the buttons on the keypad are being entered, the seven segment displays update accordingly to show the current number selected from 
the keypad as well as the first 16-bit input.
-Input 2 state functions exactly the same as input 1 state.
-In the floating point calculation state, the floating point addition of the two 16-bit hexidecimal numbers from the previous two 
states is calculated. The result of this addition is then displayed on the seven segment displays. Incrementing after the calculation
is complete will send the design back to the default reset state.
