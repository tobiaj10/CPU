# CPU

Designed a synthesized CPU that utilizes different methods of stalling and forwarding to keep the CPUs speed as quick and reliable as possible. This CPU is composed of 5 different stages: the instruction fetch, instruction decode, execution, memory, and write back stages. Each stage is important and carries out a distinct function. 

The instruction fetch stage oversees obtaining the instruction from the user and passing it to the instruction decode stage which actually reads the instruction and passes certain important information from it for future stages. 

The execution stage takes the important information and uses the ALU to properly follow the instruction information to iterate on the data properly before passing it to the memory stage. 

The memory access stage can access memory if something is needed to be read from memory or if the ALU result must be written to memory. This is then passed on to the writeback stage which is in charge of taking the updated values that were operated on by the ALU, passing them back to be used in earlier stages of the CPU. 

This type of architecture is important in computer organization and design because it is simple and can be designed easier for many applications than other, more complex architectures. Pipelining with this architecture is effective and cheap, making it adequate for many applications. With the current methods in place, the CPU is designed to use forwarding to not have to wait for a value in the execution and memory stages. 
