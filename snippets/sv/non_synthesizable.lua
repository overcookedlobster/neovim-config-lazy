local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local d = ls.dynamic_node
local c = ls.choice_node
local fmt = require("luasnip.extras.fmt").fmt
local fmta = require("luasnip.extras.fmt").fmta
local rep = require("luasnip.extras").rep
local helpers = require('personal.luasnip-helper-funcs')
local get_visual = helpers.get_visual

return {
  -- Initial block
  s({trig="init", descr="Initial block"},
    fmt(
      [[
      initial begin
        {}
      end
      ]],
      {d(1, function(_, snip)
        return sn(1, {i(1, snip.env.TM_SELECTED_TEXT[1] or "")})
      end)}
    )
  ),
  
  -- Task declaration
  s({trig="task", descr="Task declaration"},
    fmt(
      [[
      task {};
        {}
      endtask
      ]],
      {i(1, "task_name"), i(0)}
    )
  ),
  
  -- Function declaration
  s({trig="func", descr="Function declaration"},
    fmt(
      [[
      function {} {};
        {}
        return {};
      endfunction
      ]],
      {i(1, "return_type"), i(2, "func_name"), i(3), i(0)}
    )
  ),
  
  -- Assertion
  s({trig="assert", descr="Assertion"},
    fmt(
      [[
      assert ({}) else $error("{}: {}", {});
      ]],
      {i(1, "condition"), i(2, "Error message"), i(3, "variable"), i(0)}
    )
  ),
  
  -- Testbench template
  s({trig="tb", descr="Testbench template"},
    fmt(
      [[
      `timescale 1ns/1ps
      module {}_tb;
        // Testbench signals
        logic clk, rst_n;
        
        // DUT instantiation
        {} dut (
          .clk(clk),
          .rst_n(rst_n)
          // Add other ports here
        );
        
        // Clock generation
        always #5 clk = ~clk;
        
        initial begin
          // Initialize signals
          clk = 0;
          rst_n = 0;
          
          // Reset
          #10 rst_n = 1;
          
          // Test sequence
          {}
          
          $finish;
        end
      endmodule
      ]],
      {i(1, "module_name"), rep(1), i(0)}
    )
  ),

  -- Fork-join
  s({trig="fork", descr="Fork-join block"},
    fmt(
      [[
      fork
        begin
          {}
        end
        begin
          {}
        end
      join{}
      ]],
      {i(1), i(2), c(3, {t(""), t("_any"), t("_none")})}
    )
  ),

  -- Semaphore declaration and usage
  s({trig="sema", descr="Semaphore declaration and usage"},
    fmt(
      [[
      semaphore {};
      {} = new({}); // Initialize semaphore

      // Usage:
      {}.get({}); // Acquire semaphore
      // Critical section
      {}.put({}); // Release semaphore
      ]],
      {i(1, "sema_name"), rep(1), i(2, "initial_keys"), rep(1), i(3, "keys"), rep(1), rep(3)}
    )
  ),

  -- Mailbox declaration and usage
  s({trig="mbox", descr="Mailbox declaration and usage"},
    fmt(
      [[
      mailbox {};
      {} = new(); // Create mailbox

      // Usage:
      {}.put({}); // Send message
      {}.get({}); // Receive message
      ]],
      {i(1, "mbox_name"), rep(1), rep(1), i(2, "message"), rep(1), i(3, "received_msg")}
    )
  ),

  -- Event declaration and usage
  s({trig="event", descr="Event declaration and usage"},
    fmt(
      [[
      event {};

      // Trigger event
      -> {};

      // Wait for event
      @({});
      ]],
      {i(1, "event_name"), rep(1), rep(1)}
    )
  ),

-- Covergroup
  s({trig="cg", descr="Covergroup declaration"},
    fmt(
      [[
      covergroup {} @({});
        {} : coverpoint {} {{
          bins {} = {{}};
        }}
      endgroup
      ]],
      {i(1, "cg_name"), i(2, "sampling_event"), i(3, "cp_name"), i(4, "variable"), i(5, "bins_name")}
    )
  ),
  -- Sequence declaration
  s({trig="seq", descr="Sequence declaration"},
    fmt(
      [[
      sequence {};
        {}
      endsequence
      ]],
      {i(1, "seq_name"), i(0)}
    )
  ),

  -- Property declaration
  s({trig="prop", descr="Property declaration"},
    fmt(
      [[
      property {};
        @({})
        {}
      endproperty
      ]],
      {i(1, "prop_name"), i(2, "clock_event"), i(0)}
    )
  ),

  -- Assertion directive
  s({trig="assert_prop", descr="Assertion directive"},
    fmt(
      [[
      {} prop_{}:
        assert property ({})
        else $error("{}: {}");
      ]],
      {c(1, {t(""), t("immediate ")}), i(2, "name"), i(3, "property"), i(4, "Error message"), i(0)}
    )
  ),

  -- Randomize with constraints
  s({trig="rand", descr="Randomize with constraints"},
    fmt(
      [[
      {} = new();
      if (!{}.randomize() with {{
        {}
      }}) $error("Randomization failed");
      ]],
      {i(1, "obj_name"), rep(1), i(0)}
    )
  ),

  -- Class declaration
  s({trig="class", descr="Class declaration"},
    fmt(
      [[
      class {} {};
        // Properties
        {}

        // Methods
        function new({});
          {}
        endfunction

        {}
      endclass
      ]],
      {i(1, "class_name"), c(2, {t(""), sn(nil, {t("extends "), i(1, "parent_class")})}), i(3), i(4), i(5), i(0)}
    )
  ),

  -- Interface declaration
  s({trig="intf", descr="Interface declaration"},
    fmt(
      [[
      interface {} {};
        // Signals
        {}

        // Modports
        modport {} (
          {}
        );

        // Tasks/Functions
        {}
      endinterface
      ]],
      {i(1, "intf_name"), c(2, {t(""), sn(nil, {t("("), i(1), t(")")})}), i(3), i(4, "modport_name"), i(5), i(0)}
    )
  ),

  -- Generate block
  s({trig="gen", descr="Generate block"},
    fmt(
      [[
      generate
        {}
      endgenerate
      ]],
      {i(0)}
    )
  ),

  -- Systemverilog Assertions
  s({trig="sva", descr="SystemVerilog Assertion"},
    fmt(
      [[
      {}assert_{}: assert {}({})
        {}
        else
          {}
      ]],
      {c(1, {t(""), t("property "), t("sequence ")}), i(2, "name"), rep(1), i(3, "condition"), 
       c(4, {t(""), sn(nil, {t("$info(\""), i(1, "Pass message"), t("\")")}) }), 
       c(5, {t("$error(\"Assertion failed\")"), sn(nil, {t("$error(\""), i(1, "Fail message"), t("\")")})})}
    )
  ),

  -- Clocking block
  s({trig="clock", descr="Clocking block"},
    fmt(
      [[
      clocking {} @({});
        default input #1step output #1ps;
        {}
      endclocking
      ]],
      {i(1, "cb_name"), i(2, "clock_event"), i(0)}
    )
  ),

  -- Program block
  s({trig="program", descr="Program block"},
    fmt(
      [[
      program {}({});
        {}
      endprogram
      ]],
      {i(1, "program_name"), i(2, "interface_instance"), i(0)}
    )
  ),
-- Foreach loop
  s({trig="foreach", descr="Foreach loop"},
    fmt(
      [[
      foreach ({} [{}]) begin
        {}
      end
      ]],
      {i(1, "item"), i(2, "array"), i(0)}
    )
  ),
s({trig="for", descr="For loop"},
  fmt(
    [[
    for (int {} = 0; {} < {}; {}++) begin
      {}
    end
    ]],
    {i(1, "i"), rep(1), i(2, "limit"), rep(1), i(0)}
  )
),
-- Display task
s({trig="disp", descr="Display task"},
  fmt(
    [[
    $display("{}", {});
    ]],
    {i(1, "format_string"), i(2, "arguments")}
  )
),

-- Strobe task
s({trig="strobe", descr="Strobe task"},
  fmt(
    [[
    $strobe("{}", {});
    ]],
    {i(1, "format_string"), i(2, "arguments")}
  )
),

-- Write task
s({trig="write", descr="Write task"},
  fmt(
    [[
    $write("{}", {});
    ]],
    {i(1, "format_string"), i(2, "arguments")}
  )
),

-- Monitor task
s({trig="monitor", descr="Monitor task"},
  fmt(
    [[
    $monitor("{}", {});
    ]],
    {i(1, "format_string"), i(2, "arguments")}
  )
),

-- Fwrite task
s({trig="fwrite", descr="Fwrite task"},
  fmt(
    [[
    $fwrite({}, "{}", {});
    ]],
    {i(1, "file_handle"), i(2, "format_string"), i(3, "arguments")}
  )
),

-- Sformat function
s({trig="sformat", descr="Sformat function"},
  fmt(
    [[
    $sformat({}, "{}", {});
    ]],
    {i(1, "string_var"), i(2, "format_string"), i(3, "arguments")}
  )
),

-- Timeformat task
s({trig="timeformat", descr="Timeformat task"},
  fmt(
    [[
    $timeformat({}, {}, "{}", {});
    ]],
    {i(1, "units"), i(2, "precision"), i(3, "suffix"), i(4, "min_field_width")}
  )
),

-- Printtimescale task
s({trig="ptscale", descr="Printtimescale task"},
  fmt(
    [[
    $printtimescale({});
    ]],
    {i(1, "module_or_scope")}
  )
),

-- Value change dump
s({trig="vcd", descr="Value change dump tasks"},
  fmt(
    [[
    $dumpfile("{}");
    $dumpvars({}, {});
    ]],
    {i(1, "filename.vcd"), i(2, "levels"), i(3, "module_or_variables")}
  )
),
s({trig="forever", descr="Forever loop"},
  fmt(
    [[
    forever begin
      {}
    end
    ]],
    {i(0)}
  )
),
s({trig="repeat", descr="Repeat loop"},
  fmt(
    [[
    repeat ({}) begin
      {}
    end
    ]],
    {i(1, "count"), i(0)}
  )
),
}
