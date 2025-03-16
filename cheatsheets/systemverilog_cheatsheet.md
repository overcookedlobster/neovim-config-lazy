# 📚 SystemVerilog LuaSnip Cheatsheet 📚

## 🔑 Key Bindings
- `<C-k>`: Expand snippet or jump to next placeholder
- `<C-j>`: Jump to previous placeholder

## 📝 General Snippets
| Trigger | Description | Usage |
|---------|-------------|-------|
| `module` | Module declaration | `module<Tab>` |
| `initial` | Initial block | `initial<Tab>` |
| `task` | Task declaration | `task<Tab>` |
| `func` | Function declaration | `func<Tab>` |

## 🔄 Control Structures
| Trigger | Description | Usage |
|---------|-------------|-------|
| `aff` | Always FF block | `aff<Tab>` |
| `acomb` | Always Comb block | `acomb<Tab>` |
| `case` | Case statement | `case<Tab>` |
| `genfor` | Generate for loop | `genfor<Tab>` |
| `for` | For loop | `for<Tab>` |
| `ife` | If-else statement | `ife<Tab>` |
| `genif` | Generate if block | `genif<Tab>` |

## 📊 Data Structures
| Trigger | Description | Usage |
|---------|-------------|-------|
| `enum` | Typedef enum | `enum<Tab>` |
| `struct` | Typedef struct | `struct<Tab>` |

## 📥📤 Input/Output
| Trigger | Description | Usage |
|---------|-------------|-------|
| `input` | Input port declaration | `input<Tab>` |
| `output` | Output port declaration | `output<Tab>` |

## 🔍 Verification Constructs
| Trigger | Description | Usage |
|---------|-------------|-------|
| `assert` | Assertion | `assert<Tab>` |
| `assert_prop` | Assertion directive | `assert_prop<Tab>` |
| `cg` | Covergroup declaration | `cg<Tab>` |
| `seq` | Sequence declaration | `seq<Tab>` |
| `prop` | Property declaration | `prop<Tab>` |

## 🧮 Object-Oriented Programming
| Trigger | Description | Usage |
|---------|-------------|-------|
| `class` | Class declaration | `class<Tab>` |
| `rand` | Randomize with constraints | `rand<Tab>` |

## 📥📤 Interfaces and Modports
| Trigger | Description | Usage |
|---------|-------------|-------|
| `intf` | Interface declaration | `intf<Tab>` |

## 🔧 Advanced Features
| Trigger | Description | Usage |
|---------|-------------|-------|
| `param` | Parameter declaration | `param<Tab>` |
| `assign` | Assign statement | `assign<Tab>` |
| `sema` | Semaphore declaration and usage | `sema<Tab>` |
| `mbox` | Mailbox declaration and usage | `mbox<Tab>` |
| `event` | Event declaration and usage | `event<Tab>` |

## 🕰️ Timing and Synchronization
| Trigger | Description | Usage |
|---------|-------------|-------|
| `clocking` | Clocking block | `clocking<Tab>` |
| `program` | Program block | `program<Tab>` |

## 🔬 Testbench Specific
| Trigger | Description | Usage |
|---------|-------------|-------|
| `tb` | Testbench template | `tb<Tab>` |
| `forkjoin` | Fork-join block | `forkjoin<Tab>` |

## 💡 Miscellaneous
| Trigger | Description | Usage |
|---------|-------------|-------|
| `TODOO` | TODO comment | `TODOO<Tab>` |
| `--` | Comment separator | `--<Tab>` |

## 💡 Tips
- Many snippets use choice nodes (c) for variants, explore options with `<C-k>`
- Some snippets are context-sensitive (e.g., only in testbench or synthesizable code)
- Use visual selection with snippets for easy wrapping
- Explore the Lua files for more detailed trigger conditions and snippet behaviors

SystemVerilog + LuaSnip = Efficient Verification! 🚀

This cheatsheet provides a comprehensive overview of the SystemVerilog snippets defined in the Lua files. It covers various aspects of SystemVerilog, including general constructs, control structures, data structures, verification constructs, and advanced features specific to testbench development.
