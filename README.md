AMBA AHB-to-APB Bridge Design and Verification

📌 Project Overview

This repository contains the RTL design, verification, and hardware implementation of a fully compliant AMBA AHB-to-APB Bridge. The bridge acts as an interface between a high-speed, high-bandwidth Advanced High-performance Bus (AHB) and a low-bandwidth, low-power Advanced Peripheral Bus (APB).

It translates AHB memory-mapped transactions into APB peripheral transactions, handling all protocol conversions, pipeline delays, and wait-state generation seamlessly.

✨ Key Features

Protocol Compliant: Fully adheres to AMBA AHB and APB specifications.

Burst Support: Supports SINGLE, INCR, and mathematically accurate WRAP bursts (e.g., WRAP4) with dynamic boundary calculation.

Pipelined Architecture: Accurately models the AHB Address Phase and Data Phase separation (2-cycle delay).

Back-Pressure / Wait States: Manages HREADYOUT correctly to stall the AHB Master during the slower APB SETUP and ACCESS phases.

Error Handling: Drives HRESP to ERROR (01) for invalid address decoding, preventing silent data corruption.

Hardware Optimized: Synthesizable and timing-closed for Xilinx 7-Series FPGAs.

🏗️ Architecture

The bridge is divided into three primary modules:

AHB_Slave: Interfaces directly with the AHB Master. Laches addresses, decodes the peripheral select (tempselx), and pipelines the data phase.

APB_Controller: A Finite State Machine (FSM) that navigates the APB IDLE, SETUP, and ENABLE states, asserting PENABLE and driving HREADYOUT to stall the AHB bus.

Bridge_top: The structural top module that instantiates and connects the AHB Slave and APB Controller interfaces.

🧪 Test Plan & Verification Scenarios

A focused test suite was developed using a custom AHB Master BFM (Bus Functional Model) to ensure protocol compliance across all core transaction types:

Test Case

Scenario

Pass Condition 1
Single Write paddr=84000000, pwdata=12345678, penable pulses once.
2.Single Read paddr=80870000, hrdata returns data successfully from the peripheral memory model.
3.Burst Write (WRAP4) Address wraps correctly at 16-byte boundaries, 4 data beats executed cleanly.
4.Burst Read (INCR4) 4 consecutive reads increment correctly, data routed back cleanly.

📊 Verification Waveforms

1. Wrapping Burst (WRAP4)

Demonstrates dynamic address calculation and boundary wrapping (e.g., 0x28 -> 0x2C -> 0x20 -> 0x24).

2. Pipelined Single Write

Demonstrates the 1-cycle pipeline delay between HADDR and HWDATA, and the proper assertion of PENABLE.

3. Read Transfer with Wait States

Demonstrates the bridge pulling HREADYOUT low to stall the AHB bus while fetching data from the APB peripheral.

💻 Hardware Implementation (FPGA)
The RTL was synthesized and implemented Out-Of-Context (OOC) to validate hardware viability, targeting the Xilinx Spartan-7 (XC7S50CSGA324-1) architecture.
Max Clock Frequency (Fmax): 224.06 MHz
Timing Performance: Successfully met a strict 100MHz constraint with a massive Worst Negative Slack (WNS) of +5.537 ns, demonstrating highly efficient logic depth.

Resource Utilization:
LUTs: 65 (0.20% utilization)
Flip-Flops: 106 (0.16% utilization)

🛠️ Tools Used:
Simulation & Synthesis: Xilinx Vivado 2024.2
Language: Verilog-2001
Designed and Verified by [Your Name]
