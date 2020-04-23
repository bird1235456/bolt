open Desugar_expr
open Core

let desugar_function_defn class_defns
    (Typing.Typed_ast.TFunction
      (func_name, maybe_borrowed_ref_ret, ret_type, params, body_expr)) =
  desugar_block_expr class_defns body_expr
  |> fun desugared_body_expr ->
  Desugared_ast.TFunction
    (func_name, maybe_borrowed_ref_ret, ret_type, params, desugared_body_expr)

let desugar_method_defn class_defns
    (Typing.Typed_ast.TMethod
      (method_name, maybe_borrowed_ref_ret, ret_type, params, capabilities_used, body_expr))
    =
  desugar_block_expr class_defns body_expr
  |> fun desugared_body_expr ->
  Desugared_ast.TMethod
    ( method_name
    , maybe_borrowed_ref_ret
    , ret_type
    , params
    , capabilities_used
    , desugared_body_expr )

let desugar_class_defn class_defns
    (Typing.Typed_ast.TClass (class_name, capabilities, fields, method_defns)) =
  List.map ~f:(desugar_method_defn class_defns) method_defns
  |> fun desugared_method_defns ->
  Desugared_ast.TClass (class_name, capabilities, fields, desugared_method_defns)
