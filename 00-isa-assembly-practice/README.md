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
slli x4, x3, 1       # x4 = 15 << 1 = 30  (×2 multiply = shift left by 1)
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

## Example 3 — Loop with Comparison: Find Maximum / Minimum

**Goal:** given a 6-element array, find the largest value — then the smallest.

```asm
.data
array: .word 12, 45, 3, 67, 22, 8

.text
la   x1, array
addi x2, x0, 0            # i = 0 (process index 0 once, before the loop)
slli x3, x2, 2
add  x4, x1, x3
lw   x5, 0(x4)              # x5 = array[0]
addi x6, x5, 0                # x6 = max, initialized to array[0]
addi x2, x2, 1                 # i = 1 (loop handles indices 1..5)
addi x7, x0, 6                   # loop bound

loop:
slli x3, x2, 2
add  x4, x1, x3
lw   x5, 0(x4)                    # x5 = array[i]
blt  x5, x6, skip                 # if current < max, skip (no update)
addi x6, x5, 0                     # else update max = current
skip:
addi x2, x2, 1
blt  x2, x7, loop
```

Result: `x6 = 67` (the maximum). Flipping the comparison to `blt x6, x5, skip` instead finds the minimum (`x6 = 3`).

**Concepts practiced:** initializing an accumulator from the array's own first element (not a hardcoded guess like 0, which breaks on all-negative arrays), splitting "process index 0 once" from "loop over the rest" — the same initialize-before-loop pattern as a running sum, and how flipping a single comparison's operand order inverts max-finding into min-finding.

**Mistakes caught along the way:**
- Initially planned to initialize max to `0` — realized that fails if every array value were negative (0 would wrongly "win"). Switched to initializing from `array[0]` instead.
- The max→min comparison direction isn't obvious: copying the max version's `blt x5, x6, skip` straight over to the min version silently breaks it (it updates min to anything *larger*, backwards). Had to trace through by hand with real numbers to see why the operand order needed to flip to `blt x6, x5, skip`.
- Left the "initialize max" line (`addi x6, x5, 0`) sitting *inside* the loop by accident at first — it re-ran every iteration and unconditionally overwrote the max with whatever the current element was, silently defeating the comparison entirely.

---

## Example 4 — Conditional Accumulation: Sum of Even Numbers

**Goal:** given an 8-element array, sum only the even-valued elements.

```asm
.data
numbers: .word 4, 7, 10, 3, 8, 15, 6, 9

.text
addi x10, x0, 0        # running sum = 0
addi x11, x0, 1          # mask = 1
addi x12, x0, 8           # loop bound
la   x1, numbers
addi x2, x0, 0

loop:
slli x3, x2, 2
add  x4, x1, x3
lw   x5, 0(x4)
andi x6, x5, x11
beq  x6, x11, skip     # odd -> skip the add
add  x10, x10, x5        # even -> add to running sum
skip:
addi x2, x2, 1
blt  x2, x12, loop
```

Result: `x10 = 28` (4 + 10 + 8 + 6).

**Concepts practiced:** combining the even/odd mask check from Example 2 with a running-total accumulator, reusing the single-shared-block-with-skip pattern instead of duplicating code per branch.

**Mistakes caught along the way:**
- Set the loop bound to the wrong element count at first (miscounted the array).
- Computed the address with the raw loop index instead of the `slli`-computed byte offset (`add x4, x1, x2` instead of `add x4, x1, x3`) — happened to look fine for index 0 but breaks for every other index.

---

## Example 5 — Linear Search with Early Exit

**Goal:** find a target value's index in an array; stop as soon as it's found instead of scanning the rest.

```asm
.data
numbers: .word 5, 12, 8, 22, 3, 19
target: .word 22
found_index: .word -1

.text
addi x10, x0, 6
la   x1, target
lw   x2, 0(x1)          # x2 = target's value (22)
la   x3, numbers
addi x4, x0, 0            # i = 0

loop:
slli x5, x4, 2
add  x6, x3, x5
lw   x7, 0(x6)              # x7 = numbers[i]
bne  x7, x2, skip            # not a match -> keep looping
la   x11, found_index
sw   x4, 0(x11)                # found -> store the INDEX, not the value
jal  x0, end                    # exit the loop immediately
skip:
addi x4, x4, 1
blt  x4, x10, loop
end:
```

Result: `found_index = 3` (22 is at index 3) — and indices 4 and 5 are never even checked.

**Concepts practiced:** first use of an unconditional jump (`jal x0, end`) to break out of a loop early, rather than always running every iteration — a different control-flow shape from every earlier loop in this set.

**Mistakes caught along the way:**
- Compared the loaded array element against `x1` (the *address* of `target`) instead of `x2` (the *value* loaded from that address) — comparing a value against an address is meaningless, even though it "runs."
- Stored the matched *value* (x7) into `found_index` instead of the *index* (x4) — the task asks where it was found, not what was found.

---

## Example 6 — In-Place Array Reverse (Two-Pointer Swap)

**Goal:** reverse a 5-element array in place, without a second array.

```asm
.data
arr: .word 1, 2, 3, 4, 5

.text
la   x1, arr
addi x2, x0, 0          # left = 0
addi x4, x0, 4           # right = size-1 = 4

loop:
slli x3, x2, 2             # left's offset
add  x5, x1, x3              # left's address
slli x6, x4, 2             # right's offset
add  x7, x1, x6               # right's address
lw   x8, 0(x5)                  # x8 = arr[left]
lw   x9, 0(x7)                   # x9 = arr[right]
sw   x8, 0(x7)                    # arr[right] = old arr[left]
sw   x9, 0(x5)                     # arr[left]  = old arr[right]
addi x2, x2, 1                      # left++
addi x4, x4, -1                      # right--  (negative immediate works directly in addi)
blt  x2, x4, loop                     # keep going while left < right
```

Result: `arr = 5, 4, 3, 2, 1`.

**Concepts practiced:** first two-pointer pattern (two independent indices moving toward each other instead of one index sweeping the whole array), the classic register-swap technique (load both values into separate registers *before* overwriting either address — otherwise the first store destroys data the second store still needs).

**Mistakes caught along the way:**
- In the two address-calculation lines, swapped which register played which role — put the *index* (`x2`/`x4`) into the `add` (should hold the *base address*, `x1`) and the *base address* into the `slli` (should hold the *index*). `slli` always scales an index into a byte offset; `add` always combines that offset with the fixed base — the base itself never gets shifted.
- Tried writing `lw x3, x2(x1)` — a register can never sit directly in the offset slot of `lw`/`sw`; the offset must be an immediate, which is exactly why the offset has to be computed first (`slli`) and folded into a full address (`add`) before the load/store.
- Attempted the full reverse directly (looping through every index single-handedly) before isolating the swap mechanism on just one hardcoded pair (`arr[0]`/`arr[4]`) — splitting "get one swap right" from "generalize into a loop" made the two-pointer logic much easier to get right.

---

More worked examples will be added here as ISA practice continues, before and alongside the processor build itself.
