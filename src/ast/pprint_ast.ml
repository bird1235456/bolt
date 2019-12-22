open Ast_types

let indent_space = "   "

let pprint_capability ppf ~indent cap =
  Fmt.pf ppf "%sCap: %s@." indent (string_of_cap cap)

let pprint_mode ppf ~indent mode = Fmt.pf ppf "%sMode: %s@." indent (string_of_mode mode)

let pprint_cap_trait ppf ~indent (TCapTrait (cap, trait_name)) =
  Fmt.pf ppf "%sCapTrait: %s@." indent (Trait_name.to_string trait_name) ;
  let new_indent = indent_space ^ indent in
  pprint_capability ppf ~indent:new_indent cap

let pprint_type_field ppf ~indent tfield =
  let string_of_tfield = match tfield with TFieldInt -> "Int" | TFieldBool -> "Bool" in
  Fmt.pf ppf "%sTField: %s@." indent string_of_tfield

let pprint_field_defn ppf ~indent (TField (mode, field_name, type_field)) =
  Fmt.pf ppf "%sField Defn: %s@." indent (Field_name.to_string field_name) ;
  let new_indent = indent_space ^ indent in
  pprint_mode ppf ~indent:new_indent mode ;
  pprint_type_field ppf ~indent:new_indent type_field

let pprint_require_field_defn ppf ~indent (TRequire field_defn) =
  Fmt.pf ppf "%sRequire@." indent ;
  let new_indent = indent_space ^ indent in
  pprint_field_defn ppf ~indent:new_indent field_defn

let pprint_type_expr ppf ~indent type_expr =
  Fmt.pf ppf "%sType expr: %s@." indent (string_of_type type_expr)

let pprint_trait_defn ppf ~indent (TTrait (trait_name, cap, req_field_defns)) =
  Fmt.pf ppf "%sTrait: %s@." indent (Trait_name.to_string trait_name) ;
  let new_indent = indent_space ^ indent in
  pprint_capability ppf ~indent:new_indent cap ;
  List.iter (pprint_require_field_defn ppf ~indent:new_indent) req_field_defns

let pprint_param ppf ~indent = function
  | TParam (type_expr, param_name) ->
      Fmt.pf ppf "%sParam: %s@." indent (Var_name.to_string param_name) ;
      let new_indent = indent_space ^ indent in
      pprint_type_expr ppf ~indent:new_indent type_expr
  | TVoid -> Fmt.pf ppf "%sParam: %s@." indent (string_of_type TEUnit)
