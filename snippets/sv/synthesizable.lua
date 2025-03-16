local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {
    -- Module
    s("mod", {
        t("module "), i(1, "module_name"),
        t({ " (", "\t" }), i(2),
        t({ "", ");", "" }),
        i(0),
        t({ "", "endmodule" })
    }),
    -- Always FF block
    s("aff", {
        t("always_ff @(posedge "), i(1, "clk"), t(") begin"),
        t({ "", "\t" }), i(0),
        t({ "", "end" })
    }),
    -- Always Comb block
    s("acomb", {
        t("always_comb begin"),
        t({ "", "\t" }), i(0),
        t({ "", "end" })
    }),
    -- Case statement
    s("case", {
        t("case ("), i(1, "expression"), t(")"),
        t({ "", "\t" }), i(2, "value"), t(": "), i(3),
        t({ "", "\tdefault: "}), i(0),
        t({ "", "endcase" })
    }),
    -- Generate for loop
    s("genfor", {
        t("generate"), t({ "", "for (int " }), i(1, "i"), t(" = 0; "), 
        i(2, "i"), t(" < "), i(3, "N"), t("; "), i(4, "i"), t("++) begin : "), i(5, "gen_label"),
        t({ "", "\t" }), i(0),
        t({ "", "end", "endgenerate" })
    }),
    s("if", {
        t("if ("), i(1, "condition"), t(") begin"),
        t({ "", "\t" }), i(2),
        t({ "", "end" }),
        i(0)
    }),
    
    s("ifel", {
        t("if ("), i(1, "condition"), t(") begin"),
        t({ "", "\t" }), i(2),
        t({ "", "end else begin" }),
        t({ "", "\t" }), i(3),
        t({ "", "end" }),
        i(0)
    }),
    
    s("while", {
        t("while ("), i(1, "condition"), t(") begin"),
        t({ "", "\t" }), i(0),
        t({ "", "end" })
    }),
    
    s("assign", {
        t("assign "), i(1, "signal"), t(" = "), i(2, "value"), t(";"),
        i(0)
    }),
}
