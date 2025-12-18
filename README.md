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
<img width="1578" height="591" alt="alu_tb" src="https://github.com/user-attachments/assets/8579aba3-fc11-401b-ac1b-fa5069644eeb" />


### 2. Register file
We made the Register File based on an array of "std_logic_vector" that makes us 16 registers, we write the data on a register synchronously at the opposite of the reading. According to the wanted architecture, we can read two register throught two outputs.

The synthesizers report gives us the LUTs and Registers count.
```
+-------------------------+------+-------+------------+-----------+-------+
|        Site Type        | Used | Fixed | Prohibited | Available | Util% |
+-------------------------+------+-------+------------+-----------+-------+
| Slice LUTs*             |   99 |     0 |          0 |     20800 |  0.48 |
|   LUT as Logic          |   99 |     0 |          0 |     20800 |  0.48 |
|   LUT as Memory         |    0 |     0 |          0 |      9600 |  0.00 |
| Slice Registers         |  128 |     0 |          0 |     41600 |  0.31 |
|   Register as Flip Flop |  128 |     0 |          0 |     41600 |  0.31 |
|   Register as Latch     |    0 |     0 |          0 |     41600 |  0.00 |
| F7 Muxes                |   32 |     0 |          0 |     16300 |  0.20 |
| F8 Muxes                |   16 |     0 |          0 |      8150 |  0.20 |
+-------------------------+------+-------+------------+-----------+-------+
```

Here is the behavioral testbench of the register file:
<img width="1828" height="517" alt="register_file_tb" src="https://github.com/user-attachments/assets/1c8a2cfa-9e19-41a1-9678-33e9a6383db5" />


### 3. 8 bit counter
The 8 bit counter was made as a practical exercice for learning how to implement a program on our development board
It lies on a clock, negative logic reset, negative logic enable, up/down, load, d_in and d_out ports.


```
+-------------------------+------+-------+------------+-----------+-------+
|        Site Type        | Used | Fixed | Prohibited | Available | Util% |
+-------------------------+------+-------+------------+-----------+-------+
| Slice LUTs*             |   13 |     0 |          0 |     20800 |  0.06 |
|   LUT as Logic          |   13 |     0 |          0 |     20800 |  0.06 |
|   LUT as Memory         |    0 |     0 |          0 |      9600 |  0.00 |
| Slice Registers         |    8 |     0 |          0 |     41600 |  0.02 |
|   Register as Flip Flop |    8 |     0 |          0 |     41600 |  0.02 |
|   Register as Latch     |    0 |     0 |          0 |     41600 |  0.00 |
| F7 Muxes                |    0 |     0 |          0 |     16300 |  0.00 |
| F8 Muxes                |    0 |     0 |          0 |      8150 |  0.00 |
+-------------------------+------+-------+------------+-----------+-------+
```
Here is the behavioral testbench of the register file:
<img width="1579" height="587" alt="8_bit_counter_tb" src="https://github.com/user-attachments/assets/75be0cd1-1c40-44d7-84b0-fc4aab1365ca" />

### 4. Memories
According to the desired architecture, we split up the main memory into the instruction and data memory. We decided to create 2 different files not to jam the 2 architectures together.
Again, the architecture is centered around an array of ``std_logic_vector``.
The data file is read asynchronously but set synchronously, while the instruction file is read synchronously.
The data file read needed to be done within the clock tick such that we didn't have to implement a data hazard detection, when we try to read at an adress we just wrote on.

The synthesizers reports gives us the LUTs and Registers count.
a warning is displayed : LUT and register counts can differ from implementation. In our case, the count doesn't change.
Data Memory :
(wrong chip selected so available values are wrong)
```
+-------------------------+------+-------+------------+-----------+-------+
|        Site Type        | Used | Fixed | Prohibited | Available | Util% |
+-------------------------+------+-------+------------+-----------+-------+
| Slice LUTs*             |  842 |     0 |          0 |    303600 |  0.28 |
|   LUT as Logic          |  842 |     0 |          0 |    303600 |  0.28 |
|   LUT as Memory         |    0 |     0 |          0 |    130800 |  0.00 |
| Slice Registers         | 2048 |     0 |          0 |    607200 |  0.34 |
|   Register as Flip Flop | 2048 |     0 |          0 |    607200 |  0.34 |
|   Register as Latch     |    0 |     0 |          0 |    607200 |  0.00 |
| F7 Muxes                |  272 |     0 |          0 |    151800 |  0.18 |
| F8 Muxes                |  136 |     0 |          0 |     75900 |  0.18 |
+-------------------------+------+-------+------------+-----------+-------+
```

Instruction Memory : the synthesiser only uses Flip/Flops for non-noop instruction
(wrong chip selected so available values are wrong)
```
+-------------------------+------+-------+------------+-----------+-------+
|        Site Type        | Used | Fixed | Prohibited | Available | Util% |
+-------------------------+------+-------+------------+-----------+-------+
| Slice LUTs*             |   14 |     0 |          0 |    303600 | <0.01 |
|   LUT as Logic          |   14 |     0 |          0 |    303600 | <0.01 |
|   LUT as Memory         |    0 |     0 |          0 |    130800 |  0.00 |
| Slice Registers         |   16 |     0 |          0 |    607200 | <0.01 |
|   Register as Flip Flop |   16 |     0 |          0 |    607200 | <0.01 |
|   Register as Latch     |    0 |     0 |          0 |    607200 |  0.00 |
| F7 Muxes                |    0 |     0 |          0 |    151800 |  0.00 |
| F8 Muxes                |    0 |     0 |          0 |     75900 |  0.00 |
+-------------------------+------+-------+------------+-----------+-------+
```

Here is the behavioral testbench for both memories:
<img width="1545" height="587" alt="memory_tb" src="https://github.com/user-attachments/assets/a88eb3c1-0728-4cf4-b226-d16660766347" />


### 5. Datapath
All of the components were merged into projet_compo, the main project.
We created a 5 stage pipeline with data hazard protection. The protection uses a bubble algorithm to stall instructions that are going to read a register that is going to be modified later in the pipeline, covering every instructions and every case for this hasard.
Everything implemented works in behavioral simulation, synthesise and still remains functionning.

Last one : here is the whole projects summary of LUT and Registers used :
```
+-------------------------+------+-------+------------+-----------+-------+
|        Site Type        | Used | Fixed | Prohibited | Available | Util% |
+-------------------------+------+-------+------------+-----------+-------+
| Slice LUTs*             | 1054 |     0 |          0 |     20800 |  5.07 |
|   LUT as Logic          | 1054 |     0 |          0 |     20800 |  5.07 |
|   LUT as Memory         |    0 |     0 |          0 |      9600 |  0.00 |
| Slice Registers         | 2192 |     0 |          0 |     41600 |  5.27 |
|   Register as Flip Flop | 2192 |     0 |          0 |     41600 |  5.27 |
|   Register as Latch     |    0 |     0 |          0 |     41600 |  0.00 |
| F7 Muxes                |  280 |     0 |          0 |     16300 |  1.72 |
| F8 Muxes                |  136 |     0 |          0 |      8150 |  1.67 |
+-------------------------+------+-------+------------+-----------+-------+
```

Here is the full behavioral simulation, showing instructions going through every stages of the pipeline, being processed, the data hazard detection firing and sending a NOP down the stages and locking the current "Lidi" instruction :
<img width="1848" height="825" alt="total_tb" src="https://github.com/user-attachments/assets/877de100-75ff-406c-a0ab-0fb8b5d33215" />

### 6. Design Flow
We now focus on the steps to implement the project into our FPGA:
First we start a new behavioral synthesis focused on the ports and also the data hazard detection :
<img width="1885" height="874" alt="totbe_tb" src="https://github.com/user-attachments/assets/5514f69d-0929-48e2-9785-13de4dc7cabb" />
Everything works according to the assembly code.

Then we synthesize the design to get the following schematic : we are sure that the design wasn't trunkated down to nothing by the synthesizer.
Previously, we had parts of our design simplified to nothing, but it was due to certain tests at the core of the project : "and var/="UUUUUUUU"" was always false during synthesis. Removing the condition made everything go back to normal.
<img width="1015" height="430" alt="schema_tout" src="https://github.com/user-attachments/assets/92903637-69c1-4c35-ad54-20ecc1d0b4a6" />

The post synthesis functionnal simulation is the following, matching the behavioral simulation :
<img width="1888" height="875" alt="totsy_tb" src="https://github.com/user-attachments/assets/b498cdf6-3979-4cbb-9639-07b4b4f81fdf" />

Then we add the pin assignment to the constraint files, and specify the clock isn't internal to the fpga.
Thus we can implement the design to our FPGA, the Basys 3.
<img width="1888" height="680" alt="totim_tb" src="https://github.com/user-attachments/assets/40aacc84-8244-4303-822d-c4e7c214c644" />

At this stage it is now important to know how it behaves according to time :
<img width="1887" height="638" alt="totim_tb_timing" src="https://github.com/user-attachments/assets/b83eff64-d0a4-4367-b046-6a32da1c8ebc" />
We clearly see the signals go through a transition phase to go from a value to the next : every bit has to change, possibly at different times.
Our instruction counter lags behind every other port, and we can see our data hazard detection is mostly but isn't always stable through time. This is caused again by the rising and falling edges of the registers not happening at the same time, and taking a bit of time to do so.
Also, our enable bit is inverted compared to our simulations. It must be a simplification because it behaves like the original one).

Finally we can take a look at the LUT and Register use for the whole project, and discover our critical path.
<img width="537" height="263" alt="imple_use" src="https://github.com/user-attachments/assets/9b33c279-adcf-43ef-972b-cfee68721164" />
<img width="1606" height="487" alt="imple_timing_report" src="https://github.com/user-attachments/assets/09986e4e-4e47-4c2b-8ae4-05214e175d4b" />
Our critical path is during the memory writing stage of the pipeline. We expected it to be within the Arithmetic stage.
