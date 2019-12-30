open Core
open Run_program

let get_file_extension filename =
  String.split_on_chars filename ~on:['.'] |> List.last |> Option.value ~default:""

let bolt_file =
  let error_not_file filename =
    eprintf "'%s' is not a bolt file. Hint: use the .bolt extension\n%!" filename ;
    exit 1 in
  Command.Spec.Arg_type.create (fun filename ->
      match Sys.is_file filename with
      | `Yes           ->
          if get_file_extension filename = "bolt" then filename
          else error_not_file filename
      | `No | `Unknown -> error_not_file filename)

let command =
  Command.basic ~summary:"Run bolt programs"
    ~readme:(fun () -> "A list of execution options")
    Command.Let_syntax.(
      let%map_open should_pprint_past =
        flag "-print-parsed-ast" no_arg ~doc:" Pretty print the parsed AST of the program"
      and should_pprint_tast =
        flag "-print-typed-ast" no_arg ~doc:" Pretty print the typed AST of the program"
      and _check_data_races =
        flag "-check-data-races" no_arg ~doc:"Check programs for potential data-races"
      and print_execution =
        flag "-print-execution" no_arg
          ~doc:"Print each step of the interpreter's execution"
      and filename = anon (maybe_with_default "-" ("filename" %: bolt_file)) in
      fun () ->
        In_channel.with_file filename ~f:(fun file_ic ->
            let lexbuf =
              Lexing.from_channel file_ic
              (*Create a lex buffer from the file to read in tokens *) in
            run_program lexbuf ~should_pprint_past ~should_pprint_tast ~print_execution))

let () = Command.run ~version:"1.0" ~build_info:"RWO" command
