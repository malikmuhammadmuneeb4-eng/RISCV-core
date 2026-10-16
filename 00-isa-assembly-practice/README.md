# ISA / Assembly Practice — RV32I

Before building the processor's RTL module by module, I worked through hand-writing and tracing small RV32I assembly programs by hand (in RIPES) to get fluent with the instruction set this core will eventually execute — registers, memory addressing, branches, and loops.

Each example below is documented with what it does, the concepts it exercises, and the real mistakes I made and fixed along the way (left in deliberately — the debugging is the actual learning).

---

## Example 1 — Basic Arithmetic: (5 + 10) × 2

**Goal:** compute (5 + 10) × 2 and store the result in memory.

```asm
.data
result: .word 0

.text
addi x1, x0, 10
addi x2, x0, 5
add  x3, x2, x1      # x3 = 15
slli x4, x3, 1       # x4 = 15 << 1 = 30  (x2 multiply = shift left by 1)
la   x5, result       # x5 = address of 'result' (no memory access — just computes the address)
sw   x4, 0(x5)        # store 30 into result
```

**Concepts practiced:** `addi`/`add` arithmetic, `slli` as a power-of-2 multiply, `la` (load address — a pseudo-instruction, doesn't touch memory) vs `lw`/`sw` (actual memory access), base+offset addressing.

**Mistakes caught along the way:**
- Confused `sll` (shift amount comes from a *register*) with `slli` (shift amount is a fixed *immediate*) — for a known constant shift like ×2, `slli` is correct.
- Assumed shifting left by *n* multiplies by *n* — it actually multiplies by 2ⁿ (shift by 1 → ×2, shift by 3 → ×8, etc.).
- Thought `la` reads from memory like `lw` does — it only *computes an address* into a register; no memory access happens until a later `lw`/`sw` uses that register as a base.
- Tried to write a register name directly as the offset/base (`lw x2, 0(vals)`) — the parenthesized part of `lw`/`sw` must be a register holding an address, not a label.

---

## Example 2 — Loop: Count Even Numbers in an Array

**Goal:** given an 8-element array, count how many elements are even.

```asm
.data
numbers: .word 3, 8, 15, 22, 9, 4, 11, 6

.text
addi x9, x0, 0        # counter = 0
addi x10, x0, 8        # loop bound = 8 (array length)
addi x8, x0, 1          # mask = 1 (for isolating the LSB)
la   x1, numbers
addi x2, x0, 0          # i = 0

loop:
slli x3, x2, 2          # offset = i * 4
add  x4, x1, x3          # address = base + offset
lw   x5, 0(x4)            # x5 = numbers[i]
andi x6, x5, x8           # x6 = LSB of numbers[i]
beq  x6, x8, skip         # if odd (LSB==1), skip the increment
addi x9, x9, 1             # even -> counter++
skip:
addi x2, x2, 1              # i++
blt  x2, x10, loop           # loop while i < 8
```

Result: `x9 = 4` (the evens are 8, 22, 4, 6).

**Concepts practiced:** indexed/computed addressing (offset = i×4 via `slli`, then `add` to the base — `lw`/`sw` can't take two registers directly, so the address has to be computed first), `andi` bit-masking to check even/odd, conditional branches (`beq`/`bne`/`blt`), unconditional jump (`jal`/`j`) for if/else control flow, and a loop built from an increment + back-branch.

**Mistakes caught along the way:**
- First attempt duplicated the load+check logic under two separate labels (`odd:` / `even:`) instead of one shared loop body with a single conditional skip — caused the program to get stuck with no way back to the loop. Fixed by using one load+check block per iteration, with `beq`/`bne` only skipping the *increment*, not the whole block, so both outcomes converge and loop back from the same point.
- Wrote a branch with an immediate operand (`blt x2, 8, loop`) — branch instructions (`beq`/`bne`/`blt`/`bge`) only compare two *registers*, never an immediate. Had to put `8` in its own register first.
- Mixed up an address register with the value it points to — used the *address* register in an arithmetic/compare operation instead of the *loaded value* register.
- Reused a register for two unrelated purposes (AND-mask constant and loop bound) in the same draft, which caused confusing results until each got its own register.

---

More worked examples will be added here as ISA practice continues, before and alongside the processor build itself.
