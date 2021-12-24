Day 2

I solved part 1 of this challenge using x86\_64 assembly code.
The resulting executable can be called using `main input.txt e` to get the epsilon value in binary, or `main input.txt g` to get the gamma value.
Calling `make run` will call both invocations and multiply their results, returning printing it in decimal.
I hypothetically could have written the dual-invocation into the assembly itself, but then I would have had to write a procedure to print hardware integers as decimal ASCII values, and that sounded exhausting so I didn't do it. The executable prints binary strings instead, which was a very simple procedure in this context.

I will probably use assembly for part 2, since to debug this I had to spend a lot of time in GDB.
