Plan of attack:

- Transpose the input text file
- Collapse the file to a binary string of 32-bit unsigned ints.
- If $R is the number of rows in the original file, the new file will be 5 regions of $R 32-bit ints.
- Each region should be collapsed to 0 if it adds up to ($R / 2) or less, and 1 if more.
- These collapsed regions should be assembled bitwise and output as an integer.
- Multiply by its complement.
- Print the output.
