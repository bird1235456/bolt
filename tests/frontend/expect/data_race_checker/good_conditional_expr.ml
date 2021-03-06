open Core
open Print_data_race_checker_ast

let%expect_test "Good if statement" =
  print_data_race_checker_ast
    " 
   void main(){
     let x = true;
     if x {
       0
     }
     else {
       1
     }
   }
  " ;
  [%expect
    {|
      Program
      └──Main block
         └──Type expr: Int
         └──Expr: Let var: _x0
            └──Type expr: Bool
            └──Expr: Bool:true
         └──Expr: If
            └──Type expr: Int
            └──Expr: Variable: _x0
               └──Type expr: Bool
            └──Then block
               └──Type expr: Int
               └──Expr: Int:0
            └──Else block
               └──Type expr: Int
               └──Expr: Int:1 |}]

let%expect_test "Good while loop" =
  print_data_race_checker_ast
    " 
  void main(){
   while (1 < 2){
     let x = 5
   }
  }
  " ;
  [%expect
    {|
      Program
      └──Main block
         └──Type expr: Void
         └──Expr: While
            └──Type expr: Void
            └──Expr: Bin Op: <
               └──Type expr: Bool
               └──Expr: Int:1
               └──Expr: Int:2
            └──Body block
               └──Type expr: Int
               └──Expr: Let var: _x0
                  └──Type expr: Int
                  └──Expr: Int:5 |}]

let%expect_test "Good for loop" =
  print_data_race_checker_ast
    " 
  void main(){
    for (let i=0; i < (5*5); i:= i+1) {
      i
    }
   }
  " ;
  [%expect
    {|
      Program
      └──Main block
         └──Type expr: Void
            └──Expr: Let var: _i0
               └──Type expr: Int
               └──Expr: Int:0
            └──Expr: While
               └──Type expr: Void
               └──Expr: Bin Op: <
                  └──Type expr: Bool
                  └──Expr: Variable: _i0
                     └──Type expr: Int
                  └──Expr: Bin Op: *
                     └──Type expr: Int
                     └──Expr: Int:5
                     └──Expr: Int:5
               └──Body block
                  └──Type expr: Int
                  └──Expr: Variable: _i0
                     └──Type expr: Int
                  └──Expr: Assign
                     └──Type expr: Int
                     └──Expr: Variable: _i0
                        └──Type expr: Int
                     └──Expr: Bin Op: +
                        └──Type expr: Int
                        └──Expr: Variable: _i0
                           └──Type expr: Int
                        └──Expr: Int:1 |}]
