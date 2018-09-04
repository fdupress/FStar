open Prims
type goal = FStar_Tactics_Types.goal
type name = FStar_Syntax_Syntax.bv
type env = FStar_TypeChecker_Env.env
type implicits = FStar_TypeChecker_Env.implicits
let (normalize :
  FStar_TypeChecker_Env.steps ->
    FStar_TypeChecker_Env.env ->
      FStar_Syntax_Syntax.term -> FStar_Syntax_Syntax.term)
  =
  fun s  ->
    fun e  ->
      fun t  ->
        FStar_TypeChecker_Normalize.normalize_with_primitive_steps
          FStar_Reflection_Interpreter.reflection_primops s e t
  
let (bnorm :
  FStar_TypeChecker_Env.env ->
    FStar_Syntax_Syntax.term -> FStar_Syntax_Syntax.term)
  = fun e  -> fun t  -> normalize [] e t 
let (tts :
  FStar_TypeChecker_Env.env -> FStar_Syntax_Syntax.term -> Prims.string) =
  FStar_TypeChecker_Normalize.term_to_string 
let (bnorm_goal : FStar_Tactics_Types.goal -> FStar_Tactics_Types.goal) =
  fun g  ->
    let uu____39 =
      let uu____40 = FStar_Tactics_Types.goal_env g  in
      let uu____41 = FStar_Tactics_Types.goal_type g  in
      bnorm uu____40 uu____41  in
    FStar_Tactics_Types.goal_with_type g uu____39
  
type 'a tac =
  {
  tac_f: FStar_Tactics_Types.proofstate -> 'a FStar_Tactics_Result.__result }
let __proj__Mktac__item__tac_f :
  'a .
    'a tac ->
      FStar_Tactics_Types.proofstate -> 'a FStar_Tactics_Result.__result
  =
  fun projectee  ->
    match projectee with | { tac_f = __fname__tac_f;_} -> __fname__tac_f
  
let mk_tac :
  'a .
    (FStar_Tactics_Types.proofstate -> 'a FStar_Tactics_Result.__result) ->
      'a tac
  = fun f  -> { tac_f = f } 
let run :
  'a .
    'a tac ->
      FStar_Tactics_Types.proofstate -> 'a FStar_Tactics_Result.__result
  = fun t  -> fun p  -> t.tac_f p 
let run_safe :
  'a .
    'a tac ->
      FStar_Tactics_Types.proofstate -> 'a FStar_Tactics_Result.__result
  =
  fun t  ->
    fun p  ->
      let uu____151 = FStar_Options.tactics_failhard ()  in
      if uu____151
      then run t p
      else
        (try (fun uu___359_158  -> match () with | () -> run t p) ()
         with
         | FStar_Errors.Err (uu____167,msg) ->
             FStar_Tactics_Result.Failed (msg, p)
         | FStar_Errors.Error (uu____169,msg,uu____171) ->
             FStar_Tactics_Result.Failed (msg, p)
         | e ->
             let uu____173 =
               let uu____178 = FStar_Util.message_of_exn e  in (uu____178, p)
                in
             FStar_Tactics_Result.Failed uu____173)
  
let rec (log : FStar_Tactics_Types.proofstate -> (unit -> unit) -> unit) =
  fun ps  ->
    fun f  -> if ps.FStar_Tactics_Types.tac_verb_dbg then f () else ()
  
let ret : 'a . 'a -> 'a tac =
  fun x  -> mk_tac (fun p  -> FStar_Tactics_Result.Success (x, p)) 
let bind : 'a 'b . 'a tac -> ('a -> 'b tac) -> 'b tac =
  fun t1  ->
    fun t2  ->
      mk_tac
        (fun p  ->
           let uu____250 = run t1 p  in
           match uu____250 with
           | FStar_Tactics_Result.Success (a,q) ->
               let uu____257 = t2 a  in run uu____257 q
           | FStar_Tactics_Result.Failed (msg,q) ->
               FStar_Tactics_Result.Failed (msg, q))
  
let (get : FStar_Tactics_Types.proofstate tac) =
  mk_tac (fun p  -> FStar_Tactics_Result.Success (p, p)) 
let (idtac : unit tac) = ret () 
let (get_uvar_solved :
  FStar_Syntax_Syntax.ctx_uvar ->
    FStar_Syntax_Syntax.term FStar_Pervasives_Native.option)
  =
  fun uv  ->
    let uu____277 =
      FStar_Syntax_Unionfind.find uv.FStar_Syntax_Syntax.ctx_uvar_head  in
    match uu____277 with
    | FStar_Pervasives_Native.Some t -> FStar_Pervasives_Native.Some t
    | FStar_Pervasives_Native.None  -> FStar_Pervasives_Native.None
  
let (check_goal_solved :
  FStar_Tactics_Types.goal ->
    FStar_Syntax_Syntax.term FStar_Pervasives_Native.option)
  = fun goal  -> get_uvar_solved goal.FStar_Tactics_Types.goal_ctx_uvar 
let (goal_to_string_verbose : FStar_Tactics_Types.goal -> Prims.string) =
  fun g  ->
    let uu____295 =
      FStar_Syntax_Print.ctx_uvar_to_string
        g.FStar_Tactics_Types.goal_ctx_uvar
       in
    let uu____296 =
      let uu____297 = check_goal_solved g  in
      match uu____297 with
      | FStar_Pervasives_Native.None  -> ""
      | FStar_Pervasives_Native.Some t ->
          let uu____301 = FStar_Syntax_Print.term_to_string t  in
          FStar_Util.format1 "\tGOAL ALREADY SOLVED!: %s" uu____301
       in
    FStar_Util.format2 "%s%s" uu____295 uu____296
  
let (goal_to_string :
  Prims.string ->
    (Prims.int,Prims.int) FStar_Pervasives_Native.tuple2
      FStar_Pervasives_Native.option ->
      FStar_Tactics_Types.proofstate ->
        FStar_Tactics_Types.goal -> Prims.string)
  =
  fun kind  ->
    fun maybe_num  ->
      fun ps  ->
        fun g  ->
          let uu____334 =
            (FStar_Options.print_implicits ()) ||
              ps.FStar_Tactics_Types.tac_verb_dbg
             in
          if uu____334
          then goal_to_string_verbose g
          else
            (let w =
               let uu____337 =
                 get_uvar_solved g.FStar_Tactics_Types.goal_ctx_uvar  in
               match uu____337 with
               | FStar_Pervasives_Native.None  -> "_"
               | FStar_Pervasives_Native.Some t ->
                   let uu____341 = FStar_Tactics_Types.goal_env g  in
                   tts uu____341 t
                in
             let num =
               match maybe_num with
               | FStar_Pervasives_Native.None  -> ""
               | FStar_Pervasives_Native.Some (i,n1) ->
                   let uu____353 = FStar_Util.string_of_int i  in
                   let uu____354 = FStar_Util.string_of_int n1  in
                   FStar_Util.format2 " %s/%s" uu____353 uu____354
                in
             let maybe_label =
               match g.FStar_Tactics_Types.label with
               | "" -> ""
               | l -> Prims.strcat " (" (Prims.strcat l ")")  in
             let uu____357 =
               FStar_Syntax_Print.binders_to_string ", "
                 (g.FStar_Tactics_Types.goal_ctx_uvar).FStar_Syntax_Syntax.ctx_uvar_binders
                in
             let uu____358 =
               let uu____359 = FStar_Tactics_Types.goal_env g  in
               tts uu____359
                 (g.FStar_Tactics_Types.goal_ctx_uvar).FStar_Syntax_Syntax.ctx_uvar_typ
                in
             FStar_Util.format6 "%s%s%s:\n%s |- %s : %s\n\n" kind num
               maybe_label uu____357 w uu____358)
  
let (tacprint : Prims.string -> unit) =
  fun s  -> FStar_Util.print1 "TAC>> %s\n" s 
let (tacprint1 : Prims.string -> Prims.string -> unit) =
  fun s  ->
    fun x  ->
      let uu____375 = FStar_Util.format1 s x  in
      FStar_Util.print1 "TAC>> %s\n" uu____375
  
let (tacprint2 : Prims.string -> Prims.string -> Prims.string -> unit) =
  fun s  ->
    fun x  ->
      fun y  ->
        let uu____391 = FStar_Util.format2 s x y  in
        FStar_Util.print1 "TAC>> %s\n" uu____391
  
let (tacprint3 :
  Prims.string -> Prims.string -> Prims.string -> Prims.string -> unit) =
  fun s  ->
    fun x  ->
      fun y  ->
        fun z  ->
          let uu____412 = FStar_Util.format3 s x y z  in
          FStar_Util.print1 "TAC>> %s\n" uu____412
  
let (comp_to_typ : FStar_Syntax_Syntax.comp -> FStar_Reflection_Data.typ) =
  fun c  ->
    match c.FStar_Syntax_Syntax.n with
    | FStar_Syntax_Syntax.Total (t,uu____419) -> t
    | FStar_Syntax_Syntax.GTotal (t,uu____429) -> t
    | FStar_Syntax_Syntax.Comp ct -> ct.FStar_Syntax_Syntax.result_typ
  
let (get_phi :
  FStar_Tactics_Types.goal ->
    FStar_Syntax_Syntax.term FStar_Pervasives_Native.option)
  =
  fun g  ->
    let uu____448 =
      let uu____449 = FStar_Tactics_Types.goal_env g  in
      let uu____450 = FStar_Tactics_Types.goal_type g  in
      FStar_TypeChecker_Normalize.unfold_whnf uu____449 uu____450  in
    FStar_Syntax_Util.un_squash uu____448
  
let (is_irrelevant : FStar_Tactics_Types.goal -> Prims.bool) =
  fun g  -> let uu____456 = get_phi g  in FStar_Option.isSome uu____456 
let (print : Prims.string -> unit tac) = fun msg  -> tacprint msg; ret () 
let (debugging : unit -> Prims.bool tac) =
  fun uu____475  ->
    bind get
      (fun ps  ->
         let uu____481 =
           FStar_TypeChecker_Env.debug ps.FStar_Tactics_Types.main_context
             (FStar_Options.Other "Tac")
            in
         ret uu____481)
  
let (ps_to_string :
  (Prims.string,FStar_Tactics_Types.proofstate)
    FStar_Pervasives_Native.tuple2 -> Prims.string)
  =
  fun uu____490  ->
    match uu____490 with
    | (msg,ps) ->
        let p_imp imp =
          FStar_Syntax_Print.uvar_to_string
            (imp.FStar_TypeChecker_Env.imp_uvar).FStar_Syntax_Syntax.ctx_uvar_head
           in
        let n_active = FStar_List.length ps.FStar_Tactics_Types.goals  in
        let n_smt = FStar_List.length ps.FStar_Tactics_Types.smt_goals  in
        let n1 = n_active + n_smt  in
        let uu____516 =
          let uu____519 =
            let uu____522 =
              let uu____523 =
                FStar_Util.string_of_int ps.FStar_Tactics_Types.depth  in
              FStar_Util.format2 "State dump @ depth %s (%s):\n" uu____523
                msg
               in
            let uu____524 =
              let uu____527 =
                if
                  ps.FStar_Tactics_Types.entry_range <>
                    FStar_Range.dummyRange
                then
                  let uu____528 =
                    FStar_Range.string_of_def_range
                      ps.FStar_Tactics_Types.entry_range
                     in
                  FStar_Util.format1 "Location: %s\n" uu____528
                else ""  in
              let uu____530 =
                let uu____533 =
                  let uu____534 =
                    FStar_TypeChecker_Env.debug
                      ps.FStar_Tactics_Types.main_context
                      (FStar_Options.Other "Imp")
                     in
                  if uu____534
                  then
                    let uu____535 =
                      FStar_Common.string_of_list p_imp
                        ps.FStar_Tactics_Types.all_implicits
                       in
                    FStar_Util.format1 "Imps: %s\n" uu____535
                  else ""  in
                [uu____533]  in
              uu____527 :: uu____530  in
            uu____522 :: uu____524  in
          let uu____537 =
            let uu____540 =
              FStar_List.mapi
                (fun i  ->
                   fun g  ->
                     goal_to_string "Goal"
                       (FStar_Pervasives_Native.Some
                          (((Prims.parse_int "1") + i), n1)) ps g)
                ps.FStar_Tactics_Types.goals
               in
            let uu____551 =
              FStar_List.mapi
                (fun i  ->
                   fun g  ->
                     goal_to_string "SMT Goal"
                       (FStar_Pervasives_Native.Some
                          ((((Prims.parse_int "1") + n_active) + i), n1)) ps
                       g) ps.FStar_Tactics_Types.smt_goals
               in
            FStar_List.append uu____540 uu____551  in
          FStar_List.append uu____519 uu____537  in
        FStar_String.concat "" uu____516
  
let (goal_to_json : FStar_Tactics_Types.goal -> FStar_Util.json) =
  fun g  ->
    let g_binders =
      let uu____572 =
        let uu____573 = FStar_Tactics_Types.goal_env g  in
        FStar_TypeChecker_Env.all_binders uu____573  in
      let uu____574 =
        let uu____579 =
          let uu____580 = FStar_Tactics_Types.goal_env g  in
          FStar_TypeChecker_Env.dsenv uu____580  in
        FStar_Syntax_Print.binders_to_json uu____579  in
      FStar_All.pipe_right uu____572 uu____574  in
    let uu____581 =
      let uu____588 =
        let uu____595 =
          let uu____600 =
            let uu____601 =
              let uu____608 =
                let uu____613 =
                  let uu____614 =
                    let uu____615 = FStar_Tactics_Types.goal_env g  in
                    let uu____616 = FStar_Tactics_Types.goal_witness g  in
                    tts uu____615 uu____616  in
                  FStar_Util.JsonStr uu____614  in
                ("witness", uu____613)  in
              let uu____617 =
                let uu____624 =
                  let uu____629 =
                    let uu____630 =
                      let uu____631 = FStar_Tactics_Types.goal_env g  in
                      let uu____632 = FStar_Tactics_Types.goal_type g  in
                      tts uu____631 uu____632  in
                    FStar_Util.JsonStr uu____630  in
                  ("type", uu____629)  in
                [uu____624;
                ("label", (FStar_Util.JsonStr (g.FStar_Tactics_Types.label)))]
                 in
              uu____608 :: uu____617  in
            FStar_Util.JsonAssoc uu____601  in
          ("goal", uu____600)  in
        [uu____595]  in
      ("hyps", g_binders) :: uu____588  in
    FStar_Util.JsonAssoc uu____581
  
let (ps_to_json :
  (Prims.string,FStar_Tactics_Types.proofstate)
    FStar_Pervasives_Native.tuple2 -> FStar_Util.json)
  =
  fun uu____669  ->
    match uu____669 with
    | (msg,ps) ->
        let uu____676 =
          let uu____683 =
            let uu____690 =
              let uu____697 =
                let uu____704 =
                  let uu____709 =
                    let uu____710 =
                      FStar_List.map goal_to_json
                        ps.FStar_Tactics_Types.goals
                       in
                    FStar_Util.JsonList uu____710  in
                  ("goals", uu____709)  in
                let uu____713 =
                  let uu____720 =
                    let uu____725 =
                      let uu____726 =
                        FStar_List.map goal_to_json
                          ps.FStar_Tactics_Types.smt_goals
                         in
                      FStar_Util.JsonList uu____726  in
                    ("smt-goals", uu____725)  in
                  [uu____720]  in
                uu____704 :: uu____713  in
              ("depth", (FStar_Util.JsonInt (ps.FStar_Tactics_Types.depth)))
                :: uu____697
               in
            ("label", (FStar_Util.JsonStr msg)) :: uu____690  in
          let uu____749 =
            if ps.FStar_Tactics_Types.entry_range <> FStar_Range.dummyRange
            then
              let uu____762 =
                let uu____767 =
                  FStar_Range.json_of_def_range
                    ps.FStar_Tactics_Types.entry_range
                   in
                ("location", uu____767)  in
              [uu____762]
            else []  in
          FStar_List.append uu____683 uu____749  in
        FStar_Util.JsonAssoc uu____676
  
let (dump_proofstate :
  FStar_Tactics_Types.proofstate -> Prims.string -> unit) =
  fun ps  ->
    fun msg  ->
      FStar_Options.with_saved_options
        (fun uu____797  ->
           FStar_Options.set_option "print_effect_args"
             (FStar_Options.Bool true);
           FStar_Util.print_generic "proof-state" ps_to_string ps_to_json
             (msg, ps))
  
let (print_proof_state : Prims.string -> unit tac) =
  fun msg  ->
    mk_tac
      (fun ps  ->
         let psc = ps.FStar_Tactics_Types.psc  in
         let subst1 = FStar_TypeChecker_Cfg.psc_subst psc  in
         (let uu____820 = FStar_Tactics_Types.subst_proof_state subst1 ps  in
          dump_proofstate uu____820 msg);
         FStar_Tactics_Result.Success ((), ps))
  
let mlog : 'a . (unit -> unit) -> (unit -> 'a tac) -> 'a tac =
  fun f  -> fun cont  -> bind get (fun ps  -> log ps f; cont ()) 
let fail : 'a . Prims.string -> 'a tac =
  fun msg  ->
    mk_tac
      (fun ps  ->
         (let uu____874 =
            FStar_TypeChecker_Env.debug ps.FStar_Tactics_Types.main_context
              (FStar_Options.Other "TacFail")
             in
          if uu____874
          then dump_proofstate ps (Prims.strcat "TACTIC FAILING: " msg)
          else ());
         FStar_Tactics_Result.Failed (msg, ps))
  
let fail1 : 'Auu____882 . Prims.string -> Prims.string -> 'Auu____882 tac =
  fun msg  ->
    fun x  -> let uu____895 = FStar_Util.format1 msg x  in fail uu____895
  
let fail2 :
  'Auu____904 .
    Prims.string -> Prims.string -> Prims.string -> 'Auu____904 tac
  =
  fun msg  ->
    fun x  ->
      fun y  -> let uu____922 = FStar_Util.format2 msg x y  in fail uu____922
  
let fail3 :
  'Auu____933 .
    Prims.string ->
      Prims.string -> Prims.string -> Prims.string -> 'Auu____933 tac
  =
  fun msg  ->
    fun x  ->
      fun y  ->
        fun z  ->
          let uu____956 = FStar_Util.format3 msg x y z  in fail uu____956
  
let fail4 :
  'Auu____969 .
    Prims.string ->
      Prims.string ->
        Prims.string -> Prims.string -> Prims.string -> 'Auu____969 tac
  =
  fun msg  ->
    fun x  ->
      fun y  ->
        fun z  ->
          fun w  ->
            let uu____997 = FStar_Util.format4 msg x y z w  in fail uu____997
  
let catch : 'a . 'a tac -> (Prims.string,'a) FStar_Util.either tac =
  fun t  ->
    mk_tac
      (fun ps  ->
         let tx = FStar_Syntax_Unionfind.new_transaction ()  in
         let uu____1030 = run t ps  in
         match uu____1030 with
         | FStar_Tactics_Result.Success (a,q) ->
             (FStar_Syntax_Unionfind.commit tx;
              FStar_Tactics_Result.Success ((FStar_Util.Inr a), q))
         | FStar_Tactics_Result.Failed (m,q) ->
             (FStar_Syntax_Unionfind.rollback tx;
              (let ps1 =
                 let uu___360_1054 = ps  in
                 {
                   FStar_Tactics_Types.main_context =
                     (uu___360_1054.FStar_Tactics_Types.main_context);
                   FStar_Tactics_Types.main_goal =
                     (uu___360_1054.FStar_Tactics_Types.main_goal);
                   FStar_Tactics_Types.all_implicits =
                     (uu___360_1054.FStar_Tactics_Types.all_implicits);
                   FStar_Tactics_Types.goals =
                     (uu___360_1054.FStar_Tactics_Types.goals);
                   FStar_Tactics_Types.smt_goals =
                     (uu___360_1054.FStar_Tactics_Types.smt_goals);
                   FStar_Tactics_Types.depth =
                     (uu___360_1054.FStar_Tactics_Types.depth);
                   FStar_Tactics_Types.__dump =
                     (uu___360_1054.FStar_Tactics_Types.__dump);
                   FStar_Tactics_Types.psc =
                     (uu___360_1054.FStar_Tactics_Types.psc);
                   FStar_Tactics_Types.entry_range =
                     (uu___360_1054.FStar_Tactics_Types.entry_range);
                   FStar_Tactics_Types.guard_policy =
                     (uu___360_1054.FStar_Tactics_Types.guard_policy);
                   FStar_Tactics_Types.freshness =
                     (q.FStar_Tactics_Types.freshness);
                   FStar_Tactics_Types.tac_verb_dbg =
                     (uu___360_1054.FStar_Tactics_Types.tac_verb_dbg);
                   FStar_Tactics_Types.local_state =
                     (uu___360_1054.FStar_Tactics_Types.local_state)
                 }  in
               FStar_Tactics_Result.Success ((FStar_Util.Inl m), ps1))))
  
let recover : 'a . 'a tac -> (Prims.string,'a) FStar_Util.either tac =
  fun t  ->
    mk_tac
      (fun ps  ->
         let uu____1092 = run t ps  in
         match uu____1092 with
         | FStar_Tactics_Result.Success (a,q) ->
             FStar_Tactics_Result.Success ((FStar_Util.Inr a), q)
         | FStar_Tactics_Result.Failed (m,q) ->
             FStar_Tactics_Result.Success ((FStar_Util.Inl m), q))
  
let trytac : 'a . 'a tac -> 'a FStar_Pervasives_Native.option tac =
  fun t  ->
    let uu____1139 = catch t  in
    bind uu____1139
      (fun r  ->
         match r with
         | FStar_Util.Inr v1 -> ret (FStar_Pervasives_Native.Some v1)
         | FStar_Util.Inl uu____1166 -> ret FStar_Pervasives_Native.None)
  
let trytac_exn : 'a . 'a tac -> 'a FStar_Pervasives_Native.option tac =
  fun t  ->
    mk_tac
      (fun ps  ->
         try
           (fun uu___362_1197  ->
              match () with
              | () -> let uu____1202 = trytac t  in run uu____1202 ps) ()
         with
         | FStar_Errors.Err (uu____1218,msg) ->
             (log ps
                (fun uu____1222  ->
                   FStar_Util.print1 "trytac_exn error: (%s)" msg);
              FStar_Tactics_Result.Success (FStar_Pervasives_Native.None, ps))
         | FStar_Errors.Error (uu____1227,msg,uu____1229) ->
             (log ps
                (fun uu____1232  ->
                   FStar_Util.print1 "trytac_exn error: (%s)" msg);
              FStar_Tactics_Result.Success (FStar_Pervasives_Native.None, ps)))
  
let wrap_err : 'a . Prims.string -> 'a tac -> 'a tac =
  fun pref  ->
    fun t  ->
      mk_tac
        (fun ps  ->
           let uu____1265 = run t ps  in
           match uu____1265 with
           | FStar_Tactics_Result.Success (a,q) ->
               FStar_Tactics_Result.Success (a, q)
           | FStar_Tactics_Result.Failed (msg,q) ->
               FStar_Tactics_Result.Failed
                 ((Prims.strcat pref (Prims.strcat ": " msg)), q))
  
let (set : FStar_Tactics_Types.proofstate -> unit tac) =
  fun p  -> mk_tac (fun uu____1284  -> FStar_Tactics_Result.Success ((), p)) 
let (add_implicits : implicits -> unit tac) =
  fun i  ->
    bind get
      (fun p  ->
         set
           (let uu___363_1298 = p  in
            {
              FStar_Tactics_Types.main_context =
                (uu___363_1298.FStar_Tactics_Types.main_context);
              FStar_Tactics_Types.main_goal =
                (uu___363_1298.FStar_Tactics_Types.main_goal);
              FStar_Tactics_Types.all_implicits =
                (FStar_List.append i p.FStar_Tactics_Types.all_implicits);
              FStar_Tactics_Types.goals =
                (uu___363_1298.FStar_Tactics_Types.goals);
              FStar_Tactics_Types.smt_goals =
                (uu___363_1298.FStar_Tactics_Types.smt_goals);
              FStar_Tactics_Types.depth =
                (uu___363_1298.FStar_Tactics_Types.depth);
              FStar_Tactics_Types.__dump =
                (uu___363_1298.FStar_Tactics_Types.__dump);
              FStar_Tactics_Types.psc =
                (uu___363_1298.FStar_Tactics_Types.psc);
              FStar_Tactics_Types.entry_range =
                (uu___363_1298.FStar_Tactics_Types.entry_range);
              FStar_Tactics_Types.guard_policy =
                (uu___363_1298.FStar_Tactics_Types.guard_policy);
              FStar_Tactics_Types.freshness =
                (uu___363_1298.FStar_Tactics_Types.freshness);
              FStar_Tactics_Types.tac_verb_dbg =
                (uu___363_1298.FStar_Tactics_Types.tac_verb_dbg);
              FStar_Tactics_Types.local_state =
                (uu___363_1298.FStar_Tactics_Types.local_state)
            }))
  
let (__do_unify :
  env ->
    FStar_Syntax_Syntax.term -> FStar_Syntax_Syntax.term -> Prims.bool tac)
  =
  fun env  ->
    fun t1  ->
      fun t2  ->
        (let uu____1319 =
           FStar_TypeChecker_Env.debug env (FStar_Options.Other "1346")  in
         if uu____1319
         then
           let uu____1320 = FStar_Syntax_Print.term_to_string t1  in
           let uu____1321 = FStar_Syntax_Print.term_to_string t2  in
           FStar_Util.print2 "%%%%%%%%do_unify %s =? %s\n" uu____1320
             uu____1321
         else ());
        (try
           (fun uu___365_1328  ->
              match () with
              | () ->
                  let res = FStar_TypeChecker_Rel.teq_nosmt env t1 t2  in
                  ((let uu____1335 =
                      FStar_TypeChecker_Env.debug env
                        (FStar_Options.Other "1346")
                       in
                    if uu____1335
                    then
                      let uu____1336 =
                        FStar_Common.string_of_option
                          (FStar_TypeChecker_Rel.guard_to_string env) res
                         in
                      let uu____1337 = FStar_Syntax_Print.term_to_string t1
                         in
                      let uu____1338 = FStar_Syntax_Print.term_to_string t2
                         in
                      FStar_Util.print3
                        "%%%%%%%%do_unify (RESULT %s) %s =? %s\n" uu____1336
                        uu____1337 uu____1338
                    else ());
                   (match res with
                    | FStar_Pervasives_Native.None  -> ret false
                    | FStar_Pervasives_Native.Some g ->
                        let uu____1343 =
                          add_implicits g.FStar_TypeChecker_Env.implicits  in
                        bind uu____1343 (fun uu____1347  -> ret true)))) ()
         with
         | FStar_Errors.Err (uu____1354,msg) ->
             mlog
               (fun uu____1357  ->
                  FStar_Util.print1 ">> do_unify error, (%s)\n" msg)
               (fun uu____1359  -> ret false)
         | FStar_Errors.Error (uu____1360,msg,r) ->
             mlog
               (fun uu____1365  ->
                  let uu____1366 = FStar_Range.string_of_range r  in
                  FStar_Util.print2 ">> do_unify error, (%s) at (%s)\n" msg
                    uu____1366) (fun uu____1368  -> ret false))
  
let (compress_implicits : unit tac) =
  bind get
    (fun ps  ->
       let imps = ps.FStar_Tactics_Types.all_implicits  in
       let g =
         let uu___366_1379 = FStar_TypeChecker_Env.trivial_guard  in
         {
           FStar_TypeChecker_Env.guard_f =
             (uu___366_1379.FStar_TypeChecker_Env.guard_f);
           FStar_TypeChecker_Env.deferred =
             (uu___366_1379.FStar_TypeChecker_Env.deferred);
           FStar_TypeChecker_Env.univ_ineqs =
             (uu___366_1379.FStar_TypeChecker_Env.univ_ineqs);
           FStar_TypeChecker_Env.implicits = imps
         }  in
       let g1 =
         FStar_TypeChecker_Rel.resolve_implicits_tac
           ps.FStar_Tactics_Types.main_context g
          in
       let ps' =
         let uu___367_1382 = ps  in
         {
           FStar_Tactics_Types.main_context =
             (uu___367_1382.FStar_Tactics_Types.main_context);
           FStar_Tactics_Types.main_goal =
             (uu___367_1382.FStar_Tactics_Types.main_goal);
           FStar_Tactics_Types.all_implicits =
             (g1.FStar_TypeChecker_Env.implicits);
           FStar_Tactics_Types.goals =
             (uu___367_1382.FStar_Tactics_Types.goals);
           FStar_Tactics_Types.smt_goals =
             (uu___367_1382.FStar_Tactics_Types.smt_goals);
           FStar_Tactics_Types.depth =
             (uu___367_1382.FStar_Tactics_Types.depth);
           FStar_Tactics_Types.__dump =
             (uu___367_1382.FStar_Tactics_Types.__dump);
           FStar_Tactics_Types.psc = (uu___367_1382.FStar_Tactics_Types.psc);
           FStar_Tactics_Types.entry_range =
             (uu___367_1382.FStar_Tactics_Types.entry_range);
           FStar_Tactics_Types.guard_policy =
             (uu___367_1382.FStar_Tactics_Types.guard_policy);
           FStar_Tactics_Types.freshness =
             (uu___367_1382.FStar_Tactics_Types.freshness);
           FStar_Tactics_Types.tac_verb_dbg =
             (uu___367_1382.FStar_Tactics_Types.tac_verb_dbg);
           FStar_Tactics_Types.local_state =
             (uu___367_1382.FStar_Tactics_Types.local_state)
         }  in
       set ps')
  
let (do_unify :
  FStar_TypeChecker_Env.env ->
    FStar_Syntax_Syntax.term -> FStar_Syntax_Syntax.term -> Prims.bool tac)
  =
  fun env  ->
    fun t1  ->
      fun t2  ->
        bind idtac
          (fun uu____1405  ->
             (let uu____1407 =
                FStar_TypeChecker_Env.debug env (FStar_Options.Other "1346")
                 in
              if uu____1407
              then
                (FStar_Options.push ();
                 (let uu____1409 =
                    FStar_Options.set_options FStar_Options.Set
                      "--debug_level Rel --debug_level RelCheck"
                     in
                  ()))
              else ());
             (let uu____1411 = __do_unify env t1 t2  in
              bind uu____1411
                (fun r  ->
                   (let uu____1418 =
                      FStar_TypeChecker_Env.debug env
                        (FStar_Options.Other "1346")
                       in
                    if uu____1418 then FStar_Options.pop () else ());
                   bind compress_implicits (fun uu____1421  -> ret r))))
  
let (remove_solved_goals : unit tac) =
  bind get
    (fun ps  ->
       let ps' =
         let uu___368_1428 = ps  in
         let uu____1429 =
           FStar_List.filter
             (fun g  ->
                let uu____1435 = check_goal_solved g  in
                FStar_Option.isNone uu____1435) ps.FStar_Tactics_Types.goals
            in
         {
           FStar_Tactics_Types.main_context =
             (uu___368_1428.FStar_Tactics_Types.main_context);
           FStar_Tactics_Types.main_goal =
             (uu___368_1428.FStar_Tactics_Types.main_goal);
           FStar_Tactics_Types.all_implicits =
             (uu___368_1428.FStar_Tactics_Types.all_implicits);
           FStar_Tactics_Types.goals = uu____1429;
           FStar_Tactics_Types.smt_goals =
             (uu___368_1428.FStar_Tactics_Types.smt_goals);
           FStar_Tactics_Types.depth =
             (uu___368_1428.FStar_Tactics_Types.depth);
           FStar_Tactics_Types.__dump =
             (uu___368_1428.FStar_Tactics_Types.__dump);
           FStar_Tactics_Types.psc = (uu___368_1428.FStar_Tactics_Types.psc);
           FStar_Tactics_Types.entry_range =
             (uu___368_1428.FStar_Tactics_Types.entry_range);
           FStar_Tactics_Types.guard_policy =
             (uu___368_1428.FStar_Tactics_Types.guard_policy);
           FStar_Tactics_Types.freshness =
             (uu___368_1428.FStar_Tactics_Types.freshness);
           FStar_Tactics_Types.tac_verb_dbg =
             (uu___368_1428.FStar_Tactics_Types.tac_verb_dbg);
           FStar_Tactics_Types.local_state =
             (uu___368_1428.FStar_Tactics_Types.local_state)
         }  in
       set ps')
  
let (set_solution :
  FStar_Tactics_Types.goal -> FStar_Syntax_Syntax.term -> unit tac) =
  fun goal  ->
    fun solution  ->
      let uu____1452 =
        FStar_Syntax_Unionfind.find
          (goal.FStar_Tactics_Types.goal_ctx_uvar).FStar_Syntax_Syntax.ctx_uvar_head
         in
      match uu____1452 with
      | FStar_Pervasives_Native.Some uu____1457 ->
          let uu____1458 =
            let uu____1459 = goal_to_string_verbose goal  in
            FStar_Util.format1 "Goal %s is already solved" uu____1459  in
          fail uu____1458
      | FStar_Pervasives_Native.None  ->
          (FStar_Syntax_Unionfind.change
             (goal.FStar_Tactics_Types.goal_ctx_uvar).FStar_Syntax_Syntax.ctx_uvar_head
             solution;
           ret ())
  
let (trysolve :
  FStar_Tactics_Types.goal -> FStar_Syntax_Syntax.term -> Prims.bool tac) =
  fun goal  ->
    fun solution  ->
      let uu____1475 = FStar_Tactics_Types.goal_env goal  in
      let uu____1476 = FStar_Tactics_Types.goal_witness goal  in
      do_unify uu____1475 solution uu____1476
  
let (__dismiss : unit tac) =
  bind get
    (fun p  ->
       let uu____1482 =
         let uu___369_1483 = p  in
         let uu____1484 = FStar_List.tl p.FStar_Tactics_Types.goals  in
         {
           FStar_Tactics_Types.main_context =
             (uu___369_1483.FStar_Tactics_Types.main_context);
           FStar_Tactics_Types.main_goal =
             (uu___369_1483.FStar_Tactics_Types.main_goal);
           FStar_Tactics_Types.all_implicits =
             (uu___369_1483.FStar_Tactics_Types.all_implicits);
           FStar_Tactics_Types.goals = uu____1484;
           FStar_Tactics_Types.smt_goals =
             (uu___369_1483.FStar_Tactics_Types.smt_goals);
           FStar_Tactics_Types.depth =
             (uu___369_1483.FStar_Tactics_Types.depth);
           FStar_Tactics_Types.__dump =
             (uu___369_1483.FStar_Tactics_Types.__dump);
           FStar_Tactics_Types.psc = (uu___369_1483.FStar_Tactics_Types.psc);
           FStar_Tactics_Types.entry_range =
             (uu___369_1483.FStar_Tactics_Types.entry_range);
           FStar_Tactics_Types.guard_policy =
             (uu___369_1483.FStar_Tactics_Types.guard_policy);
           FStar_Tactics_Types.freshness =
             (uu___369_1483.FStar_Tactics_Types.freshness);
           FStar_Tactics_Types.tac_verb_dbg =
             (uu___369_1483.FStar_Tactics_Types.tac_verb_dbg);
           FStar_Tactics_Types.local_state =
             (uu___369_1483.FStar_Tactics_Types.local_state)
         }  in
       set uu____1482)
  
let (solve :
  FStar_Tactics_Types.goal -> FStar_Syntax_Syntax.term -> unit tac) =
  fun goal  ->
    fun solution  ->
      let e = FStar_Tactics_Types.goal_env goal  in
      mlog
        (fun uu____1505  ->
           let uu____1506 =
             let uu____1507 = FStar_Tactics_Types.goal_witness goal  in
             FStar_Syntax_Print.term_to_string uu____1507  in
           let uu____1508 = FStar_Syntax_Print.term_to_string solution  in
           FStar_Util.print2 "solve %s := %s\n" uu____1506 uu____1508)
        (fun uu____1511  ->
           let uu____1512 = trysolve goal solution  in
           bind uu____1512
             (fun b  ->
                if b
                then bind __dismiss (fun uu____1520  -> remove_solved_goals)
                else
                  (let uu____1522 =
                     let uu____1523 =
                       let uu____1524 = FStar_Tactics_Types.goal_env goal  in
                       tts uu____1524 solution  in
                     let uu____1525 =
                       let uu____1526 = FStar_Tactics_Types.goal_env goal  in
                       let uu____1527 = FStar_Tactics_Types.goal_witness goal
                          in
                       tts uu____1526 uu____1527  in
                     let uu____1528 =
                       let uu____1529 = FStar_Tactics_Types.goal_env goal  in
                       let uu____1530 = FStar_Tactics_Types.goal_type goal
                          in
                       tts uu____1529 uu____1530  in
                     FStar_Util.format3 "%s does not solve %s : %s"
                       uu____1523 uu____1525 uu____1528
                      in
                   fail uu____1522)))
  
let (solve' :
  FStar_Tactics_Types.goal -> FStar_Syntax_Syntax.term -> unit tac) =
  fun goal  ->
    fun solution  ->
      let uu____1545 = set_solution goal solution  in
      bind uu____1545
        (fun uu____1549  ->
           bind __dismiss (fun uu____1551  -> remove_solved_goals))
  
let (set_goals : FStar_Tactics_Types.goal Prims.list -> unit tac) =
  fun gs  ->
    bind get
      (fun ps  ->
         set
           (let uu___370_1569 = ps  in
            {
              FStar_Tactics_Types.main_context =
                (uu___370_1569.FStar_Tactics_Types.main_context);
              FStar_Tactics_Types.main_goal =
                (uu___370_1569.FStar_Tactics_Types.main_goal);
              FStar_Tactics_Types.all_implicits =
                (uu___370_1569.FStar_Tactics_Types.all_implicits);
              FStar_Tactics_Types.goals = gs;
              FStar_Tactics_Types.smt_goals =
                (uu___370_1569.FStar_Tactics_Types.smt_goals);
              FStar_Tactics_Types.depth =
                (uu___370_1569.FStar_Tactics_Types.depth);
              FStar_Tactics_Types.__dump =
                (uu___370_1569.FStar_Tactics_Types.__dump);
              FStar_Tactics_Types.psc =
                (uu___370_1569.FStar_Tactics_Types.psc);
              FStar_Tactics_Types.entry_range =
                (uu___370_1569.FStar_Tactics_Types.entry_range);
              FStar_Tactics_Types.guard_policy =
                (uu___370_1569.FStar_Tactics_Types.guard_policy);
              FStar_Tactics_Types.freshness =
                (uu___370_1569.FStar_Tactics_Types.freshness);
              FStar_Tactics_Types.tac_verb_dbg =
                (uu___370_1569.FStar_Tactics_Types.tac_verb_dbg);
              FStar_Tactics_Types.local_state =
                (uu___370_1569.FStar_Tactics_Types.local_state)
            }))
  
let (set_smt_goals : FStar_Tactics_Types.goal Prims.list -> unit tac) =
  fun gs  ->
    bind get
      (fun ps  ->
         set
           (let uu___371_1587 = ps  in
            {
              FStar_Tactics_Types.main_context =
                (uu___371_1587.FStar_Tactics_Types.main_context);
              FStar_Tactics_Types.main_goal =
                (uu___371_1587.FStar_Tactics_Types.main_goal);
              FStar_Tactics_Types.all_implicits =
                (uu___371_1587.FStar_Tactics_Types.all_implicits);
              FStar_Tactics_Types.goals =
                (uu___371_1587.FStar_Tactics_Types.goals);
              FStar_Tactics_Types.smt_goals = gs;
              FStar_Tactics_Types.depth =
                (uu___371_1587.FStar_Tactics_Types.depth);
              FStar_Tactics_Types.__dump =
                (uu___371_1587.FStar_Tactics_Types.__dump);
              FStar_Tactics_Types.psc =
                (uu___371_1587.FStar_Tactics_Types.psc);
              FStar_Tactics_Types.entry_range =
                (uu___371_1587.FStar_Tactics_Types.entry_range);
              FStar_Tactics_Types.guard_policy =
                (uu___371_1587.FStar_Tactics_Types.guard_policy);
              FStar_Tactics_Types.freshness =
                (uu___371_1587.FStar_Tactics_Types.freshness);
              FStar_Tactics_Types.tac_verb_dbg =
                (uu___371_1587.FStar_Tactics_Types.tac_verb_dbg);
              FStar_Tactics_Types.local_state =
                (uu___371_1587.FStar_Tactics_Types.local_state)
            }))
  
let (dismiss_all : unit tac) = set_goals [] 
let (nwarn : Prims.int FStar_ST.ref) =
  FStar_Util.mk_ref (Prims.parse_int "0") 
let (check_valid_goal : FStar_Tactics_Types.goal -> unit) =
  fun g  ->
    let uu____1608 = FStar_Options.defensive ()  in
    if uu____1608
    then
      let b = true  in
      let env = FStar_Tactics_Types.goal_env g  in
      let b1 =
        b &&
          (let uu____1613 = FStar_Tactics_Types.goal_witness g  in
           FStar_TypeChecker_Env.closed env uu____1613)
         in
      let b2 =
        b1 &&
          (let uu____1616 = FStar_Tactics_Types.goal_type g  in
           FStar_TypeChecker_Env.closed env uu____1616)
         in
      let rec aux b3 e =
        let uu____1628 = FStar_TypeChecker_Env.pop_bv e  in
        match uu____1628 with
        | FStar_Pervasives_Native.None  -> b3
        | FStar_Pervasives_Native.Some (bv,e1) ->
            let b4 =
              b3 &&
                (FStar_TypeChecker_Env.closed e1 bv.FStar_Syntax_Syntax.sort)
               in
            aux b4 e1
         in
      let uu____1646 =
        (let uu____1649 = aux b2 env  in Prims.op_Negation uu____1649) &&
          (let uu____1651 = FStar_ST.op_Bang nwarn  in
           uu____1651 < (Prims.parse_int "5"))
         in
      (if uu____1646
       then
         ((let uu____1672 =
             let uu____1673 = FStar_Tactics_Types.goal_type g  in
             uu____1673.FStar_Syntax_Syntax.pos  in
           let uu____1676 =
             let uu____1681 =
               let uu____1682 = goal_to_string_verbose g  in
               FStar_Util.format1
                 "The following goal is ill-formed. Keeping calm and carrying on...\n<%s>\n\n"
                 uu____1682
                in
             (FStar_Errors.Warning_IllFormedGoal, uu____1681)  in
           FStar_Errors.log_issue uu____1672 uu____1676);
          (let uu____1683 =
             let uu____1684 = FStar_ST.op_Bang nwarn  in
             uu____1684 + (Prims.parse_int "1")  in
           FStar_ST.op_Colon_Equals nwarn uu____1683))
       else ())
    else ()
  
let (add_goals : FStar_Tactics_Types.goal Prims.list -> unit tac) =
  fun gs  ->
    bind get
      (fun p  ->
         FStar_List.iter check_valid_goal gs;
         set
           (let uu___372_1744 = p  in
            {
              FStar_Tactics_Types.main_context =
                (uu___372_1744.FStar_Tactics_Types.main_context);
              FStar_Tactics_Types.main_goal =
                (uu___372_1744.FStar_Tactics_Types.main_goal);
              FStar_Tactics_Types.all_implicits =
                (uu___372_1744.FStar_Tactics_Types.all_implicits);
              FStar_Tactics_Types.goals =
                (FStar_List.append gs p.FStar_Tactics_Types.goals);
              FStar_Tactics_Types.smt_goals =
                (uu___372_1744.FStar_Tactics_Types.smt_goals);
              FStar_Tactics_Types.depth =
                (uu___372_1744.FStar_Tactics_Types.depth);
              FStar_Tactics_Types.__dump =
                (uu___372_1744.FStar_Tactics_Types.__dump);
              FStar_Tactics_Types.psc =
                (uu___372_1744.FStar_Tactics_Types.psc);
              FStar_Tactics_Types.entry_range =
                (uu___372_1744.FStar_Tactics_Types.entry_range);
              FStar_Tactics_Types.guard_policy =
                (uu___372_1744.FStar_Tactics_Types.guard_policy);
              FStar_Tactics_Types.freshness =
                (uu___372_1744.FStar_Tactics_Types.freshness);
              FStar_Tactics_Types.tac_verb_dbg =
                (uu___372_1744.FStar_Tactics_Types.tac_verb_dbg);
              FStar_Tactics_Types.local_state =
                (uu___372_1744.FStar_Tactics_Types.local_state)
            }))
  
let (add_smt_goals : FStar_Tactics_Types.goal Prims.list -> unit tac) =
  fun gs  ->
    bind get
      (fun p  ->
         FStar_List.iter check_valid_goal gs;
         set
           (let uu___373_1764 = p  in
            {
              FStar_Tactics_Types.main_context =
                (uu___373_1764.FStar_Tactics_Types.main_context);
              FStar_Tactics_Types.main_goal =
                (uu___373_1764.FStar_Tactics_Types.main_goal);
              FStar_Tactics_Types.all_implicits =
                (uu___373_1764.FStar_Tactics_Types.all_implicits);
              FStar_Tactics_Types.goals =
                (uu___373_1764.FStar_Tactics_Types.goals);
              FStar_Tactics_Types.smt_goals =
                (FStar_List.append gs p.FStar_Tactics_Types.smt_goals);
              FStar_Tactics_Types.depth =
                (uu___373_1764.FStar_Tactics_Types.depth);
              FStar_Tactics_Types.__dump =
                (uu___373_1764.FStar_Tactics_Types.__dump);
              FStar_Tactics_Types.psc =
                (uu___373_1764.FStar_Tactics_Types.psc);
              FStar_Tactics_Types.entry_range =
                (uu___373_1764.FStar_Tactics_Types.entry_range);
              FStar_Tactics_Types.guard_policy =
                (uu___373_1764.FStar_Tactics_Types.guard_policy);
              FStar_Tactics_Types.freshness =
                (uu___373_1764.FStar_Tactics_Types.freshness);
              FStar_Tactics_Types.tac_verb_dbg =
                (uu___373_1764.FStar_Tactics_Types.tac_verb_dbg);
              FStar_Tactics_Types.local_state =
                (uu___373_1764.FStar_Tactics_Types.local_state)
            }))
  
let (push_goals : FStar_Tactics_Types.goal Prims.list -> unit tac) =
  fun gs  ->
    bind get
      (fun p  ->
         FStar_List.iter check_valid_goal gs;
         set
           (let uu___374_1784 = p  in
            {
              FStar_Tactics_Types.main_context =
                (uu___374_1784.FStar_Tactics_Types.main_context);
              FStar_Tactics_Types.main_goal =
                (uu___374_1784.FStar_Tactics_Types.main_goal);
              FStar_Tactics_Types.all_implicits =
                (uu___374_1784.FStar_Tactics_Types.all_implicits);
              FStar_Tactics_Types.goals =
                (FStar_List.append p.FStar_Tactics_Types.goals gs);
              FStar_Tactics_Types.smt_goals =
                (uu___374_1784.FStar_Tactics_Types.smt_goals);
              FStar_Tactics_Types.depth =
                (uu___374_1784.FStar_Tactics_Types.depth);
              FStar_Tactics_Types.__dump =
                (uu___374_1784.FStar_Tactics_Types.__dump);
              FStar_Tactics_Types.psc =
                (uu___374_1784.FStar_Tactics_Types.psc);
              FStar_Tactics_Types.entry_range =
                (uu___374_1784.FStar_Tactics_Types.entry_range);
              FStar_Tactics_Types.guard_policy =
                (uu___374_1784.FStar_Tactics_Types.guard_policy);
              FStar_Tactics_Types.freshness =
                (uu___374_1784.FStar_Tactics_Types.freshness);
              FStar_Tactics_Types.tac_verb_dbg =
                (uu___374_1784.FStar_Tactics_Types.tac_verb_dbg);
              FStar_Tactics_Types.local_state =
                (uu___374_1784.FStar_Tactics_Types.local_state)
            }))
  
let (push_smt_goals : FStar_Tactics_Types.goal Prims.list -> unit tac) =
  fun gs  ->
    bind get
      (fun p  ->
         FStar_List.iter check_valid_goal gs;
         set
           (let uu___375_1804 = p  in
            {
              FStar_Tactics_Types.main_context =
                (uu___375_1804.FStar_Tactics_Types.main_context);
              FStar_Tactics_Types.main_goal =
                (uu___375_1804.FStar_Tactics_Types.main_goal);
              FStar_Tactics_Types.all_implicits =
                (uu___375_1804.FStar_Tactics_Types.all_implicits);
              FStar_Tactics_Types.goals =
                (uu___375_1804.FStar_Tactics_Types.goals);
              FStar_Tactics_Types.smt_goals =
                (FStar_List.append p.FStar_Tactics_Types.smt_goals gs);
              FStar_Tactics_Types.depth =
                (uu___375_1804.FStar_Tactics_Types.depth);
              FStar_Tactics_Types.__dump =
                (uu___375_1804.FStar_Tactics_Types.__dump);
              FStar_Tactics_Types.psc =
                (uu___375_1804.FStar_Tactics_Types.psc);
              FStar_Tactics_Types.entry_range =
                (uu___375_1804.FStar_Tactics_Types.entry_range);
              FStar_Tactics_Types.guard_policy =
                (uu___375_1804.FStar_Tactics_Types.guard_policy);
              FStar_Tactics_Types.freshness =
                (uu___375_1804.FStar_Tactics_Types.freshness);
              FStar_Tactics_Types.tac_verb_dbg =
                (uu___375_1804.FStar_Tactics_Types.tac_verb_dbg);
              FStar_Tactics_Types.local_state =
                (uu___375_1804.FStar_Tactics_Types.local_state)
            }))
  
let (replace_cur : FStar_Tactics_Types.goal -> unit tac) =
  fun g  -> bind __dismiss (fun uu____1815  -> add_goals [g]) 
let (new_uvar :
  Prims.string ->
    env ->
      FStar_Reflection_Data.typ ->
        (FStar_Syntax_Syntax.term,FStar_Syntax_Syntax.ctx_uvar)
          FStar_Pervasives_Native.tuple2 tac)
  =
  fun reason  ->
    fun env  ->
      fun typ  ->
        let uu____1843 =
          FStar_TypeChecker_Env.new_implicit_var_aux reason
            typ.FStar_Syntax_Syntax.pos env typ
            FStar_Syntax_Syntax.Allow_untyped
           in
        match uu____1843 with
        | (u,ctx_uvar,g_u) ->
            let uu____1877 =
              add_implicits g_u.FStar_TypeChecker_Env.implicits  in
            bind uu____1877
              (fun uu____1886  ->
                 let uu____1887 =
                   let uu____1892 =
                     let uu____1893 = FStar_List.hd ctx_uvar  in
                     FStar_Pervasives_Native.fst uu____1893  in
                   (u, uu____1892)  in
                 ret uu____1887)
  
let (is_true : FStar_Syntax_Syntax.term -> Prims.bool) =
  fun t  ->
    let uu____1911 = FStar_Syntax_Util.un_squash t  in
    match uu____1911 with
    | FStar_Pervasives_Native.Some t' ->
        let uu____1921 =
          let uu____1922 = FStar_Syntax_Subst.compress t'  in
          uu____1922.FStar_Syntax_Syntax.n  in
        (match uu____1921 with
         | FStar_Syntax_Syntax.Tm_fvar fv ->
             FStar_Syntax_Syntax.fv_eq_lid fv FStar_Parser_Const.true_lid
         | uu____1926 -> false)
    | uu____1927 -> false
  
let (is_false : FStar_Syntax_Syntax.term -> Prims.bool) =
  fun t  ->
    let uu____1937 = FStar_Syntax_Util.un_squash t  in
    match uu____1937 with
    | FStar_Pervasives_Native.Some t' ->
        let uu____1947 =
          let uu____1948 = FStar_Syntax_Subst.compress t'  in
          uu____1948.FStar_Syntax_Syntax.n  in
        (match uu____1947 with
         | FStar_Syntax_Syntax.Tm_fvar fv ->
             FStar_Syntax_Syntax.fv_eq_lid fv FStar_Parser_Const.false_lid
         | uu____1952 -> false)
    | uu____1953 -> false
  
let (cur_goal : unit -> FStar_Tactics_Types.goal tac) =
  fun uu____1964  ->
    bind get
      (fun p  ->
         match p.FStar_Tactics_Types.goals with
         | [] -> fail "No more goals (1)"
         | hd1::tl1 ->
             let uu____1975 =
               FStar_Syntax_Unionfind.find
                 (hd1.FStar_Tactics_Types.goal_ctx_uvar).FStar_Syntax_Syntax.ctx_uvar_head
                in
             (match uu____1975 with
              | FStar_Pervasives_Native.None  -> ret hd1
              | FStar_Pervasives_Native.Some t ->
                  ((let uu____1982 = goal_to_string_verbose hd1  in
                    let uu____1983 = FStar_Syntax_Print.term_to_string t  in
                    FStar_Util.print2
                      "!!!!!!!!!!!! GOAL IS ALREADY SOLVED! %s\nsol is %s\n"
                      uu____1982 uu____1983);
                   ret hd1)))
  
let (tadmit_t : FStar_Syntax_Syntax.term -> unit tac) =
  fun t  ->
    let uu____1993 =
      bind get
        (fun ps  ->
           let uu____1999 = cur_goal ()  in
           bind uu____1999
             (fun g  ->
                (let uu____2006 =
                   let uu____2007 = FStar_Tactics_Types.goal_type g  in
                   uu____2007.FStar_Syntax_Syntax.pos  in
                 let uu____2010 =
                   let uu____2015 =
                     let uu____2016 =
                       goal_to_string "" FStar_Pervasives_Native.None ps g
                        in
                     FStar_Util.format1 "Tactics admitted goal <%s>\n\n"
                       uu____2016
                      in
                   (FStar_Errors.Warning_TacAdmit, uu____2015)  in
                 FStar_Errors.log_issue uu____2006 uu____2010);
                solve' g t))
       in
    FStar_All.pipe_left (wrap_err "tadmit_t") uu____1993
  
let (fresh : unit -> FStar_BigInt.t tac) =
  fun uu____2031  ->
    bind get
      (fun ps  ->
         let n1 = ps.FStar_Tactics_Types.freshness  in
         let ps1 =
           let uu___376_2041 = ps  in
           {
             FStar_Tactics_Types.main_context =
               (uu___376_2041.FStar_Tactics_Types.main_context);
             FStar_Tactics_Types.main_goal =
               (uu___376_2041.FStar_Tactics_Types.main_goal);
             FStar_Tactics_Types.all_implicits =
               (uu___376_2041.FStar_Tactics_Types.all_implicits);
             FStar_Tactics_Types.goals =
               (uu___376_2041.FStar_Tactics_Types.goals);
             FStar_Tactics_Types.smt_goals =
               (uu___376_2041.FStar_Tactics_Types.smt_goals);
             FStar_Tactics_Types.depth =
               (uu___376_2041.FStar_Tactics_Types.depth);
             FStar_Tactics_Types.__dump =
               (uu___376_2041.FStar_Tactics_Types.__dump);
             FStar_Tactics_Types.psc =
               (uu___376_2041.FStar_Tactics_Types.psc);
             FStar_Tactics_Types.entry_range =
               (uu___376_2041.FStar_Tactics_Types.entry_range);
             FStar_Tactics_Types.guard_policy =
               (uu___376_2041.FStar_Tactics_Types.guard_policy);
             FStar_Tactics_Types.freshness = (n1 + (Prims.parse_int "1"));
             FStar_Tactics_Types.tac_verb_dbg =
               (uu___376_2041.FStar_Tactics_Types.tac_verb_dbg);
             FStar_Tactics_Types.local_state =
               (uu___376_2041.FStar_Tactics_Types.local_state)
           }  in
         let uu____2042 = set ps1  in
         bind uu____2042
           (fun uu____2047  ->
              let uu____2048 = FStar_BigInt.of_int_fs n1  in ret uu____2048))
  
let (mk_irrelevant_goal :
  Prims.string ->
    env ->
      FStar_Reflection_Data.typ ->
        FStar_Options.optionstate ->
          Prims.string -> FStar_Tactics_Types.goal tac)
  =
  fun reason  ->
    fun env  ->
      fun phi  ->
        fun opts  ->
          fun label1  ->
            let typ =
              let uu____2081 = env.FStar_TypeChecker_Env.universe_of env phi
                 in
              FStar_Syntax_Util.mk_squash uu____2081 phi  in
            let uu____2082 = new_uvar reason env typ  in
            bind uu____2082
              (fun uu____2097  ->
                 match uu____2097 with
                 | (uu____2104,ctx_uvar) ->
                     let goal =
                       FStar_Tactics_Types.mk_goal env ctx_uvar opts false
                         label1
                        in
                     ret goal)
  
let (__tc :
  env ->
    FStar_Syntax_Syntax.term ->
      (FStar_Syntax_Syntax.term,FStar_Reflection_Data.typ,FStar_TypeChecker_Env.guard_t)
        FStar_Pervasives_Native.tuple3 tac)
  =
  fun e  ->
    fun t  ->
      bind get
        (fun ps  ->
           mlog
             (fun uu____2149  ->
                let uu____2150 = FStar_Syntax_Print.term_to_string t  in
                FStar_Util.print1 "Tac> __tc(%s)\n" uu____2150)
             (fun uu____2153  ->
                let e1 =
                  let uu___377_2155 = e  in
                  {
                    FStar_TypeChecker_Env.solver =
                      (uu___377_2155.FStar_TypeChecker_Env.solver);
                    FStar_TypeChecker_Env.range =
                      (uu___377_2155.FStar_TypeChecker_Env.range);
                    FStar_TypeChecker_Env.curmodule =
                      (uu___377_2155.FStar_TypeChecker_Env.curmodule);
                    FStar_TypeChecker_Env.gamma =
                      (uu___377_2155.FStar_TypeChecker_Env.gamma);
                    FStar_TypeChecker_Env.gamma_sig =
                      (uu___377_2155.FStar_TypeChecker_Env.gamma_sig);
                    FStar_TypeChecker_Env.gamma_cache =
                      (uu___377_2155.FStar_TypeChecker_Env.gamma_cache);
                    FStar_TypeChecker_Env.modules =
                      (uu___377_2155.FStar_TypeChecker_Env.modules);
                    FStar_TypeChecker_Env.expected_typ =
                      (uu___377_2155.FStar_TypeChecker_Env.expected_typ);
                    FStar_TypeChecker_Env.sigtab =
                      (uu___377_2155.FStar_TypeChecker_Env.sigtab);
                    FStar_TypeChecker_Env.attrtab =
                      (uu___377_2155.FStar_TypeChecker_Env.attrtab);
                    FStar_TypeChecker_Env.is_pattern =
                      (uu___377_2155.FStar_TypeChecker_Env.is_pattern);
                    FStar_TypeChecker_Env.instantiate_imp =
                      (uu___377_2155.FStar_TypeChecker_Env.instantiate_imp);
                    FStar_TypeChecker_Env.effects =
                      (uu___377_2155.FStar_TypeChecker_Env.effects);
                    FStar_TypeChecker_Env.generalize =
                      (uu___377_2155.FStar_TypeChecker_Env.generalize);
                    FStar_TypeChecker_Env.letrecs =
                      (uu___377_2155.FStar_TypeChecker_Env.letrecs);
                    FStar_TypeChecker_Env.top_level =
                      (uu___377_2155.FStar_TypeChecker_Env.top_level);
                    FStar_TypeChecker_Env.check_uvars =
                      (uu___377_2155.FStar_TypeChecker_Env.check_uvars);
                    FStar_TypeChecker_Env.use_eq =
                      (uu___377_2155.FStar_TypeChecker_Env.use_eq);
                    FStar_TypeChecker_Env.is_iface =
                      (uu___377_2155.FStar_TypeChecker_Env.is_iface);
                    FStar_TypeChecker_Env.admit =
                      (uu___377_2155.FStar_TypeChecker_Env.admit);
                    FStar_TypeChecker_Env.lax =
                      (uu___377_2155.FStar_TypeChecker_Env.lax);
                    FStar_TypeChecker_Env.lax_universes =
                      (uu___377_2155.FStar_TypeChecker_Env.lax_universes);
                    FStar_TypeChecker_Env.phase1 =
                      (uu___377_2155.FStar_TypeChecker_Env.phase1);
                    FStar_TypeChecker_Env.failhard =
                      (uu___377_2155.FStar_TypeChecker_Env.failhard);
                    FStar_TypeChecker_Env.nosynth =
                      (uu___377_2155.FStar_TypeChecker_Env.nosynth);
                    FStar_TypeChecker_Env.uvar_subtyping = false;
                    FStar_TypeChecker_Env.tc_term =
                      (uu___377_2155.FStar_TypeChecker_Env.tc_term);
                    FStar_TypeChecker_Env.type_of =
                      (uu___377_2155.FStar_TypeChecker_Env.type_of);
                    FStar_TypeChecker_Env.universe_of =
                      (uu___377_2155.FStar_TypeChecker_Env.universe_of);
                    FStar_TypeChecker_Env.check_type_of =
                      (uu___377_2155.FStar_TypeChecker_Env.check_type_of);
                    FStar_TypeChecker_Env.use_bv_sorts =
                      (uu___377_2155.FStar_TypeChecker_Env.use_bv_sorts);
                    FStar_TypeChecker_Env.qtbl_name_and_index =
                      (uu___377_2155.FStar_TypeChecker_Env.qtbl_name_and_index);
                    FStar_TypeChecker_Env.normalized_eff_names =
                      (uu___377_2155.FStar_TypeChecker_Env.normalized_eff_names);
                    FStar_TypeChecker_Env.fv_delta_depths =
                      (uu___377_2155.FStar_TypeChecker_Env.fv_delta_depths);
                    FStar_TypeChecker_Env.proof_ns =
                      (uu___377_2155.FStar_TypeChecker_Env.proof_ns);
                    FStar_TypeChecker_Env.synth_hook =
                      (uu___377_2155.FStar_TypeChecker_Env.synth_hook);
                    FStar_TypeChecker_Env.splice =
                      (uu___377_2155.FStar_TypeChecker_Env.splice);
                    FStar_TypeChecker_Env.postprocess =
                      (uu___377_2155.FStar_TypeChecker_Env.postprocess);
                    FStar_TypeChecker_Env.is_native_tactic =
                      (uu___377_2155.FStar_TypeChecker_Env.is_native_tactic);
                    FStar_TypeChecker_Env.identifier_info =
                      (uu___377_2155.FStar_TypeChecker_Env.identifier_info);
                    FStar_TypeChecker_Env.tc_hooks =
                      (uu___377_2155.FStar_TypeChecker_Env.tc_hooks);
                    FStar_TypeChecker_Env.dsenv =
                      (uu___377_2155.FStar_TypeChecker_Env.dsenv);
                    FStar_TypeChecker_Env.nbe =
                      (uu___377_2155.FStar_TypeChecker_Env.nbe)
                  }  in
                try
                  (fun uu___379_2166  ->
                     match () with
                     | () ->
                         let uu____2175 =
                           FStar_TypeChecker_TcTerm.type_of_tot_term e1 t  in
                         ret uu____2175) ()
                with
                | FStar_Errors.Err (uu____2202,msg) ->
                    let uu____2204 = tts e1 t  in
                    let uu____2205 =
                      let uu____2206 = FStar_TypeChecker_Env.all_binders e1
                         in
                      FStar_All.pipe_right uu____2206
                        (FStar_Syntax_Print.binders_to_string ", ")
                       in
                    fail3 "Cannot type %s in context (%s). Error = (%s)"
                      uu____2204 uu____2205 msg
                | FStar_Errors.Error (uu____2213,msg,uu____2215) ->
                    let uu____2216 = tts e1 t  in
                    let uu____2217 =
                      let uu____2218 = FStar_TypeChecker_Env.all_binders e1
                         in
                      FStar_All.pipe_right uu____2218
                        (FStar_Syntax_Print.binders_to_string ", ")
                       in
                    fail3 "Cannot type %s in context (%s). Error = (%s)"
                      uu____2216 uu____2217 msg))
  
let (__tc_ghost :
  env ->
    FStar_Syntax_Syntax.term ->
      (FStar_Syntax_Syntax.term,FStar_Reflection_Data.typ,FStar_TypeChecker_Env.guard_t)
        FStar_Pervasives_Native.tuple3 tac)
  =
  fun e  ->
    fun t  ->
      bind get
        (fun ps  ->
           mlog
             (fun uu____2267  ->
                let uu____2268 = FStar_Syntax_Print.term_to_string t  in
                FStar_Util.print1 "Tac> __tc_ghost(%s)\n" uu____2268)
             (fun uu____2271  ->
                let e1 =
                  let uu___380_2273 = e  in
                  {
                    FStar_TypeChecker_Env.solver =
                      (uu___380_2273.FStar_TypeChecker_Env.solver);
                    FStar_TypeChecker_Env.range =
                      (uu___380_2273.FStar_TypeChecker_Env.range);
                    FStar_TypeChecker_Env.curmodule =
                      (uu___380_2273.FStar_TypeChecker_Env.curmodule);
                    FStar_TypeChecker_Env.gamma =
                      (uu___380_2273.FStar_TypeChecker_Env.gamma);
                    FStar_TypeChecker_Env.gamma_sig =
                      (uu___380_2273.FStar_TypeChecker_Env.gamma_sig);
                    FStar_TypeChecker_Env.gamma_cache =
                      (uu___380_2273.FStar_TypeChecker_Env.gamma_cache);
                    FStar_TypeChecker_Env.modules =
                      (uu___380_2273.FStar_TypeChecker_Env.modules);
                    FStar_TypeChecker_Env.expected_typ =
                      (uu___380_2273.FStar_TypeChecker_Env.expected_typ);
                    FStar_TypeChecker_Env.sigtab =
                      (uu___380_2273.FStar_TypeChecker_Env.sigtab);
                    FStar_TypeChecker_Env.attrtab =
                      (uu___380_2273.FStar_TypeChecker_Env.attrtab);
                    FStar_TypeChecker_Env.is_pattern =
                      (uu___380_2273.FStar_TypeChecker_Env.is_pattern);
                    FStar_TypeChecker_Env.instantiate_imp =
                      (uu___380_2273.FStar_TypeChecker_Env.instantiate_imp);
                    FStar_TypeChecker_Env.effects =
                      (uu___380_2273.FStar_TypeChecker_Env.effects);
                    FStar_TypeChecker_Env.generalize =
                      (uu___380_2273.FStar_TypeChecker_Env.generalize);
                    FStar_TypeChecker_Env.letrecs =
                      (uu___380_2273.FStar_TypeChecker_Env.letrecs);
                    FStar_TypeChecker_Env.top_level =
                      (uu___380_2273.FStar_TypeChecker_Env.top_level);
                    FStar_TypeChecker_Env.check_uvars =
                      (uu___380_2273.FStar_TypeChecker_Env.check_uvars);
                    FStar_TypeChecker_Env.use_eq =
                      (uu___380_2273.FStar_TypeChecker_Env.use_eq);
                    FStar_TypeChecker_Env.is_iface =
                      (uu___380_2273.FStar_TypeChecker_Env.is_iface);
                    FStar_TypeChecker_Env.admit =
                      (uu___380_2273.FStar_TypeChecker_Env.admit);
                    FStar_TypeChecker_Env.lax =
                      (uu___380_2273.FStar_TypeChecker_Env.lax);
                    FStar_TypeChecker_Env.lax_universes =
                      (uu___380_2273.FStar_TypeChecker_Env.lax_universes);
                    FStar_TypeChecker_Env.phase1 =
                      (uu___380_2273.FStar_TypeChecker_Env.phase1);
                    FStar_TypeChecker_Env.failhard =
                      (uu___380_2273.FStar_TypeChecker_Env.failhard);
                    FStar_TypeChecker_Env.nosynth =
                      (uu___380_2273.FStar_TypeChecker_Env.nosynth);
                    FStar_TypeChecker_Env.uvar_subtyping = false;
                    FStar_TypeChecker_Env.tc_term =
                      (uu___380_2273.FStar_TypeChecker_Env.tc_term);
                    FStar_TypeChecker_Env.type_of =
                      (uu___380_2273.FStar_TypeChecker_Env.type_of);
                    FStar_TypeChecker_Env.universe_of =
                      (uu___380_2273.FStar_TypeChecker_Env.universe_of);
                    FStar_TypeChecker_Env.check_type_of =
                      (uu___380_2273.FStar_TypeChecker_Env.check_type_of);
                    FStar_TypeChecker_Env.use_bv_sorts =
                      (uu___380_2273.FStar_TypeChecker_Env.use_bv_sorts);
                    FStar_TypeChecker_Env.qtbl_name_and_index =
                      (uu___380_2273.FStar_TypeChecker_Env.qtbl_name_and_index);
                    FStar_TypeChecker_Env.normalized_eff_names =
                      (uu___380_2273.FStar_TypeChecker_Env.normalized_eff_names);
                    FStar_TypeChecker_Env.fv_delta_depths =
                      (uu___380_2273.FStar_TypeChecker_Env.fv_delta_depths);
                    FStar_TypeChecker_Env.proof_ns =
                      (uu___380_2273.FStar_TypeChecker_Env.proof_ns);
                    FStar_TypeChecker_Env.synth_hook =
                      (uu___380_2273.FStar_TypeChecker_Env.synth_hook);
                    FStar_TypeChecker_Env.splice =
                      (uu___380_2273.FStar_TypeChecker_Env.splice);
                    FStar_TypeChecker_Env.postprocess =
                      (uu___380_2273.FStar_TypeChecker_Env.postprocess);
                    FStar_TypeChecker_Env.is_native_tactic =
                      (uu___380_2273.FStar_TypeChecker_Env.is_native_tactic);
                    FStar_TypeChecker_Env.identifier_info =
                      (uu___380_2273.FStar_TypeChecker_Env.identifier_info);
                    FStar_TypeChecker_Env.tc_hooks =
                      (uu___380_2273.FStar_TypeChecker_Env.tc_hooks);
                    FStar_TypeChecker_Env.dsenv =
                      (uu___380_2273.FStar_TypeChecker_Env.dsenv);
                    FStar_TypeChecker_Env.nbe =
                      (uu___380_2273.FStar_TypeChecker_Env.nbe)
                  }  in
                try
                  (fun uu___382_2287  ->
                     match () with
                     | () ->
                         let uu____2296 =
                           FStar_TypeChecker_TcTerm.tc_tot_or_gtot_term e1 t
                            in
                         (match uu____2296 with
                          | (t1,lc,g) ->
                              ret (t1, (lc.FStar_Syntax_Syntax.res_typ), g)))
                    ()
                with
                | FStar_Errors.Err (uu____2334,msg) ->
                    let uu____2336 = tts e1 t  in
                    let uu____2337 =
                      let uu____2338 = FStar_TypeChecker_Env.all_binders e1
                         in
                      FStar_All.pipe_right uu____2338
                        (FStar_Syntax_Print.binders_to_string ", ")
                       in
                    fail3 "Cannot type %s in context (%s). Error = (%s)"
                      uu____2336 uu____2337 msg
                | FStar_Errors.Error (uu____2345,msg,uu____2347) ->
                    let uu____2348 = tts e1 t  in
                    let uu____2349 =
                      let uu____2350 = FStar_TypeChecker_Env.all_binders e1
                         in
                      FStar_All.pipe_right uu____2350
                        (FStar_Syntax_Print.binders_to_string ", ")
                       in
                    fail3 "Cannot type %s in context (%s). Error = (%s)"
                      uu____2348 uu____2349 msg))
  
let (__tc_lax :
  env ->
    FStar_Syntax_Syntax.term ->
      (FStar_Syntax_Syntax.term,FStar_Reflection_Data.typ,FStar_TypeChecker_Env.guard_t)
        FStar_Pervasives_Native.tuple3 tac)
  =
  fun e  ->
    fun t  ->
      bind get
        (fun ps  ->
           mlog
             (fun uu____2399  ->
                let uu____2400 = FStar_Syntax_Print.term_to_string t  in
                FStar_Util.print1 "Tac> __tc(%s)\n" uu____2400)
             (fun uu____2404  ->
                let e1 =
                  let uu___383_2406 = e  in
                  {
                    FStar_TypeChecker_Env.solver =
                      (uu___383_2406.FStar_TypeChecker_Env.solver);
                    FStar_TypeChecker_Env.range =
                      (uu___383_2406.FStar_TypeChecker_Env.range);
                    FStar_TypeChecker_Env.curmodule =
                      (uu___383_2406.FStar_TypeChecker_Env.curmodule);
                    FStar_TypeChecker_Env.gamma =
                      (uu___383_2406.FStar_TypeChecker_Env.gamma);
                    FStar_TypeChecker_Env.gamma_sig =
                      (uu___383_2406.FStar_TypeChecker_Env.gamma_sig);
                    FStar_TypeChecker_Env.gamma_cache =
                      (uu___383_2406.FStar_TypeChecker_Env.gamma_cache);
                    FStar_TypeChecker_Env.modules =
                      (uu___383_2406.FStar_TypeChecker_Env.modules);
                    FStar_TypeChecker_Env.expected_typ =
                      (uu___383_2406.FStar_TypeChecker_Env.expected_typ);
                    FStar_TypeChecker_Env.sigtab =
                      (uu___383_2406.FStar_TypeChecker_Env.sigtab);
                    FStar_TypeChecker_Env.attrtab =
                      (uu___383_2406.FStar_TypeChecker_Env.attrtab);
                    FStar_TypeChecker_Env.is_pattern =
                      (uu___383_2406.FStar_TypeChecker_Env.is_pattern);
                    FStar_TypeChecker_Env.instantiate_imp =
                      (uu___383_2406.FStar_TypeChecker_Env.instantiate_imp);
                    FStar_TypeChecker_Env.effects =
                      (uu___383_2406.FStar_TypeChecker_Env.effects);
                    FStar_TypeChecker_Env.generalize =
                      (uu___383_2406.FStar_TypeChecker_Env.generalize);
                    FStar_TypeChecker_Env.letrecs =
                      (uu___383_2406.FStar_TypeChecker_Env.letrecs);
                    FStar_TypeChecker_Env.top_level =
                      (uu___383_2406.FStar_TypeChecker_Env.top_level);
                    FStar_TypeChecker_Env.check_uvars =
                      (uu___383_2406.FStar_TypeChecker_Env.check_uvars);
                    FStar_TypeChecker_Env.use_eq =
                      (uu___383_2406.FStar_TypeChecker_Env.use_eq);
                    FStar_TypeChecker_Env.is_iface =
                      (uu___383_2406.FStar_TypeChecker_Env.is_iface);
                    FStar_TypeChecker_Env.admit =
                      (uu___383_2406.FStar_TypeChecker_Env.admit);
                    FStar_TypeChecker_Env.lax =
                      (uu___383_2406.FStar_TypeChecker_Env.lax);
                    FStar_TypeChecker_Env.lax_universes =
                      (uu___383_2406.FStar_TypeChecker_Env.lax_universes);
                    FStar_TypeChecker_Env.phase1 =
                      (uu___383_2406.FStar_TypeChecker_Env.phase1);
                    FStar_TypeChecker_Env.failhard =
                      (uu___383_2406.FStar_TypeChecker_Env.failhard);
                    FStar_TypeChecker_Env.nosynth =
                      (uu___383_2406.FStar_TypeChecker_Env.nosynth);
                    FStar_TypeChecker_Env.uvar_subtyping = false;
                    FStar_TypeChecker_Env.tc_term =
                      (uu___383_2406.FStar_TypeChecker_Env.tc_term);
                    FStar_TypeChecker_Env.type_of =
                      (uu___383_2406.FStar_TypeChecker_Env.type_of);
                    FStar_TypeChecker_Env.universe_of =
                      (uu___383_2406.FStar_TypeChecker_Env.universe_of);
                    FStar_TypeChecker_Env.check_type_of =
                      (uu___383_2406.FStar_TypeChecker_Env.check_type_of);
                    FStar_TypeChecker_Env.use_bv_sorts =
                      (uu___383_2406.FStar_TypeChecker_Env.use_bv_sorts);
                    FStar_TypeChecker_Env.qtbl_name_and_index =
                      (uu___383_2406.FStar_TypeChecker_Env.qtbl_name_and_index);
                    FStar_TypeChecker_Env.normalized_eff_names =
                      (uu___383_2406.FStar_TypeChecker_Env.normalized_eff_names);
                    FStar_TypeChecker_Env.fv_delta_depths =
                      (uu___383_2406.FStar_TypeChecker_Env.fv_delta_depths);
                    FStar_TypeChecker_Env.proof_ns =
                      (uu___383_2406.FStar_TypeChecker_Env.proof_ns);
                    FStar_TypeChecker_Env.synth_hook =
                      (uu___383_2406.FStar_TypeChecker_Env.synth_hook);
                    FStar_TypeChecker_Env.splice =
                      (uu___383_2406.FStar_TypeChecker_Env.splice);
                    FStar_TypeChecker_Env.postprocess =
                      (uu___383_2406.FStar_TypeChecker_Env.postprocess);
                    FStar_TypeChecker_Env.is_native_tactic =
                      (uu___383_2406.FStar_TypeChecker_Env.is_native_tactic);
                    FStar_TypeChecker_Env.identifier_info =
                      (uu___383_2406.FStar_TypeChecker_Env.identifier_info);
                    FStar_TypeChecker_Env.tc_hooks =
                      (uu___383_2406.FStar_TypeChecker_Env.tc_hooks);
                    FStar_TypeChecker_Env.dsenv =
                      (uu___383_2406.FStar_TypeChecker_Env.dsenv);
                    FStar_TypeChecker_Env.nbe =
                      (uu___383_2406.FStar_TypeChecker_Env.nbe)
                  }  in
                let e2 =
                  let uu___384_2408 = e1  in
                  {
                    FStar_TypeChecker_Env.solver =
                      (uu___384_2408.FStar_TypeChecker_Env.solver);
                    FStar_TypeChecker_Env.range =
                      (uu___384_2408.FStar_TypeChecker_Env.range);
                    FStar_TypeChecker_Env.curmodule =
                      (uu___384_2408.FStar_TypeChecker_Env.curmodule);
                    FStar_TypeChecker_Env.gamma =
                      (uu___384_2408.FStar_TypeChecker_Env.gamma);
                    FStar_TypeChecker_Env.gamma_sig =
                      (uu___384_2408.FStar_TypeChecker_Env.gamma_sig);
                    FStar_TypeChecker_Env.gamma_cache =
                      (uu___384_2408.FStar_TypeChecker_Env.gamma_cache);
                    FStar_TypeChecker_Env.modules =
                      (uu___384_2408.FStar_TypeChecker_Env.modules);
                    FStar_TypeChecker_Env.expected_typ =
                      (uu___384_2408.FStar_TypeChecker_Env.expected_typ);
                    FStar_TypeChecker_Env.sigtab =
                      (uu___384_2408.FStar_TypeChecker_Env.sigtab);
                    FStar_TypeChecker_Env.attrtab =
                      (uu___384_2408.FStar_TypeChecker_Env.attrtab);
                    FStar_TypeChecker_Env.is_pattern =
                      (uu___384_2408.FStar_TypeChecker_Env.is_pattern);
                    FStar_TypeChecker_Env.instantiate_imp =
                      (uu___384_2408.FStar_TypeChecker_Env.instantiate_imp);
                    FStar_TypeChecker_Env.effects =
                      (uu___384_2408.FStar_TypeChecker_Env.effects);
                    FStar_TypeChecker_Env.generalize =
                      (uu___384_2408.FStar_TypeChecker_Env.generalize);
                    FStar_TypeChecker_Env.letrecs =
                      (uu___384_2408.FStar_TypeChecker_Env.letrecs);
                    FStar_TypeChecker_Env.top_level =
                      (uu___384_2408.FStar_TypeChecker_Env.top_level);
                    FStar_TypeChecker_Env.check_uvars =
                      (uu___384_2408.FStar_TypeChecker_Env.check_uvars);
                    FStar_TypeChecker_Env.use_eq =
                      (uu___384_2408.FStar_TypeChecker_Env.use_eq);
                    FStar_TypeChecker_Env.is_iface =
                      (uu___384_2408.FStar_TypeChecker_Env.is_iface);
                    FStar_TypeChecker_Env.admit =
                      (uu___384_2408.FStar_TypeChecker_Env.admit);
                    FStar_TypeChecker_Env.lax = true;
                    FStar_TypeChecker_Env.lax_universes =
                      (uu___384_2408.FStar_TypeChecker_Env.lax_universes);
                    FStar_TypeChecker_Env.phase1 =
                      (uu___384_2408.FStar_TypeChecker_Env.phase1);
                    FStar_TypeChecker_Env.failhard =
                      (uu___384_2408.FStar_TypeChecker_Env.failhard);
                    FStar_TypeChecker_Env.nosynth =
                      (uu___384_2408.FStar_TypeChecker_Env.nosynth);
                    FStar_TypeChecker_Env.uvar_subtyping =
                      (uu___384_2408.FStar_TypeChecker_Env.uvar_subtyping);
                    FStar_TypeChecker_Env.tc_term =
                      (uu___384_2408.FStar_TypeChecker_Env.tc_term);
                    FStar_TypeChecker_Env.type_of =
                      (uu___384_2408.FStar_TypeChecker_Env.type_of);
                    FStar_TypeChecker_Env.universe_of =
                      (uu___384_2408.FStar_TypeChecker_Env.universe_of);
                    FStar_TypeChecker_Env.check_type_of =
                      (uu___384_2408.FStar_TypeChecker_Env.check_type_of);
                    FStar_TypeChecker_Env.use_bv_sorts =
                      (uu___384_2408.FStar_TypeChecker_Env.use_bv_sorts);
                    FStar_TypeChecker_Env.qtbl_name_and_index =
                      (uu___384_2408.FStar_TypeChecker_Env.qtbl_name_and_index);
                    FStar_TypeChecker_Env.normalized_eff_names =
                      (uu___384_2408.FStar_TypeChecker_Env.normalized_eff_names);
                    FStar_TypeChecker_Env.fv_delta_depths =
                      (uu___384_2408.FStar_TypeChecker_Env.fv_delta_depths);
                    FStar_TypeChecker_Env.proof_ns =
                      (uu___384_2408.FStar_TypeChecker_Env.proof_ns);
                    FStar_TypeChecker_Env.synth_hook =
                      (uu___384_2408.FStar_TypeChecker_Env.synth_hook);
                    FStar_TypeChecker_Env.splice =
                      (uu___384_2408.FStar_TypeChecker_Env.splice);
                    FStar_TypeChecker_Env.postprocess =
                      (uu___384_2408.FStar_TypeChecker_Env.postprocess);
                    FStar_TypeChecker_Env.is_native_tactic =
                      (uu___384_2408.FStar_TypeChecker_Env.is_native_tactic);
                    FStar_TypeChecker_Env.identifier_info =
                      (uu___384_2408.FStar_TypeChecker_Env.identifier_info);
                    FStar_TypeChecker_Env.tc_hooks =
                      (uu___384_2408.FStar_TypeChecker_Env.tc_hooks);
                    FStar_TypeChecker_Env.dsenv =
                      (uu___384_2408.FStar_TypeChecker_Env.dsenv);
                    FStar_TypeChecker_Env.nbe =
                      (uu___384_2408.FStar_TypeChecker_Env.nbe)
                  }  in
                try
                  (fun uu___386_2422  ->
                     match () with
                     | () ->
                         let uu____2431 =
                           FStar_TypeChecker_TcTerm.tc_term e2 t  in
                         (match uu____2431 with
                          | (t1,lc,g) ->
                              ret (t1, (lc.FStar_Syntax_Syntax.res_typ), g)))
                    ()
                with
                | FStar_Errors.Err (uu____2469,msg) ->
                    let uu____2471 = tts e2 t  in
                    let uu____2472 =
                      let uu____2473 = FStar_TypeChecker_Env.all_binders e2
                         in
                      FStar_All.pipe_right uu____2473
                        (FStar_Syntax_Print.binders_to_string ", ")
                       in
                    fail3 "Cannot type %s in context (%s). Error = (%s)"
                      uu____2471 uu____2472 msg
                | FStar_Errors.Error (uu____2480,msg,uu____2482) ->
                    let uu____2483 = tts e2 t  in
                    let uu____2484 =
                      let uu____2485 = FStar_TypeChecker_Env.all_binders e2
                         in
                      FStar_All.pipe_right uu____2485
                        (FStar_Syntax_Print.binders_to_string ", ")
                       in
                    fail3 "Cannot type %s in context (%s). Error = (%s)"
                      uu____2483 uu____2484 msg))
  
let (istrivial : env -> FStar_Syntax_Syntax.term -> Prims.bool) =
  fun e  ->
    fun t  ->
      let steps =
        [FStar_TypeChecker_Env.Reify;
        FStar_TypeChecker_Env.UnfoldUntil FStar_Syntax_Syntax.delta_constant;
        FStar_TypeChecker_Env.Primops;
        FStar_TypeChecker_Env.Simplify;
        FStar_TypeChecker_Env.UnfoldTac;
        FStar_TypeChecker_Env.Unmeta]  in
      let t1 = normalize steps e t  in is_true t1
  
let (get_guard_policy : unit -> FStar_Tactics_Types.guard_policy tac) =
  fun uu____2512  ->
    bind get (fun ps  -> ret ps.FStar_Tactics_Types.guard_policy)
  
let (set_guard_policy : FStar_Tactics_Types.guard_policy -> unit tac) =
  fun pol  ->
    bind get
      (fun ps  ->
         set
           (let uu___387_2530 = ps  in
            {
              FStar_Tactics_Types.main_context =
                (uu___387_2530.FStar_Tactics_Types.main_context);
              FStar_Tactics_Types.main_goal =
                (uu___387_2530.FStar_Tactics_Types.main_goal);
              FStar_Tactics_Types.all_implicits =
                (uu___387_2530.FStar_Tactics_Types.all_implicits);
              FStar_Tactics_Types.goals =
                (uu___387_2530.FStar_Tactics_Types.goals);
              FStar_Tactics_Types.smt_goals =
                (uu___387_2530.FStar_Tactics_Types.smt_goals);
              FStar_Tactics_Types.depth =
                (uu___387_2530.FStar_Tactics_Types.depth);
              FStar_Tactics_Types.__dump =
                (uu___387_2530.FStar_Tactics_Types.__dump);
              FStar_Tactics_Types.psc =
                (uu___387_2530.FStar_Tactics_Types.psc);
              FStar_Tactics_Types.entry_range =
                (uu___387_2530.FStar_Tactics_Types.entry_range);
              FStar_Tactics_Types.guard_policy = pol;
              FStar_Tactics_Types.freshness =
                (uu___387_2530.FStar_Tactics_Types.freshness);
              FStar_Tactics_Types.tac_verb_dbg =
                (uu___387_2530.FStar_Tactics_Types.tac_verb_dbg);
              FStar_Tactics_Types.local_state =
                (uu___387_2530.FStar_Tactics_Types.local_state)
            }))
  
let with_policy : 'a . FStar_Tactics_Types.guard_policy -> 'a tac -> 'a tac =
  fun pol  ->
    fun t  ->
      let uu____2554 = get_guard_policy ()  in
      bind uu____2554
        (fun old_pol  ->
           let uu____2560 = set_guard_policy pol  in
           bind uu____2560
             (fun uu____2564  ->
                bind t
                  (fun r  ->
                     let uu____2568 = set_guard_policy old_pol  in
                     bind uu____2568 (fun uu____2572  -> ret r))))
  
let (getopts : FStar_Options.optionstate tac) =
  let uu____2575 = let uu____2580 = cur_goal ()  in trytac uu____2580  in
  bind uu____2575
    (fun uu___350_2587  ->
       match uu___350_2587 with
       | FStar_Pervasives_Native.Some g -> ret g.FStar_Tactics_Types.opts
       | FStar_Pervasives_Native.None  ->
           let uu____2593 = FStar_Options.peek ()  in ret uu____2593)
  
let (proc_guard :
  Prims.string -> env -> FStar_TypeChecker_Env.guard_t -> unit tac) =
  fun reason  ->
    fun e  ->
      fun g  ->
        mlog
          (fun uu____2615  ->
             let uu____2616 = FStar_TypeChecker_Rel.guard_to_string e g  in
             FStar_Util.print2 "Processing guard (%s:%s)\n" reason uu____2616)
          (fun uu____2619  ->
             let uu____2620 = add_implicits g.FStar_TypeChecker_Env.implicits
                in
             bind uu____2620
               (fun uu____2624  ->
                  bind getopts
                    (fun opts  ->
                       let uu____2628 =
                         let uu____2629 =
                           FStar_TypeChecker_Rel.simplify_guard e g  in
                         uu____2629.FStar_TypeChecker_Env.guard_f  in
                       match uu____2628 with
                       | FStar_TypeChecker_Common.Trivial  -> ret ()
                       | FStar_TypeChecker_Common.NonTrivial f ->
                           let uu____2633 = istrivial e f  in
                           if uu____2633
                           then ret ()
                           else
                             bind get
                               (fun ps  ->
                                  match ps.FStar_Tactics_Types.guard_policy
                                  with
                                  | FStar_Tactics_Types.Drop  ->
                                      ((let uu____2643 =
                                          let uu____2648 =
                                            let uu____2649 =
                                              FStar_TypeChecker_Rel.guard_to_string
                                                e g
                                               in
                                            FStar_Util.format1
                                              "Tactics admitted guard <%s>\n\n"
                                              uu____2649
                                             in
                                          (FStar_Errors.Warning_TacAdmit,
                                            uu____2648)
                                           in
                                        FStar_Errors.log_issue
                                          e.FStar_TypeChecker_Env.range
                                          uu____2643);
                                       ret ())
                                  | FStar_Tactics_Types.Goal  ->
                                      mlog
                                        (fun uu____2652  ->
                                           let uu____2653 =
                                             FStar_TypeChecker_Rel.guard_to_string
                                               e g
                                              in
                                           FStar_Util.print2
                                             "Making guard (%s:%s) into a goal\n"
                                             reason uu____2653)
                                        (fun uu____2656  ->
                                           let uu____2657 =
                                             mk_irrelevant_goal reason e f
                                               opts ""
                                              in
                                           bind uu____2657
                                             (fun goal  ->
                                                let goal1 =
                                                  let uu___388_2664 = goal
                                                     in
                                                  {
                                                    FStar_Tactics_Types.goal_main_env
                                                      =
                                                      (uu___388_2664.FStar_Tactics_Types.goal_main_env);
                                                    FStar_Tactics_Types.goal_ctx_uvar
                                                      =
                                                      (uu___388_2664.FStar_Tactics_Types.goal_ctx_uvar);
                                                    FStar_Tactics_Types.opts
                                                      =
                                                      (uu___388_2664.FStar_Tactics_Types.opts);
                                                    FStar_Tactics_Types.is_guard
                                                      = true;
                                                    FStar_Tactics_Types.label
                                                      =
                                                      (uu___388_2664.FStar_Tactics_Types.label)
                                                  }  in
                                                push_goals [goal1]))
                                  | FStar_Tactics_Types.SMT  ->
                                      mlog
                                        (fun uu____2667  ->
                                           let uu____2668 =
                                             FStar_TypeChecker_Rel.guard_to_string
                                               e g
                                              in
                                           FStar_Util.print2
                                             "Sending guard (%s:%s) to SMT goal\n"
                                             reason uu____2668)
                                        (fun uu____2671  ->
                                           let uu____2672 =
                                             mk_irrelevant_goal reason e f
                                               opts ""
                                              in
                                           bind uu____2672
                                             (fun goal  ->
                                                let goal1 =
                                                  let uu___389_2679 = goal
                                                     in
                                                  {
                                                    FStar_Tactics_Types.goal_main_env
                                                      =
                                                      (uu___389_2679.FStar_Tactics_Types.goal_main_env);
                                                    FStar_Tactics_Types.goal_ctx_uvar
                                                      =
                                                      (uu___389_2679.FStar_Tactics_Types.goal_ctx_uvar);
                                                    FStar_Tactics_Types.opts
                                                      =
                                                      (uu___389_2679.FStar_Tactics_Types.opts);
                                                    FStar_Tactics_Types.is_guard
                                                      = true;
                                                    FStar_Tactics_Types.label
                                                      =
                                                      (uu___389_2679.FStar_Tactics_Types.label)
                                                  }  in
                                                push_smt_goals [goal1]))
                                  | FStar_Tactics_Types.Force  ->
                                      mlog
                                        (fun uu____2682  ->
                                           let uu____2683 =
                                             FStar_TypeChecker_Rel.guard_to_string
                                               e g
                                              in
                                           FStar_Util.print2
                                             "Forcing guard (%s:%s)\n" reason
                                             uu____2683)
                                        (fun uu____2685  ->
                                           try
                                             (fun uu___391_2690  ->
                                                match () with
                                                | () ->
                                                    let uu____2693 =
                                                      let uu____2694 =
                                                        let uu____2695 =
                                                          FStar_TypeChecker_Rel.discharge_guard_no_smt
                                                            e g
                                                           in
                                                        FStar_All.pipe_left
                                                          FStar_TypeChecker_Env.is_trivial
                                                          uu____2695
                                                         in
                                                      Prims.op_Negation
                                                        uu____2694
                                                       in
                                                    if uu____2693
                                                    then
                                                      mlog
                                                        (fun uu____2700  ->
                                                           let uu____2701 =
                                                             FStar_TypeChecker_Rel.guard_to_string
                                                               e g
                                                              in
                                                           FStar_Util.print1
                                                             "guard = %s\n"
                                                             uu____2701)
                                                        (fun uu____2703  ->
                                                           fail1
                                                             "Forcing the guard failed (%s)"
                                                             reason)
                                                    else ret ()) ()
                                           with
                                           | uu___390_2706 ->
                                               mlog
                                                 (fun uu____2711  ->
                                                    let uu____2712 =
                                                      FStar_TypeChecker_Rel.guard_to_string
                                                        e g
                                                       in
                                                    FStar_Util.print1
                                                      "guard = %s\n"
                                                      uu____2712)
                                                 (fun uu____2714  ->
                                                    fail1
                                                      "Forcing the guard failed (%s)"
                                                      reason))))))
  
let (tc : FStar_Syntax_Syntax.term -> FStar_Reflection_Data.typ tac) =
  fun t  ->
    let uu____2724 =
      let uu____2727 = cur_goal ()  in
      bind uu____2727
        (fun goal  ->
           let uu____2733 =
             let uu____2742 = FStar_Tactics_Types.goal_env goal  in
             __tc_lax uu____2742 t  in
           bind uu____2733
             (fun uu____2753  ->
                match uu____2753 with
                | (uu____2762,typ,uu____2764) -> ret typ))
       in
    FStar_All.pipe_left (wrap_err "tc") uu____2724
  
let (add_irrelevant_goal :
  Prims.string ->
    env ->
      FStar_Reflection_Data.typ ->
        FStar_Options.optionstate -> Prims.string -> unit tac)
  =
  fun reason  ->
    fun env  ->
      fun phi  ->
        fun opts  ->
          fun label1  ->
            let uu____2798 = mk_irrelevant_goal reason env phi opts label1
               in
            bind uu____2798 (fun goal  -> add_goals [goal])
  
let (trivial : unit -> unit tac) =
  fun uu____2809  ->
    let uu____2812 = cur_goal ()  in
    bind uu____2812
      (fun goal  ->
         let uu____2818 =
           let uu____2819 = FStar_Tactics_Types.goal_env goal  in
           let uu____2820 = FStar_Tactics_Types.goal_type goal  in
           istrivial uu____2819 uu____2820  in
         if uu____2818
         then solve' goal FStar_Syntax_Util.exp_unit
         else
           (let uu____2824 =
              let uu____2825 = FStar_Tactics_Types.goal_env goal  in
              let uu____2826 = FStar_Tactics_Types.goal_type goal  in
              tts uu____2825 uu____2826  in
            fail1 "Not a trivial goal: %s" uu____2824))
  
let divide :
  'a 'b .
    FStar_BigInt.t ->
      'a tac -> 'b tac -> ('a,'b) FStar_Pervasives_Native.tuple2 tac
  =
  fun n1  ->
    fun l  ->
      fun r  ->
        bind get
          (fun p  ->
             let uu____2875 =
               try
                 (fun uu___396_2898  ->
                    match () with
                    | () ->
                        let uu____2909 =
                          let uu____2918 = FStar_BigInt.to_int_fs n1  in
                          FStar_List.splitAt uu____2918
                            p.FStar_Tactics_Types.goals
                           in
                        ret uu____2909) ()
               with | uu___395_2928 -> fail "divide: not enough goals"  in
             bind uu____2875
               (fun uu____2964  ->
                  match uu____2964 with
                  | (lgs,rgs) ->
                      let lp =
                        let uu___392_2990 = p  in
                        {
                          FStar_Tactics_Types.main_context =
                            (uu___392_2990.FStar_Tactics_Types.main_context);
                          FStar_Tactics_Types.main_goal =
                            (uu___392_2990.FStar_Tactics_Types.main_goal);
                          FStar_Tactics_Types.all_implicits =
                            (uu___392_2990.FStar_Tactics_Types.all_implicits);
                          FStar_Tactics_Types.goals = lgs;
                          FStar_Tactics_Types.smt_goals = [];
                          FStar_Tactics_Types.depth =
                            (uu___392_2990.FStar_Tactics_Types.depth);
                          FStar_Tactics_Types.__dump =
                            (uu___392_2990.FStar_Tactics_Types.__dump);
                          FStar_Tactics_Types.psc =
                            (uu___392_2990.FStar_Tactics_Types.psc);
                          FStar_Tactics_Types.entry_range =
                            (uu___392_2990.FStar_Tactics_Types.entry_range);
                          FStar_Tactics_Types.guard_policy =
                            (uu___392_2990.FStar_Tactics_Types.guard_policy);
                          FStar_Tactics_Types.freshness =
                            (uu___392_2990.FStar_Tactics_Types.freshness);
                          FStar_Tactics_Types.tac_verb_dbg =
                            (uu___392_2990.FStar_Tactics_Types.tac_verb_dbg);
                          FStar_Tactics_Types.local_state =
                            (uu___392_2990.FStar_Tactics_Types.local_state)
                        }  in
                      let uu____2991 = set lp  in
                      bind uu____2991
                        (fun uu____2999  ->
                           bind l
                             (fun a  ->
                                bind get
                                  (fun lp'  ->
                                     let rp =
                                       let uu___393_3015 = lp'  in
                                       {
                                         FStar_Tactics_Types.main_context =
                                           (uu___393_3015.FStar_Tactics_Types.main_context);
                                         FStar_Tactics_Types.main_goal =
                                           (uu___393_3015.FStar_Tactics_Types.main_goal);
                                         FStar_Tactics_Types.all_implicits =
                                           (uu___393_3015.FStar_Tactics_Types.all_implicits);
                                         FStar_Tactics_Types.goals = rgs;
                                         FStar_Tactics_Types.smt_goals = [];
                                         FStar_Tactics_Types.depth =
                                           (uu___393_3015.FStar_Tactics_Types.depth);
                                         FStar_Tactics_Types.__dump =
                                           (uu___393_3015.FStar_Tactics_Types.__dump);
                                         FStar_Tactics_Types.psc =
                                           (uu___393_3015.FStar_Tactics_Types.psc);
                                         FStar_Tactics_Types.entry_range =
                                           (uu___393_3015.FStar_Tactics_Types.entry_range);
                                         FStar_Tactics_Types.guard_policy =
                                           (uu___393_3015.FStar_Tactics_Types.guard_policy);
                                         FStar_Tactics_Types.freshness =
                                           (uu___393_3015.FStar_Tactics_Types.freshness);
                                         FStar_Tactics_Types.tac_verb_dbg =
                                           (uu___393_3015.FStar_Tactics_Types.tac_verb_dbg);
                                         FStar_Tactics_Types.local_state =
                                           (uu___393_3015.FStar_Tactics_Types.local_state)
                                       }  in
                                     let uu____3016 = set rp  in
                                     bind uu____3016
                                       (fun uu____3024  ->
                                          bind r
                                            (fun b  ->
                                               bind get
                                                 (fun rp'  ->
                                                    let p' =
                                                      let uu___394_3040 = rp'
                                                         in
                                                      {
                                                        FStar_Tactics_Types.main_context
                                                          =
                                                          (uu___394_3040.FStar_Tactics_Types.main_context);
                                                        FStar_Tactics_Types.main_goal
                                                          =
                                                          (uu___394_3040.FStar_Tactics_Types.main_goal);
                                                        FStar_Tactics_Types.all_implicits
                                                          =
                                                          (uu___394_3040.FStar_Tactics_Types.all_implicits);
                                                        FStar_Tactics_Types.goals
                                                          =
                                                          (FStar_List.append
                                                             lp'.FStar_Tactics_Types.goals
                                                             rp'.FStar_Tactics_Types.goals);
                                                        FStar_Tactics_Types.smt_goals
                                                          =
                                                          (FStar_List.append
                                                             lp'.FStar_Tactics_Types.smt_goals
                                                             (FStar_List.append
                                                                rp'.FStar_Tactics_Types.smt_goals
                                                                p.FStar_Tactics_Types.smt_goals));
                                                        FStar_Tactics_Types.depth
                                                          =
                                                          (uu___394_3040.FStar_Tactics_Types.depth);
                                                        FStar_Tactics_Types.__dump
                                                          =
                                                          (uu___394_3040.FStar_Tactics_Types.__dump);
                                                        FStar_Tactics_Types.psc
                                                          =
                                                          (uu___394_3040.FStar_Tactics_Types.psc);
                                                        FStar_Tactics_Types.entry_range
                                                          =
                                                          (uu___394_3040.FStar_Tactics_Types.entry_range);
                                                        FStar_Tactics_Types.guard_policy
                                                          =
                                                          (uu___394_3040.FStar_Tactics_Types.guard_policy);
                                                        FStar_Tactics_Types.freshness
                                                          =
                                                          (uu___394_3040.FStar_Tactics_Types.freshness);
                                                        FStar_Tactics_Types.tac_verb_dbg
                                                          =
                                                          (uu___394_3040.FStar_Tactics_Types.tac_verb_dbg);
                                                        FStar_Tactics_Types.local_state
                                                          =
                                                          (uu___394_3040.FStar_Tactics_Types.local_state)
                                                      }  in
                                                    let uu____3041 = set p'
                                                       in
                                                    bind uu____3041
                                                      (fun uu____3049  ->
                                                         bind
                                                           remove_solved_goals
                                                           (fun uu____3055 
                                                              -> ret (a, b)))))))))))
  
let focus : 'a . 'a tac -> 'a tac =
  fun f  ->
    let uu____3076 = divide FStar_BigInt.one f idtac  in
    bind uu____3076
      (fun uu____3089  -> match uu____3089 with | (a,()) -> ret a)
  
let rec map : 'a . 'a tac -> 'a Prims.list tac =
  fun tau  ->
    bind get
      (fun p  ->
         match p.FStar_Tactics_Types.goals with
         | [] -> ret []
         | uu____3126::uu____3127 ->
             let uu____3130 =
               let uu____3139 = map tau  in
               divide FStar_BigInt.one tau uu____3139  in
             bind uu____3130
               (fun uu____3157  ->
                  match uu____3157 with | (h,t) -> ret (h :: t)))
  
let (seq : unit tac -> unit tac -> unit tac) =
  fun t1  ->
    fun t2  ->
      let uu____3198 =
        bind t1
          (fun uu____3203  ->
             let uu____3204 = map t2  in
             bind uu____3204 (fun uu____3212  -> ret ()))
         in
      focus uu____3198
  
let (intro : unit -> FStar_Syntax_Syntax.binder tac) =
  fun uu____3221  ->
    let uu____3224 =
      let uu____3227 = cur_goal ()  in
      bind uu____3227
        (fun goal  ->
           let uu____3236 =
             let uu____3243 = FStar_Tactics_Types.goal_type goal  in
             FStar_Syntax_Util.arrow_one uu____3243  in
           match uu____3236 with
           | FStar_Pervasives_Native.Some (b,c) ->
               let uu____3252 =
                 let uu____3253 = FStar_Syntax_Util.is_total_comp c  in
                 Prims.op_Negation uu____3253  in
               if uu____3252
               then fail "Codomain is effectful"
               else
                 (let env' =
                    let uu____3258 = FStar_Tactics_Types.goal_env goal  in
                    FStar_TypeChecker_Env.push_binders uu____3258 [b]  in
                  let typ' = comp_to_typ c  in
                  let uu____3272 = new_uvar "intro" env' typ'  in
                  bind uu____3272
                    (fun uu____3288  ->
                       match uu____3288 with
                       | (body,ctx_uvar) ->
                           let sol =
                             FStar_Syntax_Util.abs [b] body
                               (FStar_Pervasives_Native.Some
                                  (FStar_Syntax_Util.residual_comp_of_comp c))
                              in
                           let uu____3312 = set_solution goal sol  in
                           bind uu____3312
                             (fun uu____3318  ->
                                let g =
                                  FStar_Tactics_Types.mk_goal env' ctx_uvar
                                    goal.FStar_Tactics_Types.opts
                                    goal.FStar_Tactics_Types.is_guard
                                    goal.FStar_Tactics_Types.label
                                   in
                                let uu____3320 =
                                  let uu____3323 = bnorm_goal g  in
                                  replace_cur uu____3323  in
                                bind uu____3320 (fun uu____3325  -> ret b))))
           | FStar_Pervasives_Native.None  ->
               let uu____3330 =
                 let uu____3331 = FStar_Tactics_Types.goal_env goal  in
                 let uu____3332 = FStar_Tactics_Types.goal_type goal  in
                 tts uu____3331 uu____3332  in
               fail1 "goal is not an arrow (%s)" uu____3330)
       in
    FStar_All.pipe_left (wrap_err "intro") uu____3224
  
let (intro_rec :
  unit ->
    (FStar_Syntax_Syntax.binder,FStar_Syntax_Syntax.binder)
      FStar_Pervasives_Native.tuple2 tac)
  =
  fun uu____3347  ->
    let uu____3354 = cur_goal ()  in
    bind uu____3354
      (fun goal  ->
         FStar_Util.print_string
           "WARNING (intro_rec): calling this is known to cause normalizer loops\n";
         FStar_Util.print_string
           "WARNING (intro_rec): proceed at your own risk...\n";
         (let uu____3371 =
            let uu____3378 = FStar_Tactics_Types.goal_type goal  in
            FStar_Syntax_Util.arrow_one uu____3378  in
          match uu____3371 with
          | FStar_Pervasives_Native.Some (b,c) ->
              let uu____3391 =
                let uu____3392 = FStar_Syntax_Util.is_total_comp c  in
                Prims.op_Negation uu____3392  in
              if uu____3391
              then fail "Codomain is effectful"
              else
                (let bv =
                   let uu____3405 = FStar_Tactics_Types.goal_type goal  in
                   FStar_Syntax_Syntax.gen_bv "__recf"
                     FStar_Pervasives_Native.None uu____3405
                    in
                 let bs =
                   let uu____3415 = FStar_Syntax_Syntax.mk_binder bv  in
                   [uu____3415; b]  in
                 let env' =
                   let uu____3441 = FStar_Tactics_Types.goal_env goal  in
                   FStar_TypeChecker_Env.push_binders uu____3441 bs  in
                 let uu____3442 =
                   let uu____3449 = comp_to_typ c  in
                   new_uvar "intro_rec" env' uu____3449  in
                 bind uu____3442
                   (fun uu____3468  ->
                      match uu____3468 with
                      | (u,ctx_uvar_u) ->
                          let lb =
                            let uu____3482 =
                              FStar_Tactics_Types.goal_type goal  in
                            let uu____3485 =
                              FStar_Syntax_Util.abs [b] u
                                FStar_Pervasives_Native.None
                               in
                            FStar_Syntax_Util.mk_letbinding
                              (FStar_Util.Inl bv) [] uu____3482
                              FStar_Parser_Const.effect_Tot_lid uu____3485 []
                              FStar_Range.dummyRange
                             in
                          let body = FStar_Syntax_Syntax.bv_to_name bv  in
                          let uu____3503 =
                            FStar_Syntax_Subst.close_let_rec [lb] body  in
                          (match uu____3503 with
                           | (lbs,body1) ->
                               let tm =
                                 let uu____3525 =
                                   let uu____3526 =
                                     FStar_Tactics_Types.goal_witness goal
                                      in
                                   uu____3526.FStar_Syntax_Syntax.pos  in
                                 FStar_Syntax_Syntax.mk
                                   (FStar_Syntax_Syntax.Tm_let
                                      ((true, lbs), body1))
                                   FStar_Pervasives_Native.None uu____3525
                                  in
                               let uu____3539 = set_solution goal tm  in
                               bind uu____3539
                                 (fun uu____3548  ->
                                    let uu____3549 =
                                      let uu____3552 =
                                        bnorm_goal
                                          (let uu___397_3555 = goal  in
                                           {
                                             FStar_Tactics_Types.goal_main_env
                                               =
                                               (uu___397_3555.FStar_Tactics_Types.goal_main_env);
                                             FStar_Tactics_Types.goal_ctx_uvar
                                               = ctx_uvar_u;
                                             FStar_Tactics_Types.opts =
                                               (uu___397_3555.FStar_Tactics_Types.opts);
                                             FStar_Tactics_Types.is_guard =
                                               (uu___397_3555.FStar_Tactics_Types.is_guard);
                                             FStar_Tactics_Types.label =
                                               (uu___397_3555.FStar_Tactics_Types.label)
                                           })
                                         in
                                      replace_cur uu____3552  in
                                    bind uu____3549
                                      (fun uu____3562  ->
                                         let uu____3563 =
                                           let uu____3568 =
                                             FStar_Syntax_Syntax.mk_binder bv
                                              in
                                           (uu____3568, b)  in
                                         ret uu____3563)))))
          | FStar_Pervasives_Native.None  ->
              let uu____3577 =
                let uu____3578 = FStar_Tactics_Types.goal_env goal  in
                let uu____3579 = FStar_Tactics_Types.goal_type goal  in
                tts uu____3578 uu____3579  in
              fail1 "intro_rec: goal is not an arrow (%s)" uu____3577))
  
let (norm : FStar_Syntax_Embeddings.norm_step Prims.list -> unit tac) =
  fun s  ->
    let uu____3597 = cur_goal ()  in
    bind uu____3597
      (fun goal  ->
         mlog
           (fun uu____3604  ->
              let uu____3605 =
                let uu____3606 = FStar_Tactics_Types.goal_witness goal  in
                FStar_Syntax_Print.term_to_string uu____3606  in
              FStar_Util.print1 "norm: witness = %s\n" uu____3605)
           (fun uu____3611  ->
              let steps =
                let uu____3615 = FStar_TypeChecker_Normalize.tr_norm_steps s
                   in
                FStar_List.append
                  [FStar_TypeChecker_Env.Reify;
                  FStar_TypeChecker_Env.UnfoldTac] uu____3615
                 in
              let t =
                let uu____3619 = FStar_Tactics_Types.goal_env goal  in
                let uu____3620 = FStar_Tactics_Types.goal_type goal  in
                normalize steps uu____3619 uu____3620  in
              let uu____3621 = FStar_Tactics_Types.goal_with_type goal t  in
              replace_cur uu____3621))
  
let (norm_term_env :
  env ->
    FStar_Syntax_Embeddings.norm_step Prims.list ->
      FStar_Syntax_Syntax.term -> FStar_Syntax_Syntax.term tac)
  =
  fun e  ->
    fun s  ->
      fun t  ->
        let uu____3645 =
          bind get
            (fun ps  ->
               let opts =
                 match ps.FStar_Tactics_Types.goals with
                 | g::uu____3653 -> g.FStar_Tactics_Types.opts
                 | uu____3656 -> FStar_Options.peek ()  in
               mlog
                 (fun uu____3661  ->
                    let uu____3662 = FStar_Syntax_Print.term_to_string t  in
                    FStar_Util.print1 "norm_term_env: t = %s\n" uu____3662)
                 (fun uu____3665  ->
                    let uu____3666 = __tc_lax e t  in
                    bind uu____3666
                      (fun uu____3687  ->
                         match uu____3687 with
                         | (t1,uu____3697,uu____3698) ->
                             let steps =
                               let uu____3702 =
                                 FStar_TypeChecker_Normalize.tr_norm_steps s
                                  in
                               FStar_List.append
                                 [FStar_TypeChecker_Env.Reify;
                                 FStar_TypeChecker_Env.UnfoldTac] uu____3702
                                in
                             let t2 =
                               normalize steps
                                 ps.FStar_Tactics_Types.main_context t1
                                in
                             mlog
                               (fun uu____3708  ->
                                  let uu____3709 =
                                    FStar_Syntax_Print.term_to_string t2  in
                                  FStar_Util.print1
                                    "norm_term_env: t' = %s\n" uu____3709)
                               (fun uu____3711  -> ret t2))))
           in
        FStar_All.pipe_left (wrap_err "norm_term") uu____3645
  
let (refine_intro : unit -> unit tac) =
  fun uu____3722  ->
    let uu____3725 =
      let uu____3728 = cur_goal ()  in
      bind uu____3728
        (fun g  ->
           let uu____3735 =
             let uu____3746 = FStar_Tactics_Types.goal_env g  in
             let uu____3747 = FStar_Tactics_Types.goal_type g  in
             FStar_TypeChecker_Rel.base_and_refinement uu____3746 uu____3747
              in
           match uu____3735 with
           | (uu____3750,FStar_Pervasives_Native.None ) ->
               fail "not a refinement"
           | (t,FStar_Pervasives_Native.Some (bv,phi)) ->
               let g1 = FStar_Tactics_Types.goal_with_type g t  in
               let uu____3775 =
                 let uu____3780 =
                   let uu____3785 =
                     let uu____3786 = FStar_Syntax_Syntax.mk_binder bv  in
                     [uu____3786]  in
                   FStar_Syntax_Subst.open_term uu____3785 phi  in
                 match uu____3780 with
                 | (bvs,phi1) ->
                     let uu____3811 =
                       let uu____3812 = FStar_List.hd bvs  in
                       FStar_Pervasives_Native.fst uu____3812  in
                     (uu____3811, phi1)
                  in
               (match uu____3775 with
                | (bv1,phi1) ->
                    let uu____3831 =
                      let uu____3834 = FStar_Tactics_Types.goal_env g  in
                      let uu____3835 =
                        let uu____3836 =
                          let uu____3839 =
                            let uu____3840 =
                              let uu____3847 =
                                FStar_Tactics_Types.goal_witness g  in
                              (bv1, uu____3847)  in
                            FStar_Syntax_Syntax.NT uu____3840  in
                          [uu____3839]  in
                        FStar_Syntax_Subst.subst uu____3836 phi1  in
                      mk_irrelevant_goal "refine_intro refinement" uu____3834
                        uu____3835 g.FStar_Tactics_Types.opts
                        g.FStar_Tactics_Types.label
                       in
                    bind uu____3831
                      (fun g2  ->
                         bind __dismiss
                           (fun uu____3855  -> add_goals [g1; g2]))))
       in
    FStar_All.pipe_left (wrap_err "refine_intro") uu____3725
  
let (__exact_now : Prims.bool -> FStar_Syntax_Syntax.term -> unit tac) =
  fun set_expected_typ1  ->
    fun t  ->
      let uu____3874 = cur_goal ()  in
      bind uu____3874
        (fun goal  ->
           let env =
             if set_expected_typ1
             then
               let uu____3882 = FStar_Tactics_Types.goal_env goal  in
               let uu____3883 = FStar_Tactics_Types.goal_type goal  in
               FStar_TypeChecker_Env.set_expected_typ uu____3882 uu____3883
             else FStar_Tactics_Types.goal_env goal  in
           let uu____3885 = __tc env t  in
           bind uu____3885
             (fun uu____3904  ->
                match uu____3904 with
                | (t1,typ,guard) ->
                    mlog
                      (fun uu____3919  ->
                         let uu____3920 =
                           FStar_Syntax_Print.term_to_string typ  in
                         let uu____3921 =
                           let uu____3922 = FStar_Tactics_Types.goal_env goal
                              in
                           FStar_TypeChecker_Rel.guard_to_string uu____3922
                             guard
                            in
                         FStar_Util.print2
                           "__exact_now: got type %s\n__exact_now: and guard %s\n"
                           uu____3920 uu____3921)
                      (fun uu____3925  ->
                         let uu____3926 =
                           let uu____3929 = FStar_Tactics_Types.goal_env goal
                              in
                           proc_guard "__exact typing" uu____3929 guard  in
                         bind uu____3926
                           (fun uu____3931  ->
                              mlog
                                (fun uu____3935  ->
                                   let uu____3936 =
                                     FStar_Syntax_Print.term_to_string typ
                                      in
                                   let uu____3937 =
                                     let uu____3938 =
                                       FStar_Tactics_Types.goal_type goal  in
                                     FStar_Syntax_Print.term_to_string
                                       uu____3938
                                      in
                                   FStar_Util.print2
                                     "__exact_now: unifying %s and %s\n"
                                     uu____3936 uu____3937)
                                (fun uu____3941  ->
                                   let uu____3942 =
                                     let uu____3945 =
                                       FStar_Tactics_Types.goal_env goal  in
                                     let uu____3946 =
                                       FStar_Tactics_Types.goal_type goal  in
                                     do_unify uu____3945 typ uu____3946  in
                                   bind uu____3942
                                     (fun b  ->
                                        if b
                                        then solve goal t1
                                        else
                                          (let uu____3952 =
                                             let uu____3953 =
                                               FStar_Tactics_Types.goal_env
                                                 goal
                                                in
                                             tts uu____3953 t1  in
                                           let uu____3954 =
                                             let uu____3955 =
                                               FStar_Tactics_Types.goal_env
                                                 goal
                                                in
                                             tts uu____3955 typ  in
                                           let uu____3956 =
                                             let uu____3957 =
                                               FStar_Tactics_Types.goal_env
                                                 goal
                                                in
                                             let uu____3958 =
                                               FStar_Tactics_Types.goal_type
                                                 goal
                                                in
                                             tts uu____3957 uu____3958  in
                                           let uu____3959 =
                                             let uu____3960 =
                                               FStar_Tactics_Types.goal_env
                                                 goal
                                                in
                                             let uu____3961 =
                                               FStar_Tactics_Types.goal_witness
                                                 goal
                                                in
                                             tts uu____3960 uu____3961  in
                                           fail4
                                             "%s : %s does not exactly solve the goal %s (witness = %s)"
                                             uu____3952 uu____3954 uu____3956
                                             uu____3959)))))))
  
let (t_exact :
  Prims.bool -> Prims.bool -> FStar_Syntax_Syntax.term -> unit tac) =
  fun try_refine  ->
    fun set_expected_typ1  ->
      fun tm  ->
        let uu____3981 =
          mlog
            (fun uu____3986  ->
               let uu____3987 = FStar_Syntax_Print.term_to_string tm  in
               FStar_Util.print1 "t_exact: tm = %s\n" uu____3987)
            (fun uu____3990  ->
               let uu____3991 =
                 let uu____3998 = __exact_now set_expected_typ1 tm  in
                 catch uu____3998  in
               bind uu____3991
                 (fun uu___352_4007  ->
                    match uu___352_4007 with
                    | FStar_Util.Inr r -> ret ()
                    | FStar_Util.Inl e when Prims.op_Negation try_refine ->
                        fail e
                    | FStar_Util.Inl e ->
                        mlog
                          (fun uu____4018  ->
                             FStar_Util.print_string
                               "__exact_now failed, trying refine...\n")
                          (fun uu____4021  ->
                             let uu____4022 =
                               let uu____4029 =
                                 let uu____4032 =
                                   norm [FStar_Syntax_Embeddings.Delta]  in
                                 bind uu____4032
                                   (fun uu____4037  ->
                                      let uu____4038 = refine_intro ()  in
                                      bind uu____4038
                                        (fun uu____4042  ->
                                           __exact_now set_expected_typ1 tm))
                                  in
                               catch uu____4029  in
                             bind uu____4022
                               (fun uu___351_4049  ->
                                  match uu___351_4049 with
                                  | FStar_Util.Inr r ->
                                      mlog
                                        (fun uu____4058  ->
                                           FStar_Util.print_string
                                             "__exact_now: failed after refining too\n")
                                        (fun uu____4060  -> ret ())
                                  | FStar_Util.Inl uu____4061 ->
                                      mlog
                                        (fun uu____4063  ->
                                           FStar_Util.print_string
                                             "__exact_now: was not a refinement\n")
                                        (fun uu____4065  -> fail e)))))
           in
        FStar_All.pipe_left (wrap_err "exact") uu____3981
  
let rec mapM : 'a 'b . ('a -> 'b tac) -> 'a Prims.list -> 'b Prims.list tac =
  fun f  ->
    fun l  ->
      match l with
      | [] -> ret []
      | x::xs ->
          let uu____4115 = f x  in
          bind uu____4115
            (fun y  ->
               let uu____4123 = mapM f xs  in
               bind uu____4123 (fun ys  -> ret (y :: ys)))
  
let rec (__try_match_by_application :
  (FStar_Syntax_Syntax.term,FStar_Syntax_Syntax.aqual,FStar_Syntax_Syntax.ctx_uvar)
    FStar_Pervasives_Native.tuple3 Prims.list ->
    env ->
      FStar_Syntax_Syntax.term ->
        FStar_Syntax_Syntax.term ->
          (FStar_Syntax_Syntax.term,FStar_Syntax_Syntax.aqual,FStar_Syntax_Syntax.ctx_uvar)
            FStar_Pervasives_Native.tuple3 Prims.list tac)
  =
  fun acc  ->
    fun e  ->
      fun ty1  ->
        fun ty2  ->
          let uu____4194 = do_unify e ty1 ty2  in
          bind uu____4194
            (fun uu___353_4206  ->
               if uu___353_4206
               then ret acc
               else
                 (let uu____4225 = FStar_Syntax_Util.arrow_one ty1  in
                  match uu____4225 with
                  | FStar_Pervasives_Native.None  ->
                      let uu____4246 = FStar_Syntax_Print.term_to_string ty1
                         in
                      let uu____4247 = FStar_Syntax_Print.term_to_string ty2
                         in
                      fail2 "Could not instantiate, %s to %s" uu____4246
                        uu____4247
                  | FStar_Pervasives_Native.Some (b,c) ->
                      let uu____4262 =
                        let uu____4263 = FStar_Syntax_Util.is_total_comp c
                           in
                        Prims.op_Negation uu____4263  in
                      if uu____4262
                      then fail "Codomain is effectful"
                      else
                        (let uu____4283 =
                           new_uvar "apply arg" e
                             (FStar_Pervasives_Native.fst b).FStar_Syntax_Syntax.sort
                            in
                         bind uu____4283
                           (fun uu____4309  ->
                              match uu____4309 with
                              | (uvt,uv) ->
                                  let typ = comp_to_typ c  in
                                  let typ' =
                                    FStar_Syntax_Subst.subst
                                      [FStar_Syntax_Syntax.NT
                                         ((FStar_Pervasives_Native.fst b),
                                           uvt)] typ
                                     in
                                  __try_match_by_application
                                    ((uvt, (FStar_Pervasives_Native.snd b),
                                       uv) :: acc) e typ' ty2))))
  
let (try_match_by_application :
  env ->
    FStar_Syntax_Syntax.term ->
      FStar_Syntax_Syntax.term ->
        (FStar_Syntax_Syntax.term,FStar_Syntax_Syntax.aqual,FStar_Syntax_Syntax.ctx_uvar)
          FStar_Pervasives_Native.tuple3 Prims.list tac)
  = fun e  -> fun ty1  -> fun ty2  -> __try_match_by_application [] e ty1 ty2 
let (t_apply : Prims.bool -> FStar_Syntax_Syntax.term -> unit tac) =
  fun uopt  ->
    fun tm  ->
      let uu____4395 =
        mlog
          (fun uu____4400  ->
             let uu____4401 = FStar_Syntax_Print.term_to_string tm  in
             FStar_Util.print1 "t_apply: tm = %s\n" uu____4401)
          (fun uu____4404  ->
             let uu____4405 = cur_goal ()  in
             bind uu____4405
               (fun goal  ->
                  let e = FStar_Tactics_Types.goal_env goal  in
                  let uu____4413 = __tc e tm  in
                  bind uu____4413
                    (fun uu____4434  ->
                       match uu____4434 with
                       | (tm1,typ,guard) ->
                           let typ1 = bnorm e typ  in
                           let uu____4447 =
                             let uu____4458 =
                               FStar_Tactics_Types.goal_type goal  in
                             try_match_by_application e typ1 uu____4458  in
                           bind uu____4447
                             (fun uvs  ->
                                let w =
                                  FStar_List.fold_right
                                    (fun uu____4501  ->
                                       fun w  ->
                                         match uu____4501 with
                                         | (uvt,q,uu____4519) ->
                                             FStar_Syntax_Util.mk_app w
                                               [(uvt, q)]) uvs tm1
                                   in
                                let uvset =
                                  let uu____4551 =
                                    FStar_Syntax_Free.new_uv_set ()  in
                                  FStar_List.fold_right
                                    (fun uu____4568  ->
                                       fun s  ->
                                         match uu____4568 with
                                         | (uu____4580,uu____4581,uv) ->
                                             let uu____4583 =
                                               FStar_Syntax_Free.uvars
                                                 uv.FStar_Syntax_Syntax.ctx_uvar_typ
                                                in
                                             FStar_Util.set_union s
                                               uu____4583) uvs uu____4551
                                   in
                                let free_in_some_goal uv =
                                  FStar_Util.set_mem uv uvset  in
                                let uu____4592 = solve' goal w  in
                                bind uu____4592
                                  (fun uu____4597  ->
                                     let uu____4598 =
                                       mapM
                                         (fun uu____4615  ->
                                            match uu____4615 with
                                            | (uvt,q,uv) ->
                                                let uu____4627 =
                                                  FStar_Syntax_Unionfind.find
                                                    uv.FStar_Syntax_Syntax.ctx_uvar_head
                                                   in
                                                (match uu____4627 with
                                                 | FStar_Pervasives_Native.Some
                                                     uu____4632 -> ret ()
                                                 | FStar_Pervasives_Native.None
                                                      ->
                                                     let uu____4633 =
                                                       uopt &&
                                                         (free_in_some_goal
                                                            uv)
                                                        in
                                                     if uu____4633
                                                     then ret ()
                                                     else
                                                       (let uu____4637 =
                                                          let uu____4640 =
                                                            bnorm_goal
                                                              (let uu___398_4643
                                                                 = goal  in
                                                               {
                                                                 FStar_Tactics_Types.goal_main_env
                                                                   =
                                                                   (uu___398_4643.FStar_Tactics_Types.goal_main_env);
                                                                 FStar_Tactics_Types.goal_ctx_uvar
                                                                   = uv;
                                                                 FStar_Tactics_Types.opts
                                                                   =
                                                                   (uu___398_4643.FStar_Tactics_Types.opts);
                                                                 FStar_Tactics_Types.is_guard
                                                                   = false;
                                                                 FStar_Tactics_Types.label
                                                                   =
                                                                   (uu___398_4643.FStar_Tactics_Types.label)
                                                               })
                                                             in
                                                          [uu____4640]  in
                                                        add_goals uu____4637)))
                                         uvs
                                        in
                                     bind uu____4598
                                       (fun uu____4647  ->
                                          proc_guard "apply guard" e guard))))))
         in
      FStar_All.pipe_left (wrap_err "apply") uu____4395
  
let (lemma_or_sq :
  FStar_Syntax_Syntax.comp ->
    (FStar_Syntax_Syntax.term,FStar_Syntax_Syntax.term)
      FStar_Pervasives_Native.tuple2 FStar_Pervasives_Native.option)
  =
  fun c  ->
    let ct = FStar_Syntax_Util.comp_to_comp_typ_nouniv c  in
    let uu____4672 =
      FStar_Ident.lid_equals ct.FStar_Syntax_Syntax.effect_name
        FStar_Parser_Const.effect_Lemma_lid
       in
    if uu____4672
    then
      let uu____4679 =
        match ct.FStar_Syntax_Syntax.effect_args with
        | pre::post::uu____4694 ->
            ((FStar_Pervasives_Native.fst pre),
              (FStar_Pervasives_Native.fst post))
        | uu____4747 -> failwith "apply_lemma: impossible: not a lemma"  in
      match uu____4679 with
      | (pre,post) ->
          let post1 =
            let uu____4779 =
              let uu____4790 =
                FStar_Syntax_Syntax.as_arg FStar_Syntax_Util.exp_unit  in
              [uu____4790]  in
            FStar_Syntax_Util.mk_app post uu____4779  in
          FStar_Pervasives_Native.Some (pre, post1)
    else
      (let uu____4820 =
         FStar_Syntax_Util.is_pure_effect ct.FStar_Syntax_Syntax.effect_name
          in
       if uu____4820
       then
         let uu____4827 =
           FStar_Syntax_Util.un_squash ct.FStar_Syntax_Syntax.result_typ  in
         FStar_Util.map_opt uu____4827
           (fun post  -> (FStar_Syntax_Util.t_true, post))
       else FStar_Pervasives_Native.None)
  
let (apply_lemma : FStar_Syntax_Syntax.term -> unit tac) =
  fun tm  ->
    let uu____4860 =
      let uu____4863 =
        bind get
          (fun ps  ->
             mlog
               (fun uu____4870  ->
                  let uu____4871 = FStar_Syntax_Print.term_to_string tm  in
                  FStar_Util.print1 "apply_lemma: tm = %s\n" uu____4871)
               (fun uu____4875  ->
                  let is_unit_t t =
                    let uu____4882 =
                      let uu____4883 = FStar_Syntax_Subst.compress t  in
                      uu____4883.FStar_Syntax_Syntax.n  in
                    match uu____4882 with
                    | FStar_Syntax_Syntax.Tm_fvar fv when
                        FStar_Syntax_Syntax.fv_eq_lid fv
                          FStar_Parser_Const.unit_lid
                        -> true
                    | uu____4887 -> false  in
                  let uu____4888 = cur_goal ()  in
                  bind uu____4888
                    (fun goal  ->
                       let uu____4894 =
                         let uu____4903 = FStar_Tactics_Types.goal_env goal
                            in
                         __tc uu____4903 tm  in
                       bind uu____4894
                         (fun uu____4918  ->
                            match uu____4918 with
                            | (tm1,t,guard) ->
                                let uu____4930 =
                                  FStar_Syntax_Util.arrow_formals_comp t  in
                                (match uu____4930 with
                                 | (bs,comp) ->
                                     let uu____4963 = lemma_or_sq comp  in
                                     (match uu____4963 with
                                      | FStar_Pervasives_Native.None  ->
                                          fail
                                            "not a lemma or squashed function"
                                      | FStar_Pervasives_Native.Some
                                          (pre,post) ->
                                          let uu____4982 =
                                            FStar_List.fold_left
                                              (fun uu____5030  ->
                                                 fun uu____5031  ->
                                                   match (uu____5030,
                                                           uu____5031)
                                                   with
                                                   | ((uvs,guard1,subst1),
                                                      (b,aq)) ->
                                                       let b_t =
                                                         FStar_Syntax_Subst.subst
                                                           subst1
                                                           b.FStar_Syntax_Syntax.sort
                                                          in
                                                       let uu____5144 =
                                                         is_unit_t b_t  in
                                                       if uu____5144
                                                       then
                                                         (((FStar_Syntax_Util.exp_unit,
                                                             aq) :: uvs),
                                                           guard1,
                                                           ((FStar_Syntax_Syntax.NT
                                                               (b,
                                                                 FStar_Syntax_Util.exp_unit))
                                                           :: subst1))
                                                       else
                                                         (let uu____5182 =
                                                            let uu____5195 =
                                                              let uu____5196
                                                                =
                                                                FStar_Tactics_Types.goal_type
                                                                  goal
                                                                 in
                                                              uu____5196.FStar_Syntax_Syntax.pos
                                                               in
                                                            let uu____5199 =
                                                              FStar_Tactics_Types.goal_env
                                                                goal
                                                               in
                                                            FStar_TypeChecker_Util.new_implicit_var
                                                              "apply_lemma"
                                                              uu____5195
                                                              uu____5199 b_t
                                                             in
                                                          match uu____5182
                                                          with
                                                          | (u,uu____5217,g_u)
                                                              ->
                                                              let uu____5231
                                                                =
                                                                FStar_TypeChecker_Env.conj_guard
                                                                  guard1 g_u
                                                                 in
                                                              (((u, aq) ::
                                                                uvs),
                                                                uu____5231,
                                                                ((FStar_Syntax_Syntax.NT
                                                                    (b, u))
                                                                :: subst1))))
                                              ([], guard, []) bs
                                             in
                                          (match uu____4982 with
                                           | (uvs,implicits,subst1) ->
                                               let uvs1 = FStar_List.rev uvs
                                                  in
                                               let pre1 =
                                                 FStar_Syntax_Subst.subst
                                                   subst1 pre
                                                  in
                                               let post1 =
                                                 FStar_Syntax_Subst.subst
                                                   subst1 post
                                                  in
                                               let uu____5310 =
                                                 let uu____5313 =
                                                   FStar_Tactics_Types.goal_env
                                                     goal
                                                    in
                                                 let uu____5314 =
                                                   FStar_Syntax_Util.mk_squash
                                                     FStar_Syntax_Syntax.U_zero
                                                     post1
                                                    in
                                                 let uu____5315 =
                                                   FStar_Tactics_Types.goal_type
                                                     goal
                                                    in
                                                 do_unify uu____5313
                                                   uu____5314 uu____5315
                                                  in
                                               bind uu____5310
                                                 (fun b  ->
                                                    if Prims.op_Negation b
                                                    then
                                                      let uu____5323 =
                                                        let uu____5324 =
                                                          FStar_Tactics_Types.goal_env
                                                            goal
                                                           in
                                                        tts uu____5324 tm1
                                                         in
                                                      let uu____5325 =
                                                        let uu____5326 =
                                                          FStar_Tactics_Types.goal_env
                                                            goal
                                                           in
                                                        let uu____5327 =
                                                          FStar_Syntax_Util.mk_squash
                                                            FStar_Syntax_Syntax.U_zero
                                                            post1
                                                           in
                                                        tts uu____5326
                                                          uu____5327
                                                         in
                                                      let uu____5328 =
                                                        let uu____5329 =
                                                          FStar_Tactics_Types.goal_env
                                                            goal
                                                           in
                                                        let uu____5330 =
                                                          FStar_Tactics_Types.goal_type
                                                            goal
                                                           in
                                                        tts uu____5329
                                                          uu____5330
                                                         in
                                                      fail3
                                                        "Cannot instantiate lemma %s (with postcondition: %s) to match goal (%s)"
                                                        uu____5323 uu____5325
                                                        uu____5328
                                                    else
                                                      (let uu____5332 =
                                                         add_implicits
                                                           implicits.FStar_TypeChecker_Env.implicits
                                                          in
                                                       bind uu____5332
                                                         (fun uu____5337  ->
                                                            let uu____5338 =
                                                              solve' goal
                                                                FStar_Syntax_Util.exp_unit
                                                               in
                                                            bind uu____5338
                                                              (fun uu____5346
                                                                  ->
                                                                 let is_free_uvar
                                                                   uv t1 =
                                                                   let free_uvars
                                                                    =
                                                                    let uu____5371
                                                                    =
                                                                    let uu____5374
                                                                    =
                                                                    FStar_Syntax_Free.uvars
                                                                    t1  in
                                                                    FStar_Util.set_elements
                                                                    uu____5374
                                                                     in
                                                                    FStar_List.map
                                                                    (fun x 
                                                                    ->
                                                                    x.FStar_Syntax_Syntax.ctx_uvar_head)
                                                                    uu____5371
                                                                     in
                                                                   FStar_List.existsML
                                                                    (fun u 
                                                                    ->
                                                                    FStar_Syntax_Unionfind.equiv
                                                                    u uv)
                                                                    free_uvars
                                                                    in
                                                                 let appears
                                                                   uv goals =
                                                                   FStar_List.existsML
                                                                    (fun g' 
                                                                    ->
                                                                    let uu____5409
                                                                    =
                                                                    FStar_Tactics_Types.goal_type
                                                                    g'  in
                                                                    is_free_uvar
                                                                    uv
                                                                    uu____5409)
                                                                    goals
                                                                    in
                                                                 let checkone
                                                                   t1 goals =
                                                                   let uu____5425
                                                                    =
                                                                    FStar_Syntax_Util.head_and_args
                                                                    t1  in
                                                                   match uu____5425
                                                                   with
                                                                   | 
                                                                   (hd1,uu____5443)
                                                                    ->
                                                                    (match 
                                                                    hd1.FStar_Syntax_Syntax.n
                                                                    with
                                                                    | 
                                                                    FStar_Syntax_Syntax.Tm_uvar
                                                                    (uv,uu____5469)
                                                                    ->
                                                                    appears
                                                                    uv.FStar_Syntax_Syntax.ctx_uvar_head
                                                                    goals
                                                                    | 
                                                                    uu____5486
                                                                    -> false)
                                                                    in
                                                                 let uu____5487
                                                                   =
                                                                   FStar_All.pipe_right
                                                                    implicits.FStar_TypeChecker_Env.implicits
                                                                    (mapM
                                                                    (fun imp 
                                                                    ->
                                                                    let term
                                                                    =
                                                                    imp.FStar_TypeChecker_Env.imp_tm
                                                                     in
                                                                    let ctx_uvar
                                                                    =
                                                                    imp.FStar_TypeChecker_Env.imp_uvar
                                                                     in
                                                                    let uu____5517
                                                                    =
                                                                    FStar_Syntax_Util.head_and_args
                                                                    term  in
                                                                    match uu____5517
                                                                    with
                                                                    | 
                                                                    (hd1,uu____5539)
                                                                    ->
                                                                    let uu____5564
                                                                    =
                                                                    let uu____5565
                                                                    =
                                                                    FStar_Syntax_Subst.compress
                                                                    hd1  in
                                                                    uu____5565.FStar_Syntax_Syntax.n
                                                                     in
                                                                    (match uu____5564
                                                                    with
                                                                    | 
                                                                    FStar_Syntax_Syntax.Tm_uvar
                                                                    (ctx_uvar1,uu____5573)
                                                                    ->
                                                                    let goal1
                                                                    =
                                                                    bnorm_goal
                                                                    (let uu___399_5593
                                                                    = goal
                                                                     in
                                                                    {
                                                                    FStar_Tactics_Types.goal_main_env
                                                                    =
                                                                    (uu___399_5593.FStar_Tactics_Types.goal_main_env);
                                                                    FStar_Tactics_Types.goal_ctx_uvar
                                                                    =
                                                                    ctx_uvar1;
                                                                    FStar_Tactics_Types.opts
                                                                    =
                                                                    (uu___399_5593.FStar_Tactics_Types.opts);
                                                                    FStar_Tactics_Types.is_guard
                                                                    =
                                                                    (uu___399_5593.FStar_Tactics_Types.is_guard);
                                                                    FStar_Tactics_Types.label
                                                                    =
                                                                    (uu___399_5593.FStar_Tactics_Types.label)
                                                                    })  in
                                                                    ret
                                                                    [goal1]
                                                                    | 
                                                                    uu____5596
                                                                    ->
                                                                    mlog
                                                                    (fun
                                                                    uu____5602
                                                                     ->
                                                                    let uu____5603
                                                                    =
                                                                    FStar_Syntax_Print.uvar_to_string
                                                                    ctx_uvar.FStar_Syntax_Syntax.ctx_uvar_head
                                                                     in
                                                                    let uu____5604
                                                                    =
                                                                    FStar_Syntax_Print.term_to_string
                                                                    term  in
                                                                    FStar_Util.print2
                                                                    "apply_lemma: arg %s unified to (%s)\n"
                                                                    uu____5603
                                                                    uu____5604)
                                                                    (fun
                                                                    uu____5609
                                                                     ->
                                                                    let env =
                                                                    let uu___400_5611
                                                                    =
                                                                    FStar_Tactics_Types.goal_env
                                                                    goal  in
                                                                    {
                                                                    FStar_TypeChecker_Env.solver
                                                                    =
                                                                    (uu___400_5611.FStar_TypeChecker_Env.solver);
                                                                    FStar_TypeChecker_Env.range
                                                                    =
                                                                    (uu___400_5611.FStar_TypeChecker_Env.range);
                                                                    FStar_TypeChecker_Env.curmodule
                                                                    =
                                                                    (uu___400_5611.FStar_TypeChecker_Env.curmodule);
                                                                    FStar_TypeChecker_Env.gamma
                                                                    =
                                                                    (ctx_uvar.FStar_Syntax_Syntax.ctx_uvar_gamma);
                                                                    FStar_TypeChecker_Env.gamma_sig
                                                                    =
                                                                    (uu___400_5611.FStar_TypeChecker_Env.gamma_sig);
                                                                    FStar_TypeChecker_Env.gamma_cache
                                                                    =
                                                                    (uu___400_5611.FStar_TypeChecker_Env.gamma_cache);
                                                                    FStar_TypeChecker_Env.modules
                                                                    =
                                                                    (uu___400_5611.FStar_TypeChecker_Env.modules);
                                                                    FStar_TypeChecker_Env.expected_typ
                                                                    =
                                                                    (uu___400_5611.FStar_TypeChecker_Env.expected_typ);
                                                                    FStar_TypeChecker_Env.sigtab
                                                                    =
                                                                    (uu___400_5611.FStar_TypeChecker_Env.sigtab);
                                                                    FStar_TypeChecker_Env.attrtab
                                                                    =
                                                                    (uu___400_5611.FStar_TypeChecker_Env.attrtab);
                                                                    FStar_TypeChecker_Env.is_pattern
                                                                    =
                                                                    (uu___400_5611.FStar_TypeChecker_Env.is_pattern);
                                                                    FStar_TypeChecker_Env.instantiate_imp
                                                                    =
                                                                    (uu___400_5611.FStar_TypeChecker_Env.instantiate_imp);
                                                                    FStar_TypeChecker_Env.effects
                                                                    =
                                                                    (uu___400_5611.FStar_TypeChecker_Env.effects);
                                                                    FStar_TypeChecker_Env.generalize
                                                                    =
                                                                    (uu___400_5611.FStar_TypeChecker_Env.generalize);
                                                                    FStar_TypeChecker_Env.letrecs
                                                                    =
                                                                    (uu___400_5611.FStar_TypeChecker_Env.letrecs);
                                                                    FStar_TypeChecker_Env.top_level
                                                                    =
                                                                    (uu___400_5611.FStar_TypeChecker_Env.top_level);
                                                                    FStar_TypeChecker_Env.check_uvars
                                                                    =
                                                                    (uu___400_5611.FStar_TypeChecker_Env.check_uvars);
                                                                    FStar_TypeChecker_Env.use_eq
                                                                    =
                                                                    (uu___400_5611.FStar_TypeChecker_Env.use_eq);
                                                                    FStar_TypeChecker_Env.is_iface
                                                                    =
                                                                    (uu___400_5611.FStar_TypeChecker_Env.is_iface);
                                                                    FStar_TypeChecker_Env.admit
                                                                    =
                                                                    (uu___400_5611.FStar_TypeChecker_Env.admit);
                                                                    FStar_TypeChecker_Env.lax
                                                                    =
                                                                    (uu___400_5611.FStar_TypeChecker_Env.lax);
                                                                    FStar_TypeChecker_Env.lax_universes
                                                                    =
                                                                    (uu___400_5611.FStar_TypeChecker_Env.lax_universes);
                                                                    FStar_TypeChecker_Env.phase1
                                                                    =
                                                                    (uu___400_5611.FStar_TypeChecker_Env.phase1);
                                                                    FStar_TypeChecker_Env.failhard
                                                                    =
                                                                    (uu___400_5611.FStar_TypeChecker_Env.failhard);
                                                                    FStar_TypeChecker_Env.nosynth
                                                                    =
                                                                    (uu___400_5611.FStar_TypeChecker_Env.nosynth);
                                                                    FStar_TypeChecker_Env.uvar_subtyping
                                                                    =
                                                                    (uu___400_5611.FStar_TypeChecker_Env.uvar_subtyping);
                                                                    FStar_TypeChecker_Env.tc_term
                                                                    =
                                                                    (uu___400_5611.FStar_TypeChecker_Env.tc_term);
                                                                    FStar_TypeChecker_Env.type_of
                                                                    =
                                                                    (uu___400_5611.FStar_TypeChecker_Env.type_of);
                                                                    FStar_TypeChecker_Env.universe_of
                                                                    =
                                                                    (uu___400_5611.FStar_TypeChecker_Env.universe_of);
                                                                    FStar_TypeChecker_Env.check_type_of
                                                                    =
                                                                    (uu___400_5611.FStar_TypeChecker_Env.check_type_of);
                                                                    FStar_TypeChecker_Env.use_bv_sorts
                                                                    =
                                                                    (uu___400_5611.FStar_TypeChecker_Env.use_bv_sorts);
                                                                    FStar_TypeChecker_Env.qtbl_name_and_index
                                                                    =
                                                                    (uu___400_5611.FStar_TypeChecker_Env.qtbl_name_and_index);
                                                                    FStar_TypeChecker_Env.normalized_eff_names
                                                                    =
                                                                    (uu___400_5611.FStar_TypeChecker_Env.normalized_eff_names);
                                                                    FStar_TypeChecker_Env.fv_delta_depths
                                                                    =
                                                                    (uu___400_5611.FStar_TypeChecker_Env.fv_delta_depths);
                                                                    FStar_TypeChecker_Env.proof_ns
                                                                    =
                                                                    (uu___400_5611.FStar_TypeChecker_Env.proof_ns);
                                                                    FStar_TypeChecker_Env.synth_hook
                                                                    =
                                                                    (uu___400_5611.FStar_TypeChecker_Env.synth_hook);
                                                                    FStar_TypeChecker_Env.splice
                                                                    =
                                                                    (uu___400_5611.FStar_TypeChecker_Env.splice);
                                                                    FStar_TypeChecker_Env.postprocess
                                                                    =
                                                                    (uu___400_5611.FStar_TypeChecker_Env.postprocess);
                                                                    FStar_TypeChecker_Env.is_native_tactic
                                                                    =
                                                                    (uu___400_5611.FStar_TypeChecker_Env.is_native_tactic);
                                                                    FStar_TypeChecker_Env.identifier_info
                                                                    =
                                                                    (uu___400_5611.FStar_TypeChecker_Env.identifier_info);
                                                                    FStar_TypeChecker_Env.tc_hooks
                                                                    =
                                                                    (uu___400_5611.FStar_TypeChecker_Env.tc_hooks);
                                                                    FStar_TypeChecker_Env.dsenv
                                                                    =
                                                                    (uu___400_5611.FStar_TypeChecker_Env.dsenv);
                                                                    FStar_TypeChecker_Env.nbe
                                                                    =
                                                                    (uu___400_5611.FStar_TypeChecker_Env.nbe)
                                                                    }  in
                                                                    let g_typ
                                                                    =
                                                                    FStar_TypeChecker_TcTerm.check_type_of_well_typed_term'
                                                                    true env
                                                                    term
                                                                    ctx_uvar.FStar_Syntax_Syntax.ctx_uvar_typ
                                                                     in
                                                                    let uu____5613
                                                                    =
                                                                    let uu____5616
                                                                    =
                                                                    if
                                                                    ps.FStar_Tactics_Types.tac_verb_dbg
                                                                    then
                                                                    let uu____5617
                                                                    =
                                                                    FStar_Syntax_Print.ctx_uvar_to_string
                                                                    ctx_uvar
                                                                     in
                                                                    let uu____5618
                                                                    =
                                                                    FStar_Syntax_Print.term_to_string
                                                                    term  in
                                                                    FStar_Util.format2
                                                                    "apply_lemma solved arg %s to %s\n"
                                                                    uu____5617
                                                                    uu____5618
                                                                    else
                                                                    "apply_lemma solved arg"
                                                                     in
                                                                    let uu____5620
                                                                    =
                                                                    FStar_Tactics_Types.goal_env
                                                                    goal  in
                                                                    proc_guard
                                                                    uu____5616
                                                                    uu____5620
                                                                    g_typ  in
                                                                    bind
                                                                    uu____5613
                                                                    (fun
                                                                    uu____5624
                                                                     ->
                                                                    ret [])))))
                                                                    in
                                                                 bind
                                                                   uu____5487
                                                                   (fun
                                                                    sub_goals
                                                                     ->
                                                                    let sub_goals1
                                                                    =
                                                                    FStar_List.flatten
                                                                    sub_goals
                                                                     in
                                                                    let rec filter'
                                                                    f xs =
                                                                    match xs
                                                                    with
                                                                    | 
                                                                    [] -> []
                                                                    | 
                                                                    x::xs1 ->
                                                                    let uu____5686
                                                                    = f x xs1
                                                                     in
                                                                    if
                                                                    uu____5686
                                                                    then
                                                                    let uu____5689
                                                                    =
                                                                    filter' f
                                                                    xs1  in x
                                                                    ::
                                                                    uu____5689
                                                                    else
                                                                    filter' f
                                                                    xs1  in
                                                                    let sub_goals2
                                                                    =
                                                                    filter'
                                                                    (fun g 
                                                                    ->
                                                                    fun goals
                                                                     ->
                                                                    let uu____5703
                                                                    =
                                                                    let uu____5704
                                                                    =
                                                                    FStar_Tactics_Types.goal_witness
                                                                    g  in
                                                                    checkone
                                                                    uu____5704
                                                                    goals  in
                                                                    Prims.op_Negation
                                                                    uu____5703)
                                                                    sub_goals1
                                                                     in
                                                                    let uu____5705
                                                                    =
                                                                    let uu____5708
                                                                    =
                                                                    FStar_Tactics_Types.goal_env
                                                                    goal  in
                                                                    proc_guard
                                                                    "apply_lemma guard"
                                                                    uu____5708
                                                                    guard  in
                                                                    bind
                                                                    uu____5705
                                                                    (fun
                                                                    uu____5711
                                                                     ->
                                                                    let uu____5712
                                                                    =
                                                                    let uu____5715
                                                                    =
                                                                    let uu____5716
                                                                    =
                                                                    let uu____5717
                                                                    =
                                                                    FStar_Tactics_Types.goal_env
                                                                    goal  in
                                                                    let uu____5718
                                                                    =
                                                                    FStar_Syntax_Util.mk_squash
                                                                    FStar_Syntax_Syntax.U_zero
                                                                    pre1  in
                                                                    istrivial
                                                                    uu____5717
                                                                    uu____5718
                                                                     in
                                                                    Prims.op_Negation
                                                                    uu____5716
                                                                     in
                                                                    if
                                                                    uu____5715
                                                                    then
                                                                    let uu____5721
                                                                    =
                                                                    FStar_Tactics_Types.goal_env
                                                                    goal  in
                                                                    add_irrelevant_goal
                                                                    "apply_lemma precondition"
                                                                    uu____5721
                                                                    pre1
                                                                    goal.FStar_Tactics_Types.opts
                                                                    goal.FStar_Tactics_Types.label
                                                                    else
                                                                    ret ()
                                                                     in
                                                                    bind
                                                                    uu____5712
                                                                    (fun
                                                                    uu____5724
                                                                     ->
                                                                    add_goals
                                                                    sub_goals2))))))))))))))
         in
      focus uu____4863  in
    FStar_All.pipe_left (wrap_err "apply_lemma") uu____4860
  
let (destruct_eq' :
  FStar_Reflection_Data.typ ->
    (FStar_Syntax_Syntax.term,FStar_Syntax_Syntax.term)
      FStar_Pervasives_Native.tuple2 FStar_Pervasives_Native.option)
  =
  fun typ  ->
    let uu____5746 = FStar_Syntax_Util.destruct_typ_as_formula typ  in
    match uu____5746 with
    | FStar_Pervasives_Native.Some (FStar_Syntax_Util.BaseConn
        (l,uu____5756::(e1,uu____5758)::(e2,uu____5760)::[])) when
        FStar_Ident.lid_equals l FStar_Parser_Const.eq2_lid ->
        FStar_Pervasives_Native.Some (e1, e2)
    | uu____5821 -> FStar_Pervasives_Native.None
  
let (destruct_eq :
  FStar_Reflection_Data.typ ->
    (FStar_Syntax_Syntax.term,FStar_Syntax_Syntax.term)
      FStar_Pervasives_Native.tuple2 FStar_Pervasives_Native.option)
  =
  fun typ  ->
    let uu____5845 = destruct_eq' typ  in
    match uu____5845 with
    | FStar_Pervasives_Native.Some t -> FStar_Pervasives_Native.Some t
    | FStar_Pervasives_Native.None  ->
        let uu____5875 = FStar_Syntax_Util.un_squash typ  in
        (match uu____5875 with
         | FStar_Pervasives_Native.Some typ1 -> destruct_eq' typ1
         | FStar_Pervasives_Native.None  -> FStar_Pervasives_Native.None)
  
let (split_env :
  FStar_Syntax_Syntax.bv ->
    env ->
      (env,FStar_Syntax_Syntax.bv Prims.list) FStar_Pervasives_Native.tuple2
        FStar_Pervasives_Native.option)
  =
  fun bvar  ->
    fun e  ->
      let rec aux e1 =
        let uu____5937 = FStar_TypeChecker_Env.pop_bv e1  in
        match uu____5937 with
        | FStar_Pervasives_Native.None  -> FStar_Pervasives_Native.None
        | FStar_Pervasives_Native.Some (bv',e') ->
            if FStar_Syntax_Syntax.bv_eq bvar bv'
            then FStar_Pervasives_Native.Some (e', [])
            else
              (let uu____5985 = aux e'  in
               FStar_Util.map_opt uu____5985
                 (fun uu____6009  ->
                    match uu____6009 with | (e'',bvs) -> (e'', (bv' :: bvs))))
         in
      let uu____6030 = aux e  in
      FStar_Util.map_opt uu____6030
        (fun uu____6054  ->
           match uu____6054 with | (e',bvs) -> (e', (FStar_List.rev bvs)))
  
let (push_bvs :
  FStar_TypeChecker_Env.env ->
    FStar_Syntax_Syntax.bv Prims.list -> FStar_TypeChecker_Env.env)
  =
  fun e  ->
    fun bvs  ->
      FStar_List.fold_left
        (fun e1  -> fun b  -> FStar_TypeChecker_Env.push_bv e1 b) e bvs
  
let (subst_goal :
  FStar_Syntax_Syntax.bv ->
    FStar_Syntax_Syntax.bv ->
      FStar_Syntax_Syntax.subst_elt Prims.list ->
        FStar_Tactics_Types.goal ->
          FStar_Tactics_Types.goal FStar_Pervasives_Native.option)
  =
  fun b1  ->
    fun b2  ->
      fun s  ->
        fun g  ->
          let uu____6121 =
            let uu____6130 = FStar_Tactics_Types.goal_env g  in
            split_env b1 uu____6130  in
          FStar_Util.map_opt uu____6121
            (fun uu____6145  ->
               match uu____6145 with
               | (e0,bvs) ->
                   let s1 bv =
                     let uu___401_6164 = bv  in
                     let uu____6165 =
                       FStar_Syntax_Subst.subst s bv.FStar_Syntax_Syntax.sort
                        in
                     {
                       FStar_Syntax_Syntax.ppname =
                         (uu___401_6164.FStar_Syntax_Syntax.ppname);
                       FStar_Syntax_Syntax.index =
                         (uu___401_6164.FStar_Syntax_Syntax.index);
                       FStar_Syntax_Syntax.sort = uu____6165
                     }  in
                   let bvs1 = FStar_List.map s1 bvs  in
                   let new_env = push_bvs e0 (b2 :: bvs1)  in
                   let new_goal =
                     let uu___402_6173 = g.FStar_Tactics_Types.goal_ctx_uvar
                        in
                     let uu____6174 =
                       FStar_TypeChecker_Env.all_binders new_env  in
                     let uu____6183 =
                       let uu____6186 = FStar_Tactics_Types.goal_type g  in
                       FStar_Syntax_Subst.subst s uu____6186  in
                     {
                       FStar_Syntax_Syntax.ctx_uvar_head =
                         (uu___402_6173.FStar_Syntax_Syntax.ctx_uvar_head);
                       FStar_Syntax_Syntax.ctx_uvar_gamma =
                         (new_env.FStar_TypeChecker_Env.gamma);
                       FStar_Syntax_Syntax.ctx_uvar_binders = uu____6174;
                       FStar_Syntax_Syntax.ctx_uvar_typ = uu____6183;
                       FStar_Syntax_Syntax.ctx_uvar_reason =
                         (uu___402_6173.FStar_Syntax_Syntax.ctx_uvar_reason);
                       FStar_Syntax_Syntax.ctx_uvar_should_check =
                         (uu___402_6173.FStar_Syntax_Syntax.ctx_uvar_should_check);
                       FStar_Syntax_Syntax.ctx_uvar_range =
                         (uu___402_6173.FStar_Syntax_Syntax.ctx_uvar_range)
                     }  in
                   let uu___403_6187 = g  in
                   {
                     FStar_Tactics_Types.goal_main_env =
                       (uu___403_6187.FStar_Tactics_Types.goal_main_env);
                     FStar_Tactics_Types.goal_ctx_uvar = new_goal;
                     FStar_Tactics_Types.opts =
                       (uu___403_6187.FStar_Tactics_Types.opts);
                     FStar_Tactics_Types.is_guard =
                       (uu___403_6187.FStar_Tactics_Types.is_guard);
                     FStar_Tactics_Types.label =
                       (uu___403_6187.FStar_Tactics_Types.label)
                   })
  
let (rewrite : FStar_Syntax_Syntax.binder -> unit tac) =
  fun h  ->
    let uu____6197 =
      let uu____6200 = cur_goal ()  in
      bind uu____6200
        (fun goal  ->
           let uu____6208 = h  in
           match uu____6208 with
           | (bv,uu____6212) ->
               mlog
                 (fun uu____6220  ->
                    let uu____6221 = FStar_Syntax_Print.bv_to_string bv  in
                    let uu____6222 =
                      FStar_Syntax_Print.term_to_string
                        bv.FStar_Syntax_Syntax.sort
                       in
                    FStar_Util.print2 "+++Rewrite %s : %s\n" uu____6221
                      uu____6222)
                 (fun uu____6225  ->
                    let uu____6226 =
                      let uu____6235 = FStar_Tactics_Types.goal_env goal  in
                      split_env bv uu____6235  in
                    match uu____6226 with
                    | FStar_Pervasives_Native.None  ->
                        fail "binder not found in environment"
                    | FStar_Pervasives_Native.Some (e0,bvs) ->
                        let uu____6256 =
                          destruct_eq bv.FStar_Syntax_Syntax.sort  in
                        (match uu____6256 with
                         | FStar_Pervasives_Native.Some (x,e) ->
                             let uu____6271 =
                               let uu____6272 = FStar_Syntax_Subst.compress x
                                  in
                               uu____6272.FStar_Syntax_Syntax.n  in
                             (match uu____6271 with
                              | FStar_Syntax_Syntax.Tm_name x1 ->
                                  let s = [FStar_Syntax_Syntax.NT (x1, e)]
                                     in
                                  let s1 bv1 =
                                    let uu___404_6289 = bv1  in
                                    let uu____6290 =
                                      FStar_Syntax_Subst.subst s
                                        bv1.FStar_Syntax_Syntax.sort
                                       in
                                    {
                                      FStar_Syntax_Syntax.ppname =
                                        (uu___404_6289.FStar_Syntax_Syntax.ppname);
                                      FStar_Syntax_Syntax.index =
                                        (uu___404_6289.FStar_Syntax_Syntax.index);
                                      FStar_Syntax_Syntax.sort = uu____6290
                                    }  in
                                  let bvs1 = FStar_List.map s1 bvs  in
                                  let new_env = push_bvs e0 (bv :: bvs1)  in
                                  let new_goal =
                                    let uu___405_6298 =
                                      goal.FStar_Tactics_Types.goal_ctx_uvar
                                       in
                                    let uu____6299 =
                                      FStar_TypeChecker_Env.all_binders
                                        new_env
                                       in
                                    let uu____6308 =
                                      let uu____6311 =
                                        FStar_Tactics_Types.goal_type goal
                                         in
                                      FStar_Syntax_Subst.subst s uu____6311
                                       in
                                    {
                                      FStar_Syntax_Syntax.ctx_uvar_head =
                                        (uu___405_6298.FStar_Syntax_Syntax.ctx_uvar_head);
                                      FStar_Syntax_Syntax.ctx_uvar_gamma =
                                        (new_env.FStar_TypeChecker_Env.gamma);
                                      FStar_Syntax_Syntax.ctx_uvar_binders =
                                        uu____6299;
                                      FStar_Syntax_Syntax.ctx_uvar_typ =
                                        uu____6308;
                                      FStar_Syntax_Syntax.ctx_uvar_reason =
                                        (uu___405_6298.FStar_Syntax_Syntax.ctx_uvar_reason);
                                      FStar_Syntax_Syntax.ctx_uvar_should_check
                                        =
                                        (uu___405_6298.FStar_Syntax_Syntax.ctx_uvar_should_check);
                                      FStar_Syntax_Syntax.ctx_uvar_range =
                                        (uu___405_6298.FStar_Syntax_Syntax.ctx_uvar_range)
                                    }  in
                                  replace_cur
                                    (let uu___406_6314 = goal  in
                                     {
                                       FStar_Tactics_Types.goal_main_env =
                                         (uu___406_6314.FStar_Tactics_Types.goal_main_env);
                                       FStar_Tactics_Types.goal_ctx_uvar =
                                         new_goal;
                                       FStar_Tactics_Types.opts =
                                         (uu___406_6314.FStar_Tactics_Types.opts);
                                       FStar_Tactics_Types.is_guard =
                                         (uu___406_6314.FStar_Tactics_Types.is_guard);
                                       FStar_Tactics_Types.label =
                                         (uu___406_6314.FStar_Tactics_Types.label)
                                     })
                              | uu____6315 ->
                                  fail
                                    "Not an equality hypothesis with a variable on the LHS")
                         | uu____6316 -> fail "Not an equality hypothesis")))
       in
    FStar_All.pipe_left (wrap_err "rewrite") uu____6197
  
let (rename_to : FStar_Syntax_Syntax.binder -> Prims.string -> unit tac) =
  fun b  ->
    fun s  ->
      let uu____6341 =
        let uu____6344 = cur_goal ()  in
        bind uu____6344
          (fun goal  ->
             let uu____6355 = b  in
             match uu____6355 with
             | (bv,uu____6359) ->
                 let bv' =
                   let uu____6365 =
                     let uu___407_6366 = bv  in
                     let uu____6367 =
                       FStar_Ident.mk_ident
                         (s,
                           ((bv.FStar_Syntax_Syntax.ppname).FStar_Ident.idRange))
                        in
                     {
                       FStar_Syntax_Syntax.ppname = uu____6367;
                       FStar_Syntax_Syntax.index =
                         (uu___407_6366.FStar_Syntax_Syntax.index);
                       FStar_Syntax_Syntax.sort =
                         (uu___407_6366.FStar_Syntax_Syntax.sort)
                     }  in
                   FStar_Syntax_Syntax.freshen_bv uu____6365  in
                 let s1 =
                   let uu____6371 =
                     let uu____6372 =
                       let uu____6379 = FStar_Syntax_Syntax.bv_to_name bv'
                          in
                       (bv, uu____6379)  in
                     FStar_Syntax_Syntax.NT uu____6372  in
                   [uu____6371]  in
                 let uu____6384 = subst_goal bv bv' s1 goal  in
                 (match uu____6384 with
                  | FStar_Pervasives_Native.None  ->
                      fail "binder not found in environment"
                  | FStar_Pervasives_Native.Some goal1 -> replace_cur goal1))
         in
      FStar_All.pipe_left (wrap_err "rename_to") uu____6341
  
let (binder_retype : FStar_Syntax_Syntax.binder -> unit tac) =
  fun b  ->
    let uu____6403 =
      let uu____6406 = cur_goal ()  in
      bind uu____6406
        (fun goal  ->
           let uu____6415 = b  in
           match uu____6415 with
           | (bv,uu____6419) ->
               let uu____6424 =
                 let uu____6433 = FStar_Tactics_Types.goal_env goal  in
                 split_env bv uu____6433  in
               (match uu____6424 with
                | FStar_Pervasives_Native.None  ->
                    fail "binder is not present in environment"
                | FStar_Pervasives_Native.Some (e0,bvs) ->
                    let uu____6454 = FStar_Syntax_Util.type_u ()  in
                    (match uu____6454 with
                     | (ty,u) ->
                         let uu____6463 = new_uvar "binder_retype" e0 ty  in
                         bind uu____6463
                           (fun uu____6481  ->
                              match uu____6481 with
                              | (t',u_t') ->
                                  let bv'' =
                                    let uu___408_6491 = bv  in
                                    {
                                      FStar_Syntax_Syntax.ppname =
                                        (uu___408_6491.FStar_Syntax_Syntax.ppname);
                                      FStar_Syntax_Syntax.index =
                                        (uu___408_6491.FStar_Syntax_Syntax.index);
                                      FStar_Syntax_Syntax.sort = t'
                                    }  in
                                  let s =
                                    let uu____6495 =
                                      let uu____6496 =
                                        let uu____6503 =
                                          FStar_Syntax_Syntax.bv_to_name bv''
                                           in
                                        (bv, uu____6503)  in
                                      FStar_Syntax_Syntax.NT uu____6496  in
                                    [uu____6495]  in
                                  let bvs1 =
                                    FStar_List.map
                                      (fun b1  ->
                                         let uu___409_6515 = b1  in
                                         let uu____6516 =
                                           FStar_Syntax_Subst.subst s
                                             b1.FStar_Syntax_Syntax.sort
                                            in
                                         {
                                           FStar_Syntax_Syntax.ppname =
                                             (uu___409_6515.FStar_Syntax_Syntax.ppname);
                                           FStar_Syntax_Syntax.index =
                                             (uu___409_6515.FStar_Syntax_Syntax.index);
                                           FStar_Syntax_Syntax.sort =
                                             uu____6516
                                         }) bvs
                                     in
                                  let env' = push_bvs e0 (bv'' :: bvs1)  in
                                  bind __dismiss
                                    (fun uu____6523  ->
                                       let new_goal =
                                         let uu____6525 =
                                           FStar_Tactics_Types.goal_with_env
                                             goal env'
                                            in
                                         let uu____6526 =
                                           let uu____6527 =
                                             FStar_Tactics_Types.goal_type
                                               goal
                                              in
                                           FStar_Syntax_Subst.subst s
                                             uu____6527
                                            in
                                         FStar_Tactics_Types.goal_with_type
                                           uu____6525 uu____6526
                                          in
                                       let uu____6528 = add_goals [new_goal]
                                          in
                                       bind uu____6528
                                         (fun uu____6533  ->
                                            let uu____6534 =
                                              FStar_Syntax_Util.mk_eq2
                                                (FStar_Syntax_Syntax.U_succ u)
                                                ty
                                                bv.FStar_Syntax_Syntax.sort
                                                t'
                                               in
                                            add_irrelevant_goal
                                              "binder_retype equation" e0
                                              uu____6534
                                              goal.FStar_Tactics_Types.opts
                                              goal.FStar_Tactics_Types.label))))))
       in
    FStar_All.pipe_left (wrap_err "binder_retype") uu____6403
  
let (norm_binder_type :
  FStar_Syntax_Embeddings.norm_step Prims.list ->
    FStar_Syntax_Syntax.binder -> unit tac)
  =
  fun s  ->
    fun b  ->
      let uu____6557 =
        let uu____6560 = cur_goal ()  in
        bind uu____6560
          (fun goal  ->
             let uu____6569 = b  in
             match uu____6569 with
             | (bv,uu____6573) ->
                 let uu____6578 =
                   let uu____6587 = FStar_Tactics_Types.goal_env goal  in
                   split_env bv uu____6587  in
                 (match uu____6578 with
                  | FStar_Pervasives_Native.None  ->
                      fail "binder is not present in environment"
                  | FStar_Pervasives_Native.Some (e0,bvs) ->
                      let steps =
                        let uu____6611 =
                          FStar_TypeChecker_Normalize.tr_norm_steps s  in
                        FStar_List.append
                          [FStar_TypeChecker_Env.Reify;
                          FStar_TypeChecker_Env.UnfoldTac] uu____6611
                         in
                      let sort' =
                        normalize steps e0 bv.FStar_Syntax_Syntax.sort  in
                      let bv' =
                        let uu___410_6616 = bv  in
                        {
                          FStar_Syntax_Syntax.ppname =
                            (uu___410_6616.FStar_Syntax_Syntax.ppname);
                          FStar_Syntax_Syntax.index =
                            (uu___410_6616.FStar_Syntax_Syntax.index);
                          FStar_Syntax_Syntax.sort = sort'
                        }  in
                      let env' = push_bvs e0 (bv' :: bvs)  in
                      let uu____6618 =
                        FStar_Tactics_Types.goal_with_env goal env'  in
                      replace_cur uu____6618))
         in
      FStar_All.pipe_left (wrap_err "norm_binder_type") uu____6557
  
let (revert : unit -> unit tac) =
  fun uu____6629  ->
    let uu____6632 = cur_goal ()  in
    bind uu____6632
      (fun goal  ->
         let uu____6638 =
           let uu____6645 = FStar_Tactics_Types.goal_env goal  in
           FStar_TypeChecker_Env.pop_bv uu____6645  in
         match uu____6638 with
         | FStar_Pervasives_Native.None  ->
             fail "Cannot revert; empty context"
         | FStar_Pervasives_Native.Some (x,env') ->
             let typ' =
               let uu____6661 =
                 let uu____6664 = FStar_Tactics_Types.goal_type goal  in
                 FStar_Syntax_Syntax.mk_Total uu____6664  in
               FStar_Syntax_Util.arrow [(x, FStar_Pervasives_Native.None)]
                 uu____6661
                in
             let uu____6679 = new_uvar "revert" env' typ'  in
             bind uu____6679
               (fun uu____6694  ->
                  match uu____6694 with
                  | (r,u_r) ->
                      let uu____6703 =
                        let uu____6706 =
                          let uu____6707 =
                            let uu____6708 =
                              FStar_Tactics_Types.goal_type goal  in
                            uu____6708.FStar_Syntax_Syntax.pos  in
                          let uu____6711 =
                            let uu____6716 =
                              let uu____6717 =
                                let uu____6726 =
                                  FStar_Syntax_Syntax.bv_to_name x  in
                                FStar_Syntax_Syntax.as_arg uu____6726  in
                              [uu____6717]  in
                            FStar_Syntax_Syntax.mk_Tm_app r uu____6716  in
                          uu____6711 FStar_Pervasives_Native.None uu____6707
                           in
                        set_solution goal uu____6706  in
                      bind uu____6703
                        (fun uu____6747  ->
                           let g =
                             FStar_Tactics_Types.mk_goal env' u_r
                               goal.FStar_Tactics_Types.opts
                               goal.FStar_Tactics_Types.is_guard
                               goal.FStar_Tactics_Types.label
                              in
                           replace_cur g)))
  
let (free_in :
  FStar_Syntax_Syntax.bv -> FStar_Syntax_Syntax.term -> Prims.bool) =
  fun bv  ->
    fun t  ->
      let uu____6759 = FStar_Syntax_Free.names t  in
      FStar_Util.set_mem bv uu____6759
  
let rec (clear : FStar_Syntax_Syntax.binder -> unit tac) =
  fun b  ->
    let bv = FStar_Pervasives_Native.fst b  in
    let uu____6774 = cur_goal ()  in
    bind uu____6774
      (fun goal  ->
         mlog
           (fun uu____6782  ->
              let uu____6783 = FStar_Syntax_Print.binder_to_string b  in
              let uu____6784 =
                let uu____6785 =
                  let uu____6786 =
                    let uu____6795 = FStar_Tactics_Types.goal_env goal  in
                    FStar_TypeChecker_Env.all_binders uu____6795  in
                  FStar_All.pipe_right uu____6786 FStar_List.length  in
                FStar_All.pipe_right uu____6785 FStar_Util.string_of_int  in
              FStar_Util.print2 "Clear of (%s), env has %s binders\n"
                uu____6783 uu____6784)
           (fun uu____6812  ->
              let uu____6813 =
                let uu____6822 = FStar_Tactics_Types.goal_env goal  in
                split_env bv uu____6822  in
              match uu____6813 with
              | FStar_Pervasives_Native.None  ->
                  fail "Cannot clear; binder not in environment"
              | FStar_Pervasives_Native.Some (e',bvs) ->
                  let rec check1 bvs1 =
                    match bvs1 with
                    | [] -> ret ()
                    | bv'::bvs2 ->
                        let uu____6861 =
                          free_in bv bv'.FStar_Syntax_Syntax.sort  in
                        if uu____6861
                        then
                          let uu____6864 =
                            let uu____6865 =
                              FStar_Syntax_Print.bv_to_string bv'  in
                            FStar_Util.format1
                              "Cannot clear; binder present in the type of %s"
                              uu____6865
                             in
                          fail uu____6864
                        else check1 bvs2
                     in
                  let uu____6867 =
                    let uu____6868 = FStar_Tactics_Types.goal_type goal  in
                    free_in bv uu____6868  in
                  if uu____6867
                  then fail "Cannot clear; binder present in goal"
                  else
                    (let uu____6872 = check1 bvs  in
                     bind uu____6872
                       (fun uu____6878  ->
                          let env' = push_bvs e' bvs  in
                          let uu____6880 =
                            let uu____6887 =
                              FStar_Tactics_Types.goal_type goal  in
                            new_uvar "clear.witness" env' uu____6887  in
                          bind uu____6880
                            (fun uu____6896  ->
                               match uu____6896 with
                               | (ut,uvar_ut) ->
                                   let uu____6905 = set_solution goal ut  in
                                   bind uu____6905
                                     (fun uu____6910  ->
                                        let uu____6911 =
                                          FStar_Tactics_Types.mk_goal env'
                                            uvar_ut
                                            goal.FStar_Tactics_Types.opts
                                            goal.FStar_Tactics_Types.is_guard
                                            goal.FStar_Tactics_Types.label
                                           in
                                        replace_cur uu____6911))))))
  
let (clear_top : unit -> unit tac) =
  fun uu____6918  ->
    let uu____6921 = cur_goal ()  in
    bind uu____6921
      (fun goal  ->
         let uu____6927 =
           let uu____6934 = FStar_Tactics_Types.goal_env goal  in
           FStar_TypeChecker_Env.pop_bv uu____6934  in
         match uu____6927 with
         | FStar_Pervasives_Native.None  ->
             fail "Cannot clear; empty context"
         | FStar_Pervasives_Native.Some (x,uu____6942) ->
             let uu____6947 = FStar_Syntax_Syntax.mk_binder x  in
             clear uu____6947)
  
let (prune : Prims.string -> unit tac) =
  fun s  ->
    let uu____6957 = cur_goal ()  in
    bind uu____6957
      (fun g  ->
         let ctx = FStar_Tactics_Types.goal_env g  in
         let ctx' =
           let uu____6967 = FStar_Ident.path_of_text s  in
           FStar_TypeChecker_Env.rem_proof_ns ctx uu____6967  in
         let g' = FStar_Tactics_Types.goal_with_env g ctx'  in
         bind __dismiss (fun uu____6970  -> add_goals [g']))
  
let (addns : Prims.string -> unit tac) =
  fun s  ->
    let uu____6980 = cur_goal ()  in
    bind uu____6980
      (fun g  ->
         let ctx = FStar_Tactics_Types.goal_env g  in
         let ctx' =
           let uu____6990 = FStar_Ident.path_of_text s  in
           FStar_TypeChecker_Env.add_proof_ns ctx uu____6990  in
         let g' = FStar_Tactics_Types.goal_with_env g ctx'  in
         bind __dismiss (fun uu____6993  -> add_goals [g']))
  
let rec (tac_fold_env :
  FStar_Tactics_Types.direction ->
    (env -> FStar_Syntax_Syntax.term -> FStar_Syntax_Syntax.term tac) ->
      env -> FStar_Syntax_Syntax.term -> FStar_Syntax_Syntax.term tac)
  =
  fun d  ->
    fun f  ->
      fun env  ->
        fun t  ->
          let tn =
            let uu____7033 = FStar_Syntax_Subst.compress t  in
            uu____7033.FStar_Syntax_Syntax.n  in
          let uu____7036 =
            if d = FStar_Tactics_Types.TopDown
            then
              f env
                (let uu___414_7042 = t  in
                 {
                   FStar_Syntax_Syntax.n = tn;
                   FStar_Syntax_Syntax.pos =
                     (uu___414_7042.FStar_Syntax_Syntax.pos);
                   FStar_Syntax_Syntax.vars =
                     (uu___414_7042.FStar_Syntax_Syntax.vars)
                 })
            else ret t  in
          bind uu____7036
            (fun t1  ->
               let ff = tac_fold_env d f env  in
               let tn1 =
                 let uu____7058 =
                   let uu____7059 = FStar_Syntax_Subst.compress t1  in
                   uu____7059.FStar_Syntax_Syntax.n  in
                 match uu____7058 with
                 | FStar_Syntax_Syntax.Tm_app (hd1,args) ->
                     let uu____7090 = ff hd1  in
                     bind uu____7090
                       (fun hd2  ->
                          let fa uu____7116 =
                            match uu____7116 with
                            | (a,q) ->
                                let uu____7137 = ff a  in
                                bind uu____7137 (fun a1  -> ret (a1, q))
                             in
                          let uu____7156 = mapM fa args  in
                          bind uu____7156
                            (fun args1  ->
                               ret (FStar_Syntax_Syntax.Tm_app (hd2, args1))))
                 | FStar_Syntax_Syntax.Tm_abs (bs,t2,k) ->
                     let uu____7238 = FStar_Syntax_Subst.open_term bs t2  in
                     (match uu____7238 with
                      | (bs1,t') ->
                          let uu____7247 =
                            let uu____7250 =
                              FStar_TypeChecker_Env.push_binders env bs1  in
                            tac_fold_env d f uu____7250 t'  in
                          bind uu____7247
                            (fun t''  ->
                               let uu____7254 =
                                 let uu____7255 =
                                   let uu____7274 =
                                     FStar_Syntax_Subst.close_binders bs1  in
                                   let uu____7283 =
                                     FStar_Syntax_Subst.close bs1 t''  in
                                   (uu____7274, uu____7283, k)  in
                                 FStar_Syntax_Syntax.Tm_abs uu____7255  in
                               ret uu____7254))
                 | FStar_Syntax_Syntax.Tm_arrow (bs,k) -> ret tn
                 | FStar_Syntax_Syntax.Tm_match (hd1,brs) ->
                     let uu____7358 = ff hd1  in
                     bind uu____7358
                       (fun hd2  ->
                          let ffb br =
                            let uu____7373 =
                              FStar_Syntax_Subst.open_branch br  in
                            match uu____7373 with
                            | (pat,w,e) ->
                                let bvs = FStar_Syntax_Syntax.pat_bvs pat  in
                                let ff1 =
                                  let uu____7405 =
                                    FStar_TypeChecker_Env.push_bvs env bvs
                                     in
                                  tac_fold_env d f uu____7405  in
                                let uu____7406 = ff1 e  in
                                bind uu____7406
                                  (fun e1  ->
                                     let br1 =
                                       FStar_Syntax_Subst.close_branch
                                         (pat, w, e1)
                                        in
                                     ret br1)
                             in
                          let uu____7421 = mapM ffb brs  in
                          bind uu____7421
                            (fun brs1  ->
                               ret (FStar_Syntax_Syntax.Tm_match (hd2, brs1))))
                 | FStar_Syntax_Syntax.Tm_let
                     ((false
                       ,{ FStar_Syntax_Syntax.lbname = FStar_Util.Inl bv;
                          FStar_Syntax_Syntax.lbunivs = uu____7465;
                          FStar_Syntax_Syntax.lbtyp = uu____7466;
                          FStar_Syntax_Syntax.lbeff = uu____7467;
                          FStar_Syntax_Syntax.lbdef = def;
                          FStar_Syntax_Syntax.lbattrs = uu____7469;
                          FStar_Syntax_Syntax.lbpos = uu____7470;_}::[]),e)
                     ->
                     let lb =
                       let uu____7495 =
                         let uu____7496 = FStar_Syntax_Subst.compress t1  in
                         uu____7496.FStar_Syntax_Syntax.n  in
                       match uu____7495 with
                       | FStar_Syntax_Syntax.Tm_let
                           ((false ,lb::[]),uu____7500) -> lb
                       | uu____7513 -> failwith "impossible"  in
                     let fflb lb1 =
                       let uu____7522 = ff lb1.FStar_Syntax_Syntax.lbdef  in
                       bind uu____7522
                         (fun def1  ->
                            ret
                              (let uu___411_7528 = lb1  in
                               {
                                 FStar_Syntax_Syntax.lbname =
                                   (uu___411_7528.FStar_Syntax_Syntax.lbname);
                                 FStar_Syntax_Syntax.lbunivs =
                                   (uu___411_7528.FStar_Syntax_Syntax.lbunivs);
                                 FStar_Syntax_Syntax.lbtyp =
                                   (uu___411_7528.FStar_Syntax_Syntax.lbtyp);
                                 FStar_Syntax_Syntax.lbeff =
                                   (uu___411_7528.FStar_Syntax_Syntax.lbeff);
                                 FStar_Syntax_Syntax.lbdef = def1;
                                 FStar_Syntax_Syntax.lbattrs =
                                   (uu___411_7528.FStar_Syntax_Syntax.lbattrs);
                                 FStar_Syntax_Syntax.lbpos =
                                   (uu___411_7528.FStar_Syntax_Syntax.lbpos)
                               }))
                        in
                     let uu____7529 = fflb lb  in
                     bind uu____7529
                       (fun lb1  ->
                          let uu____7539 =
                            let uu____7544 =
                              let uu____7545 =
                                FStar_Syntax_Syntax.mk_binder bv  in
                              [uu____7545]  in
                            FStar_Syntax_Subst.open_term uu____7544 e  in
                          match uu____7539 with
                          | (bs,e1) ->
                              let ff1 =
                                let uu____7575 =
                                  FStar_TypeChecker_Env.push_binders env bs
                                   in
                                tac_fold_env d f uu____7575  in
                              let uu____7576 = ff1 e1  in
                              bind uu____7576
                                (fun e2  ->
                                   let e3 = FStar_Syntax_Subst.close bs e2
                                      in
                                   ret
                                     (FStar_Syntax_Syntax.Tm_let
                                        ((false, [lb1]), e3))))
                 | FStar_Syntax_Syntax.Tm_let ((true ,lbs),e) ->
                     let fflb lb =
                       let uu____7617 = ff lb.FStar_Syntax_Syntax.lbdef  in
                       bind uu____7617
                         (fun def  ->
                            ret
                              (let uu___412_7623 = lb  in
                               {
                                 FStar_Syntax_Syntax.lbname =
                                   (uu___412_7623.FStar_Syntax_Syntax.lbname);
                                 FStar_Syntax_Syntax.lbunivs =
                                   (uu___412_7623.FStar_Syntax_Syntax.lbunivs);
                                 FStar_Syntax_Syntax.lbtyp =
                                   (uu___412_7623.FStar_Syntax_Syntax.lbtyp);
                                 FStar_Syntax_Syntax.lbeff =
                                   (uu___412_7623.FStar_Syntax_Syntax.lbeff);
                                 FStar_Syntax_Syntax.lbdef = def;
                                 FStar_Syntax_Syntax.lbattrs =
                                   (uu___412_7623.FStar_Syntax_Syntax.lbattrs);
                                 FStar_Syntax_Syntax.lbpos =
                                   (uu___412_7623.FStar_Syntax_Syntax.lbpos)
                               }))
                        in
                     let uu____7624 = FStar_Syntax_Subst.open_let_rec lbs e
                        in
                     (match uu____7624 with
                      | (lbs1,e1) ->
                          let uu____7639 = mapM fflb lbs1  in
                          bind uu____7639
                            (fun lbs2  ->
                               let uu____7651 = ff e1  in
                               bind uu____7651
                                 (fun e2  ->
                                    let uu____7659 =
                                      FStar_Syntax_Subst.close_let_rec lbs2
                                        e2
                                       in
                                    match uu____7659 with
                                    | (lbs3,e3) ->
                                        ret
                                          (FStar_Syntax_Syntax.Tm_let
                                             ((true, lbs3), e3)))))
                 | FStar_Syntax_Syntax.Tm_ascribed (t2,asc,eff) ->
                     let uu____7727 = ff t2  in
                     bind uu____7727
                       (fun t3  ->
                          ret
                            (FStar_Syntax_Syntax.Tm_ascribed (t3, asc, eff)))
                 | FStar_Syntax_Syntax.Tm_meta (t2,m) ->
                     let uu____7758 = ff t2  in
                     bind uu____7758
                       (fun t3  -> ret (FStar_Syntax_Syntax.Tm_meta (t3, m)))
                 | uu____7765 -> ret tn  in
               bind tn1
                 (fun tn2  ->
                    let t' =
                      let uu___413_7772 = t1  in
                      {
                        FStar_Syntax_Syntax.n = tn2;
                        FStar_Syntax_Syntax.pos =
                          (uu___413_7772.FStar_Syntax_Syntax.pos);
                        FStar_Syntax_Syntax.vars =
                          (uu___413_7772.FStar_Syntax_Syntax.vars)
                      }  in
                    if d = FStar_Tactics_Types.BottomUp
                    then f env t'
                    else ret t'))
  
let (pointwise_rec :
  FStar_Tactics_Types.proofstate ->
    unit tac ->
      FStar_Options.optionstate ->
        Prims.string ->
          FStar_TypeChecker_Env.env ->
            FStar_Syntax_Syntax.term -> FStar_Syntax_Syntax.term tac)
  =
  fun ps  ->
    fun tau  ->
      fun opts  ->
        fun label1  ->
          fun env  ->
            fun t  ->
              let uu____7814 =
                FStar_TypeChecker_TcTerm.tc_term
                  (let uu___415_7823 = env  in
                   {
                     FStar_TypeChecker_Env.solver =
                       (uu___415_7823.FStar_TypeChecker_Env.solver);
                     FStar_TypeChecker_Env.range =
                       (uu___415_7823.FStar_TypeChecker_Env.range);
                     FStar_TypeChecker_Env.curmodule =
                       (uu___415_7823.FStar_TypeChecker_Env.curmodule);
                     FStar_TypeChecker_Env.gamma =
                       (uu___415_7823.FStar_TypeChecker_Env.gamma);
                     FStar_TypeChecker_Env.gamma_sig =
                       (uu___415_7823.FStar_TypeChecker_Env.gamma_sig);
                     FStar_TypeChecker_Env.gamma_cache =
                       (uu___415_7823.FStar_TypeChecker_Env.gamma_cache);
                     FStar_TypeChecker_Env.modules =
                       (uu___415_7823.FStar_TypeChecker_Env.modules);
                     FStar_TypeChecker_Env.expected_typ =
                       (uu___415_7823.FStar_TypeChecker_Env.expected_typ);
                     FStar_TypeChecker_Env.sigtab =
                       (uu___415_7823.FStar_TypeChecker_Env.sigtab);
                     FStar_TypeChecker_Env.attrtab =
                       (uu___415_7823.FStar_TypeChecker_Env.attrtab);
                     FStar_TypeChecker_Env.is_pattern =
                       (uu___415_7823.FStar_TypeChecker_Env.is_pattern);
                     FStar_TypeChecker_Env.instantiate_imp =
                       (uu___415_7823.FStar_TypeChecker_Env.instantiate_imp);
                     FStar_TypeChecker_Env.effects =
                       (uu___415_7823.FStar_TypeChecker_Env.effects);
                     FStar_TypeChecker_Env.generalize =
                       (uu___415_7823.FStar_TypeChecker_Env.generalize);
                     FStar_TypeChecker_Env.letrecs =
                       (uu___415_7823.FStar_TypeChecker_Env.letrecs);
                     FStar_TypeChecker_Env.top_level =
                       (uu___415_7823.FStar_TypeChecker_Env.top_level);
                     FStar_TypeChecker_Env.check_uvars =
                       (uu___415_7823.FStar_TypeChecker_Env.check_uvars);
                     FStar_TypeChecker_Env.use_eq =
                       (uu___415_7823.FStar_TypeChecker_Env.use_eq);
                     FStar_TypeChecker_Env.is_iface =
                       (uu___415_7823.FStar_TypeChecker_Env.is_iface);
                     FStar_TypeChecker_Env.admit =
                       (uu___415_7823.FStar_TypeChecker_Env.admit);
                     FStar_TypeChecker_Env.lax = true;
                     FStar_TypeChecker_Env.lax_universes =
                       (uu___415_7823.FStar_TypeChecker_Env.lax_universes);
                     FStar_TypeChecker_Env.phase1 =
                       (uu___415_7823.FStar_TypeChecker_Env.phase1);
                     FStar_TypeChecker_Env.failhard =
                       (uu___415_7823.FStar_TypeChecker_Env.failhard);
                     FStar_TypeChecker_Env.nosynth =
                       (uu___415_7823.FStar_TypeChecker_Env.nosynth);
                     FStar_TypeChecker_Env.uvar_subtyping =
                       (uu___415_7823.FStar_TypeChecker_Env.uvar_subtyping);
                     FStar_TypeChecker_Env.tc_term =
                       (uu___415_7823.FStar_TypeChecker_Env.tc_term);
                     FStar_TypeChecker_Env.type_of =
                       (uu___415_7823.FStar_TypeChecker_Env.type_of);
                     FStar_TypeChecker_Env.universe_of =
                       (uu___415_7823.FStar_TypeChecker_Env.universe_of);
                     FStar_TypeChecker_Env.check_type_of =
                       (uu___415_7823.FStar_TypeChecker_Env.check_type_of);
                     FStar_TypeChecker_Env.use_bv_sorts =
                       (uu___415_7823.FStar_TypeChecker_Env.use_bv_sorts);
                     FStar_TypeChecker_Env.qtbl_name_and_index =
                       (uu___415_7823.FStar_TypeChecker_Env.qtbl_name_and_index);
                     FStar_TypeChecker_Env.normalized_eff_names =
                       (uu___415_7823.FStar_TypeChecker_Env.normalized_eff_names);
                     FStar_TypeChecker_Env.fv_delta_depths =
                       (uu___415_7823.FStar_TypeChecker_Env.fv_delta_depths);
                     FStar_TypeChecker_Env.proof_ns =
                       (uu___415_7823.FStar_TypeChecker_Env.proof_ns);
                     FStar_TypeChecker_Env.synth_hook =
                       (uu___415_7823.FStar_TypeChecker_Env.synth_hook);
                     FStar_TypeChecker_Env.splice =
                       (uu___415_7823.FStar_TypeChecker_Env.splice);
                     FStar_TypeChecker_Env.postprocess =
                       (uu___415_7823.FStar_TypeChecker_Env.postprocess);
                     FStar_TypeChecker_Env.is_native_tactic =
                       (uu___415_7823.FStar_TypeChecker_Env.is_native_tactic);
                     FStar_TypeChecker_Env.identifier_info =
                       (uu___415_7823.FStar_TypeChecker_Env.identifier_info);
                     FStar_TypeChecker_Env.tc_hooks =
                       (uu___415_7823.FStar_TypeChecker_Env.tc_hooks);
                     FStar_TypeChecker_Env.dsenv =
                       (uu___415_7823.FStar_TypeChecker_Env.dsenv);
                     FStar_TypeChecker_Env.nbe =
                       (uu___415_7823.FStar_TypeChecker_Env.nbe)
                   }) t
                 in
              match uu____7814 with
              | (t1,lcomp,g) ->
                  let uu____7829 =
                    (let uu____7832 =
                       FStar_Syntax_Util.is_pure_or_ghost_lcomp lcomp  in
                     Prims.op_Negation uu____7832) ||
                      (let uu____7834 = FStar_TypeChecker_Env.is_trivial g
                          in
                       Prims.op_Negation uu____7834)
                     in
                  if uu____7829
                  then ret t1
                  else
                    (let rewrite_eq =
                       let typ = lcomp.FStar_Syntax_Syntax.res_typ  in
                       let uu____7842 = new_uvar "pointwise_rec" env typ  in
                       bind uu____7842
                         (fun uu____7858  ->
                            match uu____7858 with
                            | (ut,uvar_ut) ->
                                (log ps
                                   (fun uu____7871  ->
                                      let uu____7872 =
                                        FStar_Syntax_Print.term_to_string t1
                                         in
                                      let uu____7873 =
                                        FStar_Syntax_Print.term_to_string ut
                                         in
                                      FStar_Util.print2
                                        "Pointwise_rec: making equality\n\t%s ==\n\t%s\n"
                                        uu____7872 uu____7873);
                                 (let uu____7874 =
                                    let uu____7877 =
                                      let uu____7878 =
                                        FStar_TypeChecker_TcTerm.universe_of
                                          env typ
                                         in
                                      FStar_Syntax_Util.mk_eq2 uu____7878 typ
                                        t1 ut
                                       in
                                    add_irrelevant_goal
                                      "pointwise_rec equation" env uu____7877
                                      opts label1
                                     in
                                  bind uu____7874
                                    (fun uu____7881  ->
                                       let uu____7882 =
                                         bind tau
                                           (fun uu____7888  ->
                                              let ut1 =
                                                FStar_TypeChecker_Normalize.reduce_uvar_solutions
                                                  env ut
                                                 in
                                              log ps
                                                (fun uu____7894  ->
                                                   let uu____7895 =
                                                     FStar_Syntax_Print.term_to_string
                                                       t1
                                                      in
                                                   let uu____7896 =
                                                     FStar_Syntax_Print.term_to_string
                                                       ut1
                                                      in
                                                   FStar_Util.print2
                                                     "Pointwise_rec: succeeded rewriting\n\t%s to\n\t%s\n"
                                                     uu____7895 uu____7896);
                                              ret ut1)
                                          in
                                       focus uu____7882))))
                        in
                     let uu____7897 = catch rewrite_eq  in
                     bind uu____7897
                       (fun x  ->
                          match x with
                          | FStar_Util.Inl "SKIP" -> ret t1
                          | FStar_Util.Inl e -> fail e
                          | FStar_Util.Inr x1 -> ret x1))
  
type ctrl = FStar_BigInt.t
let (keepGoing : ctrl) = FStar_BigInt.zero 
let (proceedToNextSubtree : FStar_BigInt.bigint) = FStar_BigInt.one 
let (globalStop : FStar_BigInt.bigint) =
  FStar_BigInt.succ_big_int FStar_BigInt.one 
type rewrite_result = Prims.bool
let (skipThisTerm : Prims.bool) = false 
let (rewroteThisTerm : Prims.bool) = true 
type 'a ctrl_tac = ('a,ctrl) FStar_Pervasives_Native.tuple2 tac
let rec (ctrl_tac_fold :
  (env -> FStar_Syntax_Syntax.term -> FStar_Syntax_Syntax.term ctrl_tac) ->
    env ->
      ctrl -> FStar_Syntax_Syntax.term -> FStar_Syntax_Syntax.term ctrl_tac)
  =
  fun f  ->
    fun env  ->
      fun ctrl  ->
        fun t  ->
          let keep_going c =
            if c = proceedToNextSubtree then keepGoing else c  in
          let maybe_continue ctrl1 t1 k =
            if ctrl1 = globalStop
            then ret (t1, globalStop)
            else
              if ctrl1 = proceedToNextSubtree
              then ret (t1, keepGoing)
              else k t1
             in
          let uu____8095 = FStar_Syntax_Subst.compress t  in
          maybe_continue ctrl uu____8095
            (fun t1  ->
               let uu____8103 =
                 f env
                   (let uu___418_8112 = t1  in
                    {
                      FStar_Syntax_Syntax.n = (t1.FStar_Syntax_Syntax.n);
                      FStar_Syntax_Syntax.pos =
                        (uu___418_8112.FStar_Syntax_Syntax.pos);
                      FStar_Syntax_Syntax.vars =
                        (uu___418_8112.FStar_Syntax_Syntax.vars)
                    })
                  in
               bind uu____8103
                 (fun uu____8128  ->
                    match uu____8128 with
                    | (t2,ctrl1) ->
                        maybe_continue ctrl1 t2
                          (fun t3  ->
                             let uu____8151 =
                               let uu____8152 =
                                 FStar_Syntax_Subst.compress t3  in
                               uu____8152.FStar_Syntax_Syntax.n  in
                             match uu____8151 with
                             | FStar_Syntax_Syntax.Tm_app (hd1,args) ->
                                 let uu____8189 =
                                   ctrl_tac_fold f env ctrl1 hd1  in
                                 bind uu____8189
                                   (fun uu____8214  ->
                                      match uu____8214 with
                                      | (hd2,ctrl2) ->
                                          let ctrl3 = keep_going ctrl2  in
                                          let uu____8230 =
                                            ctrl_tac_fold_args f env ctrl3
                                              args
                                             in
                                          bind uu____8230
                                            (fun uu____8257  ->
                                               match uu____8257 with
                                               | (args1,ctrl4) ->
                                                   ret
                                                     ((let uu___416_8287 = t3
                                                          in
                                                       {
                                                         FStar_Syntax_Syntax.n
                                                           =
                                                           (FStar_Syntax_Syntax.Tm_app
                                                              (hd2, args1));
                                                         FStar_Syntax_Syntax.pos
                                                           =
                                                           (uu___416_8287.FStar_Syntax_Syntax.pos);
                                                         FStar_Syntax_Syntax.vars
                                                           =
                                                           (uu___416_8287.FStar_Syntax_Syntax.vars)
                                                       }), ctrl4)))
                             | FStar_Syntax_Syntax.Tm_abs (bs,t4,k) ->
                                 let uu____8329 =
                                   FStar_Syntax_Subst.open_term bs t4  in
                                 (match uu____8329 with
                                  | (bs1,t') ->
                                      let uu____8344 =
                                        let uu____8351 =
                                          FStar_TypeChecker_Env.push_binders
                                            env bs1
                                           in
                                        ctrl_tac_fold f uu____8351 ctrl1 t'
                                         in
                                      bind uu____8344
                                        (fun uu____8369  ->
                                           match uu____8369 with
                                           | (t'',ctrl2) ->
                                               let uu____8384 =
                                                 let uu____8391 =
                                                   let uu___417_8394 = t4  in
                                                   let uu____8397 =
                                                     let uu____8398 =
                                                       let uu____8417 =
                                                         FStar_Syntax_Subst.close_binders
                                                           bs1
                                                          in
                                                       let uu____8426 =
                                                         FStar_Syntax_Subst.close
                                                           bs1 t''
                                                          in
                                                       (uu____8417,
                                                         uu____8426, k)
                                                        in
                                                     FStar_Syntax_Syntax.Tm_abs
                                                       uu____8398
                                                      in
                                                   {
                                                     FStar_Syntax_Syntax.n =
                                                       uu____8397;
                                                     FStar_Syntax_Syntax.pos
                                                       =
                                                       (uu___417_8394.FStar_Syntax_Syntax.pos);
                                                     FStar_Syntax_Syntax.vars
                                                       =
                                                       (uu___417_8394.FStar_Syntax_Syntax.vars)
                                                   }  in
                                                 (uu____8391, ctrl2)  in
                                               ret uu____8384))
                             | FStar_Syntax_Syntax.Tm_arrow (bs,k) ->
                                 ret (t3, ctrl1)
                             | uu____8479 -> ret (t3, ctrl1))))

and (ctrl_tac_fold_args :
  (env -> FStar_Syntax_Syntax.term -> FStar_Syntax_Syntax.term ctrl_tac) ->
    env ->
      ctrl ->
        FStar_Syntax_Syntax.arg Prims.list ->
          FStar_Syntax_Syntax.arg Prims.list ctrl_tac)
  =
  fun f  ->
    fun env  ->
      fun ctrl  ->
        fun ts  ->
          match ts with
          | [] -> ret ([], ctrl)
          | (t,q)::ts1 ->
              let uu____8526 = ctrl_tac_fold f env ctrl t  in
              bind uu____8526
                (fun uu____8550  ->
                   match uu____8550 with
                   | (t1,ctrl1) ->
                       let uu____8565 = ctrl_tac_fold_args f env ctrl1 ts1
                          in
                       bind uu____8565
                         (fun uu____8592  ->
                            match uu____8592 with
                            | (ts2,ctrl2) -> ret (((t1, q) :: ts2), ctrl2)))

let (rewrite_rec :
  FStar_Tactics_Types.proofstate ->
    (FStar_Syntax_Syntax.term -> rewrite_result ctrl_tac) ->
      unit tac ->
        FStar_Options.optionstate ->
          Prims.string ->
            FStar_TypeChecker_Env.env ->
              FStar_Syntax_Syntax.term -> FStar_Syntax_Syntax.term ctrl_tac)
  =
  fun ps  ->
    fun ctrl  ->
      fun rewriter  ->
        fun opts  ->
          fun label1  ->
            fun env  ->
              fun t  ->
                let t1 = FStar_Syntax_Subst.compress t  in
                let uu____8681 =
                  let uu____8688 =
                    add_irrelevant_goal "dummy" env FStar_Syntax_Util.t_true
                      opts label1
                     in
                  bind uu____8688
                    (fun uu____8697  ->
                       let uu____8698 = ctrl t1  in
                       bind uu____8698
                         (fun res  ->
                            let uu____8721 = trivial ()  in
                            bind uu____8721 (fun uu____8729  -> ret res)))
                   in
                bind uu____8681
                  (fun uu____8745  ->
                     match uu____8745 with
                     | (should_rewrite,ctrl1) ->
                         if Prims.op_Negation should_rewrite
                         then ret (t1, ctrl1)
                         else
                           (let uu____8769 =
                              FStar_TypeChecker_TcTerm.tc_term
                                (let uu___419_8778 = env  in
                                 {
                                   FStar_TypeChecker_Env.solver =
                                     (uu___419_8778.FStar_TypeChecker_Env.solver);
                                   FStar_TypeChecker_Env.range =
                                     (uu___419_8778.FStar_TypeChecker_Env.range);
                                   FStar_TypeChecker_Env.curmodule =
                                     (uu___419_8778.FStar_TypeChecker_Env.curmodule);
                                   FStar_TypeChecker_Env.gamma =
                                     (uu___419_8778.FStar_TypeChecker_Env.gamma);
                                   FStar_TypeChecker_Env.gamma_sig =
                                     (uu___419_8778.FStar_TypeChecker_Env.gamma_sig);
                                   FStar_TypeChecker_Env.gamma_cache =
                                     (uu___419_8778.FStar_TypeChecker_Env.gamma_cache);
                                   FStar_TypeChecker_Env.modules =
                                     (uu___419_8778.FStar_TypeChecker_Env.modules);
                                   FStar_TypeChecker_Env.expected_typ =
                                     (uu___419_8778.FStar_TypeChecker_Env.expected_typ);
                                   FStar_TypeChecker_Env.sigtab =
                                     (uu___419_8778.FStar_TypeChecker_Env.sigtab);
                                   FStar_TypeChecker_Env.attrtab =
                                     (uu___419_8778.FStar_TypeChecker_Env.attrtab);
                                   FStar_TypeChecker_Env.is_pattern =
                                     (uu___419_8778.FStar_TypeChecker_Env.is_pattern);
                                   FStar_TypeChecker_Env.instantiate_imp =
                                     (uu___419_8778.FStar_TypeChecker_Env.instantiate_imp);
                                   FStar_TypeChecker_Env.effects =
                                     (uu___419_8778.FStar_TypeChecker_Env.effects);
                                   FStar_TypeChecker_Env.generalize =
                                     (uu___419_8778.FStar_TypeChecker_Env.generalize);
                                   FStar_TypeChecker_Env.letrecs =
                                     (uu___419_8778.FStar_TypeChecker_Env.letrecs);
                                   FStar_TypeChecker_Env.top_level =
                                     (uu___419_8778.FStar_TypeChecker_Env.top_level);
                                   FStar_TypeChecker_Env.check_uvars =
                                     (uu___419_8778.FStar_TypeChecker_Env.check_uvars);
                                   FStar_TypeChecker_Env.use_eq =
                                     (uu___419_8778.FStar_TypeChecker_Env.use_eq);
                                   FStar_TypeChecker_Env.is_iface =
                                     (uu___419_8778.FStar_TypeChecker_Env.is_iface);
                                   FStar_TypeChecker_Env.admit =
                                     (uu___419_8778.FStar_TypeChecker_Env.admit);
                                   FStar_TypeChecker_Env.lax = true;
                                   FStar_TypeChecker_Env.lax_universes =
                                     (uu___419_8778.FStar_TypeChecker_Env.lax_universes);
                                   FStar_TypeChecker_Env.phase1 =
                                     (uu___419_8778.FStar_TypeChecker_Env.phase1);
                                   FStar_TypeChecker_Env.failhard =
                                     (uu___419_8778.FStar_TypeChecker_Env.failhard);
                                   FStar_TypeChecker_Env.nosynth =
                                     (uu___419_8778.FStar_TypeChecker_Env.nosynth);
                                   FStar_TypeChecker_Env.uvar_subtyping =
                                     (uu___419_8778.FStar_TypeChecker_Env.uvar_subtyping);
                                   FStar_TypeChecker_Env.tc_term =
                                     (uu___419_8778.FStar_TypeChecker_Env.tc_term);
                                   FStar_TypeChecker_Env.type_of =
                                     (uu___419_8778.FStar_TypeChecker_Env.type_of);
                                   FStar_TypeChecker_Env.universe_of =
                                     (uu___419_8778.FStar_TypeChecker_Env.universe_of);
                                   FStar_TypeChecker_Env.check_type_of =
                                     (uu___419_8778.FStar_TypeChecker_Env.check_type_of);
                                   FStar_TypeChecker_Env.use_bv_sorts =
                                     (uu___419_8778.FStar_TypeChecker_Env.use_bv_sorts);
                                   FStar_TypeChecker_Env.qtbl_name_and_index
                                     =
                                     (uu___419_8778.FStar_TypeChecker_Env.qtbl_name_and_index);
                                   FStar_TypeChecker_Env.normalized_eff_names
                                     =
                                     (uu___419_8778.FStar_TypeChecker_Env.normalized_eff_names);
                                   FStar_TypeChecker_Env.fv_delta_depths =
                                     (uu___419_8778.FStar_TypeChecker_Env.fv_delta_depths);
                                   FStar_TypeChecker_Env.proof_ns =
                                     (uu___419_8778.FStar_TypeChecker_Env.proof_ns);
                                   FStar_TypeChecker_Env.synth_hook =
                                     (uu___419_8778.FStar_TypeChecker_Env.synth_hook);
                                   FStar_TypeChecker_Env.splice =
                                     (uu___419_8778.FStar_TypeChecker_Env.splice);
                                   FStar_TypeChecker_Env.postprocess =
                                     (uu___419_8778.FStar_TypeChecker_Env.postprocess);
                                   FStar_TypeChecker_Env.is_native_tactic =
                                     (uu___419_8778.FStar_TypeChecker_Env.is_native_tactic);
                                   FStar_TypeChecker_Env.identifier_info =
                                     (uu___419_8778.FStar_TypeChecker_Env.identifier_info);
                                   FStar_TypeChecker_Env.tc_hooks =
                                     (uu___419_8778.FStar_TypeChecker_Env.tc_hooks);
                                   FStar_TypeChecker_Env.dsenv =
                                     (uu___419_8778.FStar_TypeChecker_Env.dsenv);
                                   FStar_TypeChecker_Env.nbe =
                                     (uu___419_8778.FStar_TypeChecker_Env.nbe)
                                 }) t1
                               in
                            match uu____8769 with
                            | (t2,lcomp,g) ->
                                let uu____8788 =
                                  (let uu____8791 =
                                     FStar_Syntax_Util.is_pure_or_ghost_lcomp
                                       lcomp
                                      in
                                   Prims.op_Negation uu____8791) ||
                                    (let uu____8793 =
                                       FStar_TypeChecker_Env.is_trivial g  in
                                     Prims.op_Negation uu____8793)
                                   in
                                if uu____8788
                                then ret (t2, globalStop)
                                else
                                  (let typ =
                                     lcomp.FStar_Syntax_Syntax.res_typ  in
                                   let uu____8806 =
                                     new_uvar "pointwise_rec" env typ  in
                                   bind uu____8806
                                     (fun uu____8826  ->
                                        match uu____8826 with
                                        | (ut,uvar_ut) ->
                                            (log ps
                                               (fun uu____8843  ->
                                                  let uu____8844 =
                                                    FStar_Syntax_Print.term_to_string
                                                      t2
                                                     in
                                                  let uu____8845 =
                                                    FStar_Syntax_Print.term_to_string
                                                      ut
                                                     in
                                                  FStar_Util.print2
                                                    "Pointwise_rec: making equality\n\t%s ==\n\t%s\n"
                                                    uu____8844 uu____8845);
                                             (let uu____8846 =
                                                let uu____8849 =
                                                  let uu____8850 =
                                                    FStar_TypeChecker_TcTerm.universe_of
                                                      env typ
                                                     in
                                                  FStar_Syntax_Util.mk_eq2
                                                    uu____8850 typ t2 ut
                                                   in
                                                add_irrelevant_goal
                                                  "rewrite_rec equation" env
                                                  uu____8849 opts label1
                                                 in
                                              bind uu____8846
                                                (fun uu____8857  ->
                                                   let uu____8858 =
                                                     bind rewriter
                                                       (fun uu____8872  ->
                                                          let ut1 =
                                                            FStar_TypeChecker_Normalize.reduce_uvar_solutions
                                                              env ut
                                                             in
                                                          log ps
                                                            (fun uu____8878 
                                                               ->
                                                               let uu____8879
                                                                 =
                                                                 FStar_Syntax_Print.term_to_string
                                                                   t2
                                                                  in
                                                               let uu____8880
                                                                 =
                                                                 FStar_Syntax_Print.term_to_string
                                                                   ut1
                                                                  in
                                                               FStar_Util.print2
                                                                 "rewrite_rec: succeeded rewriting\n\t%s to\n\t%s\n"
                                                                 uu____8879
                                                                 uu____8880);
                                                          ret (ut1, ctrl1))
                                                      in
                                                   focus uu____8858)))))))
  
let (topdown_rewrite :
  (FStar_Syntax_Syntax.term ->
     (Prims.bool,FStar_BigInt.t) FStar_Pervasives_Native.tuple2 tac)
    -> unit tac -> unit tac)
  =
  fun ctrl  ->
    fun rewriter  ->
      let uu____8921 =
        bind get
          (fun ps  ->
             let uu____8931 =
               match ps.FStar_Tactics_Types.goals with
               | g::gs -> (g, gs)
               | [] -> failwith "no goals"  in
             match uu____8931 with
             | (g,gs) ->
                 let gt1 = FStar_Tactics_Types.goal_type g  in
                 (log ps
                    (fun uu____8968  ->
                       let uu____8969 = FStar_Syntax_Print.term_to_string gt1
                          in
                       FStar_Util.print1 "Topdown_rewrite starting with %s\n"
                         uu____8969);
                  bind dismiss_all
                    (fun uu____8972  ->
                       let uu____8973 =
                         let uu____8980 = FStar_Tactics_Types.goal_env g  in
                         ctrl_tac_fold
                           (rewrite_rec ps ctrl rewriter
                              g.FStar_Tactics_Types.opts
                              g.FStar_Tactics_Types.label) uu____8980
                           keepGoing gt1
                          in
                       bind uu____8973
                         (fun uu____8992  ->
                            match uu____8992 with
                            | (gt',uu____9000) ->
                                (log ps
                                   (fun uu____9004  ->
                                      let uu____9005 =
                                        FStar_Syntax_Print.term_to_string gt'
                                         in
                                      FStar_Util.print1
                                        "Topdown_rewrite seems to have succeded with %s\n"
                                        uu____9005);
                                 (let uu____9006 = push_goals gs  in
                                  bind uu____9006
                                    (fun uu____9011  ->
                                       let uu____9012 =
                                         let uu____9015 =
                                           FStar_Tactics_Types.goal_with_type
                                             g gt'
                                            in
                                         [uu____9015]  in
                                       add_goals uu____9012)))))))
         in
      FStar_All.pipe_left (wrap_err "topdown_rewrite") uu____8921
  
let (pointwise : FStar_Tactics_Types.direction -> unit tac -> unit tac) =
  fun d  ->
    fun tau  ->
      let uu____9038 =
        bind get
          (fun ps  ->
             let uu____9048 =
               match ps.FStar_Tactics_Types.goals with
               | g::gs -> (g, gs)
               | [] -> failwith "no goals"  in
             match uu____9048 with
             | (g,gs) ->
                 let gt1 = FStar_Tactics_Types.goal_type g  in
                 (log ps
                    (fun uu____9085  ->
                       let uu____9086 = FStar_Syntax_Print.term_to_string gt1
                          in
                       FStar_Util.print1 "Pointwise starting with %s\n"
                         uu____9086);
                  bind dismiss_all
                    (fun uu____9089  ->
                       let uu____9090 =
                         let uu____9093 = FStar_Tactics_Types.goal_env g  in
                         tac_fold_env d
                           (pointwise_rec ps tau g.FStar_Tactics_Types.opts
                              g.FStar_Tactics_Types.label) uu____9093 gt1
                          in
                       bind uu____9090
                         (fun gt'  ->
                            log ps
                              (fun uu____9101  ->
                                 let uu____9102 =
                                   FStar_Syntax_Print.term_to_string gt'  in
                                 FStar_Util.print1
                                   "Pointwise seems to have succeded with %s\n"
                                   uu____9102);
                            (let uu____9103 = push_goals gs  in
                             bind uu____9103
                               (fun uu____9108  ->
                                  let uu____9109 =
                                    let uu____9112 =
                                      FStar_Tactics_Types.goal_with_type g
                                        gt'
                                       in
                                    [uu____9112]  in
                                  add_goals uu____9109))))))
         in
      FStar_All.pipe_left (wrap_err "pointwise") uu____9038
  
let (trefl : unit -> unit tac) =
  fun uu____9123  ->
    let uu____9126 =
      let uu____9129 = cur_goal ()  in
      bind uu____9129
        (fun g  ->
           let uu____9147 =
             let uu____9152 = FStar_Tactics_Types.goal_type g  in
             FStar_Syntax_Util.un_squash uu____9152  in
           match uu____9147 with
           | FStar_Pervasives_Native.Some t ->
               let uu____9160 = FStar_Syntax_Util.head_and_args' t  in
               (match uu____9160 with
                | (hd1,args) ->
                    let uu____9199 =
                      let uu____9212 =
                        let uu____9213 = FStar_Syntax_Util.un_uinst hd1  in
                        uu____9213.FStar_Syntax_Syntax.n  in
                      (uu____9212, args)  in
                    (match uu____9199 with
                     | (FStar_Syntax_Syntax.Tm_fvar
                        fv,uu____9227::(l,uu____9229)::(r,uu____9231)::[])
                         when
                         FStar_Syntax_Syntax.fv_eq_lid fv
                           FStar_Parser_Const.eq2_lid
                         ->
                         let uu____9278 =
                           let uu____9281 = FStar_Tactics_Types.goal_env g
                              in
                           do_unify uu____9281 l r  in
                         bind uu____9278
                           (fun b  ->
                              if b
                              then solve' g FStar_Syntax_Util.exp_unit
                              else
                                (let l1 =
                                   let uu____9288 =
                                     FStar_Tactics_Types.goal_env g  in
                                   FStar_TypeChecker_Normalize.normalize
                                     [FStar_TypeChecker_Env.UnfoldUntil
                                        FStar_Syntax_Syntax.delta_constant;
                                     FStar_TypeChecker_Env.Primops;
                                     FStar_TypeChecker_Env.UnfoldTac]
                                     uu____9288 l
                                    in
                                 let r1 =
                                   let uu____9290 =
                                     FStar_Tactics_Types.goal_env g  in
                                   FStar_TypeChecker_Normalize.normalize
                                     [FStar_TypeChecker_Env.UnfoldUntil
                                        FStar_Syntax_Syntax.delta_constant;
                                     FStar_TypeChecker_Env.Primops;
                                     FStar_TypeChecker_Env.UnfoldTac]
                                     uu____9290 r
                                    in
                                 let uu____9291 =
                                   let uu____9294 =
                                     FStar_Tactics_Types.goal_env g  in
                                   do_unify uu____9294 l1 r1  in
                                 bind uu____9291
                                   (fun b1  ->
                                      if b1
                                      then
                                        solve' g FStar_Syntax_Util.exp_unit
                                      else
                                        (let uu____9300 =
                                           let uu____9301 =
                                             FStar_Tactics_Types.goal_env g
                                              in
                                           tts uu____9301 l1  in
                                         let uu____9302 =
                                           let uu____9303 =
                                             FStar_Tactics_Types.goal_env g
                                              in
                                           tts uu____9303 r1  in
                                         fail2
                                           "not a trivial equality ((%s) vs (%s))"
                                           uu____9300 uu____9302))))
                     | (hd2,uu____9305) ->
                         let uu____9322 =
                           let uu____9323 = FStar_Tactics_Types.goal_env g
                              in
                           tts uu____9323 t  in
                         fail1 "trefl: not an equality (%s)" uu____9322))
           | FStar_Pervasives_Native.None  -> fail "not an irrelevant goal")
       in
    FStar_All.pipe_left (wrap_err "trefl") uu____9126
  
let (dup : unit -> unit tac) =
  fun uu____9336  ->
    let uu____9339 = cur_goal ()  in
    bind uu____9339
      (fun g  ->
         let uu____9345 =
           let uu____9352 = FStar_Tactics_Types.goal_env g  in
           let uu____9353 = FStar_Tactics_Types.goal_type g  in
           new_uvar "dup" uu____9352 uu____9353  in
         bind uu____9345
           (fun uu____9362  ->
              match uu____9362 with
              | (u,u_uvar) ->
                  let g' =
                    let uu___420_9372 = g  in
                    {
                      FStar_Tactics_Types.goal_main_env =
                        (uu___420_9372.FStar_Tactics_Types.goal_main_env);
                      FStar_Tactics_Types.goal_ctx_uvar = u_uvar;
                      FStar_Tactics_Types.opts =
                        (uu___420_9372.FStar_Tactics_Types.opts);
                      FStar_Tactics_Types.is_guard =
                        (uu___420_9372.FStar_Tactics_Types.is_guard);
                      FStar_Tactics_Types.label =
                        (uu___420_9372.FStar_Tactics_Types.label)
                    }  in
                  bind __dismiss
                    (fun uu____9375  ->
                       let uu____9376 =
                         let uu____9379 = FStar_Tactics_Types.goal_env g  in
                         let uu____9380 =
                           let uu____9381 =
                             let uu____9382 = FStar_Tactics_Types.goal_env g
                                in
                             let uu____9383 = FStar_Tactics_Types.goal_type g
                                in
                             FStar_TypeChecker_TcTerm.universe_of uu____9382
                               uu____9383
                              in
                           let uu____9384 = FStar_Tactics_Types.goal_type g
                              in
                           let uu____9385 =
                             FStar_Tactics_Types.goal_witness g  in
                           FStar_Syntax_Util.mk_eq2 uu____9381 uu____9384 u
                             uu____9385
                            in
                         add_irrelevant_goal "dup equation" uu____9379
                           uu____9380 g.FStar_Tactics_Types.opts
                           g.FStar_Tactics_Types.label
                          in
                       bind uu____9376
                         (fun uu____9388  ->
                            let uu____9389 = add_goals [g']  in
                            bind uu____9389 (fun uu____9393  -> ret ())))))
  
let rec longest_prefix :
  'a .
    ('a -> 'a -> Prims.bool) ->
      'a Prims.list ->
        'a Prims.list ->
          ('a Prims.list,'a Prims.list,'a Prims.list)
            FStar_Pervasives_Native.tuple3
  =
  fun f  ->
    fun l1  ->
      fun l2  ->
        let rec aux acc l11 l21 =
          match (l11, l21) with
          | (x::xs,y::ys) ->
              let uu____9516 = f x y  in
              if uu____9516 then aux (x :: acc) xs ys else (acc, xs, ys)
          | uu____9536 -> (acc, l11, l21)  in
        let uu____9551 = aux [] l1 l2  in
        match uu____9551 with | (pr,t1,t2) -> ((FStar_List.rev pr), t1, t2)
  
let (join_goals :
  FStar_Tactics_Types.goal ->
    FStar_Tactics_Types.goal -> FStar_Tactics_Types.goal tac)
  =
  fun g1  ->
    fun g2  ->
      let close_forall_no_univs1 bs f =
        FStar_List.fold_right
          (fun b  ->
             fun f1  ->
               FStar_Syntax_Util.mk_forall_no_univ
                 (FStar_Pervasives_Native.fst b) f1) bs f
         in
      let uu____9656 = get_phi g1  in
      match uu____9656 with
      | FStar_Pervasives_Native.None  -> fail "goal 1 is not irrelevant"
      | FStar_Pervasives_Native.Some phi1 ->
          let uu____9662 = get_phi g2  in
          (match uu____9662 with
           | FStar_Pervasives_Native.None  -> fail "goal 2 is not irrelevant"
           | FStar_Pervasives_Native.Some phi2 ->
               let gamma1 =
                 (g1.FStar_Tactics_Types.goal_ctx_uvar).FStar_Syntax_Syntax.ctx_uvar_gamma
                  in
               let gamma2 =
                 (g2.FStar_Tactics_Types.goal_ctx_uvar).FStar_Syntax_Syntax.ctx_uvar_gamma
                  in
               let uu____9674 =
                 longest_prefix FStar_Syntax_Syntax.eq_binding
                   (FStar_List.rev gamma1) (FStar_List.rev gamma2)
                  in
               (match uu____9674 with
                | (gamma,r1,r2) ->
                    let t1 =
                      let uu____9705 =
                        FStar_TypeChecker_Env.binders_of_bindings
                          (FStar_List.rev r1)
                         in
                      close_forall_no_univs1 uu____9705 phi1  in
                    let t2 =
                      let uu____9715 =
                        FStar_TypeChecker_Env.binders_of_bindings
                          (FStar_List.rev r2)
                         in
                      close_forall_no_univs1 uu____9715 phi2  in
                    let uu____9724 =
                      set_solution g1 FStar_Syntax_Util.exp_unit  in
                    bind uu____9724
                      (fun uu____9729  ->
                         let uu____9730 =
                           set_solution g2 FStar_Syntax_Util.exp_unit  in
                         bind uu____9730
                           (fun uu____9737  ->
                              let ng = FStar_Syntax_Util.mk_conj t1 t2  in
                              let nenv =
                                let uu___421_9742 =
                                  FStar_Tactics_Types.goal_env g1  in
                                let uu____9743 =
                                  FStar_Util.smap_create
                                    (Prims.parse_int "100")
                                   in
                                {
                                  FStar_TypeChecker_Env.solver =
                                    (uu___421_9742.FStar_TypeChecker_Env.solver);
                                  FStar_TypeChecker_Env.range =
                                    (uu___421_9742.FStar_TypeChecker_Env.range);
                                  FStar_TypeChecker_Env.curmodule =
                                    (uu___421_9742.FStar_TypeChecker_Env.curmodule);
                                  FStar_TypeChecker_Env.gamma =
                                    (FStar_List.rev gamma);
                                  FStar_TypeChecker_Env.gamma_sig =
                                    (uu___421_9742.FStar_TypeChecker_Env.gamma_sig);
                                  FStar_TypeChecker_Env.gamma_cache =
                                    uu____9743;
                                  FStar_TypeChecker_Env.modules =
                                    (uu___421_9742.FStar_TypeChecker_Env.modules);
                                  FStar_TypeChecker_Env.expected_typ =
                                    (uu___421_9742.FStar_TypeChecker_Env.expected_typ);
                                  FStar_TypeChecker_Env.sigtab =
                                    (uu___421_9742.FStar_TypeChecker_Env.sigtab);
                                  FStar_TypeChecker_Env.attrtab =
                                    (uu___421_9742.FStar_TypeChecker_Env.attrtab);
                                  FStar_TypeChecker_Env.is_pattern =
                                    (uu___421_9742.FStar_TypeChecker_Env.is_pattern);
                                  FStar_TypeChecker_Env.instantiate_imp =
                                    (uu___421_9742.FStar_TypeChecker_Env.instantiate_imp);
                                  FStar_TypeChecker_Env.effects =
                                    (uu___421_9742.FStar_TypeChecker_Env.effects);
                                  FStar_TypeChecker_Env.generalize =
                                    (uu___421_9742.FStar_TypeChecker_Env.generalize);
                                  FStar_TypeChecker_Env.letrecs =
                                    (uu___421_9742.FStar_TypeChecker_Env.letrecs);
                                  FStar_TypeChecker_Env.top_level =
                                    (uu___421_9742.FStar_TypeChecker_Env.top_level);
                                  FStar_TypeChecker_Env.check_uvars =
                                    (uu___421_9742.FStar_TypeChecker_Env.check_uvars);
                                  FStar_TypeChecker_Env.use_eq =
                                    (uu___421_9742.FStar_TypeChecker_Env.use_eq);
                                  FStar_TypeChecker_Env.is_iface =
                                    (uu___421_9742.FStar_TypeChecker_Env.is_iface);
                                  FStar_TypeChecker_Env.admit =
                                    (uu___421_9742.FStar_TypeChecker_Env.admit);
                                  FStar_TypeChecker_Env.lax =
                                    (uu___421_9742.FStar_TypeChecker_Env.lax);
                                  FStar_TypeChecker_Env.lax_universes =
                                    (uu___421_9742.FStar_TypeChecker_Env.lax_universes);
                                  FStar_TypeChecker_Env.phase1 =
                                    (uu___421_9742.FStar_TypeChecker_Env.phase1);
                                  FStar_TypeChecker_Env.failhard =
                                    (uu___421_9742.FStar_TypeChecker_Env.failhard);
                                  FStar_TypeChecker_Env.nosynth =
                                    (uu___421_9742.FStar_TypeChecker_Env.nosynth);
                                  FStar_TypeChecker_Env.uvar_subtyping =
                                    (uu___421_9742.FStar_TypeChecker_Env.uvar_subtyping);
                                  FStar_TypeChecker_Env.tc_term =
                                    (uu___421_9742.FStar_TypeChecker_Env.tc_term);
                                  FStar_TypeChecker_Env.type_of =
                                    (uu___421_9742.FStar_TypeChecker_Env.type_of);
                                  FStar_TypeChecker_Env.universe_of =
                                    (uu___421_9742.FStar_TypeChecker_Env.universe_of);
                                  FStar_TypeChecker_Env.check_type_of =
                                    (uu___421_9742.FStar_TypeChecker_Env.check_type_of);
                                  FStar_TypeChecker_Env.use_bv_sorts =
                                    (uu___421_9742.FStar_TypeChecker_Env.use_bv_sorts);
                                  FStar_TypeChecker_Env.qtbl_name_and_index =
                                    (uu___421_9742.FStar_TypeChecker_Env.qtbl_name_and_index);
                                  FStar_TypeChecker_Env.normalized_eff_names
                                    =
                                    (uu___421_9742.FStar_TypeChecker_Env.normalized_eff_names);
                                  FStar_TypeChecker_Env.fv_delta_depths =
                                    (uu___421_9742.FStar_TypeChecker_Env.fv_delta_depths);
                                  FStar_TypeChecker_Env.proof_ns =
                                    (uu___421_9742.FStar_TypeChecker_Env.proof_ns);
                                  FStar_TypeChecker_Env.synth_hook =
                                    (uu___421_9742.FStar_TypeChecker_Env.synth_hook);
                                  FStar_TypeChecker_Env.splice =
                                    (uu___421_9742.FStar_TypeChecker_Env.splice);
                                  FStar_TypeChecker_Env.postprocess =
                                    (uu___421_9742.FStar_TypeChecker_Env.postprocess);
                                  FStar_TypeChecker_Env.is_native_tactic =
                                    (uu___421_9742.FStar_TypeChecker_Env.is_native_tactic);
                                  FStar_TypeChecker_Env.identifier_info =
                                    (uu___421_9742.FStar_TypeChecker_Env.identifier_info);
                                  FStar_TypeChecker_Env.tc_hooks =
                                    (uu___421_9742.FStar_TypeChecker_Env.tc_hooks);
                                  FStar_TypeChecker_Env.dsenv =
                                    (uu___421_9742.FStar_TypeChecker_Env.dsenv);
                                  FStar_TypeChecker_Env.nbe =
                                    (uu___421_9742.FStar_TypeChecker_Env.nbe)
                                }  in
                              let uu____9746 =
                                mk_irrelevant_goal "joined" nenv ng
                                  g1.FStar_Tactics_Types.opts
                                  g1.FStar_Tactics_Types.label
                                 in
                              bind uu____9746
                                (fun goal  ->
                                   mlog
                                     (fun uu____9755  ->
                                        let uu____9756 =
                                          goal_to_string_verbose g1  in
                                        let uu____9757 =
                                          goal_to_string_verbose g2  in
                                        let uu____9758 =
                                          goal_to_string_verbose goal  in
                                        FStar_Util.print3
                                          "join_goals of\n(%s)\nand\n(%s)\n= (%s)\n"
                                          uu____9756 uu____9757 uu____9758)
                                     (fun uu____9760  -> ret goal))))))
  
let (join : unit -> unit tac) =
  fun uu____9767  ->
    bind get
      (fun ps  ->
         match ps.FStar_Tactics_Types.goals with
         | g1::g2::gs ->
             let uu____9783 =
               set
                 (let uu___422_9788 = ps  in
                  {
                    FStar_Tactics_Types.main_context =
                      (uu___422_9788.FStar_Tactics_Types.main_context);
                    FStar_Tactics_Types.main_goal =
                      (uu___422_9788.FStar_Tactics_Types.main_goal);
                    FStar_Tactics_Types.all_implicits =
                      (uu___422_9788.FStar_Tactics_Types.all_implicits);
                    FStar_Tactics_Types.goals = gs;
                    FStar_Tactics_Types.smt_goals =
                      (uu___422_9788.FStar_Tactics_Types.smt_goals);
                    FStar_Tactics_Types.depth =
                      (uu___422_9788.FStar_Tactics_Types.depth);
                    FStar_Tactics_Types.__dump =
                      (uu___422_9788.FStar_Tactics_Types.__dump);
                    FStar_Tactics_Types.psc =
                      (uu___422_9788.FStar_Tactics_Types.psc);
                    FStar_Tactics_Types.entry_range =
                      (uu___422_9788.FStar_Tactics_Types.entry_range);
                    FStar_Tactics_Types.guard_policy =
                      (uu___422_9788.FStar_Tactics_Types.guard_policy);
                    FStar_Tactics_Types.freshness =
                      (uu___422_9788.FStar_Tactics_Types.freshness);
                    FStar_Tactics_Types.tac_verb_dbg =
                      (uu___422_9788.FStar_Tactics_Types.tac_verb_dbg);
                    FStar_Tactics_Types.local_state =
                      (uu___422_9788.FStar_Tactics_Types.local_state)
                  })
                in
             bind uu____9783
               (fun uu____9791  ->
                  let uu____9792 = join_goals g1 g2  in
                  bind uu____9792 (fun g12  -> add_goals [g12]))
         | uu____9797 -> fail "join: less than 2 goals")
  
let (cases :
  FStar_Syntax_Syntax.term ->
    (FStar_Syntax_Syntax.term,FStar_Syntax_Syntax.term)
      FStar_Pervasives_Native.tuple2 tac)
  =
  fun t  ->
    let uu____9817 =
      let uu____9824 = cur_goal ()  in
      bind uu____9824
        (fun g  ->
           let uu____9834 =
             let uu____9843 = FStar_Tactics_Types.goal_env g  in
             __tc uu____9843 t  in
           bind uu____9834
             (fun uu____9871  ->
                match uu____9871 with
                | (t1,typ,guard) ->
                    let uu____9887 = FStar_Syntax_Util.head_and_args typ  in
                    (match uu____9887 with
                     | (hd1,args) ->
                         let uu____9936 =
                           let uu____9951 =
                             let uu____9952 = FStar_Syntax_Util.un_uinst hd1
                                in
                             uu____9952.FStar_Syntax_Syntax.n  in
                           (uu____9951, args)  in
                         (match uu____9936 with
                          | (FStar_Syntax_Syntax.Tm_fvar
                             fv,(p,uu____9973)::(q,uu____9975)::[]) when
                              FStar_Syntax_Syntax.fv_eq_lid fv
                                FStar_Parser_Const.or_lid
                              ->
                              let v_p =
                                FStar_Syntax_Syntax.new_bv
                                  FStar_Pervasives_Native.None p
                                 in
                              let v_q =
                                FStar_Syntax_Syntax.new_bv
                                  FStar_Pervasives_Native.None q
                                 in
                              let g1 =
                                let uu____10029 =
                                  let uu____10030 =
                                    FStar_Tactics_Types.goal_env g  in
                                  FStar_TypeChecker_Env.push_bv uu____10030
                                    v_p
                                   in
                                FStar_Tactics_Types.goal_with_env g
                                  uu____10029
                                 in
                              let g2 =
                                let uu____10032 =
                                  let uu____10033 =
                                    FStar_Tactics_Types.goal_env g  in
                                  FStar_TypeChecker_Env.push_bv uu____10033
                                    v_q
                                   in
                                FStar_Tactics_Types.goal_with_env g
                                  uu____10032
                                 in
                              bind __dismiss
                                (fun uu____10040  ->
                                   let uu____10041 = add_goals [g1; g2]  in
                                   bind uu____10041
                                     (fun uu____10050  ->
                                        let uu____10051 =
                                          let uu____10056 =
                                            FStar_Syntax_Syntax.bv_to_name
                                              v_p
                                             in
                                          let uu____10057 =
                                            FStar_Syntax_Syntax.bv_to_name
                                              v_q
                                             in
                                          (uu____10056, uu____10057)  in
                                        ret uu____10051))
                          | uu____10062 ->
                              let uu____10077 =
                                let uu____10078 =
                                  FStar_Tactics_Types.goal_env g  in
                                tts uu____10078 typ  in
                              fail1 "Not a disjunction: %s" uu____10077))))
       in
    FStar_All.pipe_left (wrap_err "cases") uu____9817
  
let (set_options : Prims.string -> unit tac) =
  fun s  ->
    let uu____10108 =
      let uu____10111 = cur_goal ()  in
      bind uu____10111
        (fun g  ->
           FStar_Options.push ();
           (let uu____10124 = FStar_Util.smap_copy g.FStar_Tactics_Types.opts
               in
            FStar_Options.set uu____10124);
           (let res = FStar_Options.set_options FStar_Options.Set s  in
            let opts' = FStar_Options.peek ()  in
            FStar_Options.pop ();
            (match res with
             | FStar_Getopt.Success  ->
                 let g' =
                   let uu___423_10131 = g  in
                   {
                     FStar_Tactics_Types.goal_main_env =
                       (uu___423_10131.FStar_Tactics_Types.goal_main_env);
                     FStar_Tactics_Types.goal_ctx_uvar =
                       (uu___423_10131.FStar_Tactics_Types.goal_ctx_uvar);
                     FStar_Tactics_Types.opts = opts';
                     FStar_Tactics_Types.is_guard =
                       (uu___423_10131.FStar_Tactics_Types.is_guard);
                     FStar_Tactics_Types.label =
                       (uu___423_10131.FStar_Tactics_Types.label)
                   }  in
                 replace_cur g'
             | FStar_Getopt.Error err ->
                 fail2 "Setting options `%s` failed: %s" s err
             | FStar_Getopt.Help  ->
                 fail1 "Setting options `%s` failed (got `Help`?)" s)))
       in
    FStar_All.pipe_left (wrap_err "set_options") uu____10108
  
let (top_env : unit -> env tac) =
  fun uu____10143  ->
    bind get
      (fun ps  -> FStar_All.pipe_left ret ps.FStar_Tactics_Types.main_context)
  
let (lax_on : unit -> Prims.bool tac) =
  fun uu____10156  ->
    let uu____10159 = cur_goal ()  in
    bind uu____10159
      (fun g  ->
         let uu____10165 =
           (FStar_Options.lax ()) ||
             (let uu____10167 = FStar_Tactics_Types.goal_env g  in
              uu____10167.FStar_TypeChecker_Env.lax)
            in
         ret uu____10165)
  
let (unquote :
  FStar_Reflection_Data.typ ->
    FStar_Syntax_Syntax.term -> FStar_Syntax_Syntax.term tac)
  =
  fun ty  ->
    fun tm  ->
      let uu____10182 =
        mlog
          (fun uu____10187  ->
             let uu____10188 = FStar_Syntax_Print.term_to_string tm  in
             FStar_Util.print1 "unquote: tm = %s\n" uu____10188)
          (fun uu____10191  ->
             let uu____10192 = cur_goal ()  in
             bind uu____10192
               (fun goal  ->
                  let env =
                    let uu____10200 = FStar_Tactics_Types.goal_env goal  in
                    FStar_TypeChecker_Env.set_expected_typ uu____10200 ty  in
                  let uu____10201 = __tc_ghost env tm  in
                  bind uu____10201
                    (fun uu____10220  ->
                       match uu____10220 with
                       | (tm1,typ,guard) ->
                           mlog
                             (fun uu____10234  ->
                                let uu____10235 =
                                  FStar_Syntax_Print.term_to_string tm1  in
                                FStar_Util.print1 "unquote: tm' = %s\n"
                                  uu____10235)
                             (fun uu____10237  ->
                                mlog
                                  (fun uu____10240  ->
                                     let uu____10241 =
                                       FStar_Syntax_Print.term_to_string typ
                                        in
                                     FStar_Util.print1 "unquote: typ = %s\n"
                                       uu____10241)
                                  (fun uu____10244  ->
                                     let uu____10245 =
                                       proc_guard "unquote" env guard  in
                                     bind uu____10245
                                       (fun uu____10249  -> ret tm1))))))
         in
      FStar_All.pipe_left (wrap_err "unquote") uu____10182
  
let (uvar_env :
  env ->
    FStar_Reflection_Data.typ FStar_Pervasives_Native.option ->
      FStar_Syntax_Syntax.term tac)
  =
  fun env  ->
    fun ty  ->
      let uu____10272 =
        match ty with
        | FStar_Pervasives_Native.Some ty1 -> ret ty1
        | FStar_Pervasives_Native.None  ->
            let uu____10278 =
              let uu____10285 =
                let uu____10286 = FStar_Syntax_Util.type_u ()  in
                FStar_All.pipe_left FStar_Pervasives_Native.fst uu____10286
                 in
              new_uvar "uvar_env.2" env uu____10285  in
            bind uu____10278
              (fun uu____10302  ->
                 match uu____10302 with | (typ,uvar_typ) -> ret typ)
         in
      bind uu____10272
        (fun typ  ->
           let uu____10314 = new_uvar "uvar_env" env typ  in
           bind uu____10314
             (fun uu____10328  ->
                match uu____10328 with | (t,uvar_t) -> ret t))
  
let (unshelve : FStar_Syntax_Syntax.term -> unit tac) =
  fun t  ->
    let uu____10346 =
      bind get
        (fun ps  ->
           let env = ps.FStar_Tactics_Types.main_context  in
           let opts =
             match ps.FStar_Tactics_Types.goals with
             | g::uu____10365 -> g.FStar_Tactics_Types.opts
             | uu____10368 -> FStar_Options.peek ()  in
           let uu____10371 = FStar_Syntax_Util.head_and_args t  in
           match uu____10371 with
           | ({
                FStar_Syntax_Syntax.n = FStar_Syntax_Syntax.Tm_uvar
                  (ctx_uvar,uu____10391);
                FStar_Syntax_Syntax.pos = uu____10392;
                FStar_Syntax_Syntax.vars = uu____10393;_},uu____10394)
               ->
               let env1 =
                 let uu___424_10436 = env  in
                 {
                   FStar_TypeChecker_Env.solver =
                     (uu___424_10436.FStar_TypeChecker_Env.solver);
                   FStar_TypeChecker_Env.range =
                     (uu___424_10436.FStar_TypeChecker_Env.range);
                   FStar_TypeChecker_Env.curmodule =
                     (uu___424_10436.FStar_TypeChecker_Env.curmodule);
                   FStar_TypeChecker_Env.gamma =
                     (ctx_uvar.FStar_Syntax_Syntax.ctx_uvar_gamma);
                   FStar_TypeChecker_Env.gamma_sig =
                     (uu___424_10436.FStar_TypeChecker_Env.gamma_sig);
                   FStar_TypeChecker_Env.gamma_cache =
                     (uu___424_10436.FStar_TypeChecker_Env.gamma_cache);
                   FStar_TypeChecker_Env.modules =
                     (uu___424_10436.FStar_TypeChecker_Env.modules);
                   FStar_TypeChecker_Env.expected_typ =
                     (uu___424_10436.FStar_TypeChecker_Env.expected_typ);
                   FStar_TypeChecker_Env.sigtab =
                     (uu___424_10436.FStar_TypeChecker_Env.sigtab);
                   FStar_TypeChecker_Env.attrtab =
                     (uu___424_10436.FStar_TypeChecker_Env.attrtab);
                   FStar_TypeChecker_Env.is_pattern =
                     (uu___424_10436.FStar_TypeChecker_Env.is_pattern);
                   FStar_TypeChecker_Env.instantiate_imp =
                     (uu___424_10436.FStar_TypeChecker_Env.instantiate_imp);
                   FStar_TypeChecker_Env.effects =
                     (uu___424_10436.FStar_TypeChecker_Env.effects);
                   FStar_TypeChecker_Env.generalize =
                     (uu___424_10436.FStar_TypeChecker_Env.generalize);
                   FStar_TypeChecker_Env.letrecs =
                     (uu___424_10436.FStar_TypeChecker_Env.letrecs);
                   FStar_TypeChecker_Env.top_level =
                     (uu___424_10436.FStar_TypeChecker_Env.top_level);
                   FStar_TypeChecker_Env.check_uvars =
                     (uu___424_10436.FStar_TypeChecker_Env.check_uvars);
                   FStar_TypeChecker_Env.use_eq =
                     (uu___424_10436.FStar_TypeChecker_Env.use_eq);
                   FStar_TypeChecker_Env.is_iface =
                     (uu___424_10436.FStar_TypeChecker_Env.is_iface);
                   FStar_TypeChecker_Env.admit =
                     (uu___424_10436.FStar_TypeChecker_Env.admit);
                   FStar_TypeChecker_Env.lax =
                     (uu___424_10436.FStar_TypeChecker_Env.lax);
                   FStar_TypeChecker_Env.lax_universes =
                     (uu___424_10436.FStar_TypeChecker_Env.lax_universes);
                   FStar_TypeChecker_Env.phase1 =
                     (uu___424_10436.FStar_TypeChecker_Env.phase1);
                   FStar_TypeChecker_Env.failhard =
                     (uu___424_10436.FStar_TypeChecker_Env.failhard);
                   FStar_TypeChecker_Env.nosynth =
                     (uu___424_10436.FStar_TypeChecker_Env.nosynth);
                   FStar_TypeChecker_Env.uvar_subtyping =
                     (uu___424_10436.FStar_TypeChecker_Env.uvar_subtyping);
                   FStar_TypeChecker_Env.tc_term =
                     (uu___424_10436.FStar_TypeChecker_Env.tc_term);
                   FStar_TypeChecker_Env.type_of =
                     (uu___424_10436.FStar_TypeChecker_Env.type_of);
                   FStar_TypeChecker_Env.universe_of =
                     (uu___424_10436.FStar_TypeChecker_Env.universe_of);
                   FStar_TypeChecker_Env.check_type_of =
                     (uu___424_10436.FStar_TypeChecker_Env.check_type_of);
                   FStar_TypeChecker_Env.use_bv_sorts =
                     (uu___424_10436.FStar_TypeChecker_Env.use_bv_sorts);
                   FStar_TypeChecker_Env.qtbl_name_and_index =
                     (uu___424_10436.FStar_TypeChecker_Env.qtbl_name_and_index);
                   FStar_TypeChecker_Env.normalized_eff_names =
                     (uu___424_10436.FStar_TypeChecker_Env.normalized_eff_names);
                   FStar_TypeChecker_Env.fv_delta_depths =
                     (uu___424_10436.FStar_TypeChecker_Env.fv_delta_depths);
                   FStar_TypeChecker_Env.proof_ns =
                     (uu___424_10436.FStar_TypeChecker_Env.proof_ns);
                   FStar_TypeChecker_Env.synth_hook =
                     (uu___424_10436.FStar_TypeChecker_Env.synth_hook);
                   FStar_TypeChecker_Env.splice =
                     (uu___424_10436.FStar_TypeChecker_Env.splice);
                   FStar_TypeChecker_Env.postprocess =
                     (uu___424_10436.FStar_TypeChecker_Env.postprocess);
                   FStar_TypeChecker_Env.is_native_tactic =
                     (uu___424_10436.FStar_TypeChecker_Env.is_native_tactic);
                   FStar_TypeChecker_Env.identifier_info =
                     (uu___424_10436.FStar_TypeChecker_Env.identifier_info);
                   FStar_TypeChecker_Env.tc_hooks =
                     (uu___424_10436.FStar_TypeChecker_Env.tc_hooks);
                   FStar_TypeChecker_Env.dsenv =
                     (uu___424_10436.FStar_TypeChecker_Env.dsenv);
                   FStar_TypeChecker_Env.nbe =
                     (uu___424_10436.FStar_TypeChecker_Env.nbe)
                 }  in
               let g =
                 FStar_Tactics_Types.mk_goal env1 ctx_uvar opts false ""  in
               let uu____10438 =
                 let uu____10441 = bnorm_goal g  in [uu____10441]  in
               add_goals uu____10438
           | uu____10442 -> fail "not a uvar")
       in
    FStar_All.pipe_left (wrap_err "unshelve") uu____10346
  
let (tac_and : Prims.bool tac -> Prims.bool tac -> Prims.bool tac) =
  fun t1  ->
    fun t2  ->
      let comp =
        bind t1
          (fun b  ->
             let uu____10491 = if b then t2 else ret false  in
             bind uu____10491 (fun b'  -> if b' then ret b' else fail ""))
         in
      let uu____10502 = trytac comp  in
      bind uu____10502
        (fun uu___354_10510  ->
           match uu___354_10510 with
           | FStar_Pervasives_Native.Some (true ) -> ret true
           | FStar_Pervasives_Native.Some (false ) -> failwith "impossible"
           | FStar_Pervasives_Native.None  -> ret false)
  
let (unify_env :
  env ->
    FStar_Syntax_Syntax.term -> FStar_Syntax_Syntax.term -> Prims.bool tac)
  =
  fun e  ->
    fun t1  ->
      fun t2  ->
        let uu____10536 =
          bind get
            (fun ps  ->
               let uu____10542 = __tc e t1  in
               bind uu____10542
                 (fun uu____10562  ->
                    match uu____10562 with
                    | (t11,ty1,g1) ->
                        let uu____10574 = __tc e t2  in
                        bind uu____10574
                          (fun uu____10594  ->
                             match uu____10594 with
                             | (t21,ty2,g2) ->
                                 let uu____10606 =
                                   proc_guard "unify_env g1" e g1  in
                                 bind uu____10606
                                   (fun uu____10611  ->
                                      let uu____10612 =
                                        proc_guard "unify_env g2" e g2  in
                                      bind uu____10612
                                        (fun uu____10618  ->
                                           let uu____10619 =
                                             do_unify e ty1 ty2  in
                                           let uu____10622 =
                                             do_unify e t11 t21  in
                                           tac_and uu____10619 uu____10622)))))
           in
        FStar_All.pipe_left (wrap_err "unify_env") uu____10536
  
let (launch_process :
  Prims.string -> Prims.string Prims.list -> Prims.string -> Prims.string tac)
  =
  fun prog  ->
    fun args  ->
      fun input  ->
        bind idtac
          (fun uu____10655  ->
             let uu____10656 = FStar_Options.unsafe_tactic_exec ()  in
             if uu____10656
             then
               let s =
                 FStar_Util.run_process "tactic_launch" prog args
                   (FStar_Pervasives_Native.Some input)
                  in
               ret s
             else
               fail
                 "launch_process: will not run anything unless --unsafe_tactic_exec is provided")
  
let (fresh_bv_named :
  Prims.string -> FStar_Reflection_Data.typ -> FStar_Syntax_Syntax.bv tac) =
  fun nm  ->
    fun t  ->
      bind idtac
        (fun uu____10677  ->
           let uu____10678 =
             FStar_Syntax_Syntax.gen_bv nm FStar_Pervasives_Native.None t  in
           ret uu____10678)
  
let (change : FStar_Reflection_Data.typ -> unit tac) =
  fun ty  ->
    let uu____10688 =
      mlog
        (fun uu____10693  ->
           let uu____10694 = FStar_Syntax_Print.term_to_string ty  in
           FStar_Util.print1 "change: ty = %s\n" uu____10694)
        (fun uu____10697  ->
           let uu____10698 = cur_goal ()  in
           bind uu____10698
             (fun g  ->
                let uu____10704 =
                  let uu____10713 = FStar_Tactics_Types.goal_env g  in
                  __tc uu____10713 ty  in
                bind uu____10704
                  (fun uu____10725  ->
                     match uu____10725 with
                     | (ty1,uu____10735,guard) ->
                         let uu____10737 =
                           let uu____10740 = FStar_Tactics_Types.goal_env g
                              in
                           proc_guard "change" uu____10740 guard  in
                         bind uu____10737
                           (fun uu____10743  ->
                              let uu____10744 =
                                let uu____10747 =
                                  FStar_Tactics_Types.goal_env g  in
                                let uu____10748 =
                                  FStar_Tactics_Types.goal_type g  in
                                do_unify uu____10747 uu____10748 ty1  in
                              bind uu____10744
                                (fun bb  ->
                                   if bb
                                   then
                                     let uu____10754 =
                                       FStar_Tactics_Types.goal_with_type g
                                         ty1
                                        in
                                     replace_cur uu____10754
                                   else
                                     (let steps =
                                        [FStar_TypeChecker_Env.AllowUnboundUniverses;
                                        FStar_TypeChecker_Env.UnfoldUntil
                                          FStar_Syntax_Syntax.delta_constant;
                                        FStar_TypeChecker_Env.Primops]  in
                                      let ng =
                                        let uu____10760 =
                                          FStar_Tactics_Types.goal_env g  in
                                        let uu____10761 =
                                          FStar_Tactics_Types.goal_type g  in
                                        normalize steps uu____10760
                                          uu____10761
                                         in
                                      let nty =
                                        let uu____10763 =
                                          FStar_Tactics_Types.goal_env g  in
                                        normalize steps uu____10763 ty1  in
                                      let uu____10764 =
                                        let uu____10767 =
                                          FStar_Tactics_Types.goal_env g  in
                                        do_unify uu____10767 ng nty  in
                                      bind uu____10764
                                        (fun b  ->
                                           if b
                                           then
                                             let uu____10773 =
                                               FStar_Tactics_Types.goal_with_type
                                                 g ty1
                                                in
                                             replace_cur uu____10773
                                           else fail "not convertible")))))))
       in
    FStar_All.pipe_left (wrap_err "change") uu____10688
  
let failwhen : 'a . Prims.bool -> Prims.string -> (unit -> 'a tac) -> 'a tac
  = fun b  -> fun msg  -> fun k  -> if b then fail msg else k () 
let (t_destruct :
  FStar_Syntax_Syntax.term ->
    (FStar_Syntax_Syntax.fv,FStar_BigInt.t) FStar_Pervasives_Native.tuple2
      Prims.list tac)
  =
  fun s_tm  ->
    let uu____10836 =
      let uu____10845 = cur_goal ()  in
      bind uu____10845
        (fun g  ->
           let uu____10857 =
             let uu____10866 = FStar_Tactics_Types.goal_env g  in
             __tc uu____10866 s_tm  in
           bind uu____10857
             (fun uu____10884  ->
                match uu____10884 with
                | (s_tm1,s_ty,guard) ->
                    let uu____10902 =
                      let uu____10905 = FStar_Tactics_Types.goal_env g  in
                      proc_guard "destruct" uu____10905 guard  in
                    bind uu____10902
                      (fun uu____10917  ->
                         let uu____10918 =
                           FStar_Syntax_Util.head_and_args' s_ty  in
                         match uu____10918 with
                         | (h,args) ->
                             let uu____10963 =
                               let uu____10970 =
                                 let uu____10971 =
                                   FStar_Syntax_Subst.compress h  in
                                 uu____10971.FStar_Syntax_Syntax.n  in
                               match uu____10970 with
                               | FStar_Syntax_Syntax.Tm_fvar fv ->
                                   ret (fv, [])
                               | FStar_Syntax_Syntax.Tm_uinst
                                   ({
                                      FStar_Syntax_Syntax.n =
                                        FStar_Syntax_Syntax.Tm_fvar fv;
                                      FStar_Syntax_Syntax.pos = uu____10986;
                                      FStar_Syntax_Syntax.vars = uu____10987;_},us)
                                   -> ret (fv, us)
                               | uu____10997 -> fail "type is not an fv"  in
                             bind uu____10963
                               (fun uu____11017  ->
                                  match uu____11017 with
                                  | (fv,a_us) ->
                                      let t_lid =
                                        FStar_Syntax_Syntax.lid_of_fv fv  in
                                      let uu____11033 =
                                        let uu____11036 =
                                          FStar_Tactics_Types.goal_env g  in
                                        FStar_TypeChecker_Env.lookup_sigelt
                                          uu____11036 t_lid
                                         in
                                      (match uu____11033 with
                                       | FStar_Pervasives_Native.None  ->
                                           fail
                                             "type not found in environment"
                                       | FStar_Pervasives_Native.Some se ->
                                           (match se.FStar_Syntax_Syntax.sigel
                                            with
                                            | FStar_Syntax_Syntax.Sig_inductive_typ
                                                (_lid,t_us,t_ps,t_ty,mut,c_lids)
                                                ->
                                                failwhen
                                                  ((FStar_List.length a_us)
                                                     <>
                                                     (FStar_List.length t_us))
                                                  "t_us don't match?"
                                                  (fun uu____11085  ->
                                                     let uu____11086 =
                                                       FStar_Syntax_Subst.open_term
                                                         t_ps t_ty
                                                        in
                                                     match uu____11086 with
                                                     | (t_ps1,t_ty1) ->
                                                         let uu____11101 =
                                                           mapM
                                                             (fun c_lid  ->
                                                                let uu____11129
                                                                  =
                                                                  let uu____11132
                                                                    =
                                                                    FStar_Tactics_Types.goal_env
                                                                    g  in
                                                                  FStar_TypeChecker_Env.lookup_sigelt
                                                                    uu____11132
                                                                    c_lid
                                                                   in
                                                                match uu____11129
                                                                with
                                                                | FStar_Pervasives_Native.None
                                                                     ->
                                                                    fail
                                                                    "ctor not found?"
                                                                | FStar_Pervasives_Native.Some
                                                                    se1 ->
                                                                    (
                                                                    match 
                                                                    se1.FStar_Syntax_Syntax.sigel
                                                                    with
                                                                    | 
                                                                    FStar_Syntax_Syntax.Sig_datacon
                                                                    (_c_lid,c_us,c_ty,_t_lid,nparam,mut1)
                                                                    ->
                                                                    let fv1 =
                                                                    FStar_Syntax_Syntax.lid_as_fv
                                                                    c_lid
                                                                    FStar_Syntax_Syntax.delta_constant
                                                                    (FStar_Pervasives_Native.Some
                                                                    FStar_Syntax_Syntax.Data_ctor)
                                                                     in
                                                                    failwhen
                                                                    ((FStar_List.length
                                                                    a_us) <>
                                                                    (FStar_List.length
                                                                    c_us))
                                                                    "t_us don't match?"
                                                                    (fun
                                                                    uu____11202
                                                                     ->
                                                                    let s =
                                                                    FStar_TypeChecker_Env.mk_univ_subst
                                                                    c_us a_us
                                                                     in
                                                                    let c_ty1
                                                                    =
                                                                    FStar_Syntax_Subst.subst
                                                                    s c_ty
                                                                     in
                                                                    let uu____11207
                                                                    =
                                                                    FStar_TypeChecker_Env.inst_tscheme
                                                                    (c_us,
                                                                    c_ty1)
                                                                     in
                                                                    match uu____11207
                                                                    with
                                                                    | 
                                                                    (c_us1,c_ty2)
                                                                    ->
                                                                    let uu____11230
                                                                    =
                                                                    FStar_Syntax_Util.arrow_formals_comp
                                                                    c_ty2  in
                                                                    (match uu____11230
                                                                    with
                                                                    | 
                                                                    (bs,comp)
                                                                    ->
                                                                    let uu____11273
                                                                    =
                                                                    FStar_List.splitAt
                                                                    nparam bs
                                                                     in
                                                                    (match uu____11273
                                                                    with
                                                                    | 
                                                                    (d_ps,bs1)
                                                                    ->
                                                                    let uu____11346
                                                                    =
                                                                    let uu____11347
                                                                    =
                                                                    FStar_Syntax_Util.is_total_comp
                                                                    comp  in
                                                                    Prims.op_Negation
                                                                    uu____11347
                                                                     in
                                                                    failwhen
                                                                    uu____11346
                                                                    "not total?"
                                                                    (fun
                                                                    uu____11364
                                                                     ->
                                                                    let mk_pat
                                                                    p =
                                                                    {
                                                                    FStar_Syntax_Syntax.v
                                                                    = p;
                                                                    FStar_Syntax_Syntax.p
                                                                    =
                                                                    (s_tm1.FStar_Syntax_Syntax.pos)
                                                                    }  in
                                                                    let is_imp
                                                                    uu___355_11380
                                                                    =
                                                                    match uu___355_11380
                                                                    with
                                                                    | 
                                                                    FStar_Pervasives_Native.Some
                                                                    (FStar_Syntax_Syntax.Implicit
                                                                    uu____11383)
                                                                    -> true
                                                                    | 
                                                                    uu____11384
                                                                    -> false
                                                                     in
                                                                    let uu____11387
                                                                    =
                                                                    FStar_List.splitAt
                                                                    nparam
                                                                    args  in
                                                                    match uu____11387
                                                                    with
                                                                    | 
                                                                    (a_ps,a_is)
                                                                    ->
                                                                    failwhen
                                                                    ((FStar_List.length
                                                                    a_ps) <>
                                                                    (FStar_List.length
                                                                    d_ps))
                                                                    "params not match?"
                                                                    (fun
                                                                    uu____11520
                                                                     ->
                                                                    let d_ps_a_ps
                                                                    =
                                                                    FStar_List.zip
                                                                    d_ps a_ps
                                                                     in
                                                                    let subst1
                                                                    =
                                                                    FStar_List.map
                                                                    (fun
                                                                    uu____11582
                                                                     ->
                                                                    match uu____11582
                                                                    with
                                                                    | 
                                                                    ((bv,uu____11602),
                                                                    (t,uu____11604))
                                                                    ->
                                                                    FStar_Syntax_Syntax.NT
                                                                    (bv, t))
                                                                    d_ps_a_ps
                                                                     in
                                                                    let bs2 =
                                                                    FStar_Syntax_Subst.subst_binders
                                                                    subst1
                                                                    bs1  in
                                                                    let subpats_1
                                                                    =
                                                                    FStar_List.map
                                                                    (fun
                                                                    uu____11672
                                                                     ->
                                                                    match uu____11672
                                                                    with
                                                                    | 
                                                                    ((bv,uu____11698),
                                                                    (t,uu____11700))
                                                                    ->
                                                                    ((mk_pat
                                                                    (FStar_Syntax_Syntax.Pat_dot_term
                                                                    (bv, t))),
                                                                    true))
                                                                    d_ps_a_ps
                                                                     in
                                                                    let subpats_2
                                                                    =
                                                                    FStar_List.map
                                                                    (fun
                                                                    uu____11755
                                                                     ->
                                                                    match uu____11755
                                                                    with
                                                                    | 
                                                                    (bv,aq)
                                                                    ->
                                                                    ((mk_pat
                                                                    (FStar_Syntax_Syntax.Pat_var
                                                                    bv)),
                                                                    (is_imp
                                                                    aq))) bs2
                                                                     in
                                                                    let subpats
                                                                    =
                                                                    FStar_List.append
                                                                    subpats_1
                                                                    subpats_2
                                                                     in
                                                                    let pat =
                                                                    mk_pat
                                                                    (FStar_Syntax_Syntax.Pat_cons
                                                                    (fv1,
                                                                    subpats))
                                                                     in
                                                                    let env =
                                                                    FStar_Tactics_Types.goal_env
                                                                    g  in
                                                                    let cod =
                                                                    FStar_Tactics_Types.goal_type
                                                                    g  in
                                                                    let equ =
                                                                    env.FStar_TypeChecker_Env.universe_of
                                                                    env s_ty
                                                                     in
                                                                    let uu____11805
                                                                    =
                                                                    FStar_TypeChecker_TcTerm.tc_pat
                                                                    (let uu___425_11822
                                                                    = env  in
                                                                    {
                                                                    FStar_TypeChecker_Env.solver
                                                                    =
                                                                    (uu___425_11822.FStar_TypeChecker_Env.solver);
                                                                    FStar_TypeChecker_Env.range
                                                                    =
                                                                    (uu___425_11822.FStar_TypeChecker_Env.range);
                                                                    FStar_TypeChecker_Env.curmodule
                                                                    =
                                                                    (uu___425_11822.FStar_TypeChecker_Env.curmodule);
                                                                    FStar_TypeChecker_Env.gamma
                                                                    =
                                                                    (uu___425_11822.FStar_TypeChecker_Env.gamma);
                                                                    FStar_TypeChecker_Env.gamma_sig
                                                                    =
                                                                    (uu___425_11822.FStar_TypeChecker_Env.gamma_sig);
                                                                    FStar_TypeChecker_Env.gamma_cache
                                                                    =
                                                                    (uu___425_11822.FStar_TypeChecker_Env.gamma_cache);
                                                                    FStar_TypeChecker_Env.modules
                                                                    =
                                                                    (uu___425_11822.FStar_TypeChecker_Env.modules);
                                                                    FStar_TypeChecker_Env.expected_typ
                                                                    =
                                                                    (uu___425_11822.FStar_TypeChecker_Env.expected_typ);
                                                                    FStar_TypeChecker_Env.sigtab
                                                                    =
                                                                    (uu___425_11822.FStar_TypeChecker_Env.sigtab);
                                                                    FStar_TypeChecker_Env.attrtab
                                                                    =
                                                                    (uu___425_11822.FStar_TypeChecker_Env.attrtab);
                                                                    FStar_TypeChecker_Env.is_pattern
                                                                    =
                                                                    (uu___425_11822.FStar_TypeChecker_Env.is_pattern);
                                                                    FStar_TypeChecker_Env.instantiate_imp
                                                                    =
                                                                    (uu___425_11822.FStar_TypeChecker_Env.instantiate_imp);
                                                                    FStar_TypeChecker_Env.effects
                                                                    =
                                                                    (uu___425_11822.FStar_TypeChecker_Env.effects);
                                                                    FStar_TypeChecker_Env.generalize
                                                                    =
                                                                    (uu___425_11822.FStar_TypeChecker_Env.generalize);
                                                                    FStar_TypeChecker_Env.letrecs
                                                                    =
                                                                    (uu___425_11822.FStar_TypeChecker_Env.letrecs);
                                                                    FStar_TypeChecker_Env.top_level
                                                                    =
                                                                    (uu___425_11822.FStar_TypeChecker_Env.top_level);
                                                                    FStar_TypeChecker_Env.check_uvars
                                                                    =
                                                                    (uu___425_11822.FStar_TypeChecker_Env.check_uvars);
                                                                    FStar_TypeChecker_Env.use_eq
                                                                    =
                                                                    (uu___425_11822.FStar_TypeChecker_Env.use_eq);
                                                                    FStar_TypeChecker_Env.is_iface
                                                                    =
                                                                    (uu___425_11822.FStar_TypeChecker_Env.is_iface);
                                                                    FStar_TypeChecker_Env.admit
                                                                    =
                                                                    (uu___425_11822.FStar_TypeChecker_Env.admit);
                                                                    FStar_TypeChecker_Env.lax
                                                                    = true;
                                                                    FStar_TypeChecker_Env.lax_universes
                                                                    =
                                                                    (uu___425_11822.FStar_TypeChecker_Env.lax_universes);
                                                                    FStar_TypeChecker_Env.phase1
                                                                    =
                                                                    (uu___425_11822.FStar_TypeChecker_Env.phase1);
                                                                    FStar_TypeChecker_Env.failhard
                                                                    =
                                                                    (uu___425_11822.FStar_TypeChecker_Env.failhard);
                                                                    FStar_TypeChecker_Env.nosynth
                                                                    =
                                                                    (uu___425_11822.FStar_TypeChecker_Env.nosynth);
                                                                    FStar_TypeChecker_Env.uvar_subtyping
                                                                    =
                                                                    (uu___425_11822.FStar_TypeChecker_Env.uvar_subtyping);
                                                                    FStar_TypeChecker_Env.tc_term
                                                                    =
                                                                    (uu___425_11822.FStar_TypeChecker_Env.tc_term);
                                                                    FStar_TypeChecker_Env.type_of
                                                                    =
                                                                    (uu___425_11822.FStar_TypeChecker_Env.type_of);
                                                                    FStar_TypeChecker_Env.universe_of
                                                                    =
                                                                    (uu___425_11822.FStar_TypeChecker_Env.universe_of);
                                                                    FStar_TypeChecker_Env.check_type_of
                                                                    =
                                                                    (uu___425_11822.FStar_TypeChecker_Env.check_type_of);
                                                                    FStar_TypeChecker_Env.use_bv_sorts
                                                                    =
                                                                    (uu___425_11822.FStar_TypeChecker_Env.use_bv_sorts);
                                                                    FStar_TypeChecker_Env.qtbl_name_and_index
                                                                    =
                                                                    (uu___425_11822.FStar_TypeChecker_Env.qtbl_name_and_index);
                                                                    FStar_TypeChecker_Env.normalized_eff_names
                                                                    =
                                                                    (uu___425_11822.FStar_TypeChecker_Env.normalized_eff_names);
                                                                    FStar_TypeChecker_Env.fv_delta_depths
                                                                    =
                                                                    (uu___425_11822.FStar_TypeChecker_Env.fv_delta_depths);
                                                                    FStar_TypeChecker_Env.proof_ns
                                                                    =
                                                                    (uu___425_11822.FStar_TypeChecker_Env.proof_ns);
                                                                    FStar_TypeChecker_Env.synth_hook
                                                                    =
                                                                    (uu___425_11822.FStar_TypeChecker_Env.synth_hook);
                                                                    FStar_TypeChecker_Env.splice
                                                                    =
                                                                    (uu___425_11822.FStar_TypeChecker_Env.splice);
                                                                    FStar_TypeChecker_Env.postprocess
                                                                    =
                                                                    (uu___425_11822.FStar_TypeChecker_Env.postprocess);
                                                                    FStar_TypeChecker_Env.is_native_tactic
                                                                    =
                                                                    (uu___425_11822.FStar_TypeChecker_Env.is_native_tactic);
                                                                    FStar_TypeChecker_Env.identifier_info
                                                                    =
                                                                    (uu___425_11822.FStar_TypeChecker_Env.identifier_info);
                                                                    FStar_TypeChecker_Env.tc_hooks
                                                                    =
                                                                    (uu___425_11822.FStar_TypeChecker_Env.tc_hooks);
                                                                    FStar_TypeChecker_Env.dsenv
                                                                    =
                                                                    (uu___425_11822.FStar_TypeChecker_Env.dsenv);
                                                                    FStar_TypeChecker_Env.nbe
                                                                    =
                                                                    (uu___425_11822.FStar_TypeChecker_Env.nbe)
                                                                    }) s_ty
                                                                    pat  in
                                                                    match uu____11805
                                                                    with
                                                                    | 
                                                                    (uu____11835,uu____11836,uu____11837,pat_t,uu____11839,_guard_pat)
                                                                    ->
                                                                    let eq_b
                                                                    =
                                                                    let uu____11846
                                                                    =
                                                                    let uu____11847
                                                                    =
                                                                    FStar_Syntax_Util.mk_eq2
                                                                    equ s_ty
                                                                    s_tm1
                                                                    pat_t  in
                                                                    FStar_Syntax_Util.mk_squash
                                                                    equ
                                                                    uu____11847
                                                                     in
                                                                    FStar_Syntax_Syntax.gen_bv
                                                                    "breq"
                                                                    FStar_Pervasives_Native.None
                                                                    uu____11846
                                                                     in
                                                                    let cod1
                                                                    =
                                                                    let uu____11851
                                                                    =
                                                                    let uu____11860
                                                                    =
                                                                    FStar_Syntax_Syntax.mk_binder
                                                                    eq_b  in
                                                                    [uu____11860]
                                                                     in
                                                                    let uu____11879
                                                                    =
                                                                    FStar_Syntax_Syntax.mk_Total
                                                                    cod  in
                                                                    FStar_Syntax_Util.arrow
                                                                    uu____11851
                                                                    uu____11879
                                                                     in
                                                                    let nty =
                                                                    let uu____11885
                                                                    =
                                                                    FStar_Syntax_Syntax.mk_Total
                                                                    cod1  in
                                                                    FStar_Syntax_Util.arrow
                                                                    bs2
                                                                    uu____11885
                                                                     in
                                                                    let uu____11888
                                                                    =
                                                                    new_uvar
                                                                    "destruct branch"
                                                                    env nty
                                                                     in
                                                                    bind
                                                                    uu____11888
                                                                    (fun
                                                                    uu____11917
                                                                     ->
                                                                    match uu____11917
                                                                    with
                                                                    | 
                                                                    (uvt,uv)
                                                                    ->
                                                                    let g' =
                                                                    FStar_Tactics_Types.mk_goal
                                                                    env uv
                                                                    g.FStar_Tactics_Types.opts
                                                                    false
                                                                    g.FStar_Tactics_Types.label
                                                                     in
                                                                    let brt =
                                                                    FStar_Syntax_Util.mk_app_binders
                                                                    uvt bs2
                                                                     in
                                                                    let brt1
                                                                    =
                                                                    let uu____11943
                                                                    =
                                                                    let uu____11954
                                                                    =
                                                                    FStar_Syntax_Syntax.as_arg
                                                                    FStar_Syntax_Util.exp_unit
                                                                     in
                                                                    [uu____11954]
                                                                     in
                                                                    FStar_Syntax_Util.mk_app
                                                                    brt
                                                                    uu____11943
                                                                     in
                                                                    let br =
                                                                    FStar_Syntax_Subst.close_branch
                                                                    (pat,
                                                                    FStar_Pervasives_Native.None,
                                                                    brt1)  in
                                                                    let uu____11990
                                                                    =
                                                                    let uu____12001
                                                                    =
                                                                    let uu____12006
                                                                    =
                                                                    FStar_BigInt.of_int_fs
                                                                    (FStar_List.length
                                                                    bs2)  in
                                                                    (fv1,
                                                                    uu____12006)
                                                                     in
                                                                    (g', br,
                                                                    uu____12001)
                                                                     in
                                                                    ret
                                                                    uu____11990))))))
                                                                    | 
                                                                    uu____12027
                                                                    ->
                                                                    fail
                                                                    "impossible: not a ctor"))
                                                             c_lids
                                                            in
                                                         bind uu____11101
                                                           (fun goal_brs  ->
                                                              let uu____12076
                                                                =
                                                                FStar_List.unzip3
                                                                  goal_brs
                                                                 in
                                                              match uu____12076
                                                              with
                                                              | (goals,brs,infos)
                                                                  ->
                                                                  let w =
                                                                    FStar_Syntax_Syntax.mk
                                                                    (FStar_Syntax_Syntax.Tm_match
                                                                    (s_tm1,
                                                                    brs))
                                                                    FStar_Pervasives_Native.None
                                                                    s_tm1.FStar_Syntax_Syntax.pos
                                                                     in
                                                                  let uu____12149
                                                                    =
                                                                    solve' g
                                                                    w  in
                                                                  bind
                                                                    uu____12149
                                                                    (
                                                                    fun
                                                                    uu____12160
                                                                     ->
                                                                    let uu____12161
                                                                    =
                                                                    add_goals
                                                                    goals  in
                                                                    bind
                                                                    uu____12161
                                                                    (fun
                                                                    uu____12171
                                                                     ->
                                                                    ret infos))))
                                            | uu____12178 ->
                                                fail "not an inductive type"))))))
       in
    FStar_All.pipe_left (wrap_err "destruct") uu____10836
  
let rec last : 'a . 'a Prims.list -> 'a =
  fun l  ->
    match l with
    | [] -> failwith "last: empty list"
    | x::[] -> x
    | uu____12223::xs -> last xs
  
let rec init : 'a . 'a Prims.list -> 'a Prims.list =
  fun l  ->
    match l with
    | [] -> failwith "init: empty list"
    | x::[] -> []
    | x::xs -> let uu____12251 = init xs  in x :: uu____12251
  
let rec (inspect :
  FStar_Syntax_Syntax.term -> FStar_Reflection_Data.term_view tac) =
  fun t  ->
    let uu____12263 =
      let t1 = FStar_Syntax_Util.unascribe t  in
      let t2 = FStar_Syntax_Util.un_uinst t1  in
      let t3 = FStar_Syntax_Util.unlazy_emb t2  in
      match t3.FStar_Syntax_Syntax.n with
      | FStar_Syntax_Syntax.Tm_meta (t4,uu____12272) -> inspect t4
      | FStar_Syntax_Syntax.Tm_name bv ->
          FStar_All.pipe_left ret (FStar_Reflection_Data.Tv_Var bv)
      | FStar_Syntax_Syntax.Tm_bvar bv ->
          FStar_All.pipe_left ret (FStar_Reflection_Data.Tv_BVar bv)
      | FStar_Syntax_Syntax.Tm_fvar fv ->
          FStar_All.pipe_left ret (FStar_Reflection_Data.Tv_FVar fv)
      | FStar_Syntax_Syntax.Tm_app (hd1,[]) ->
          failwith "empty arguments on Tm_app"
      | FStar_Syntax_Syntax.Tm_app (hd1,args) ->
          let uu____12337 = last args  in
          (match uu____12337 with
           | (a,q) ->
               let q' = FStar_Reflection_Basic.inspect_aqual q  in
               let uu____12367 =
                 let uu____12368 =
                   let uu____12373 =
                     let uu____12374 =
                       let uu____12379 = init args  in
                       FStar_Syntax_Syntax.mk_Tm_app hd1 uu____12379  in
                     uu____12374 FStar_Pervasives_Native.None
                       t3.FStar_Syntax_Syntax.pos
                      in
                   (uu____12373, (a, q'))  in
                 FStar_Reflection_Data.Tv_App uu____12368  in
               FStar_All.pipe_left ret uu____12367)
      | FStar_Syntax_Syntax.Tm_abs ([],uu____12392,uu____12393) ->
          failwith "empty arguments on Tm_abs"
      | FStar_Syntax_Syntax.Tm_abs (bs,t4,k) ->
          let uu____12445 = FStar_Syntax_Subst.open_term bs t4  in
          (match uu____12445 with
           | (bs1,t5) ->
               (match bs1 with
                | [] -> failwith "impossible"
                | b::bs2 ->
                    let uu____12486 =
                      let uu____12487 =
                        let uu____12492 = FStar_Syntax_Util.abs bs2 t5 k  in
                        (b, uu____12492)  in
                      FStar_Reflection_Data.Tv_Abs uu____12487  in
                    FStar_All.pipe_left ret uu____12486))
      | FStar_Syntax_Syntax.Tm_type uu____12495 ->
          FStar_All.pipe_left ret (FStar_Reflection_Data.Tv_Type ())
      | FStar_Syntax_Syntax.Tm_arrow ([],k) ->
          failwith "empty binders on arrow"
      | FStar_Syntax_Syntax.Tm_arrow uu____12519 ->
          let uu____12534 = FStar_Syntax_Util.arrow_one t3  in
          (match uu____12534 with
           | FStar_Pervasives_Native.Some (b,c) ->
               FStar_All.pipe_left ret
                 (FStar_Reflection_Data.Tv_Arrow (b, c))
           | FStar_Pervasives_Native.None  -> failwith "impossible")
      | FStar_Syntax_Syntax.Tm_refine (bv,t4) ->
          let b = FStar_Syntax_Syntax.mk_binder bv  in
          let uu____12564 = FStar_Syntax_Subst.open_term [b] t4  in
          (match uu____12564 with
           | (b',t5) ->
               let b1 =
                 match b' with
                 | b'1::[] -> b'1
                 | uu____12617 -> failwith "impossible"  in
               FStar_All.pipe_left ret
                 (FStar_Reflection_Data.Tv_Refine
                    ((FStar_Pervasives_Native.fst b1), t5)))
      | FStar_Syntax_Syntax.Tm_constant c ->
          let uu____12629 =
            let uu____12630 = FStar_Reflection_Basic.inspect_const c  in
            FStar_Reflection_Data.Tv_Const uu____12630  in
          FStar_All.pipe_left ret uu____12629
      | FStar_Syntax_Syntax.Tm_uvar (ctx_u,s) ->
          let uu____12651 =
            let uu____12652 =
              let uu____12657 =
                let uu____12658 =
                  FStar_Syntax_Unionfind.uvar_id
                    ctx_u.FStar_Syntax_Syntax.ctx_uvar_head
                   in
                FStar_BigInt.of_int_fs uu____12658  in
              (uu____12657, (ctx_u, s))  in
            FStar_Reflection_Data.Tv_Uvar uu____12652  in
          FStar_All.pipe_left ret uu____12651
      | FStar_Syntax_Syntax.Tm_let ((false ,lb::[]),t21) ->
          if lb.FStar_Syntax_Syntax.lbunivs <> []
          then FStar_All.pipe_left ret FStar_Reflection_Data.Tv_Unknown
          else
            (match lb.FStar_Syntax_Syntax.lbname with
             | FStar_Util.Inr uu____12692 ->
                 FStar_All.pipe_left ret FStar_Reflection_Data.Tv_Unknown
             | FStar_Util.Inl bv ->
                 let b = FStar_Syntax_Syntax.mk_binder bv  in
                 let uu____12697 = FStar_Syntax_Subst.open_term [b] t21  in
                 (match uu____12697 with
                  | (bs,t22) ->
                      let b1 =
                        match bs with
                        | b1::[] -> b1
                        | uu____12750 ->
                            failwith
                              "impossible: open_term returned different amount of binders"
                         in
                      FStar_All.pipe_left ret
                        (FStar_Reflection_Data.Tv_Let
                           (false, (FStar_Pervasives_Native.fst b1),
                             (lb.FStar_Syntax_Syntax.lbdef), t22))))
      | FStar_Syntax_Syntax.Tm_let ((true ,lb::[]),t21) ->
          if lb.FStar_Syntax_Syntax.lbunivs <> []
          then FStar_All.pipe_left ret FStar_Reflection_Data.Tv_Unknown
          else
            (match lb.FStar_Syntax_Syntax.lbname with
             | FStar_Util.Inr uu____12784 ->
                 FStar_All.pipe_left ret FStar_Reflection_Data.Tv_Unknown
             | FStar_Util.Inl bv ->
                 let uu____12788 = FStar_Syntax_Subst.open_let_rec [lb] t21
                    in
                 (match uu____12788 with
                  | (lbs,t22) ->
                      (match lbs with
                       | lb1::[] ->
                           (match lb1.FStar_Syntax_Syntax.lbname with
                            | FStar_Util.Inr uu____12808 ->
                                ret FStar_Reflection_Data.Tv_Unknown
                            | FStar_Util.Inl bv1 ->
                                FStar_All.pipe_left ret
                                  (FStar_Reflection_Data.Tv_Let
                                     (true, bv1,
                                       (lb1.FStar_Syntax_Syntax.lbdef), t22)))
                       | uu____12812 ->
                           failwith
                             "impossible: open_term returned different amount of binders")))
      | FStar_Syntax_Syntax.Tm_match (t4,brs) ->
          let rec inspect_pat p =
            match p.FStar_Syntax_Syntax.v with
            | FStar_Syntax_Syntax.Pat_constant c ->
                let uu____12866 = FStar_Reflection_Basic.inspect_const c  in
                FStar_Reflection_Data.Pat_Constant uu____12866
            | FStar_Syntax_Syntax.Pat_cons (fv,ps) ->
                let uu____12885 =
                  let uu____12892 =
                    FStar_List.map
                      (fun uu____12904  ->
                         match uu____12904 with
                         | (p1,uu____12912) -> inspect_pat p1) ps
                     in
                  (fv, uu____12892)  in
                FStar_Reflection_Data.Pat_Cons uu____12885
            | FStar_Syntax_Syntax.Pat_var bv ->
                FStar_Reflection_Data.Pat_Var bv
            | FStar_Syntax_Syntax.Pat_wild bv ->
                FStar_Reflection_Data.Pat_Wild bv
            | FStar_Syntax_Syntax.Pat_dot_term (bv,t5) ->
                FStar_Reflection_Data.Pat_Dot_Term (bv, t5)
             in
          let brs1 = FStar_List.map FStar_Syntax_Subst.open_branch brs  in
          let brs2 =
            FStar_List.map
              (fun uu___356_13006  ->
                 match uu___356_13006 with
                 | (pat,uu____13028,t5) ->
                     let uu____13046 = inspect_pat pat  in (uu____13046, t5))
              brs1
             in
          FStar_All.pipe_left ret (FStar_Reflection_Data.Tv_Match (t4, brs2))
      | FStar_Syntax_Syntax.Tm_unknown  ->
          FStar_All.pipe_left ret FStar_Reflection_Data.Tv_Unknown
      | uu____13055 ->
          ((let uu____13057 =
              let uu____13062 =
                let uu____13063 = FStar_Syntax_Print.tag_of_term t3  in
                let uu____13064 = FStar_Syntax_Print.term_to_string t3  in
                FStar_Util.format2
                  "inspect: outside of expected syntax (%s, %s)\n"
                  uu____13063 uu____13064
                 in
              (FStar_Errors.Warning_CantInspect, uu____13062)  in
            FStar_Errors.log_issue t3.FStar_Syntax_Syntax.pos uu____13057);
           FStar_All.pipe_left ret FStar_Reflection_Data.Tv_Unknown)
       in
    wrap_err "inspect" uu____12263
  
let (pack : FStar_Reflection_Data.term_view -> FStar_Syntax_Syntax.term tac)
  =
  fun tv  ->
    match tv with
    | FStar_Reflection_Data.Tv_Var bv ->
        let uu____13077 = FStar_Syntax_Syntax.bv_to_name bv  in
        FStar_All.pipe_left ret uu____13077
    | FStar_Reflection_Data.Tv_BVar bv ->
        let uu____13081 = FStar_Syntax_Syntax.bv_to_tm bv  in
        FStar_All.pipe_left ret uu____13081
    | FStar_Reflection_Data.Tv_FVar fv ->
        let uu____13085 = FStar_Syntax_Syntax.fv_to_tm fv  in
        FStar_All.pipe_left ret uu____13085
    | FStar_Reflection_Data.Tv_App (l,(r,q)) ->
        let q' = FStar_Reflection_Basic.pack_aqual q  in
        let uu____13092 = FStar_Syntax_Util.mk_app l [(r, q')]  in
        FStar_All.pipe_left ret uu____13092
    | FStar_Reflection_Data.Tv_Abs (b,t) ->
        let uu____13117 =
          FStar_Syntax_Util.abs [b] t FStar_Pervasives_Native.None  in
        FStar_All.pipe_left ret uu____13117
    | FStar_Reflection_Data.Tv_Arrow (b,c) ->
        let uu____13134 = FStar_Syntax_Util.arrow [b] c  in
        FStar_All.pipe_left ret uu____13134
    | FStar_Reflection_Data.Tv_Type () ->
        FStar_All.pipe_left ret FStar_Syntax_Util.ktype
    | FStar_Reflection_Data.Tv_Refine (bv,t) ->
        let uu____13153 = FStar_Syntax_Util.refine bv t  in
        FStar_All.pipe_left ret uu____13153
    | FStar_Reflection_Data.Tv_Const c ->
        let uu____13157 =
          let uu____13158 =
            let uu____13165 =
              let uu____13166 = FStar_Reflection_Basic.pack_const c  in
              FStar_Syntax_Syntax.Tm_constant uu____13166  in
            FStar_Syntax_Syntax.mk uu____13165  in
          uu____13158 FStar_Pervasives_Native.None FStar_Range.dummyRange  in
        FStar_All.pipe_left ret uu____13157
    | FStar_Reflection_Data.Tv_Uvar (_u,ctx_u_s) ->
        let uu____13174 =
          FStar_Syntax_Syntax.mk (FStar_Syntax_Syntax.Tm_uvar ctx_u_s)
            FStar_Pervasives_Native.None FStar_Range.dummyRange
           in
        FStar_All.pipe_left ret uu____13174
    | FStar_Reflection_Data.Tv_Let (false ,bv,t1,t2) ->
        let lb =
          FStar_Syntax_Util.mk_letbinding (FStar_Util.Inl bv) []
            bv.FStar_Syntax_Syntax.sort FStar_Parser_Const.effect_Tot_lid t1
            [] FStar_Range.dummyRange
           in
        let uu____13183 =
          let uu____13184 =
            let uu____13191 =
              let uu____13192 =
                let uu____13205 =
                  let uu____13208 =
                    let uu____13209 = FStar_Syntax_Syntax.mk_binder bv  in
                    [uu____13209]  in
                  FStar_Syntax_Subst.close uu____13208 t2  in
                ((false, [lb]), uu____13205)  in
              FStar_Syntax_Syntax.Tm_let uu____13192  in
            FStar_Syntax_Syntax.mk uu____13191  in
          uu____13184 FStar_Pervasives_Native.None FStar_Range.dummyRange  in
        FStar_All.pipe_left ret uu____13183
    | FStar_Reflection_Data.Tv_Let (true ,bv,t1,t2) ->
        let lb =
          FStar_Syntax_Util.mk_letbinding (FStar_Util.Inl bv) []
            bv.FStar_Syntax_Syntax.sort FStar_Parser_Const.effect_Tot_lid t1
            [] FStar_Range.dummyRange
           in
        let uu____13249 = FStar_Syntax_Subst.close_let_rec [lb] t2  in
        (match uu____13249 with
         | (lbs,body) ->
             let uu____13264 =
               FStar_Syntax_Syntax.mk
                 (FStar_Syntax_Syntax.Tm_let ((true, lbs), body))
                 FStar_Pervasives_Native.None FStar_Range.dummyRange
                in
             FStar_All.pipe_left ret uu____13264)
    | FStar_Reflection_Data.Tv_Match (t,brs) ->
        let wrap v1 =
          {
            FStar_Syntax_Syntax.v = v1;
            FStar_Syntax_Syntax.p = FStar_Range.dummyRange
          }  in
        let rec pack_pat p =
          match p with
          | FStar_Reflection_Data.Pat_Constant c ->
              let uu____13298 =
                let uu____13299 = FStar_Reflection_Basic.pack_const c  in
                FStar_Syntax_Syntax.Pat_constant uu____13299  in
              FStar_All.pipe_left wrap uu____13298
          | FStar_Reflection_Data.Pat_Cons (fv,ps) ->
              let uu____13306 =
                let uu____13307 =
                  let uu____13320 =
                    FStar_List.map
                      (fun p1  ->
                         let uu____13336 = pack_pat p1  in
                         (uu____13336, false)) ps
                     in
                  (fv, uu____13320)  in
                FStar_Syntax_Syntax.Pat_cons uu____13307  in
              FStar_All.pipe_left wrap uu____13306
          | FStar_Reflection_Data.Pat_Var bv ->
              FStar_All.pipe_left wrap (FStar_Syntax_Syntax.Pat_var bv)
          | FStar_Reflection_Data.Pat_Wild bv ->
              FStar_All.pipe_left wrap (FStar_Syntax_Syntax.Pat_wild bv)
          | FStar_Reflection_Data.Pat_Dot_Term (bv,t1) ->
              FStar_All.pipe_left wrap
                (FStar_Syntax_Syntax.Pat_dot_term (bv, t1))
           in
        let brs1 =
          FStar_List.map
            (fun uu___357_13382  ->
               match uu___357_13382 with
               | (pat,t1) ->
                   let uu____13399 = pack_pat pat  in
                   (uu____13399, FStar_Pervasives_Native.None, t1)) brs
           in
        let brs2 = FStar_List.map FStar_Syntax_Subst.close_branch brs1  in
        let uu____13447 =
          FStar_Syntax_Syntax.mk (FStar_Syntax_Syntax.Tm_match (t, brs2))
            FStar_Pervasives_Native.None FStar_Range.dummyRange
           in
        FStar_All.pipe_left ret uu____13447
    | FStar_Reflection_Data.Tv_AscribedT (e,t,tacopt) ->
        let uu____13475 =
          FStar_Syntax_Syntax.mk
            (FStar_Syntax_Syntax.Tm_ascribed
               (e, ((FStar_Util.Inl t), tacopt),
                 FStar_Pervasives_Native.None)) FStar_Pervasives_Native.None
            FStar_Range.dummyRange
           in
        FStar_All.pipe_left ret uu____13475
    | FStar_Reflection_Data.Tv_AscribedC (e,c,tacopt) ->
        let uu____13521 =
          FStar_Syntax_Syntax.mk
            (FStar_Syntax_Syntax.Tm_ascribed
               (e, ((FStar_Util.Inr c), tacopt),
                 FStar_Pervasives_Native.None)) FStar_Pervasives_Native.None
            FStar_Range.dummyRange
           in
        FStar_All.pipe_left ret uu____13521
    | FStar_Reflection_Data.Tv_Unknown  ->
        let uu____13560 =
          FStar_Syntax_Syntax.mk FStar_Syntax_Syntax.Tm_unknown
            FStar_Pervasives_Native.None FStar_Range.dummyRange
           in
        FStar_All.pipe_left ret uu____13560
  
let (lget :
  FStar_Reflection_Data.typ -> Prims.string -> FStar_Syntax_Syntax.term tac)
  =
  fun ty  ->
    fun k  ->
      let uu____13577 =
        bind get
          (fun ps  ->
             let uu____13583 =
               FStar_Util.psmap_try_find ps.FStar_Tactics_Types.local_state k
                in
             match uu____13583 with
             | FStar_Pervasives_Native.None  -> fail "not found"
             | FStar_Pervasives_Native.Some t -> unquote ty t)
         in
      FStar_All.pipe_left (wrap_err "lget") uu____13577
  
let (lset :
  FStar_Reflection_Data.typ ->
    Prims.string -> FStar_Syntax_Syntax.term -> unit tac)
  =
  fun _ty  ->
    fun k  ->
      fun t  ->
        let uu____13612 =
          bind get
            (fun ps  ->
               let ps1 =
                 let uu___426_13619 = ps  in
                 let uu____13620 =
                   FStar_Util.psmap_add ps.FStar_Tactics_Types.local_state k
                     t
                    in
                 {
                   FStar_Tactics_Types.main_context =
                     (uu___426_13619.FStar_Tactics_Types.main_context);
                   FStar_Tactics_Types.main_goal =
                     (uu___426_13619.FStar_Tactics_Types.main_goal);
                   FStar_Tactics_Types.all_implicits =
                     (uu___426_13619.FStar_Tactics_Types.all_implicits);
                   FStar_Tactics_Types.goals =
                     (uu___426_13619.FStar_Tactics_Types.goals);
                   FStar_Tactics_Types.smt_goals =
                     (uu___426_13619.FStar_Tactics_Types.smt_goals);
                   FStar_Tactics_Types.depth =
                     (uu___426_13619.FStar_Tactics_Types.depth);
                   FStar_Tactics_Types.__dump =
                     (uu___426_13619.FStar_Tactics_Types.__dump);
                   FStar_Tactics_Types.psc =
                     (uu___426_13619.FStar_Tactics_Types.psc);
                   FStar_Tactics_Types.entry_range =
                     (uu___426_13619.FStar_Tactics_Types.entry_range);
                   FStar_Tactics_Types.guard_policy =
                     (uu___426_13619.FStar_Tactics_Types.guard_policy);
                   FStar_Tactics_Types.freshness =
                     (uu___426_13619.FStar_Tactics_Types.freshness);
                   FStar_Tactics_Types.tac_verb_dbg =
                     (uu___426_13619.FStar_Tactics_Types.tac_verb_dbg);
                   FStar_Tactics_Types.local_state = uu____13620
                 }  in
               set ps1)
           in
        FStar_All.pipe_left (wrap_err "lset") uu____13612
  
let (goal_of_goal_ty :
  env ->
    FStar_Reflection_Data.typ ->
      (FStar_Tactics_Types.goal,FStar_TypeChecker_Env.guard_t)
        FStar_Pervasives_Native.tuple2)
  =
  fun env  ->
    fun typ  ->
      let uu____13645 =
        FStar_TypeChecker_Util.new_implicit_var "proofstate_of_goal_ty"
          typ.FStar_Syntax_Syntax.pos env typ
         in
      match uu____13645 with
      | (u,ctx_uvars,g_u) ->
          let uu____13677 = FStar_List.hd ctx_uvars  in
          (match uu____13677 with
           | (ctx_uvar,uu____13691) ->
               let g =
                 let uu____13693 = FStar_Options.peek ()  in
                 FStar_Tactics_Types.mk_goal env ctx_uvar uu____13693 false
                   ""
                  in
               (g, g_u))
  
let (proofstate_of_goal_ty :
  FStar_Range.range ->
    env ->
      FStar_Reflection_Data.typ ->
        (FStar_Tactics_Types.proofstate,FStar_Syntax_Syntax.term)
          FStar_Pervasives_Native.tuple2)
  =
  fun rng  ->
    fun env  ->
      fun typ  ->
        let uu____13713 = goal_of_goal_ty env typ  in
        match uu____13713 with
        | (g,g_u) ->
            let ps =
              let uu____13725 =
                FStar_TypeChecker_Env.debug env
                  (FStar_Options.Other "TacVerbose")
                 in
              let uu____13726 = FStar_Util.psmap_empty ()  in
              {
                FStar_Tactics_Types.main_context = env;
                FStar_Tactics_Types.main_goal = g;
                FStar_Tactics_Types.all_implicits =
                  (g_u.FStar_TypeChecker_Env.implicits);
                FStar_Tactics_Types.goals = [g];
                FStar_Tactics_Types.smt_goals = [];
                FStar_Tactics_Types.depth = (Prims.parse_int "0");
                FStar_Tactics_Types.__dump =
                  (fun ps  -> fun msg  -> dump_proofstate ps msg);
                FStar_Tactics_Types.psc = FStar_TypeChecker_Cfg.null_psc;
                FStar_Tactics_Types.entry_range = rng;
                FStar_Tactics_Types.guard_policy = FStar_Tactics_Types.SMT;
                FStar_Tactics_Types.freshness = (Prims.parse_int "0");
                FStar_Tactics_Types.tac_verb_dbg = uu____13725;
                FStar_Tactics_Types.local_state = uu____13726
              }  in
            let uu____13733 = FStar_Tactics_Types.goal_witness g  in
            (ps, uu____13733)
  