# Lab 01 – Your First Own IP Core

## Advanced Hardware Engineering – HSHL

**Project:** PWM AXI4-Lite IP Core  
**University:** Hamm-Lippstadt University of Applied Sciences  
**Semester:** Winter Semester 2026/27  
**Tools:** AMD Xilinx Vivado  
**HDL:** VHDL  
**FPGA Board:** Digilent Nexys A7-100T

## 1. Project Overview

The objective of this laboratory is to design, simulate, verify and package a custom PWM (Pulse Width Modulation) hardware core as an AXI4-Lite peripheral.

The design contains three independent PWM channels:
- Red
- Green
- Blue

The PWM channels are controlled through four AXI4-Lite registers.

## 2. Project Structure

- `01_First_Project/` – Switch-to-LED FPGA design and XDC constraints.
- `02_PWM_Project/` – PWM core and simulation testbench.
- `03_AXI_IP/` – Packaged AXI4-Lite PWM IP.
- `04_Simulation/` – Simulation evidence.
- `05_Reports/` – Utilization and timing reports.
- `06_Screenshots/` – Project and hardware screenshots.

## 3. PWM Register Map

| Offset | Register | Function |
|---|---|---|
| 0x00 | CTRL | Enable all PWM channels |
| 0x04 | DUTY_R | Red duty cycle |
| 0x08 | DUTY_G | Green duty cycle |
| 0x0C | DUTY_B | Blue duty cycle |

## 4. Simulation

The PWM core is tested using a VHDL testbench with a 4-bit counter.

The testbench checks different duty values and verifies the output using assertions.

**Simulation result:** To be added after testing.

## 5. FPGA Utilization

To be added after generating the Vivado utilization report.

## 6. Timing Analysis

To be added after generating the Vivado timing summary.

## 7. Packaged IP

The final IP is named `pwm_axi`, version 1.0, with an AXI4-Lite slave interface and three PWM output channels.

## 8. Author

Electronic Engineering – HSHL

## 9. References

- AMD Vivado documentation: UG1119 and UG1118.
- Digilent Nexys A7 documentation.
- Advanced Hardware Engineering – Lab 01 lecture slides.
