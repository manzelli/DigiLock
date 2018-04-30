# DigitalLock
A Verilog implementation of a digital lock system, realized on FPGA with the support of Xilinx ISE Design Tools. 

States:

`idle`: Beginning state, when the system is first turned on. `CLSd` displayed on SSD, `passwd` is set to 0.

`locked`: `CLSd` displayed on SSD. Timeout, manual locking, and user reset trigger this state.

`await_in`: Awaiting general input from user.

`enter_pass`: Awaiting current password input from user.

`unlocked`: Lock has been deactivated. `OPEn` is displayed on SSD. The user can now change the password, or lock again by entering the current password.

`change_pass`: Awaiting new password input from user.

`lockout`: If the system has been waiting for user action for more than 15 seconds, it automatically relocks.

`backdoor`: Enter has been pressed 6 times in a row, with switch input set to 0xF. The password has been changed to `3456`. 
