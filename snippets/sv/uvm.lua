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
return {
  -- UVM Component
  s({trig="uvc", descr="UVM Component"},
    fmt(
      [[
      class {} extends uvm_component;
        `uvm_component_utils({})

        function new(string name, uvm_component parent);
          super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
          super.build_phase(phase);
          {}
        endfunction

        task run_phase(uvm_phase phase);
          super.run_phase(phase);
          {}
        endtask
      endclass
      ]],
      {i(1, "component_name"), rep(1), i(2), i(0)}
    )
  ),

  -- UVM Object
  s({trig="uvo", descr="UVM Object"},
    fmt(
      [[
      class {} extends uvm_object;
        `uvm_object_utils({})

        function new(string name = "");
          super.new(name);
        endfunction

        function void do_copy(uvm_object rhs);
          {} rhs_;
          super.do_copy(rhs);
          $cast(rhs_, rhs);
          {}
        endfunction
      endclass
      ]],
      {i(1, "object_name"), rep(1), rep(1), i(0)}
    )
  ),

  -- UVM Sequence
  s({trig="uvs", descr="UVM Sequence"},
    fmt(
      [[
      class {} extends uvm_sequence#({});
        `uvm_object_utils({})

        function new(string name = "");
          super.new(name);
        endfunction

        task body();
          {}
        endtask
      endclass
      ]],
      {i(1, "sequence_name"), i(2, "req_type"), rep(1), i(0)}
    )
  ),

  -- UVM Sequencer
  s({trig="uvsr", descr="UVM Sequencer"},
    fmt(
      [[
      class {} extends uvm_sequencer#({});
        `uvm_component_utils({})

        function new(string name, uvm_component parent);
          super.new(name, parent);
        endfunction
      endclass
      ]],
      {i(1, "sequencer_name"), i(2, "req_type"), rep(1)}
    )
  ),

  -- UVM Driver
  s({trig="uvd", descr="UVM Driver"},
    fmt(
      [[
      class {} extends uvm_driver#({});
        `uvm_component_utils({})

        function new(string name, uvm_component parent);
          super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
          super.build_phase(phase);
          {}
        endfunction

        task run_phase(uvm_phase phase);
          super.run_phase(phase);
          forever begin
            seq_item_port.get_next_item(req);
            {}
            seq_item_port.item_done();
          end
        endtask
      endclass
      ]],
      {i(1, "driver_name"), i(2, "req_type"), rep(1), i(3), i(0)}
    )
  ),

  -- UVM Monitor
  s({trig="uvm", descr="UVM Monitor"},
    fmt(
      [[
      class {} extends uvm_monitor;
        `uvm_component_utils({})

        uvm_analysis_port#({}) ap;

        function new(string name, uvm_component parent);
          super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
          super.build_phase(phase);
          ap = new("ap", this);
        endfunction

        task run_phase(uvm_phase phase);
          super.run_phase(phase);
          forever begin
            {}
          end
        endtask
      endclass
      ]],
      {i(1, "monitor_name"), rep(1), i(2, "item_type"), i(0)}
    )
  ),

  -- UVM Agent
  s({trig="uva", descr="UVM Agent"},
    fmt(
      [[
      class {} extends uvm_agent;
        `uvm_component_utils({})

        {} m_sequencer;
        {} m_driver;
        {} m_monitor;

        function new(string name, uvm_component parent);
          super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
          super.build_phase(phase);
          if(get_is_active() == UVM_ACTIVE) begin
            m_sequencer = {}.type_id::create("m_sequencer", this);
            m_driver = {}.type_id::create("m_driver", this);
          end
          m_monitor = {}.type_id::create("m_monitor", this);
        endfunction

        function void connect_phase(uvm_phase phase);
          if(get_is_active() == UVM_ACTIVE) begin
            m_driver.seq_item_port.connect(m_sequencer.seq_item_export);
          end
        endfunction
      endclass
      ]],
      {i(1, "agent_name"), rep(1), i(2, "sequencer_type"), i(3, "driver_type"), i(4, "monitor_type"), rep(2), rep(3), rep(4)}
    )
  ),

  -- UVM Scoreboard
  s({trig="uvsc", descr="UVM Scoreboard"},
    fmt(
      [[
      class {} extends uvm_scoreboard;
        `uvm_component_utils({})

        uvm_analysis_export#({}) sb_export;
        uvm_tlm_analysis_fifo#({}) sb_fifo;

        function new(string name, uvm_component parent);
          super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
          super.build_phase(phase);
          sb_export = new("sb_export", this);
          sb_fifo = new("sb_fifo", this);
        endfunction

        function void connect_phase(uvm_phase phase);
          sb_export.connect(sb_fifo.analysis_export);
        endfunction

        task run_phase(uvm_phase phase);
          {} item;
          forever begin
            sb_fifo.get(item);
            {}
          end
        endtask
      endclass
      ]],
      {i(1, "scoreboard_name"), rep(1), i(2, "item_type"), rep(2), rep(2), i(0)}
    )
  ),

  -- UVM Environment
  s({trig="uve", descr="UVM Environment"},
    fmt(
      [[
      class {} extends uvm_env;
        `uvm_component_utils({})

        {} m_agent;
        {} m_scoreboard;

        function new(string name, uvm_component parent);
          super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
          super.build_phase(phase);
          m_agent = {}.type_id::create("m_agent", this);
          m_scoreboard = {}.type_id::create("m_scoreboard", this);
        endfunction

        function void connect_phase(uvm_phase phase);
          m_agent.m_monitor.ap.connect(m_scoreboard.sb_export);
        endfunction
      endclass
      ]],
      {i(1, "env_name"), rep(1), i(2, "agent_type"), i(3, "scoreboard_type"), rep(2), rep(3)}
    )
  ),

  -- UVM Test
  s({trig="uvt", descr="UVM Test"},
    fmt(
      [[
      class {} extends uvm_test;
        `uvm_component_utils({})

        {} m_env;

        function new(string name = "{}", uvm_component parent = null);
          super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
          super.build_phase(phase);
          m_env = {}.type_id::create("m_env", this);
        endfunction

        task run_phase(uvm_phase phase);
          {}
        endtask
      endclass
      ]],
      {i(1, "test_name"), rep(1), i(2, "env_type"), rep(1), rep(2), i(0)}
    )
  ),

  -- UVM Factory Override
  s({trig="uvfo", descr="UVM Factory Override"},
    fmt(
      [[
      function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        set_type_override_by_type({}.get_type(), {}.get_type());
      endfunction
      ]],
      {i(1, "original_type"), i(2, "override_type")}
    )
  ),

  -- UVM Config DB Set
  s({trig="uvcds", descr="UVM Config DB Set"},
    fmt(
      [[
      uvm_config_db#({})::set(this, "{}", "{}", {});
      ]],
      {i(1, "type"), i(2, "instance_path"), i(3, "field_name"), i(4, "value")}
    )
  ),

  -- UVM Config DB Get
  s({trig="uvcdg", descr="UVM Config DB Get"},
    fmt(
      [[
      if (!uvm_config_db#({})::get(this, "", "{}", {}))
        `uvm_fatal("CONFIG_DB_ERROR", "{} not found in config DB")
      ]],
      {i(1, "type"), i(2, "field_name"), i(3, "variable"), rep(2)}
    )
  ),

  -- UVM Report Server
  s({trig="uvrs", descr="UVM Report Server"},
    fmt(
      [[
      uvm_report_server server;
      server = uvm_report_server::get_server();
      server.set_max_quit_count({});
      ]],
      {i(1, "max_quit_count")}
    )
  ),

  -- UVM Callback
  s({trig="uvcl", descr="UVM Callback"},
    fmt(
      [[
      class {} extends uvm_callback;
        `uvm_object_utils({})

        function new(string name = "{}");
          super.new(name);
        endfunction

        virtual task {}_cb({} context);
          {}
        endtask
      endclass
      ]],
      {i(1, "callback_name"), rep(1), rep(1), i(2, "callback_method"), i(3, "context_type"), i(0)}
    )
  ),

  -- UVM Resource DB Set
  s({trig="uvrds", descr="UVM Resource DB Set"},
    fmt(
      [[
      uvm_resource_db#({})::set("{}", "{}", {});
      ]],
      {i(1, "type"), i(2, "scope"), i(3, "name"), i(4, "value")}
    )
  ),

  -- UVM Resource DB Get
  s({trig="uvrdg", descr="UVM Resource DB Get"},
    fmt(
      [[
      if (!uvm_resource_db#({})::read_by_name("{}", "{}", {}))
        `uvm_fatal("RESOURCE_DB_ERROR", "{} not found in resource DB")
      ]],
      {i(1, "type"), i(2, "scope"), i(3, "name"), i(4, "variable"), rep(3)}
    )
  ),

  -- UVM Sequence Item
  s({trig="uvsi", descr="UVM Sequence Item"},
    fmt(
      [[
      class {} extends uvm_sequence_item;
        `uvm_object_utils({})

        {} {}; // Add your transaction fields here

        function new(string name = "{}");
          super.new(name);
        endfunction

        function void do_copy(uvm_object rhs);
          {} rhs_;
          super.do_copy(rhs);
          $cast(rhs_, rhs);
          {} = rhs_.{};
        endfunction

        function bit do_compare(uvm_object rhs, uvm_comparer comparer);
          {} rhs_;
          bit status = super.do_compare(rhs, comparer);
          $cast(rhs_, rhs);
          status &= comparer.compare_field("{}", {}, rhs_.{});
          return status;
        endfunction

        function string convert2string();
          string s;
          $sformat(s, "%s: {} = %0d", super.convert2string(), {});
          return s;
        endfunction
      endclass
      ]],
      {i(1, "item_name"), rep(1), i(2, "field_type"), i(3, "field_name"), rep(1), rep(1), rep(3), rep(3), rep(1), rep(3), rep(3), rep(3), rep(3), rep(3)}
    )
  ),
  s({trig="uvim", descr="Import UVM Package"},
    fmt(
      [[
      import uvm_pkg::*;
      `include "uvm_macros.svh"
      ]],
      {}
    )
  ),
  s({trig="uvou", descr="UVM Object Utils Block"},
    fmt(
      [[
      `uvm_object_utils_begin({})
        `uvm_field_{}({}, {})
      `uvm_object_utils_end
      ]],
      {
        i(1, "class_name"),
        i(2, "type"),
        i(3, "field_name"),
        i(4, "flags")
      }
    )
  ),
  s({trig="uvminfo", descr="UVM Info Message"},
    fmt(
      [[
      `uvm_info({}, $sformatf("{}"), UVM_{})]],
      {i(1,"get_type_name()"),i(2, "message"), c(3, {t("NONE"), t("LOW"), t("MEDIUM"), t("HIGH"), t("FULL")})}
    )
  ),
}

