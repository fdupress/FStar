module IfcExample

open Rel
open WhileLanguage
open Ifc
open FStar.Heap


let x = ST.alloc 0
let y = ST.alloc 1
let z = ST.alloc 2
let c = ST. alloc 200

(* TODO F* does not infer that these refs are distinct *)

let env var = 
  if addr_of var = addr_of x then Low
  else if addr_of var = addr_of y then Low 
    else if addr_of var = addr_of c then Low
      else if addr_of var = addr_of z then High
        else High

let c1_0 body = While (AVar c) body (AVar c)
let c1_1 = Assign x (AVar y)
let c1_2 = Assign y (AOp Plus (AVar x) (AInt 6))
let c1_3 = Assign z (AOp Plus (AVar y) (AInt 7))
let c1_4 = Assign x (AOp Plus (AVar z) (AInt 7))
let c1_5 = Assign c (AOp Minus (AVar c) (AInt 1))
let c1_6 = Seq c1_1 (Seq c1_2 (Seq c1_3 (Seq c1_4 c1_5)))

let c1 = c1_0 c1_6

val c1_1_ni : unit -> Lemma (ni_com env c1_1 Low)
let c1_1_ni _ = ()

val c1_2_ni : unit -> Lemma (ni_com env c1_2 Low)
let c1_2_ni _ = ()

val c1_3_ni : unit -> Lemma (ni_com env c1_3 Low)
let c1_3_ni _ = ()

val c1_3_4_ni : unit -> Lemma (ni_com env (Seq c1_3 c1_4) Low)
let c1_3_4_ni _ = ()

val c1_ni : unit -> Lemma (ni_com env c1 Low)
let c1_ni _ = loop_com env (AVar c) c1_6 (AVar c) Low
