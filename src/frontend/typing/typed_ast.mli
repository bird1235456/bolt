(** The typed AST consists of the original AST but augmented with type information. *)

open Ast.Ast_types

type identifier =
  | Variable of type_expr * Var_name.t
  | ObjField of Class_name.t * type_expr option * Var_name.t * type_expr * Field_name.t
      (** class of the object and whether parameterised, type of field *)

val string_of_id : identifier -> string

(** Similar to Parsed AST, only we add an extra type_expr annotation to denote the overall
    type of the expression. For loop is desugared to while loop *)
type expr =
  | Integer     of loc * int  (** no need for type_expr annotation as obviously TEInt *)
  | Boolean     of loc * bool  (** no need for type_expr annotation as obviously TEBool *)
  | Identifier  of loc * identifier  (** Type information associated with identifier *)
  | BlockExpr   of loc * block_expr  (** used to interconvert with block expr *)
  | Constructor of loc * Class_name.t * type_expr option * constructor_arg list
      (** The type of the object created can be inferred from class name and any type
          param *)
  | Let         of loc * type_expr * Var_name.t * expr
  | Assign      of loc * type_expr * identifier * expr
  | Consume     of loc * identifier  (** Type is associated with the identifier *)
  | MethodApp   of
      loc
      * type_expr
      * type_expr list
      * Var_name.t
      * Class_name.t
      * type_expr option
      * Method_name.t
      * expr list
  | FunctionApp of loc * type_expr * type_expr list * Function_name.t * expr list
  | Printf      of loc * string * expr list
      (** no need for type_expr annotation as obviously TEVoid *)
  | FinishAsync of loc * type_expr * async_expr list * block_expr
      (** overall type is that of the expr on the current thread - since forked exprs'
          values are ignored *)
  | If          of loc * type_expr * expr * block_expr * block_expr
      (** If ___ then ___ else ___ - type is that of the branch exprs *)
  | While       of loc * expr * block_expr
      (** While ___ do ___ ; - no need for type_expr annotation as type of a loop is
          TEVoid *)
  | BinOp       of loc * type_expr * bin_op * expr * expr
  | UnOp        of loc * type_expr * un_op * expr

and block_expr =
  | Block of loc * type_expr * expr list  (** type is of the final expr in block *)

and async_expr = AsyncExpr of block_expr

(** Constructor arg consists of a field and the expression being assigned to it (annotated
    with the type of the expression) *)
and constructor_arg = ConstructorArg of type_expr * Field_name.t * expr

(** Function defn consists of the function name, return type (and whether it returns a
    borrowed ref), the list of params, and the body expr of the function *)
type function_defn =
  | TFunction of
      Function_name.t * borrowed_ref option * type_expr * param list * block_expr

(** Method defn consists the method name, return type (and whether it returns a borrowed
    ref), the list of params, the capabilities used and the body expr of the function *)
type method_defn =
  | TMethod of
      Method_name.t
      * borrowed_ref option
      * type_expr
      * param list
      * capability list
      * block_expr

(** Class definitions consist of the class name and optionally specifying if generic and
    if it inherits from another class, its capabilities and the fields and methods in the
    class *)
type class_defn =
  | TClass of
      Class_name.t
      * generic_type option
      * Class_name.t option
      * capability list
      * field_defn list
      * method_defn list

(** Each bolt program defines the classes,followed by functions, followed by the main
    expression to execute. *)
type program = Prog of class_defn list * function_defn list * block_expr
