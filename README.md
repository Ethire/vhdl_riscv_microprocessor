# vhdl_riscv_microprocessor
A limited implementation of a riscV processor as a course project.

## Functionnal overview
This project aims at creating a limited yet functionnal microprocessor using the RISC architecture, using VHDL.
This processor contains the following components, implemented and tested independently, before being assembled into ``projet_compo``.
- ALU for arithmetic and bitwise operations
- Double port register bank for quick data manipulation
- Data and Instructions memory
- 8 bit counter that serves as programm counter
To assemble everything we implemented a 5 stage pipeline, and implemented data hazard prevention using the bubble method.
This implementation considers every operation and checks the rest of the pipeline before blocking incoming instructions.

## Description of core components

### 1. ALU
**Overview**\
We designed the ALU with its combinational nature in mind : the main part is in a process driven by the following sensitivity list : ``(A, B, control)``, no clock needed.
Every bitwise operation can be simply implemented as ``out <= A op B``, but the more complex operations such as Multiply and Add require more memory.
The worst is Multiply, that needs 16 bits at worst to store the result. Thus we extend our inputs and outputs internally by adding leading 0s.
The mathematical operators are greatly simplified by using the standart IEEE.unsigned library.

The synthesizers report gives us the LUTs and Registers count.
We can verify that our model is purely combinational : no registers were used
```
+-------------------------+------+-------+------------+-----------+-------+
|        Site Type        | Used | Fixed | Prohibited | Available | Util% |
+-------------------------+------+-------+------------+-----------+-------+
| Slice LUTs*             |   78 |     0 |          0 |     20800 |  0.38 |
|   LUT as Logic          |   78 |     0 |          0 |     20800 |  0.38 |
|   LUT as Memory         |    0 |     0 |          0 |      9600 |  0.00 |
| Slice Registers         |    0 |     0 |          0 |     41600 |  0.00 |
|   Register as Flip Flop |    0 |     0 |          0 |     41600 |  0.00 |
|   Register as Latch     |    0 |     0 |          0 |     41600 |  0.00 |
| F7 Muxes                |    0 |     0 |          0 |     16300 |  0.00 |
| F8 Muxes                |    0 |     0 |          0 |      8150 |  0.00 |
+-------------------------+------+-------+------------+-----------+-------+
```
This is the behavioral testbench of the ALU:
![alt text][alu_tb]

### 2. Register file
We made the Register File based on an array of "std_logic_vector" that makes us 16 registers, we write the data on a register synchronously at the opposite of the reading. According to the wanted architecture, we can read two register throught two outputs.

Here is the behavioral testbench of the register file:
![alt text][rgf_tb]

### 3. 8 bit counter
The 8 bit counter was made as a practical exercice for learning how to implement a program on our development board
It lies on a clock, negative logic reset, negative logic enable, up/down, load, d_in and d_out ports.

Here is the behavioral testbench of the register file:
![alt text][8bc_tb]

### 4. Memories
According to the desired architecture, we split up the main memory into the instruction and data memory. We decided to create 2 different files not to jam the 2 architectures together.
Again, the architecture is centered around an array of ``std_logic_vector``.
The data file is read asynchronously but set synchronously, while the instruction file is read synchronously.
The data file read needed to be done within the clock tick such that we didn't have to implement a data hazard detection, when we try to read at an adress we just wrote on.

### 5. Datapath
All of the components were merged into projet_compo, the main project.
We created a 5 stage pipeline with data hazard protection. The protection uses a bubble algorithm to stall instructions that are going to read a register that is going to be modified later in the pipeline, covering every instructions and every case for this hasard.
Everything implemented works in behavioral simulation, synthesise and still remains functionning.


[8bc_tb]: https://github.com/Ethire/vhdl_riscv_microprocessor/blob/main/testbench_graphs/8_bit_counter_tb.PNG "Behavioral simulation of 8bit counter"
[alu_tb]: https://github.com/Ethire/vhdl_riscv_microprocessor/blob/main/testbench_graphs/alu_tb.PNG "Alu testbench"
[rgf_tb]: https://github.com/Ethire/vhdl_riscv_microprocessor/blob/main/testbench_graphs/register_file_tb.PNG "Register file testbench"