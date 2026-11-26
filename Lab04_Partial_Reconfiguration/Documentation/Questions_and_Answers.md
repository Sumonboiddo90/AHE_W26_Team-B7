Question 1: How large is the full bitstream and how large are the partial ones?

Answer: The full bitstream contains the static design and the initial reconfigurable module. A partial bitstream contains only the reconfigurable partition. We will insert our measured sizes from Vivado.

Question 2: Why do the three partial bitstreams have the same size?

Answer: All three partial bitstreams configure the same physical partition, with the same reserved rectangle and number of configuration frames. Therefore, their sizes should be the same.

Question 3: What happened to the terminal output during the swap?

Answer: The module identification changed from RM A to RM B and then RM C. The counter continued increasing because the MicroBlaze remained active in the static region.

Question 4: Why was the MicroBlaze not affected?

Answer: The MicroBlaze belongs to the static region, which is not overwritten when a partial bitstream is loaded. Only the logic inside the reconfigurable partition changes.

Question 5: When would you not use reconfiguration?

Answer: Dynamic reconfiguration introduces additional design complexity, implementation effort, configuration time and resource overhead. It may not be useful when the hardware never needs to change or when a simpler static design is sufficient.
