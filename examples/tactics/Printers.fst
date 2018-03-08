module Printers

open FStar.Tactics
module TD = FStar.Tactics.Derived

#set-options "--use_two_phase_tc false"

let print_Prims_string : string -> Tot string = fun s -> "\"" ^ s ^ "\""
let print_Prims_int : int -> Tot string = string_of_int

let rec mk_concat (sep : term) (ts : list term) : term =
    mk_e_app (pack (Tv_FVar (pack_fv ["FStar"; "String"; "concat"]))) [sep; mk_list ts]

let mk_flatten = mk_concat (pack (Tv_Const (C_String "")))

let paren (e : term) : term =
    mk_flatten [mk_stringlit "("; e; mk_stringlit ")"]

let mk_print_binder (b : binder) : Tac term =
    let mk n = pack (Tv_FVar (pack_fv n)) in
    match inspect (type_of_binder b) with
    | Tv_FVar fv ->
        let f = mk ["Printers"; "print_" ^ (String.concat "_" (inspect_fv fv))] in
        mk_e_app f [pack (Tv_Var b)]
    | _ ->
        mk_stringlit "?"

let printer () : Tac unit =
    admit ();
    let x = intro () in
    let e = cur_env () in
    let xt = type_of_binder x in
    let xt_ns = match inspect xt with
                | Tv_FVar fv -> (inspect_fv fv)
                | _ -> fail "not a qname type?"
    in
    match lookup_typ e xt_ns with
    | Sg_Let _ _ _ -> fail "cannot create printer for let"
    | Sg_Inductive _ bs t ctors ->
        let br1 ctor : Tac branch = match ctor with | Ctor name t ->
            let pn = String.concat "." name in
            let t_args, _ = collect_arr t in
            let bv_pats = TD.map (fun ti -> let b = fresh_binder ti in (b, Pat_Var b)) t_args in
            let bvs, pats = List.Tot.split bv_pats in
            let head = pack (Tv_Const (C_String pn)) in
            let bod = mk_concat (mk_stringlit " ") (head :: TD.map mk_print_binder bvs) in
            let bod = match t_args with | [] -> bod | _ -> paren bod in
            (Pat_Cons (pack_fv name) pats, bod)
        in
        let branches = TD.map br1 ctors in
        let m = pack (Tv_Match (pack (Tv_Var x)) branches) in
        exact_guard m;
        smt ()
    | _ -> fail "type not found?"

type t1 =
    | A : int -> int -> t1
    | B : string -> t1
    | C : t1

let t1_print : t1 -> string = synth_by_tactic printer

let _ = assert_norm (t1_print (A 5 8) = "(Printers.A 5 8)")
let _ = assert_norm (t1_print (B "thing") = "(Printers.B \"thing\")")
let _ = assert_norm (t1_print C = "Printers.C")
