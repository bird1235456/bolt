open Core
open Print_typed_ast

let%expect_test "Class definition with no methods" =
  print_typed_ast
    " 
    class Foo {
      capability linear Bar;
      var int f : Bar;
    }
    void main(){
      let x = new Foo()
    }
  " ;
  [%expect
    {|
    Program
    └──Class: Foo
       └──Capabilities:
          └──Capability: Linear Bar
       └──Field Defn: f
          └──Modifier: Var
          └──Type expr: Int
          └──Capabilities: Bar
    └──Main block
       └──Type expr: Foo
       └──Expr: Let var: x
          └──Type expr: Foo
          └──Expr: Constructor for: Foo
             └──Type expr: Foo |}]

let%expect_test "Class definition with methods" =
  print_typed_ast
    " 
    class Foo {
      capability linear Bar;
      var int f : Bar;
      int set_f (int x) :Bar {
        this.f:=x
      }
    }
    void main(){
      let x = new Foo()
    }
  " ;
  [%expect
    {|
      Program
      └──Class: Foo
         └──Capabilities:
            └──Capability: Linear Bar
         └──Field Defn: f
            └──Modifier: Var
            └──Type expr: Int
            └──Capabilities: Bar
         └── Method: set_f
            └── Return type: Int
            └──Param: x
               └──Type expr: Int
            └── Used capabilities
            └──   Capabilities: Bar
            └──Body block
               └──Type expr: Int
               └──Expr: Assign
                  └──Type expr: Int
                  └──Expr: Objfield: (Class: Foo) this.f
                     └──Type expr: Int
                  └──Expr: Variable: x
                     └──Type expr: Int
      └──Main block
         └──Type expr: Foo
         └──Expr: Let var: x
            └──Type expr: Foo
            └──Expr: Constructor for: Foo
               └──Type expr: Foo |}]

let%expect_test "Class definition with methods call toplevel function" =
  print_typed_ast
    " 
    class Foo {
      capability linear Bar;
      var int f : Bar;

      int get_f () : Bar {
        id( this.f )
      }
    }
    function int id (int x){
        x
    }
    void main(){
      let x = new Foo();
      x.get_f()
    }
  " ;
  [%expect
    {|
      Program
      └──Class: Foo
         └──Capabilities:
            └──Capability: Linear Bar
         └──Field Defn: f
            └──Modifier: Var
            └──Type expr: Int
            └──Capabilities: Bar
         └── Method: get_f
            └── Return type: Int
            └──Param: Void
            └── Used capabilities
            └──   Capabilities: Bar
            └──Body block
               └──Type expr: Int
               └──Expr: Function App
                  └──Type expr: Int
                  └──Function: id
                  └──Expr: Objfield: (Class: Foo) this.f
                     └──Type expr: Int
      └── Function: id
         └── Return type: Int
         └──Param: x
            └──Type expr: Int
         └──Body block
            └──Type expr: Int
            └──Expr: Variable: x
               └──Type expr: Int
      └──Main block
         └──Type expr: Int
         └──Expr: Let var: x
            └──Type expr: Foo
            └──Expr: Constructor for: Foo
               └──Type expr: Foo
         └──Expr: ObjMethod: (Class: Foo) x.get_f
            └──Type expr: Int
            └──() |}]

let%expect_test "Class definition with methods returning void" =
  print_typed_ast
    " 
    class Foo {
      capability linear Bar;
      var int f : Bar;

      void get_f () : Bar {
        id( this.f ) // throw away value 
      }
    }
    function int id (int x){
        x
    }
    void main(){
      let x = new Foo();
      x.get_f()
    }
  " ;
  [%expect
    {|
      Program
      └──Class: Foo
         └──Capabilities:
            └──Capability: Linear Bar
         └──Field Defn: f
            └──Modifier: Var
            └──Type expr: Int
            └──Capabilities: Bar
         └── Method: get_f
            └── Return type: Void
            └──Param: Void
            └── Used capabilities
            └──   Capabilities: Bar
            └──Body block
               └──Type expr: Int
               └──Expr: Function App
                  └──Type expr: Int
                  └──Function: id
                  └──Expr: Objfield: (Class: Foo) this.f
                     └──Type expr: Int
      └── Function: id
         └── Return type: Int
         └──Param: x
            └──Type expr: Int
         └──Body block
            └──Type expr: Int
            └──Expr: Variable: x
               └──Type expr: Int
      └──Main block
         └──Type expr: Void
         └──Expr: Let var: x
            └──Type expr: Foo
            └──Expr: Constructor for: Foo
               └──Type expr: Foo
         └──Expr: ObjMethod: (Class: Foo) x.get_f
            └──Type expr: Void
            └──() |}]
