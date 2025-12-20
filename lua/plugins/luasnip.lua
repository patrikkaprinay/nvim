local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt

-- vim.keymap.set({ "i", "s" }, "<A-k>", function()
--   if ls.expand_or_jumpable() then
--     ls.expand_or_jump()
--   end
-- end, { silent = true })
--
-- vim.keymap.set({ "i", "s" }, "<A-j>", function()
--   if ls.jumpable(-1) then
--     ls.jump(-1)
--   end
-- end, { silent = true })

ls.add_snippets("twig", {
  s(
    { trig = "tt", name = "include translate string" },
    fmt([[{{{{ "{}"|t }}}}{}]], {
      i(1),
      i(0),
    })
  ),
  s(
    { trig = "js", name = "include js url" },
    fmt([[{{% js '{}' %}}{}]], {
      i(1),
      i(0),
    })
  ),

  s(
    { trig = "svg", name = "render svg element" },
    fmt([[{{{{ svg('@webroot/assets/svg/{}.svg') }}}}{}]], {
      i(1),
      i(0),
    })
  ),

  s(
    { trig = "splide", name = "inserts the basic splide structure" },
    fmt(
      [[
<section class="splide {}-splide" aria-label="Basic Structure Example">
  <div class="splide__track">
    <ul class="splide__list">
      <li class="splide__slide">Slide 01</li>
    </ul>
  </div>
</section>
    ]],
      {
        i(1),
      }
    )
  ),
  s(
    { trig = "s", name = "add a section with proper a11y" },
    fmt(
      [[
        <section class="{}" aria-labelledby="{}-title">
          {}
        </section>
      ]],
      {
        i(1),
        i(1),
        i(1),
      }
    )
  ),
})

ls.add_snippets("scss", {
  s({ trig = "black", name = "inserts the v.$c-black color" }, fmt([[v.$c-black]], {})),
  s({ trig = "white", name = "inserts the v.$c-white color" }, fmt([[v.$c-white]], {})),
  s({ trig = "primary", name = "inserts the v.$c-primary color" }, fmt([[v.$c-primary]], {})),
  s(
    { trig = "t1", name = "inserts a t1 font template" },
    fmt([[@include v.t1();{}]], {
      i(0),
    })
  ),
  s(
    { trig = "t2", name = "inserts a t2 font template" },
    fmt([[@include v.t2();{}]], {
      i(0),
    })
  ),
  s(
    { trig = "h1", name = "inserts a h1 font template" },
    fmt([[@include v.h1();{}]], {
      i(0),
    })
  ),
  s(
    { trig = "h2", name = "inserts a h2 font template" },
    fmt([[@include v.h2();{}]], {
      i(0),
    })
  ),
  s(
    { trig = "h3", name = "inserts a h3 font template" },
    fmt([[@include v.h3();{}]], {
      i(0),
    })
  ),
  s(
    { trig = "h4", name = "inserts a h4 font template" },
    fmt([[@include v.h4();{}]], {
      i(0),
    })
  ),
  s(
    { trig = "h5", name = "inserts a h5 font template" },
    fmt([[@include v.h5();{}]], {
      i(0),
    })
  ),
  s(
    { trig = "b1", name = "inserts a b1 font template" },
    fmt([[@include v.b1();{}]], {
      i(0),
    })
  ),
  s(
    { trig = "b2", name = "inserts a b2 font template" },
    fmt([[@include v.b2();{}]], {
      i(0),
    })
  ),
  s(
    { trig = "d", name = "inserts a d font template" },
    fmt([[@include v.d();{}]], {
      i(0),
    })
  ),
  s(
    { trig = "trans", name = "inserts a tranisition helper function" },
    fmt([[@include u.transition();{}]], {
      i(0),
    })
  ),
  s(
    { trig = "remm", name = "inserts a - rem function" },
    fmt([[u.remm({}){}]], {
      i(1),
      i(0),
    })
  ),
  s(
    { trig = "rem", name = "inserts a rem function" },
    fmt([[u.rem({}){}]], {
      i(1),
      i(0),
    })
  ),

  s(
    { trig = "grtc", name = "grid template columns" },
    fmt([[grid-template-columns: {};{}]], {
      i(1),
      i(0),
    })
  ),

  s(
    { trig = "vu", name = "inserts @use for variables and utils" },
    fmt(
      [[@use '../variables' as v;
@use '../utils' as u;]],
      {}
    )
  ),

  s(
    { trig = "mqm", name = "inserts a media query" },
    fmt(
      [[@include u.min-media(v.${}) {{ 
  {}
}}]],
      {
        i(1),
        i(0),
      }
    )
  ),

  s(
    { trig = "mq", name = "inserts a media query" },
    fmt(
      [[@include u.media(v.${}) {{ 
  {}
}}]],
      {
        i(1),
        i(0),
      }
    )
  ),

  s(
    { trig = "cl", name = "inserts a clamp-builder function" },
    fmt([[u.clamp-builder({}, {}){}]], {
      i(1),
      i(2),
      i(0),
    })
  ),

  s(
    { trig = "clampb", name = "inserts a clamp-builder function" },
    fmt([[u.clamp-builder({}, {}){}]], {
      i(1),
      i(2),
      i(0),
    })
  ),

  s(
    { trig = "clamp", name = "inserts a clamp-builder function" },
    fmt([[u.clamp-builder({}, {}){}]], {
      i(1),
      i(2),
      i(0),
    })
  ),

  s(
    { trig = "dfcc", name = "display flex column text center" },
    fmt(
      [[
        display: flex;
        flex-direction: column;
        align-items: center;
        text-align: center;
      ]],
      {}
    )
  ),
  s({ trig = "dfr", name = "display in row" }, {

    t("display: flex;"),
    t({ "", "align-items: center;" }),
    t({ "", "gap: " }),
    i(1),
    t(";"),
  }),
  s({ trig = "gapr", name = "gap with u.rem()" }, fmt([[gap: u.rem({});{}]], { i(1), i(0) })),
  s(
    { trig = "dg", name = "display grid" },
    fmt(
      [[display: grid;
grid-template-columns: {};{}]],
      { i(1), i(0) }
    )
  ),
})

ls.add_snippets("scss", {
  s(
    { trig = "dfc", name = "display flex center" },
    fmt(
      [[display: flex;
flex-direction: column;
gap: u.rem({});{}]],
      {
        i(1),
        i(0),
      }
    )
  ),
})

-- ls.add_snippets("scss", {
--   s("pt", {
--     t("padding-inline: "),
--     i(1),
--     t(";"),
--   }),
-- })
-- ls.add_snippets("scss", {
--   s("px", {
--     t("padding-inline: "),
--     i(1),
--     t(";"),
--   }),
-- })
-- ls.add_snippets("scss", {
--   s("py", {
--     t("padding-block: "),
--     i(1),
--     t(";"),
--   }),
-- })

ls.add_snippets("scss", {

  -- PADDING (logical) ---------------------------------------------------

  s("p", {
    t("padding: "),
    i(1),
    t(";"),
    i(0),
  }),

  s("pt", {
    t("padding-block-start: "),
    i(1),
    t(";"),
    i(0),
  }),

  s("pb", {
    t("padding-block-end: "),
    i(1),
    t(";"),
    i(0),
  }),

  s("pl", {
    t("padding-inline-start: "),
    i(1),
    t(";"),
    i(0),
  }),

  s("pr", {
    t("padding-inline-end: "),
    i(1),
    t(";"),
    i(0),
  }),

  -- one single px = inline shorthand
  s("px", {
    t("padding-inline: "),
    i(1),
    t(";"),
    i(0),
  }),

  -- one single py = block shorthand
  s("py", {
    t("padding-block: "),
    i(1),
    t(";"),
    i(0),
  }),

  -- MARGIN (logical) ----------------------------------------------------

  s("m", {
    t("margin: "),
    i(1),
    t(";"),
    i(0),
  }),

  s("mt", {
    t("margin-block-start: "),
    i(1),
    t(";"),
    i(0),
  }),

  s("mb", {
    t("margin-block-end: "),
    i(1),
    t(";"),
    i(0),
  }),

  s("ml", {
    t("margin-inline-start: "),
    i(1),
    t(";"),
    i(0),
  }),

  s("mr", {
    t("margin-inline-end: "),
    i(1),
    t(";"),
    i(0),
  }),

  -- one single mx = inline shorthand
  s("mx", {
    t("margin-inline: "),
    i(1),
    t(";"),
    i(0),
  }),

  -- one single my = block shorthand
  s("my", {
    t("margin-block: "),
    i(1),
    t(";"),
    i(0),
  }),
})

return {
  "L3MON4D3/LuaSnip",
  opts = {},
}
