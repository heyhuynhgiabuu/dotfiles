local ok, ls = pcall(require, "luasnip")
if not ok then
    return
end

local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local fmt = require("luasnip.extras.fmt").fmt

-- Enhanced Go snippets
ls.add_snippets("go", {
    -- Error handling snippets
    s("ifer", fmt([[
        if err != nil {{
            log.Error("{}")
        }}
        {}
    ]], { i(1, "error message"), i(0) })),
    
    s("iferr", fmt([[
        if err != nil {{
            log.Error("{}")
            return err
        }}
        {}
    ]], { i(1, "error message"), i(0) })),
    
    s("iferw", fmt([[
        if err != nil {{
            return fmt.Errorf("{}: %w", err)
        }}
        {}
    ]], { i(1, "operation failed"), i(0) })),
    
    -- Function and method snippets
    s("func", fmt([[
        func {}({}) {} {{
            {}
        }}
    ]], { i(1, "name"), i(2, "params"), i(3, "returnType"), i(0) })),
    
    s("method", fmt([[
        func ({} *{}) {}({}) {} {{
            {}
        }}
    ]], { i(1, "receiver"), i(2, "Type"), i(3, "name"), i(4, "params"), i(5, "returnType"), i(0) })),
    
    -- Main function
    s("mainf", fmt([[
        package main

        import (
            "fmt"
        )

        func main() {{
            {}
        }}
    ]], { i(0) })),
    
    -- Test snippets
    s("test", fmt([[
        func Test{}(t *testing.T) {{
            {}
        }}
    ]], { i(1, "Name"), i(0) })),
    
    s("testt", fmt([[
        func Test{}(t *testing.T) {{
            tests := []struct {{
                name string
                {}
                want {}
            }}{{
                {{
                    name: "{}",
                    {},
                }},
            }}
            
            for _, tt := range tests {{
                t.Run(tt.name, func(t *testing.T) {{
                    if got := {}; got != tt.want {{
                        t.Errorf("{}() = %v, want %v", got, tt.want)
                    }}
                }})
            }}
        }}
    ]], { 
        i(1, "Name"), i(2, "input"), i(3, "type"), 
        i(4, "test case"), i(5, "input"), 
        i(6, "functionCall"), i(7, "functionName") 
    })),
    
    -- Struct snippets
    s("struct", fmt([[
        type {} struct {{
            {}
        }}
    ]], { i(1, "Name"), i(0) })),
    
    s("interface", fmt([[
        type {} interface {{
            {}
        }}
    ]], { i(1, "Name"), i(0) })),
    
    -- HTTP and JSON snippets
    s("httphandler", fmt([[
        func {}(w http.ResponseWriter, r *http.Request) {{
            {}
        }}
    ]], { i(1, "handlerName"), i(0) })),
    
    s("jsonmarshal", fmt([[
        data, err := json.Marshal({})
        if err != nil {{
            return fmt.Errorf("failed to marshal {}: %w", err)
        }}
        {}
    ]], { i(1, "object"), i(2, "object"), i(0) })),
})

-- Enhanced Java snippets
ls.add_snippets("java", {
    -- Class and method snippets
    s("class", fmt([[
        public class {} {{
            {}
        }}
    ]], { i(1, "ClassName"), i(0) })),
    
    s("interface", fmt([[
        public interface {} {{
            {}
        }}
    ]], { i(1, "InterfaceName"), i(0) })),
    
    s("method", fmt([[
        public {} {}({}) {{
            {}
        }}
    ]], { i(1, "returnType"), i(2, "methodName"), i(3, "parameters"), i(0) })),
    
    s("main", fmt([[
        public static void main(String[] args) {{
            {}
        }}
    ]], { i(0) })),
    
    -- Constructor snippets
    s("constructor", fmt([[
        public {}({}) {{
            {}
        }}
    ]], { i(1, "ClassName"), i(2, "parameters"), i(0) })),
    
    -- Exception handling
    s("try", fmt([[
        try {{
            {}
        }} catch ({} e) {{
            {}
        }}
    ]], { i(1, "code"), i(2, "Exception"), i(0) })),
    
    s("tryf", fmt([[
        try {{
            {}
        }} catch ({} e) {{
            {}
        }} finally {{
            {}
        }}
    ]], { i(1, "code"), i(2, "Exception"), i(3, "catch"), i(0) })),
    
    -- Test snippets (JUnit)
    s("test", fmt([[
        @Test
        public void test{}() {{
            {}
        }}
    ]], { i(1, "Name"), i(0) })),
    
    s("testassert", fmt([[
        @Test
        public void test{}() {{
            // Given
            {}
            
            // When
            {} result = {};
            
            // Then
            assertEquals({}, result);
        }}
    ]], { i(1, "Name"), i(2, "setup"), i(3, "type"), i(4, "methodCall"), i(5, "expected") })),
    
    s("before", fmt([[
        @Before
        public void setUp() {{
            {}
        }}
    ]], { i(0) })),
    
    s("after", fmt([[
        @After
        public void tearDown() {{
            {}
        }}
    ]], { i(0) })),
    
    -- Spring Boot snippets
    s("controller", fmt([[
        @RestController
        @RequestMapping("{}")
        public class {} {{
            {}
        }}
    ]], { i(1, "/api"), i(2, "Controller"), i(0) })),
    
    s("service", fmt([[
        @Service
        public class {} {{
            {}
        }}
    ]], { i(1, "Service"), i(0) })),
    
    s("repository", fmt([[
        @Repository
        public interface {} extends JpaRepository<{}, {}> {{
            {}
        }}
    ]], { i(1, "Repository"), i(2, "Entity"), i(3, "Id"), i(0) })),
    
    s("getmapping", fmt([[
        @GetMapping("{}")
        public ResponseEntity<{}> {}() {{
            {}
            return ResponseEntity.ok({});
        }}
    ]], { i(1, "/path"), i(2, "Type"), i(3, "methodName"), i(4, "body"), i(5, "result") })),
    
    s("postmapping", fmt([[
        @PostMapping("{}")
        public ResponseEntity<{}> {}(@RequestBody {} {}) {{
            {}
            return ResponseEntity.ok({});
        }}
    ]], { i(1, "/path"), i(2, "Type"), i(3, "methodName"), i(4, "RequestType"), i(5, "request"), i(6, "body"), i(7, "result") })),
    
    -- Logger snippet
    s("logger", fmt([[
        private static final Logger logger = LoggerFactory.getLogger({}.class);
        {}
    ]], { i(1, "ClassName"), i(0) })),
    
    -- Getter/Setter
    s("getter", fmt([[
        public {} get{}() {{
            return {};
        }}
    ]], { i(1, "type"), i(2, "PropertyName"), i(3, "property") })),
    
    s("setter", fmt([[
        public void set{}({} {}) {{
            this.{} = {};
        }}
    ]], { i(1, "PropertyName"), i(2, "type"), i(3, "property"), i(4, "property"), i(5, "property") })),
})

-- Load VSCode-style snippets
require("luasnip.loaders.from_vscode").lazy_load()
