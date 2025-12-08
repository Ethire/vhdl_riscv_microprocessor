# vhdl_riscv_microcontroller
A limited implementation of a riscV processor as a course project.

## Functionnal overview


## Description of core components

### 1. UAL
**Overview**\
We designed the UAL with its combinational nature in mind : the main part is in a process driven by the following sensitivity list : ``(A, B, control)``, no clock needed.
Every bitwise operation can be simply implemented as ``out <= A op B``, but the more complex operations such as Multiply and Add requires mure memory. The worst is Multiply, that needs 16 bits at worst to store the result. Thus we extend our inputs and outputs internally by adding leading 0s

The synthesizers report gives us the LUTs and Registers count.
We can verify that our model is purely combinational : no registers were used
```c
+-------------------------+------+-------+------------+-----------+-------+
|        Site Type        | Used | Fixed | Prohibited | Available | Util% |
+-------------------------+------+-------+------------+-----------+-------+
| Slice LUTs*             |  107 |     0 |          0 |    303600 |  0.04 |
|   LUT as Logic          |  107 |     0 |          0 |    303600 |  0.04 |
|   LUT as Memory         |    0 |     0 |          0 |    130800 |  0.00 |
| Slice Registers         |    0 |     0 |          0 |    607200 |  0.00 |
|   Register as Flip Flop |    0 |     0 |          0 |    607200 |  0.00 |
|   Register as Latch     |    0 |     0 |          0 |    607200 |  0.00 |
| F7 Muxes                |    0 |     0 |          0 |    151800 |  0.00 |
| F8 Muxes                |    0 |     0 |          0 |     75900 |  0.00 |
+-------------------------+------+-------+------------+-----------+-------+
```

### 2. Register file

### 3. 8 bit counter

### 4. Memories
According to the desired architecture, we split up the main memory into the instruction and data memory. We decided to create 2 different files not to jam the 2 architectures together.

#### 4.1 Data memory

#### 4.2 Instruction memory

### 5. Datapath
