
open Prims

exception Un_extractable


let is_Un_extractable = (fun _discr_ -> (match (_discr_) with
| Un_extractable (_) -> begin
true
end
| _ -> begin
false
end))


let type_leq : FStar_Extraction_ML_UEnv.env  ->  FStar_Extraction_ML_Syntax.mlty  ->  FStar_Extraction_ML_Syntax.mlty  ->  Prims.bool = (fun g t1 t2 -> (FStar_Extraction_ML_Util.type_leq (FStar_Extraction_ML_Util.udelta_unfold g) t1 t2))


let type_leq_c : FStar_Extraction_ML_UEnv.env  ->  FStar_Extraction_ML_Syntax.mlexpr Prims.option  ->  FStar_Extraction_ML_Syntax.mlty  ->  FStar_Extraction_ML_Syntax.mlty  ->  (Prims.bool * FStar_Extraction_ML_Syntax.mlexpr Prims.option) = (fun g t1 t2 -> (FStar_Extraction_ML_Util.type_leq_c (FStar_Extraction_ML_Util.udelta_unfold g) t1 t2))


let erasableType : FStar_Extraction_ML_UEnv.env  ->  FStar_Extraction_ML_Syntax.mlty  ->  Prims.bool = (fun g t -> (FStar_Extraction_ML_Util.erasableType (FStar_Extraction_ML_Util.udelta_unfold g) t))


let eraseTypeDeep : FStar_Extraction_ML_UEnv.env  ->  FStar_Extraction_ML_Syntax.mlty  ->  FStar_Extraction_ML_Syntax.mlty = (fun g t -> (FStar_Extraction_ML_Util.eraseTypeDeep (FStar_Extraction_ML_Util.udelta_unfold g) t))


let fail = (fun r msg -> (

let _77_17 = (let _166_29 = (let _166_28 = (FStar_Range.string_of_range r)
in (FStar_Util.format2 "%s: %s\n" _166_28 msg))
in (FStar_All.pipe_left FStar_Util.print_string _166_29))
in (FStar_All.failwith msg)))


let err_uninst = (fun env t _77_23 -> (match (_77_23) with
| (vars, ty) -> begin
(let _166_37 = (let _166_36 = (FStar_Syntax_Print.term_to_string t)
in (let _166_35 = (let _166_33 = (FStar_All.pipe_right vars (FStar_List.map Prims.fst))
in (FStar_All.pipe_right _166_33 (FStar_String.concat ", ")))
in (let _166_34 = (FStar_Extraction_ML_Code.string_of_mlty env.FStar_Extraction_ML_UEnv.currentModule ty)
in (FStar_Util.format3 "Variable %s has a polymorphic type (forall %s. %s); expected it to be fully instantiated" _166_36 _166_35 _166_34))))
in (fail t.FStar_Syntax_Syntax.pos _166_37))
end))


let err_ill_typed_application = (fun t args ty -> (let _166_45 = (let _166_44 = (FStar_Syntax_Print.term_to_string t)
in (let _166_43 = (let _166_42 = (FStar_All.pipe_right args (FStar_List.map (fun _77_30 -> (match (_77_30) with
| (x, _77_29) -> begin
(FStar_Syntax_Print.term_to_string x)
end))))
in (FStar_All.pipe_right _166_42 (FStar_String.concat " ")))
in (FStar_Util.format2 "Ill-typed application: application is %s \n remaining args are %s\n" _166_44 _166_43)))
in (fail t.FStar_Syntax_Syntax.pos _166_45)))


let err_value_restriction = (fun t -> (fail t.FStar_Syntax_Syntax.pos "Refusing to generalize because of the value restriction"))


let err_unexpected_eff = (fun t f0 f1 -> (let _166_51 = (let _166_50 = (FStar_Syntax_Print.term_to_string t)
in (FStar_Util.format3 "for expression %s, Expected effect %s; got effect %s" _166_50 (FStar_Extraction_ML_Util.eff_to_string f0) (FStar_Extraction_ML_Util.eff_to_string f1)))
in (fail t.FStar_Syntax_Syntax.pos _166_51)))


let effect_as_etag : FStar_Extraction_ML_UEnv.env  ->  FStar_Ident.lident  ->  FStar_Extraction_ML_Syntax.e_tag = (

let cache = (FStar_Util.smap_create 20)
in (

let rec delta_norm_eff = (fun g l -> (match ((FStar_Util.smap_try_find cache l.FStar_Ident.str)) with
| Some (l) -> begin
l
end
| None -> begin
(

let res = (match ((FStar_TypeChecker_Env.lookup_effect_abbrev g.FStar_Extraction_ML_UEnv.tcenv FStar_Syntax_Syntax.U_zero l)) with
| None -> begin
l
end
| Some (_77_44, c) -> begin
(delta_norm_eff g (FStar_Syntax_Util.comp_effect_name c))
end)
in (

let _77_49 = (FStar_Util.smap_add cache l.FStar_Ident.str res)
in res))
end))
in (fun g l -> (

let l = (delta_norm_eff g l)
in if (FStar_Ident.lid_equals l FStar_Syntax_Const.effect_PURE_lid) then begin
FStar_Extraction_ML_Syntax.E_PURE
end else begin
if (FStar_Ident.lid_equals l FStar_Syntax_Const.effect_GHOST_lid) then begin
FStar_Extraction_ML_Syntax.E_GHOST
end else begin
FStar_Extraction_ML_Syntax.E_IMPURE
end
end))))


type level_t =
| Term_level
| Type_level
| Kind_level


let is_Term_level = (fun _discr_ -> (match (_discr_) with
| Term_level (_) -> begin
true
end
| _ -> begin
false
end))


let is_Type_level = (fun _discr_ -> (match (_discr_) with
| Type_level (_) -> begin
true
end
| _ -> begin
false
end))


let is_Kind_level = (fun _discr_ -> (match (_discr_) with
| Kind_level (_) -> begin
true
end
| _ -> begin
false
end))


let predecessor = (fun t _77_1 -> (match (_77_1) with
| Term_level -> begin
Term_level
end
| Type_level -> begin
Term_level
end
| Kind_level -> begin
Type_level
end))


let rec level : FStar_Extraction_ML_UEnv.env  ->  FStar_Syntax_Syntax.term  ->  level_t = (fun env t -> (

let predecessor = (fun l -> (predecessor t l))
in (

let t = (FStar_Syntax_Subst.compress t)
in (match (t.FStar_Syntax_Syntax.n) with
| FStar_Syntax_Syntax.Tm_delayed (_77_65) -> begin
(let _166_75 = (let _166_74 = (FStar_Syntax_Print.tag_of_term t)
in (FStar_Util.format1 "Impossible: %s" _166_74))
in (FStar_All.failwith _166_75))
end
| FStar_Syntax_Syntax.Tm_unknown -> begin
Kind_level
end
| FStar_Syntax_Syntax.Tm_constant (_77_69) -> begin
Term_level
end
| FStar_Syntax_Syntax.Tm_fvar ({FStar_Syntax_Syntax.fv_name = _77_77; FStar_Syntax_Syntax.fv_delta = FStar_Syntax_Syntax.Delta_unfoldable (_77_74); FStar_Syntax_Syntax.fv_qual = _77_72}) -> begin
(

let t' = (FStar_TypeChecker_Normalize.normalize ((FStar_TypeChecker_Normalize.Beta)::(FStar_TypeChecker_Normalize.UnfoldUntil (FStar_Syntax_Syntax.Delta_constant))::(FStar_TypeChecker_Normalize.EraseUniverses)::(FStar_TypeChecker_Normalize.AllowUnboundUniverses)::[]) env.FStar_Extraction_ML_UEnv.tcenv t)
in (

let _77_82 = (FStar_Extraction_ML_UEnv.debug env (fun _77_81 -> (match (()) with
| () -> begin
(let _166_78 = (FStar_Syntax_Print.term_to_string t)
in (let _166_77 = (FStar_Syntax_Print.term_to_string t')
in (FStar_Util.print2 "Normalized %s to %s\n" _166_78 _166_77)))
end)))
in (level env t')))
end
| FStar_Syntax_Syntax.Tm_fvar (fv) -> begin
if (FStar_TypeChecker_Env.is_type_constructor env.FStar_Extraction_ML_UEnv.tcenv fv.FStar_Syntax_Syntax.fv_name.FStar_Syntax_Syntax.v) then begin
Type_level
end else begin
(let _166_79 = (level env fv.FStar_Syntax_Syntax.fv_name.FStar_Syntax_Syntax.ty)
in (FStar_All.pipe_left predecessor _166_79))
end
end
| (FStar_Syntax_Syntax.Tm_uvar (_, t)) | (FStar_Syntax_Syntax.Tm_bvar ({FStar_Syntax_Syntax.ppname = _; FStar_Syntax_Syntax.index = _; FStar_Syntax_Syntax.sort = t})) | (FStar_Syntax_Syntax.Tm_name ({FStar_Syntax_Syntax.ppname = _; FStar_Syntax_Syntax.index = _; FStar_Syntax_Syntax.sort = t})) -> begin
(let _166_80 = (level env t)
in (FStar_All.pipe_left predecessor _166_80))
end
| FStar_Syntax_Syntax.Tm_ascribed (t, _77_105, _77_107) -> begin
(level env t)
end
| FStar_Syntax_Syntax.Tm_type (_77_111) -> begin
Kind_level
end
| FStar_Syntax_Syntax.Tm_uinst (t, _77_115) -> begin
(level env t)
end
| FStar_Syntax_Syntax.Tm_refine (x, _77_120) -> begin
(match ((level env x.FStar_Syntax_Syntax.sort)) with
| Term_level -> begin
Type_level
end
| l -> begin
l
end)
end
| FStar_Syntax_Syntax.Tm_arrow (bs, c) -> begin
(match ((level env (FStar_Syntax_Util.comp_result c))) with
| Term_level -> begin
Type_level
end
| l -> begin
l
end)
end
| FStar_Syntax_Syntax.Tm_abs (bs, body, _77_134) -> begin
(level env body)
end
| FStar_Syntax_Syntax.Tm_let (_77_138, body) -> begin
(level env body)
end
| FStar_Syntax_Syntax.Tm_match (_77_143, branches) -> begin
(match (branches) with
| (_77_150, _77_152, e)::_77_148 -> begin
(level env e)
end
| _77_157 -> begin
(FStar_All.failwith "Empty branches")
end)
end
| FStar_Syntax_Syntax.Tm_meta (t, _77_160) -> begin
(level env t)
end
| FStar_Syntax_Syntax.Tm_app (head, _77_165) -> begin
(level env head)
end))))


let is_type : FStar_Extraction_ML_UEnv.env  ->  FStar_Syntax_Syntax.term  ->  Prims.bool = (fun env t -> (match ((level env t)) with
| Term_level -> begin
false
end
| _77_172 -> begin
true
end))


let is_type_binder = (fun env x -> (match ((level env (Prims.fst x).FStar_Syntax_Syntax.sort)) with
| Term_level -> begin
(FStar_All.failwith "Impossible: Binder is a term")
end
| Type_level -> begin
false
end
| Kind_level -> begin
true
end))


let is_constructor : FStar_Syntax_Syntax.term  ->  Prims.bool = (fun t -> (match ((let _166_89 = (FStar_Syntax_Subst.compress t)
in _166_89.FStar_Syntax_Syntax.n)) with
| (FStar_Syntax_Syntax.Tm_fvar ({FStar_Syntax_Syntax.fv_name = _; FStar_Syntax_Syntax.fv_delta = _; FStar_Syntax_Syntax.fv_qual = Some (FStar_Syntax_Syntax.Data_ctor)})) | (FStar_Syntax_Syntax.Tm_fvar ({FStar_Syntax_Syntax.fv_name = _; FStar_Syntax_Syntax.fv_delta = _; FStar_Syntax_Syntax.fv_qual = Some (FStar_Syntax_Syntax.Record_ctor (_))})) -> begin
true
end
| _77_198 -> begin
false
end))


let rec is_fstar_value : FStar_Syntax_Syntax.term  ->  Prims.bool = (fun t -> (match ((let _166_92 = (FStar_Syntax_Subst.compress t)
in _166_92.FStar_Syntax_Syntax.n)) with
| (FStar_Syntax_Syntax.Tm_constant (_)) | (FStar_Syntax_Syntax.Tm_bvar (_)) | (FStar_Syntax_Syntax.Tm_fvar (_)) | (FStar_Syntax_Syntax.Tm_abs (_)) -> begin
true
end
| FStar_Syntax_Syntax.Tm_app (head, args) -> begin
if (is_constructor head) then begin
(FStar_All.pipe_right args (FStar_List.for_all (fun _77_219 -> (match (_77_219) with
| (te, _77_218) -> begin
(is_fstar_value te)
end))))
end else begin
false
end
end
| (FStar_Syntax_Syntax.Tm_meta (t, _)) | (FStar_Syntax_Syntax.Tm_ascribed (t, _, _)) -> begin
(is_fstar_value t)
end
| _77_232 -> begin
false
end))


let rec is_ml_value : FStar_Extraction_ML_Syntax.mlexpr  ->  Prims.bool = (fun e -> (match (e.FStar_Extraction_ML_Syntax.expr) with
| (FStar_Extraction_ML_Syntax.MLE_Const (_)) | (FStar_Extraction_ML_Syntax.MLE_Var (_)) | (FStar_Extraction_ML_Syntax.MLE_Name (_)) | (FStar_Extraction_ML_Syntax.MLE_Fun (_)) -> begin
true
end
| (FStar_Extraction_ML_Syntax.MLE_CTor (_, exps)) | (FStar_Extraction_ML_Syntax.MLE_Tuple (exps)) -> begin
(FStar_Util.for_all is_ml_value exps)
end
| FStar_Extraction_ML_Syntax.MLE_Record (_77_253, fields) -> begin
(FStar_Util.for_all (fun _77_260 -> (match (_77_260) with
| (_77_258, e) -> begin
(is_ml_value e)
end)) fields)
end
| _77_262 -> begin
false
end))


let normalize_abs : FStar_Syntax_Syntax.term  ->  FStar_Syntax_Syntax.term = (fun t0 -> (

let rec aux = (fun bs t copt -> (

let t = (FStar_Syntax_Subst.compress t)
in (match (t.FStar_Syntax_Syntax.n) with
| FStar_Syntax_Syntax.Tm_abs (bs', body, copt) -> begin
(aux (FStar_List.append bs bs') body copt)
end
| _77_275 -> begin
(

let e' = (FStar_Syntax_Util.unascribe t)
in if (FStar_Syntax_Util.is_fun e') then begin
(aux bs e' copt)
end else begin
(FStar_Syntax_Util.abs bs e' copt)
end)
end)))
in (aux [] t0 None)))


let unit_binder : FStar_Syntax_Syntax.binder = (let _166_105 = (FStar_Syntax_Syntax.new_bv None FStar_TypeChecker_Common.t_unit)
in (FStar_All.pipe_left FStar_Syntax_Syntax.mk_binder _166_105))


let check_pats_for_ite : (FStar_Syntax_Syntax.pat * FStar_Syntax_Syntax.term Prims.option * FStar_Syntax_Syntax.term) Prims.list  ->  (Prims.bool * FStar_Syntax_Syntax.term Prims.option * FStar_Syntax_Syntax.term Prims.option) = (fun l -> (

let def = (false, None, None)
in if ((FStar_List.length l) <> 2) then begin
def
end else begin
(

let _77_282 = (FStar_List.hd l)
in (match (_77_282) with
| (p1, w1, e1) -> begin
(

let _77_286 = (let _166_108 = (FStar_List.tl l)
in (FStar_List.hd _166_108))
in (match (_77_286) with
| (p2, w2, e2) -> begin
(match ((w1, w2, p1.FStar_Syntax_Syntax.v, p2.FStar_Syntax_Syntax.v)) with
| (None, None, FStar_Syntax_Syntax.Pat_constant (FStar_Const.Const_bool (true)), FStar_Syntax_Syntax.Pat_constant (FStar_Const.Const_bool (false))) -> begin
(true, Some (e1), Some (e2))
end
| (None, None, FStar_Syntax_Syntax.Pat_constant (FStar_Const.Const_bool (false)), FStar_Syntax_Syntax.Pat_constant (FStar_Const.Const_bool (true))) -> begin
(true, Some (e2), Some (e1))
end
| _77_306 -> begin
def
end)
end))
end))
end))


let instantiate : FStar_Extraction_ML_Syntax.mltyscheme  ->  FStar_Extraction_ML_Syntax.mlty Prims.list  ->  FStar_Extraction_ML_Syntax.mlty = (fun s args -> (FStar_Extraction_ML_Util.subst s args))


let erasable : FStar_Extraction_ML_UEnv.env  ->  FStar_Extraction_ML_Syntax.e_tag  ->  FStar_Extraction_ML_Syntax.mlty  ->  Prims.bool = (fun g f t -> ((f = FStar_Extraction_ML_Syntax.E_GHOST) || ((f = FStar_Extraction_ML_Syntax.E_PURE) && (erasableType g t))))


let erase : FStar_Extraction_ML_UEnv.env  ->  FStar_Extraction_ML_Syntax.mlexpr  ->  FStar_Extraction_ML_Syntax.mlty  ->  FStar_Extraction_ML_Syntax.e_tag  ->  (FStar_Extraction_ML_Syntax.mlexpr * FStar_Extraction_ML_Syntax.e_tag * FStar_Extraction_ML_Syntax.mlty) = (fun g e ty f -> (

let e = if (erasable g f ty) then begin
if (type_leq g ty FStar_Extraction_ML_Syntax.ml_unit_ty) then begin
FStar_Extraction_ML_Syntax.ml_unit
end else begin
(FStar_All.pipe_left (FStar_Extraction_ML_Syntax.with_ty ty) (FStar_Extraction_ML_Syntax.MLE_Coerce ((FStar_Extraction_ML_Syntax.ml_unit, FStar_Extraction_ML_Syntax.ml_unit_ty, ty))))
end
end else begin
e
end
in (e, f, ty)))


let maybe_coerce : FStar_Extraction_ML_UEnv.env  ->  FStar_Extraction_ML_Syntax.mlexpr  ->  FStar_Extraction_ML_Syntax.mlty  ->  FStar_Extraction_ML_Syntax.mlty  ->  FStar_Extraction_ML_Syntax.mlexpr = (fun g e ty expect -> (

let ty = (eraseTypeDeep g ty)
in (match ((type_leq_c g (Some (e)) ty expect)) with
| (true, Some (e')) -> begin
e'
end
| _77_327 -> begin
(

let _77_329 = (FStar_Extraction_ML_UEnv.debug g (fun _77_328 -> (match (()) with
| () -> begin
(let _166_138 = (FStar_Extraction_ML_Code.string_of_mlexpr g.FStar_Extraction_ML_UEnv.currentModule e)
in (let _166_137 = (FStar_Extraction_ML_Code.string_of_mlty g.FStar_Extraction_ML_UEnv.currentModule ty)
in (let _166_136 = (FStar_Extraction_ML_Code.string_of_mlty g.FStar_Extraction_ML_UEnv.currentModule expect)
in (FStar_Util.print3 "\n (*needed to coerce expression \n %s \n of type \n %s \n to type \n %s *) \n" _166_138 _166_137 _166_136))))
end)))
in (FStar_All.pipe_left (FStar_Extraction_ML_Syntax.with_ty expect) (FStar_Extraction_ML_Syntax.MLE_Coerce ((e, ty, expect)))))
end)))


let bv_as_mlty : FStar_Extraction_ML_UEnv.env  ->  FStar_Syntax_Syntax.bv  ->  FStar_Extraction_ML_Syntax.mlty = (fun g bv -> (match ((FStar_Extraction_ML_UEnv.lookup_bv g bv)) with
| FStar_Util.Inl (_77_334, t) -> begin
t
end
| _77_339 -> begin
FStar_Extraction_ML_Syntax.MLTY_Top
end))


let rec term_as_mlty : FStar_Extraction_ML_UEnv.env  ->  FStar_Syntax_Syntax.term  ->  FStar_Extraction_ML_Syntax.mlty = (fun g t -> (

let t = (FStar_TypeChecker_Normalize.normalize ((FStar_TypeChecker_Normalize.Beta)::(FStar_TypeChecker_Normalize.EraseUniverses)::(FStar_TypeChecker_Normalize.AllowUnboundUniverses)::[]) g.FStar_Extraction_ML_UEnv.tcenv t)
in (term_as_mlty' g t)))
and term_as_mlty' : FStar_Extraction_ML_UEnv.env  ->  FStar_Syntax_Syntax.term  ->  FStar_Extraction_ML_Syntax.mlty = (fun env t -> (

let t = (FStar_Syntax_Subst.compress t)
in (match (t.FStar_Syntax_Syntax.n) with
| (FStar_Syntax_Syntax.Tm_constant (_)) | (FStar_Syntax_Syntax.Tm_bvar (_)) | (FStar_Syntax_Syntax.Tm_delayed (_)) | (FStar_Syntax_Syntax.Tm_unknown) -> begin
(let _166_159 = (let _166_158 = (FStar_Syntax_Print.term_to_string t)
in (FStar_Util.format1 "Impossible: Unexpected term %s" _166_158))
in (FStar_All.failwith _166_159))
end
| FStar_Syntax_Syntax.Tm_uvar (_77_357) -> begin
FStar_Extraction_ML_UEnv.unknownType
end
| (FStar_Syntax_Syntax.Tm_meta (t, _)) | (FStar_Syntax_Syntax.Tm_refine ({FStar_Syntax_Syntax.ppname = _; FStar_Syntax_Syntax.index = _; FStar_Syntax_Syntax.sort = t}, _)) | (FStar_Syntax_Syntax.Tm_uinst (t, _)) | (FStar_Syntax_Syntax.Tm_ascribed (t, _, _)) -> begin
(term_as_mlty' env t)
end
| FStar_Syntax_Syntax.Tm_name (bv) -> begin
(bv_as_mlty env bv)
end
| FStar_Syntax_Syntax.Tm_fvar (fv) -> begin
(fv_app_as_mlty env fv [])
end
| FStar_Syntax_Syntax.Tm_arrow (bs, c) -> begin
(

let _77_393 = (FStar_Syntax_Subst.open_comp bs c)
in (match (_77_393) with
| (bs, c) -> begin
(

let _77_396 = (binders_as_ml_binders env bs)
in (match (_77_396) with
| (mlbs, env) -> begin
(

let t_ret = (term_as_mlty' env (FStar_Syntax_Util.comp_result c))
in (

let erase = (effect_as_etag env (FStar_Syntax_Util.comp_effect_name c))
in (

let _77_409 = (FStar_List.fold_right (fun _77_402 _77_405 -> (match ((_77_402, _77_405)) with
| ((_77_400, t), (tag, t')) -> begin
(FStar_Extraction_ML_Syntax.E_PURE, FStar_Extraction_ML_Syntax.MLTY_Fun ((t, tag, t')))
end)) mlbs (erase, t_ret))
in (match (_77_409) with
| (_77_407, t) -> begin
t
end))))
end))
end))
end
| FStar_Syntax_Syntax.Tm_app (head, args) -> begin
(

let res = (match ((let _166_162 = (FStar_Syntax_Subst.compress head)
in _166_162.FStar_Syntax_Syntax.n)) with
| FStar_Syntax_Syntax.Tm_name (bv) -> begin
(bv_as_mlty env bv)
end
| FStar_Syntax_Syntax.Tm_fvar (fv) -> begin
(fv_app_as_mlty env fv args)
end
| FStar_Syntax_Syntax.Tm_app (head, args') -> begin
(let _166_163 = (FStar_Syntax_Syntax.mk (FStar_Syntax_Syntax.Tm_app ((head, (FStar_List.append args' args)))) None t.FStar_Syntax_Syntax.pos)
in (term_as_mlty' env _166_163))
end
| _77_423 -> begin
FStar_Extraction_ML_UEnv.unknownType
end)
in res)
end
| FStar_Syntax_Syntax.Tm_abs (bs, ty, _77_428) -> begin
(

let _77_433 = (FStar_Syntax_Subst.open_term bs ty)
in (match (_77_433) with
| (bs, ty) -> begin
(

let _77_436 = (binders_as_ml_binders env bs)
in (match (_77_436) with
| (bts, env) -> begin
(term_as_mlty' env ty)
end))
end))
end
| (FStar_Syntax_Syntax.Tm_type (_)) | (FStar_Syntax_Syntax.Tm_let (_)) | (FStar_Syntax_Syntax.Tm_match (_)) -> begin
FStar_Extraction_ML_UEnv.unknownType
end)))
and arg_as_mlty : FStar_Extraction_ML_UEnv.env  ->  (FStar_Syntax_Syntax.term * FStar_Syntax_Syntax.arg_qualifier Prims.option)  ->  FStar_Extraction_ML_Syntax.mlty = (fun g _77_450 -> (match (_77_450) with
| (a, _77_449) -> begin
if (is_type g a) then begin
(term_as_mlty' g a)
end else begin
FStar_Extraction_ML_UEnv.erasedContent
end
end))
and fv_app_as_mlty : FStar_Extraction_ML_UEnv.env  ->  FStar_Syntax_Syntax.fv  ->  FStar_Syntax_Syntax.args  ->  FStar_Extraction_ML_Syntax.mlty = (fun g fv args -> (

let _77_456 = (FStar_Syntax_Util.arrow_formals fv.FStar_Syntax_Syntax.fv_name.FStar_Syntax_Syntax.ty)
in (match (_77_456) with
| (formals, t) -> begin
(

let mlargs = (FStar_List.map (arg_as_mlty g) args)
in (

let mlargs = (

let n_args = (FStar_List.length args)
in if ((FStar_List.length formals) > n_args) then begin
(

let _77_462 = (FStar_Util.first_N n_args formals)
in (match (_77_462) with
| (_77_460, rest) -> begin
(let _166_170 = (FStar_List.map (fun _77_463 -> FStar_Extraction_ML_UEnv.erasedContent) rest)
in (FStar_List.append mlargs _166_170))
end))
end else begin
mlargs
end)
in (let _166_172 = (let _166_171 = (FStar_Extraction_ML_Syntax.mlpath_of_lident fv.FStar_Syntax_Syntax.fv_name.FStar_Syntax_Syntax.v)
in (mlargs, _166_171))
in FStar_Extraction_ML_Syntax.MLTY_Named (_166_172))))
end)))
and binders_as_ml_binders : FStar_Extraction_ML_UEnv.env  ->  FStar_Syntax_Syntax.binders  ->  ((FStar_Extraction_ML_Syntax.mlident * FStar_Extraction_ML_Syntax.mlty) Prims.list * FStar_Extraction_ML_UEnv.env) = (fun g bs -> (

let _77_481 = (FStar_All.pipe_right bs (FStar_List.fold_left (fun _77_470 b -> (match (_77_470) with
| (ml_bs, env) -> begin
if (is_type_binder g b) then begin
(

let b = (Prims.fst b)
in (

let env = (FStar_Extraction_ML_UEnv.extend_ty env b (Some (FStar_Extraction_ML_Syntax.MLTY_Top)))
in (

let ml_b = (let _166_177 = (FStar_Extraction_ML_UEnv.bv_as_ml_termvar b)
in (_166_177, FStar_Extraction_ML_Syntax.ml_unit_ty))
in ((ml_b)::ml_bs, env))))
end else begin
(

let b = (Prims.fst b)
in (

let t = (term_as_mlty env b.FStar_Syntax_Syntax.sort)
in (

let env = (FStar_Extraction_ML_UEnv.extend_bv env b ([], t) false false false)
in (

let ml_b = (let _166_178 = (FStar_Extraction_ML_UEnv.bv_as_ml_termvar b)
in (_166_178, t))
in ((ml_b)::ml_bs, env)))))
end
end)) ([], g)))
in (match (_77_481) with
| (ml_bs, env) -> begin
((FStar_List.rev ml_bs), env)
end)))


let mk_MLE_Seq : FStar_Extraction_ML_Syntax.mlexpr  ->  FStar_Extraction_ML_Syntax.mlexpr  ->  FStar_Extraction_ML_Syntax.mlexpr' = (fun e1 e2 -> (match ((e1.FStar_Extraction_ML_Syntax.expr, e2.FStar_Extraction_ML_Syntax.expr)) with
| (FStar_Extraction_ML_Syntax.MLE_Seq (es1), FStar_Extraction_ML_Syntax.MLE_Seq (es2)) -> begin
FStar_Extraction_ML_Syntax.MLE_Seq ((FStar_List.append es1 es2))
end
| (FStar_Extraction_ML_Syntax.MLE_Seq (es1), _77_492) -> begin
FStar_Extraction_ML_Syntax.MLE_Seq ((FStar_List.append es1 ((e2)::[])))
end
| (_77_495, FStar_Extraction_ML_Syntax.MLE_Seq (es2)) -> begin
FStar_Extraction_ML_Syntax.MLE_Seq ((e1)::es2)
end
| _77_500 -> begin
FStar_Extraction_ML_Syntax.MLE_Seq ((e1)::(e2)::[])
end))


let mk_MLE_Let : Prims.bool  ->  FStar_Extraction_ML_Syntax.mlletbinding  ->  FStar_Extraction_ML_Syntax.mlexpr  ->  FStar_Extraction_ML_Syntax.mlexpr' = (fun top_level lbs body -> (match (lbs) with
| (false, lb::[]) when (not (top_level)) -> begin
(match (lb.FStar_Extraction_ML_Syntax.mllb_tysc) with
| Some ([], t) when (t = FStar_Extraction_ML_Syntax.ml_unit_ty) -> begin
if (body.FStar_Extraction_ML_Syntax.expr = FStar_Extraction_ML_Syntax.ml_unit.FStar_Extraction_ML_Syntax.expr) then begin
lb.FStar_Extraction_ML_Syntax.mllb_def.FStar_Extraction_ML_Syntax.expr
end else begin
(match (body.FStar_Extraction_ML_Syntax.expr) with
| FStar_Extraction_ML_Syntax.MLE_Var (x) when (x = lb.FStar_Extraction_ML_Syntax.mllb_name) -> begin
lb.FStar_Extraction_ML_Syntax.mllb_def.FStar_Extraction_ML_Syntax.expr
end
| _77_515 when (lb.FStar_Extraction_ML_Syntax.mllb_def.FStar_Extraction_ML_Syntax.expr = FStar_Extraction_ML_Syntax.ml_unit.FStar_Extraction_ML_Syntax.expr) -> begin
body.FStar_Extraction_ML_Syntax.expr
end
| _77_517 -> begin
(mk_MLE_Seq lb.FStar_Extraction_ML_Syntax.mllb_def body)
end)
end
end
| _77_519 -> begin
FStar_Extraction_ML_Syntax.MLE_Let ((lbs, body))
end)
end
| _77_521 -> begin
FStar_Extraction_ML_Syntax.MLE_Let ((lbs, body))
end))


let resugar_pat : FStar_Syntax_Syntax.fv_qual Prims.option  ->  FStar_Extraction_ML_Syntax.mlpattern  ->  FStar_Extraction_ML_Syntax.mlpattern = (fun q p -> (match (p) with
| FStar_Extraction_ML_Syntax.MLP_CTor (d, pats) -> begin
(match ((FStar_Extraction_ML_Util.is_xtuple d)) with
| Some (n) -> begin
FStar_Extraction_ML_Syntax.MLP_Tuple (pats)
end
| _77_531 -> begin
(match (q) with
| Some (FStar_Syntax_Syntax.Record_ctor (_77_533, fns)) -> begin
(

let p = (FStar_Extraction_ML_Util.record_field_path fns)
in (

let fs = (FStar_Extraction_ML_Util.record_fields fns pats)
in FStar_Extraction_ML_Syntax.MLP_Record ((p, fs))))
end
| _77_541 -> begin
p
end)
end)
end
| _77_543 -> begin
p
end))


let extract_pat : FStar_Extraction_ML_UEnv.env  ->  (FStar_Syntax_Syntax.pat', FStar_Syntax_Syntax.term') FStar_Syntax_Syntax.withinfo_t  ->  FStar_Extraction_ML_Syntax.mlty  ->  (FStar_Extraction_ML_UEnv.env * (FStar_Extraction_ML_Syntax.mlpattern * FStar_Extraction_ML_Syntax.mlexpr Prims.option) Prims.list * Prims.bool) = (fun g p expected_t -> (

let rec extract_one_pat = (fun disjunctive_pat imp g p expected_topt -> (

let ok = (fun t -> (match (expected_topt) with
| None -> begin
true
end
| Some (t') -> begin
(type_leq g t t')
end))
in (match (p.FStar_Syntax_Syntax.v) with
| FStar_Syntax_Syntax.Pat_disj (_77_559) -> begin
(FStar_All.failwith "Impossible: Nested disjunctive pattern")
end
| FStar_Syntax_Syntax.Pat_constant (FStar_Const.Const_int (c, None)) when (not ((FStar_Options.use_native_int ()))) -> begin
(

let i = FStar_Const.Const_int ((c, None))
in (

let x = (FStar_Extraction_ML_Syntax.gensym ())
in (

let when_clause = (let _166_219 = (let _166_218 = (let _166_217 = (let _166_216 = (FStar_All.pipe_left (FStar_Extraction_ML_Syntax.with_ty FStar_Extraction_ML_Syntax.ml_int_ty) (FStar_Extraction_ML_Syntax.MLE_Var (x)))
in (let _166_215 = (let _166_214 = (let _166_213 = (let _166_212 = (FStar_Extraction_ML_Util.mlconst_of_const' p.FStar_Syntax_Syntax.p i)
in (FStar_All.pipe_left (fun _166_211 -> FStar_Extraction_ML_Syntax.MLE_Const (_166_211)) _166_212))
in (FStar_All.pipe_left (FStar_Extraction_ML_Syntax.with_ty FStar_Extraction_ML_Syntax.ml_int_ty) _166_213))
in (_166_214)::[])
in (_166_216)::_166_215))
in (FStar_Extraction_ML_Util.prims_op_equality, _166_217))
in FStar_Extraction_ML_Syntax.MLE_App (_166_218))
in (FStar_All.pipe_left (FStar_Extraction_ML_Syntax.with_ty FStar_Extraction_ML_Syntax.ml_bool_ty) _166_219))
in (let _166_220 = (ok FStar_Extraction_ML_Syntax.ml_int_ty)
in (g, Some ((FStar_Extraction_ML_Syntax.MLP_Var (x), (when_clause)::[])), _166_220)))))
end
| FStar_Syntax_Syntax.Pat_constant (s) -> begin
(

let t = (FStar_TypeChecker_Tc.tc_constant FStar_Range.dummyRange s)
in (

let mlty = (term_as_mlty g t)
in (let _166_225 = (let _166_223 = (let _166_222 = (let _166_221 = (FStar_Extraction_ML_Util.mlconst_of_const' p.FStar_Syntax_Syntax.p s)
in FStar_Extraction_ML_Syntax.MLP_Const (_166_221))
in (_166_222, []))
in Some (_166_223))
in (let _166_224 = (ok mlty)
in (g, _166_225, _166_224)))))
end
| FStar_Syntax_Syntax.Pat_var (x) -> begin
(

let mlty = (term_as_mlty g x.FStar_Syntax_Syntax.sort)
in (

let g = (FStar_Extraction_ML_UEnv.extend_bv g x ([], mlty) false false imp)
in (let _166_230 = if imp then begin
None
end else begin
(let _166_228 = (let _166_227 = (let _166_226 = (FStar_Extraction_ML_Syntax.bv_as_mlident x)
in FStar_Extraction_ML_Syntax.MLP_Var (_166_226))
in (_166_227, []))
in Some (_166_228))
end
in (let _166_229 = (ok mlty)
in (g, _166_230, _166_229)))))
end
| FStar_Syntax_Syntax.Pat_wild (x) when disjunctive_pat -> begin
(g, Some ((FStar_Extraction_ML_Syntax.MLP_Wild, [])), true)
end
| FStar_Syntax_Syntax.Pat_wild (x) -> begin
(

let mlty = (term_as_mlty g x.FStar_Syntax_Syntax.sort)
in (

let g = (FStar_Extraction_ML_UEnv.extend_bv g x ([], mlty) false false imp)
in (let _166_235 = if imp then begin
None
end else begin
(let _166_233 = (let _166_232 = (let _166_231 = (FStar_Extraction_ML_Syntax.bv_as_mlident x)
in FStar_Extraction_ML_Syntax.MLP_Var (_166_231))
in (_166_232, []))
in Some (_166_233))
end
in (let _166_234 = (ok mlty)
in (g, _166_235, _166_234)))))
end
| FStar_Syntax_Syntax.Pat_dot_term (_77_584) -> begin
(g, None, true)
end
| FStar_Syntax_Syntax.Pat_cons (f, pats) -> begin
(

let _77_606 = (match ((FStar_Extraction_ML_UEnv.lookup_fv g f)) with
| FStar_Util.Inr ({FStar_Extraction_ML_Syntax.expr = FStar_Extraction_ML_Syntax.MLE_Name (n); FStar_Extraction_ML_Syntax.mlty = _77_593; FStar_Extraction_ML_Syntax.loc = _77_591}, ttys, _77_599) -> begin
(n, ttys)
end
| _77_603 -> begin
(FStar_All.failwith "Expected a constructor")
end)
in (match (_77_606) with
| (d, tys) -> begin
(

let nTyVars = (FStar_List.length (Prims.fst tys))
in (

let _77_610 = (FStar_Util.first_N nTyVars pats)
in (match (_77_610) with
| (tysVarPats, restPats) -> begin
(

let pat_ty_compat = (match (expected_topt) with
| None -> begin
true
end
| Some (expected_t) -> begin
try
(match (()) with
| () -> begin
(

let mlty_args = (FStar_All.pipe_right tysVarPats (FStar_List.map (fun _77_623 -> (match (_77_623) with
| (p, _77_622) -> begin
(match (p.FStar_Syntax_Syntax.v) with
| FStar_Syntax_Syntax.Pat_dot_term (_77_625, t) -> begin
(term_as_mlty g t)
end
| _77_630 -> begin
(Prims.raise Un_extractable)
end)
end))))
in (

let pat_ty = (FStar_Extraction_ML_Util.subst tys mlty_args)
in (type_leq g pat_ty expected_t)))
end)
with
| Un_extractable -> begin
false
end
end)
in (

let _77_645 = (FStar_Util.fold_map (fun g _77_637 -> (match (_77_637) with
| (p, imp) -> begin
(

let _77_642 = (extract_one_pat disjunctive_pat true g p None)
in (match (_77_642) with
| (g, p, _77_641) -> begin
(g, p)
end))
end)) g tysVarPats)
in (match (_77_645) with
| (g, tyMLPats) -> begin
(

let _77_657 = (FStar_Util.fold_map (fun g _77_649 -> (match (_77_649) with
| (p, imp) -> begin
(

let _77_654 = (extract_one_pat disjunctive_pat false g p None)
in (match (_77_654) with
| (g, p, _77_653) -> begin
(g, p)
end))
end)) g restPats)
in (match (_77_657) with
| (g, restMLPats) -> begin
(

let _77_665 = (let _166_244 = (FStar_All.pipe_right (FStar_List.append tyMLPats restMLPats) (FStar_List.collect (fun _77_2 -> (match (_77_2) with
| Some (x) -> begin
(x)::[]
end
| _77_662 -> begin
[]
end))))
in (FStar_All.pipe_right _166_244 FStar_List.split))
in (match (_77_665) with
| (mlPats, when_clauses) -> begin
(let _166_248 = (let _166_247 = (let _166_246 = (resugar_pat f.FStar_Syntax_Syntax.fv_qual (FStar_Extraction_ML_Syntax.MLP_CTor ((d, mlPats))))
in (let _166_245 = (FStar_All.pipe_right when_clauses FStar_List.flatten)
in (_166_246, _166_245)))
in Some (_166_247))
in (g, _166_248, pat_ty_compat))
end))
end))
end)))
end)))
end))
end)))
in (

let extract_one_pat = (fun disj g p expected_t -> (match ((extract_one_pat disj false g p expected_t)) with
| (g, Some (x, v), b) -> begin
(g, (x, v), b)
end
| _77_679 -> begin
(FStar_All.failwith "Impossible: Unable to translate pattern")
end))
in (

let mk_when_clause = (fun whens -> (match (whens) with
| [] -> begin
None
end
| hd::tl -> begin
(let _166_259 = (FStar_List.fold_left FStar_Extraction_ML_Util.conjoin hd tl)
in Some (_166_259))
end))
in (match (p.FStar_Syntax_Syntax.v) with
| FStar_Syntax_Syntax.Pat_disj ([]) -> begin
(FStar_All.failwith "Impossible: Empty disjunctive pattern")
end
| FStar_Syntax_Syntax.Pat_disj (p::pats) -> begin
(

let _77_695 = (extract_one_pat true g p (Some (expected_t)))
in (match (_77_695) with
| (g, p, b) -> begin
(

let _77_705 = (FStar_Util.fold_map (fun b p -> (

let _77_702 = (extract_one_pat true g p (Some (expected_t)))
in (match (_77_702) with
| (_77_699, p, b') -> begin
((b && b'), p)
end))) b pats)
in (match (_77_705) with
| (b, ps) -> begin
(

let ps = (p)::ps
in (

let _77_720 = (FStar_All.pipe_right ps (FStar_List.partition (fun _77_3 -> (match (_77_3) with
| (_77_709, _77_713::_77_711) -> begin
true
end
| _77_717 -> begin
false
end))))
in (match (_77_720) with
| (ps_when, rest) -> begin
(

let ps = (FStar_All.pipe_right ps_when (FStar_List.map (fun _77_723 -> (match (_77_723) with
| (x, whens) -> begin
(let _166_264 = (mk_when_clause whens)
in (x, _166_264))
end))))
in (

let res = (match (rest) with
| [] -> begin
(g, ps, b)
end
| rest -> begin
(let _166_268 = (let _166_267 = (let _166_266 = (let _166_265 = (FStar_List.map Prims.fst rest)
in FStar_Extraction_ML_Syntax.MLP_Branch (_166_265))
in (_166_266, None))
in (_166_267)::ps)
in (g, _166_268, b))
end)
in res))
end)))
end))
end))
end
| _77_729 -> begin
(

let _77_735 = (extract_one_pat false g p (Some (expected_t)))
in (match (_77_735) with
| (g, (p, whens), b) -> begin
(

let when_clause = (mk_when_clause whens)
in (g, ((p, when_clause))::[], b))
end))
end)))))


let maybe_eta_data_and_project_record : FStar_Extraction_ML_UEnv.env  ->  FStar_Syntax_Syntax.fv_qual Prims.option  ->  FStar_Extraction_ML_Syntax.mlty  ->  FStar_Extraction_ML_Syntax.mlexpr  ->  FStar_Extraction_ML_Syntax.mlexpr = (fun g qual residualType mlAppExpr -> (

let rec eta_args = (fun more_args t -> (match (t) with
| FStar_Extraction_ML_Syntax.MLTY_Fun (t0, _77_746, t1) -> begin
(

let x = (FStar_Extraction_ML_Syntax.gensym ())
in (let _166_283 = (let _166_282 = (let _166_281 = (FStar_All.pipe_left (FStar_Extraction_ML_Syntax.with_ty t0) (FStar_Extraction_ML_Syntax.MLE_Var (x)))
in ((x, t0), _166_281))
in (_166_282)::more_args)
in (eta_args _166_283 t1)))
end
| FStar_Extraction_ML_Syntax.MLTY_Named (_77_752, _77_754) -> begin
((FStar_List.rev more_args), t)
end
| _77_758 -> begin
(FStar_All.failwith "Impossible: Head type is not an arrow")
end))
in (

let as_record = (fun qual e -> (match ((e.FStar_Extraction_ML_Syntax.expr, qual)) with
| (FStar_Extraction_ML_Syntax.MLE_CTor (_77_763, args), Some (FStar_Syntax_Syntax.Record_ctor (_77_768, fields))) -> begin
(

let path = (FStar_Extraction_ML_Util.record_field_path fields)
in (

let fields = (FStar_Extraction_ML_Util.record_fields fields args)
in (FStar_All.pipe_left (FStar_Extraction_ML_Syntax.with_ty e.FStar_Extraction_ML_Syntax.mlty) (FStar_Extraction_ML_Syntax.MLE_Record ((path, fields))))))
end
| _77_777 -> begin
e
end))
in (

let resugar_and_maybe_eta = (fun qual e -> (

let _77_783 = (eta_args [] residualType)
in (match (_77_783) with
| (eargs, tres) -> begin
(match (eargs) with
| [] -> begin
(let _166_292 = (as_record qual e)
in (FStar_Extraction_ML_Util.resugar_exp _166_292))
end
| _77_786 -> begin
(

let _77_789 = (FStar_List.unzip eargs)
in (match (_77_789) with
| (binders, eargs) -> begin
(match (e.FStar_Extraction_ML_Syntax.expr) with
| FStar_Extraction_ML_Syntax.MLE_CTor (head, args) -> begin
(

let body = (let _166_294 = (let _166_293 = (FStar_All.pipe_left (FStar_Extraction_ML_Syntax.with_ty tres) (FStar_Extraction_ML_Syntax.MLE_CTor ((head, (FStar_List.append args eargs)))))
in (FStar_All.pipe_left (as_record qual) _166_293))
in (FStar_All.pipe_left FStar_Extraction_ML_Util.resugar_exp _166_294))
in (FStar_All.pipe_left (FStar_Extraction_ML_Syntax.with_ty e.FStar_Extraction_ML_Syntax.mlty) (FStar_Extraction_ML_Syntax.MLE_Fun ((binders, body)))))
end
| _77_796 -> begin
(FStar_All.failwith "Impossible: Not a constructor")
end)
end))
end)
end)))
in (match ((mlAppExpr.FStar_Extraction_ML_Syntax.expr, qual)) with
| (_77_798, None) -> begin
mlAppExpr
end
| (FStar_Extraction_ML_Syntax.MLE_App ({FStar_Extraction_ML_Syntax.expr = FStar_Extraction_ML_Syntax.MLE_Name (mlp); FStar_Extraction_ML_Syntax.mlty = _77_804; FStar_Extraction_ML_Syntax.loc = _77_802}, mle::args), Some (FStar_Syntax_Syntax.Record_projector (f))) -> begin
(

let fn = (FStar_Extraction_ML_Util.mlpath_of_lid f)
in (

let proj = FStar_Extraction_ML_Syntax.MLE_Proj ((mle, fn))
in (

let e = (match (args) with
| [] -> begin
proj
end
| _77_821 -> begin
(let _166_296 = (let _166_295 = (FStar_All.pipe_left (FStar_Extraction_ML_Syntax.with_ty FStar_Extraction_ML_Syntax.MLTY_Top) proj)
in (_166_295, args))
in FStar_Extraction_ML_Syntax.MLE_App (_166_296))
end)
in (FStar_Extraction_ML_Syntax.with_ty mlAppExpr.FStar_Extraction_ML_Syntax.mlty e))))
end
| ((FStar_Extraction_ML_Syntax.MLE_App ({FStar_Extraction_ML_Syntax.expr = FStar_Extraction_ML_Syntax.MLE_Name (mlp); FStar_Extraction_ML_Syntax.mlty = _; FStar_Extraction_ML_Syntax.loc = _}, mlargs), Some (FStar_Syntax_Syntax.Data_ctor))) | ((FStar_Extraction_ML_Syntax.MLE_App ({FStar_Extraction_ML_Syntax.expr = FStar_Extraction_ML_Syntax.MLE_Name (mlp); FStar_Extraction_ML_Syntax.mlty = _; FStar_Extraction_ML_Syntax.loc = _}, mlargs), Some (FStar_Syntax_Syntax.Record_ctor (_)))) -> begin
(let _166_297 = (FStar_All.pipe_left (FStar_Extraction_ML_Syntax.with_ty mlAppExpr.FStar_Extraction_ML_Syntax.mlty) (FStar_Extraction_ML_Syntax.MLE_CTor ((mlp, mlargs))))
in (FStar_All.pipe_left (resugar_and_maybe_eta qual) _166_297))
end
| ((FStar_Extraction_ML_Syntax.MLE_Name (mlp), Some (FStar_Syntax_Syntax.Data_ctor))) | ((FStar_Extraction_ML_Syntax.MLE_Name (mlp), Some (FStar_Syntax_Syntax.Record_ctor (_)))) -> begin
(let _166_298 = (FStar_All.pipe_left (FStar_Extraction_ML_Syntax.with_ty mlAppExpr.FStar_Extraction_ML_Syntax.mlty) (FStar_Extraction_ML_Syntax.MLE_CTor ((mlp, []))))
in (FStar_All.pipe_left (resugar_and_maybe_eta qual) _166_298))
end
| _77_861 -> begin
mlAppExpr
end)))))


let maybe_downgrade_eff : FStar_Extraction_ML_UEnv.env  ->  FStar_Extraction_ML_Syntax.e_tag  ->  FStar_Extraction_ML_Syntax.mlty  ->  FStar_Extraction_ML_Syntax.e_tag = (fun g f t -> if ((f = FStar_Extraction_ML_Syntax.E_GHOST) && (type_leq g t FStar_Extraction_ML_Syntax.ml_unit_ty)) then begin
FStar_Extraction_ML_Syntax.E_PURE
end else begin
f
end)


let rec term_as_mlexpr : FStar_Extraction_ML_UEnv.env  ->  FStar_Syntax_Syntax.term  ->  (FStar_Extraction_ML_Syntax.mlexpr * FStar_Extraction_ML_Syntax.e_tag * FStar_Extraction_ML_Syntax.mlty) = (fun g t -> (

let _77_870 = (term_as_mlexpr' g t)
in (match (_77_870) with
| (e, tag, ty) -> begin
(

let _77_872 = (FStar_Extraction_ML_UEnv.debug g (fun u -> (let _166_323 = (let _166_322 = (FStar_Syntax_Print.tag_of_term t)
in (let _166_321 = (FStar_Syntax_Print.term_to_string t)
in (let _166_320 = (FStar_Extraction_ML_Code.string_of_mlty g.FStar_Extraction_ML_UEnv.currentModule ty)
in (FStar_Util.format3 "term_as_mlexpr (%s) :  %s has ML type %s\n" _166_322 _166_321 _166_320))))
in (FStar_Util.print_string _166_323))))
in (erase g e ty tag))
end)))
and check_term_as_mlexpr : FStar_Extraction_ML_UEnv.env  ->  FStar_Syntax_Syntax.term  ->  FStar_Extraction_ML_Syntax.e_tag  ->  FStar_Extraction_ML_Syntax.mlty  ->  (FStar_Extraction_ML_Syntax.mlexpr * FStar_Extraction_ML_Syntax.mlty) = (fun g t f ty -> (

let _77_880 = (check_term_as_mlexpr' g t f ty)
in (match (_77_880) with
| (e, t) -> begin
(

let _77_885 = (erase g e t f)
in (match (_77_885) with
| (r, _77_883, t) -> begin
(r, t)
end))
end)))
and check_term_as_mlexpr' : FStar_Extraction_ML_UEnv.env  ->  FStar_Syntax_Syntax.term  ->  FStar_Extraction_ML_Syntax.e_tag  ->  FStar_Extraction_ML_Syntax.mlty  ->  (FStar_Extraction_ML_Syntax.mlexpr * FStar_Extraction_ML_Syntax.mlty) = (fun g e0 f ty -> (

let _77_893 = (term_as_mlexpr g e0)
in (match (_77_893) with
| (e, tag, t) -> begin
(

let tag = (maybe_downgrade_eff g tag t)
in if (FStar_Extraction_ML_Util.eff_leq tag f) then begin
(let _166_332 = (maybe_coerce g e t ty)
in (_166_332, ty))
end else begin
(err_unexpected_eff e0 f tag)
end)
end)))
and term_as_mlexpr' : FStar_Extraction_ML_UEnv.env  ->  FStar_Syntax_Syntax.term  ->  (FStar_Extraction_ML_Syntax.mlexpr * FStar_Extraction_ML_Syntax.e_tag * FStar_Extraction_ML_Syntax.mlty) = (fun g top -> (

let _77_898 = (FStar_Extraction_ML_UEnv.debug g (fun u -> (let _166_338 = (let _166_337 = (FStar_Syntax_Print.tag_of_term top)
in (let _166_336 = (FStar_Syntax_Print.term_to_string top)
in (FStar_Util.format2 "term_as_mlexpr\' (%s) :  %s \n" _166_337 _166_336)))
in (FStar_Util.print_string _166_338))))
in (

let t = (FStar_Syntax_Subst.compress top)
in (match (t.FStar_Syntax_Syntax.n) with
| (FStar_Syntax_Syntax.Tm_unknown) | (FStar_Syntax_Syntax.Tm_delayed (_)) | (FStar_Syntax_Syntax.Tm_uvar (_)) | (FStar_Syntax_Syntax.Tm_bvar (_)) -> begin
(let _166_340 = (let _166_339 = (FStar_Syntax_Print.tag_of_term t)
in (FStar_Util.format1 "Impossible: Unexpected term: %s" _166_339))
in (FStar_All.failwith _166_340))
end
| (FStar_Syntax_Syntax.Tm_type (_)) | (FStar_Syntax_Syntax.Tm_refine (_)) | (FStar_Syntax_Syntax.Tm_arrow (_)) -> begin
(FStar_Extraction_ML_Syntax.ml_unit, FStar_Extraction_ML_Syntax.E_PURE, FStar_Extraction_ML_Syntax.ml_unit_ty)
end
| (FStar_Syntax_Syntax.Tm_meta (t, _)) | (FStar_Syntax_Syntax.Tm_uinst (t, _)) -> begin
(term_as_mlexpr' g t)
end
| FStar_Syntax_Syntax.Tm_constant (c) -> begin
(

let _77_936 = (FStar_TypeChecker_Tc.type_of g.FStar_Extraction_ML_UEnv.tcenv t)
in (match (_77_936) with
| (_77_932, ty, _77_935) -> begin
(

let ml_ty = (term_as_mlty g ty)
in (let _166_344 = (let _166_343 = (let _166_342 = (FStar_Extraction_ML_Util.mlconst_of_const' t.FStar_Syntax_Syntax.pos c)
in (FStar_All.pipe_left (fun _166_341 -> FStar_Extraction_ML_Syntax.MLE_Const (_166_341)) _166_342))
in (FStar_Extraction_ML_Syntax.with_ty ml_ty _166_343))
in (_166_344, FStar_Extraction_ML_Syntax.E_PURE, ml_ty)))
end))
end
| (FStar_Syntax_Syntax.Tm_name (_)) | (FStar_Syntax_Syntax.Tm_fvar (_)) -> begin
if (is_type g t) then begin
(FStar_Extraction_ML_Syntax.ml_unit, FStar_Extraction_ML_Syntax.E_PURE, FStar_Extraction_ML_Syntax.ml_unit_ty)
end else begin
(match ((FStar_Extraction_ML_UEnv.lookup_term g t)) with
| (FStar_Util.Inl (_77_945), _77_948) -> begin
(FStar_Extraction_ML_Syntax.ml_unit, FStar_Extraction_ML_Syntax.E_PURE, FStar_Extraction_ML_Syntax.ml_unit_ty)
end
| (FStar_Util.Inr (x, mltys, _77_953), qual) -> begin
(match (mltys) with
| ([], t) when (t = FStar_Extraction_ML_Syntax.ml_unit_ty) -> begin
(FStar_Extraction_ML_Syntax.ml_unit, FStar_Extraction_ML_Syntax.E_PURE, t)
end
| ([], t) -> begin
(let _166_345 = (maybe_eta_data_and_project_record g qual t x)
in (_166_345, FStar_Extraction_ML_Syntax.E_PURE, t))
end
| _77_965 -> begin
(err_uninst g t mltys)
end)
end)
end
end
| FStar_Syntax_Syntax.Tm_abs (bs, body, copt) -> begin
(

let _77_973 = (FStar_Syntax_Subst.open_term bs body)
in (match (_77_973) with
| (bs, body) -> begin
(

let _77_976 = (binders_as_ml_binders g bs)
in (match (_77_976) with
| (ml_bs, env) -> begin
(

let _77_980 = (term_as_mlexpr env body)
in (match (_77_980) with
| (ml_body, f, t) -> begin
(

let _77_990 = (FStar_List.fold_right (fun _77_984 _77_987 -> (match ((_77_984, _77_987)) with
| ((_77_982, targ), (f, t)) -> begin
(FStar_Extraction_ML_Syntax.E_PURE, FStar_Extraction_ML_Syntax.MLTY_Fun ((targ, f, t)))
end)) ml_bs (f, t))
in (match (_77_990) with
| (f, tfun) -> begin
(let _166_348 = (FStar_All.pipe_left (FStar_Extraction_ML_Syntax.with_ty tfun) (FStar_Extraction_ML_Syntax.MLE_Fun ((ml_bs, ml_body))))
in (_166_348, f, tfun))
end))
end))
end))
end))
end
| FStar_Syntax_Syntax.Tm_app (head, args) -> begin
(match (head.FStar_Syntax_Syntax.n) with
| FStar_Syntax_Syntax.Tm_uvar (_77_996) -> begin
(

let t = (FStar_TypeChecker_Normalize.normalize ((FStar_TypeChecker_Normalize.Beta)::(FStar_TypeChecker_Normalize.EraseUniverses)::(FStar_TypeChecker_Normalize.AllowUnboundUniverses)::[]) g.FStar_Extraction_ML_UEnv.tcenv t)
in (term_as_mlexpr' g t))
end
| _77_1000 -> begin
(

let rec extract_app = (fun is_data _77_1005 _77_1008 restArgs -> (match ((_77_1005, _77_1008)) with
| ((mlhead, mlargs_f), (f, t)) -> begin
(match ((restArgs, t)) with
| ([], _77_1012) -> begin
(

let _77_1023 = if ((FStar_Syntax_Util.is_primop head) || (FStar_Extraction_ML_Util.codegen_fsharp ())) then begin
(let _166_357 = (FStar_All.pipe_right (FStar_List.rev mlargs_f) (FStar_List.map Prims.fst))
in ([], _166_357))
end else begin
(FStar_List.fold_left (fun _77_1016 _77_1019 -> (match ((_77_1016, _77_1019)) with
| ((lbs, out_args), (arg, f)) -> begin
if ((f = FStar_Extraction_ML_Syntax.E_PURE) || (f = FStar_Extraction_ML_Syntax.E_GHOST)) then begin
(lbs, (arg)::out_args)
end else begin
(

let x = (FStar_Extraction_ML_Syntax.gensym ())
in (let _166_361 = (let _166_360 = (FStar_All.pipe_left (FStar_Extraction_ML_Syntax.with_ty arg.FStar_Extraction_ML_Syntax.mlty) (FStar_Extraction_ML_Syntax.MLE_Var (x)))
in (_166_360)::out_args)
in (((x, arg))::lbs, _166_361)))
end
end)) ([], []) mlargs_f)
end
in (match (_77_1023) with
| (lbs, mlargs) -> begin
(

let app = (let _166_362 = (FStar_All.pipe_left (FStar_Extraction_ML_Syntax.with_ty t) (FStar_Extraction_ML_Syntax.MLE_App ((mlhead, mlargs))))
in (FStar_All.pipe_left (maybe_eta_data_and_project_record g is_data t) _166_362))
in (

let l_app = (FStar_List.fold_right (fun _77_1027 out -> (match (_77_1027) with
| (x, arg) -> begin
(FStar_All.pipe_left (FStar_Extraction_ML_Syntax.with_ty out.FStar_Extraction_ML_Syntax.mlty) (mk_MLE_Let false (false, ({FStar_Extraction_ML_Syntax.mllb_name = x; FStar_Extraction_ML_Syntax.mllb_tysc = Some (([], arg.FStar_Extraction_ML_Syntax.mlty)); FStar_Extraction_ML_Syntax.mllb_add_unit = false; FStar_Extraction_ML_Syntax.mllb_def = arg; FStar_Extraction_ML_Syntax.print_typ = true})::[]) out))
end)) lbs app)
in (l_app, f, t)))
end))
end
| ((arg, _77_1033)::rest, FStar_Extraction_ML_Syntax.MLTY_Fun (formal_t, f', t)) when (is_type g arg) -> begin
if (type_leq g formal_t FStar_Extraction_ML_Syntax.ml_unit_ty) then begin
(let _166_366 = (let _166_365 = (FStar_Extraction_ML_Util.join f f')
in (_166_365, t))
in (extract_app is_data (mlhead, ((FStar_Extraction_ML_Syntax.ml_unit, FStar_Extraction_ML_Syntax.E_PURE))::mlargs_f) _166_366 rest))
end else begin
(let _166_371 = (let _166_370 = (FStar_Extraction_ML_Code.string_of_mlexpr g.FStar_Extraction_ML_UEnv.currentModule mlhead)
in (let _166_369 = (FStar_Syntax_Print.term_to_string arg)
in (let _166_368 = (FStar_Syntax_Print.tag_of_term arg)
in (let _166_367 = (FStar_Extraction_ML_Code.string_of_mlty g.FStar_Extraction_ML_UEnv.currentModule formal_t)
in (FStar_Util.format4 "Impossible: ill-typed application:\n\thead=%s, arg=%s, tag=%s\n\texpected type unit, got %s" _166_370 _166_369 _166_368 _166_367)))))
in (FStar_All.failwith _166_371))
end
end
| ((e0, _77_1045)::rest, FStar_Extraction_ML_Syntax.MLTY_Fun (tExpected, f', t)) -> begin
(

let _77_1057 = (term_as_mlexpr g e0)
in (match (_77_1057) with
| (e0, f0, tInferred) -> begin
(

let e0 = (maybe_coerce g e0 tInferred tExpected)
in (let _166_373 = (let _166_372 = (FStar_Extraction_ML_Util.join_l ((f)::(f')::(f0)::[]))
in (_166_372, t))
in (extract_app is_data (mlhead, ((e0, f0))::mlargs_f) _166_373 rest)))
end))
end
| _77_1060 -> begin
(match ((FStar_Extraction_ML_Util.udelta_unfold g t)) with
| Some (t) -> begin
(extract_app is_data (mlhead, mlargs_f) (f, t) restArgs)
end
| None -> begin
(err_ill_typed_application top restArgs t)
end)
end)
end))
in (

let extract_app_maybe_projector = (fun is_data mlhead _77_1069 args -> (match (_77_1069) with
| (f, t) -> begin
(match (is_data) with
| Some (FStar_Syntax_Syntax.Record_projector (_77_1072)) -> begin
(

let rec remove_implicits = (fun args f t -> (match ((args, t)) with
| ((_77_1081, Some (FStar_Syntax_Syntax.Implicit (_77_1083)))::args, FStar_Extraction_ML_Syntax.MLTY_Fun (_77_1089, f', t)) -> begin
(let _166_388 = (FStar_Extraction_ML_Util.join f f')
in (remove_implicits args _166_388 t))
end
| _77_1096 -> begin
(args, f, t)
end))
in (

let _77_1100 = (remove_implicits args f t)
in (match (_77_1100) with
| (args, f, t) -> begin
(extract_app is_data (mlhead, []) (f, t) args)
end)))
end
| _77_1102 -> begin
(extract_app is_data (mlhead, []) (f, t) args)
end)
end))
in if (is_type g t) then begin
(FStar_Extraction_ML_Syntax.ml_unit, FStar_Extraction_ML_Syntax.E_PURE, FStar_Extraction_ML_Syntax.ml_unit_ty)
end else begin
(

let head = (FStar_Syntax_Util.un_uinst head)
in (match (head.FStar_Syntax_Syntax.n) with
| (FStar_Syntax_Syntax.Tm_bvar (_)) | (FStar_Syntax_Syntax.Tm_fvar (_)) -> begin
(

let _77_1123 = (match ((FStar_Extraction_ML_UEnv.lookup_term g head)) with
| (FStar_Util.Inr (u), q) -> begin
(u, q)
end
| _77_1115 -> begin
(FStar_All.failwith "FIXME Ty")
end)
in (match (_77_1123) with
| ((head_ml, (vars, t), inst_ok), qual) -> begin
(

let has_typ_apps = (match (args) with
| (a, _77_1128)::_77_1125 -> begin
(is_type g a)
end
| _77_1132 -> begin
false
end)
in (

let _77_1178 = (match (vars) with
| _77_1137::_77_1135 when ((not (has_typ_apps)) && inst_ok) -> begin
(head_ml, t, args)
end
| _77_1140 -> begin
(

let n = (FStar_List.length vars)
in if (n <= (FStar_List.length args)) then begin
(

let _77_1144 = (FStar_Util.first_N n args)
in (match (_77_1144) with
| (prefix, rest) -> begin
(

let prefixAsMLTypes = (FStar_List.map (fun _77_1148 -> (match (_77_1148) with
| (x, _77_1147) -> begin
(term_as_mlty g x)
end)) prefix)
in (

let t = (instantiate (vars, t) prefixAsMLTypes)
in (

let head = (match (head_ml.FStar_Extraction_ML_Syntax.expr) with
| (FStar_Extraction_ML_Syntax.MLE_Name (_)) | (FStar_Extraction_ML_Syntax.MLE_Var (_)) -> begin
(

let _77_1157 = head_ml
in {FStar_Extraction_ML_Syntax.expr = _77_1157.FStar_Extraction_ML_Syntax.expr; FStar_Extraction_ML_Syntax.mlty = t; FStar_Extraction_ML_Syntax.loc = _77_1157.FStar_Extraction_ML_Syntax.loc})
end
| FStar_Extraction_ML_Syntax.MLE_App (head, {FStar_Extraction_ML_Syntax.expr = FStar_Extraction_ML_Syntax.MLE_Const (FStar_Extraction_ML_Syntax.MLC_Unit); FStar_Extraction_ML_Syntax.mlty = _77_1163; FStar_Extraction_ML_Syntax.loc = _77_1161}::[]) -> begin
(FStar_All.pipe_right (FStar_Extraction_ML_Syntax.MLE_App (((

let _77_1170 = head
in {FStar_Extraction_ML_Syntax.expr = _77_1170.FStar_Extraction_ML_Syntax.expr; FStar_Extraction_ML_Syntax.mlty = FStar_Extraction_ML_Syntax.MLTY_Fun ((FStar_Extraction_ML_Syntax.ml_unit_ty, FStar_Extraction_ML_Syntax.E_PURE, t)); FStar_Extraction_ML_Syntax.loc = _77_1170.FStar_Extraction_ML_Syntax.loc}), (FStar_Extraction_ML_Syntax.ml_unit)::[]))) (FStar_Extraction_ML_Syntax.with_ty t))
end
| _77_1173 -> begin
(FStar_All.failwith "Impossible: Unexpected head term")
end)
in (head, t, rest))))
end))
end else begin
(err_uninst g head (vars, t))
end)
end)
in (match (_77_1178) with
| (head_ml, head_t, args) -> begin
(match (args) with
| [] -> begin
(let _166_390 = (maybe_eta_data_and_project_record g qual head_t head_ml)
in (_166_390, FStar_Extraction_ML_Syntax.E_PURE, head_t))
end
| _77_1181 -> begin
(extract_app_maybe_projector qual head_ml (FStar_Extraction_ML_Syntax.E_PURE, head_t) args)
end)
end)))
end))
end
| _77_1183 -> begin
(

let _77_1187 = (term_as_mlexpr g head)
in (match (_77_1187) with
| (head, f, t) -> begin
(extract_app_maybe_projector None head (f, t) args)
end))
end))
end))
end)
end
| FStar_Syntax_Syntax.Tm_ascribed (e0, tc, f) -> begin
(

let t = (match (tc) with
| FStar_Util.Inl (t) -> begin
(term_as_mlty g t)
end
| FStar_Util.Inr (c) -> begin
(term_as_mlty g (FStar_Syntax_Util.comp_result c))
end)
in (

let f = (match (f) with
| None -> begin
(FStar_All.failwith "Ascription node with an empty effect label")
end
| Some (l) -> begin
(effect_as_etag g l)
end)
in (

let _77_1204 = (check_term_as_mlexpr g e0 f t)
in (match (_77_1204) with
| (e, t) -> begin
(e, f, t)
end))))
end
| FStar_Syntax_Syntax.Tm_let ((is_rec, lbs), e') -> begin
(

let top_level = (FStar_Syntax_Syntax.is_top_level lbs)
in (

let _77_1220 = if is_rec then begin
(FStar_Syntax_Subst.open_let_rec lbs e')
end else begin
if (FStar_Syntax_Syntax.is_top_level lbs) then begin
(lbs, e')
end else begin
(

let lb = (FStar_List.hd lbs)
in (

let x = (let _166_391 = (FStar_Util.left lb.FStar_Syntax_Syntax.lbname)
in (FStar_Syntax_Syntax.freshen_bv _166_391))
in (

let lb = (

let _77_1214 = lb
in {FStar_Syntax_Syntax.lbname = FStar_Util.Inl (x); FStar_Syntax_Syntax.lbunivs = _77_1214.FStar_Syntax_Syntax.lbunivs; FStar_Syntax_Syntax.lbtyp = _77_1214.FStar_Syntax_Syntax.lbtyp; FStar_Syntax_Syntax.lbeff = _77_1214.FStar_Syntax_Syntax.lbeff; FStar_Syntax_Syntax.lbdef = _77_1214.FStar_Syntax_Syntax.lbdef})
in (

let e' = (FStar_Syntax_Subst.subst ((FStar_Syntax_Syntax.DB ((0, x)))::[]) e')
in ((lb)::[], e')))))
end
end
in (match (_77_1220) with
| (lbs, e') -> begin
(

let maybe_generalize = (fun _77_1228 -> (match (_77_1228) with
| {FStar_Syntax_Syntax.lbname = lbname; FStar_Syntax_Syntax.lbunivs = _77_1226; FStar_Syntax_Syntax.lbtyp = t; FStar_Syntax_Syntax.lbeff = lbeff; FStar_Syntax_Syntax.lbdef = e} -> begin
(

let f_e = (effect_as_etag g lbeff)
in (

let t = (FStar_Syntax_Subst.compress t)
in (match (t.FStar_Syntax_Syntax.n) with
| FStar_Syntax_Syntax.Tm_arrow (bs, c) when (let _166_394 = (FStar_List.hd bs)
in (FStar_All.pipe_right _166_394 (is_type_binder g))) -> begin
(

let _77_1237 = (FStar_Syntax_Subst.open_comp bs c)
in (match (_77_1237) with
| (bs, c) -> begin
(

let _77_1247 = (match ((FStar_Util.prefix_until (fun x -> (not ((is_type_binder g x)))) bs)) with
| None -> begin
(bs, (FStar_Syntax_Util.comp_result c))
end
| Some (bs, b, rest) -> begin
(let _166_396 = (FStar_Syntax_Util.arrow ((b)::rest) c)
in (bs, _166_396))
end)
in (match (_77_1247) with
| (tbinders, tbody) -> begin
(

let n_tbinders = (FStar_List.length tbinders)
in (

let e = (normalize_abs e)
in (match (e.FStar_Syntax_Syntax.n) with
| FStar_Syntax_Syntax.Tm_abs (bs, body, _77_1253) -> begin
(

let _77_1258 = (FStar_Syntax_Subst.open_term bs body)
in (match (_77_1258) with
| (bs, body) -> begin
if (n_tbinders <= (FStar_List.length bs)) then begin
(

let _77_1261 = (FStar_Util.first_N n_tbinders bs)
in (match (_77_1261) with
| (targs, rest_args) -> begin
(

let expected_t = (

let s = (FStar_List.map2 (fun _77_1265 _77_1269 -> (match ((_77_1265, _77_1269)) with
| ((x, _77_1264), (y, _77_1268)) -> begin
(let _166_400 = (let _166_399 = (FStar_Syntax_Syntax.bv_to_name y)
in (x, _166_399))
in FStar_Syntax_Syntax.NT (_166_400))
end)) tbinders targs)
in (FStar_Syntax_Subst.subst s tbody))
in (

let env = (FStar_List.fold_left (fun env _77_1276 -> (match (_77_1276) with
| (a, _77_1275) -> begin
(FStar_Extraction_ML_UEnv.extend_ty env a None)
end)) g targs)
in (

let expected_t = (term_as_mlty env expected_t)
in (

let polytype = (let _166_404 = (FStar_All.pipe_right targs (FStar_List.map (fun _77_1282 -> (match (_77_1282) with
| (x, _77_1281) -> begin
(FStar_Extraction_ML_UEnv.bv_as_ml_tyvar x)
end))))
in (_166_404, expected_t))
in (

let add_unit = (match (rest_args) with
| [] -> begin
(not ((is_fstar_value body)))
end
| _77_1286 -> begin
false
end)
in (

let rest_args = if add_unit then begin
(unit_binder)::rest_args
end else begin
rest_args
end
in (

let body = (match (rest_args) with
| [] -> begin
body
end
| _77_1291 -> begin
(FStar_Syntax_Util.abs rest_args body None)
end)
in (lbname, f_e, (t, (targs, polytype)), add_unit, body))))))))
end))
end else begin
(FStar_All.failwith "Not enough type binders")
end
end))
end
| _77_1294 -> begin
(err_value_restriction e)
end)))
end))
end))
end
| _77_1296 -> begin
(

let expected_t = (term_as_mlty g t)
in (lbname, f_e, (t, ([], ([], expected_t))), false, e))
end)))
end))
in (

let check_lb = (fun env _77_1311 -> (match (_77_1311) with
| (nm, (lbname, f, (t, (targs, polytype)), add_unit, e)) -> begin
(

let env = (FStar_List.fold_left (fun env _77_1316 -> (match (_77_1316) with
| (a, _77_1315) -> begin
(FStar_Extraction_ML_UEnv.extend_ty env a None)
end)) env targs)
in (

let expected_t = if add_unit then begin
FStar_Extraction_ML_Syntax.MLTY_Fun ((FStar_Extraction_ML_Syntax.ml_unit_ty, FStar_Extraction_ML_Syntax.E_PURE, (Prims.snd polytype)))
end else begin
(Prims.snd polytype)
end
in (

let _77_1322 = (check_term_as_mlexpr env e f expected_t)
in (match (_77_1322) with
| (e, _77_1321) -> begin
(f, {FStar_Extraction_ML_Syntax.mllb_name = nm; FStar_Extraction_ML_Syntax.mllb_tysc = Some (polytype); FStar_Extraction_ML_Syntax.mllb_add_unit = add_unit; FStar_Extraction_ML_Syntax.mllb_def = e; FStar_Extraction_ML_Syntax.print_typ = true})
end))))
end))
in (

let lbs = (FStar_All.pipe_right lbs (FStar_List.map maybe_generalize))
in (

let _77_1346 = (FStar_List.fold_right (fun lb _77_1327 -> (match (_77_1327) with
| (env, lbs) -> begin
(

let _77_1340 = lb
in (match (_77_1340) with
| (lbname, _77_1330, (t, (_77_1333, polytype)), add_unit, _77_1339) -> begin
(

let _77_1343 = (FStar_Extraction_ML_UEnv.extend_lb env lbname t polytype add_unit true)
in (match (_77_1343) with
| (env, nm) -> begin
(env, ((nm, lb))::lbs)
end))
end))
end)) lbs (g, []))
in (match (_77_1346) with
| (env_body, lbs) -> begin
(

let env_def = if is_rec then begin
env_body
end else begin
g
end
in (

let lbs = (FStar_All.pipe_right lbs (FStar_List.map (check_lb env_def)))
in (

let _77_1352 = (term_as_mlexpr env_body e')
in (match (_77_1352) with
| (e', f', t') -> begin
(

let f = (let _166_414 = (let _166_413 = (FStar_List.map Prims.fst lbs)
in (f')::_166_413)
in (FStar_Extraction_ML_Util.join_l _166_414))
in (let _166_419 = (let _166_418 = (let _166_416 = (let _166_415 = (FStar_List.map Prims.snd lbs)
in (is_rec, _166_415))
in (mk_MLE_Let top_level _166_416 e'))
in (let _166_417 = (FStar_Extraction_ML_Util.mlloc_of_range t.FStar_Syntax_Syntax.pos)
in (FStar_Extraction_ML_Syntax.with_ty_loc t' _166_418 _166_417)))
in (_166_419, f, t')))
end))))
end)))))
end)))
end
| FStar_Syntax_Syntax.Tm_match (scrutinee, pats) -> begin
(

let _77_1361 = (term_as_mlexpr g scrutinee)
in (match (_77_1361) with
| (e, f_e, t_e) -> begin
(

let _77_1365 = (check_pats_for_ite pats)
in (match (_77_1365) with
| (b, then_e, else_e) -> begin
(

let no_lift = (fun x t -> x)
in if b then begin
(match ((then_e, else_e)) with
| (Some (then_e), Some (else_e)) -> begin
(

let _77_1377 = (term_as_mlexpr g then_e)
in (match (_77_1377) with
| (then_mle, f_then, t_then) -> begin
(

let _77_1381 = (term_as_mlexpr g else_e)
in (match (_77_1381) with
| (else_mle, f_else, t_else) -> begin
(

let _77_1384 = if (type_leq g t_then t_else) then begin
(t_else, no_lift)
end else begin
if (type_leq g t_else t_then) then begin
(t_then, no_lift)
end else begin
(FStar_Extraction_ML_Syntax.MLTY_Top, FStar_Extraction_ML_Syntax.apply_obj_repr)
end
end
in (match (_77_1384) with
| (t_branch, maybe_lift) -> begin
(let _166_450 = (let _166_448 = (let _166_447 = (let _166_446 = (maybe_lift then_mle t_then)
in (let _166_445 = (let _166_444 = (maybe_lift else_mle t_else)
in Some (_166_444))
in (e, _166_446, _166_445)))
in FStar_Extraction_ML_Syntax.MLE_If (_166_447))
in (FStar_All.pipe_left (FStar_Extraction_ML_Syntax.with_ty t_branch) _166_448))
in (let _166_449 = (FStar_Extraction_ML_Util.join f_then f_else)
in (_166_450, _166_449, t_branch)))
end))
end))
end))
end
| _77_1386 -> begin
(FStar_All.failwith "ITE pats matched but then and else expressions not found?")
end)
end else begin
(

let _77_1418 = (FStar_All.pipe_right pats (FStar_Util.fold_map (fun compat br -> (

let _77_1392 = (FStar_Syntax_Subst.open_branch br)
in (match (_77_1392) with
| (pat, when_opt, branch) -> begin
(

let _77_1396 = (extract_pat g pat t_e)
in (match (_77_1396) with
| (env, p, pat_t_compat) -> begin
(

let _77_1407 = (match (when_opt) with
| None -> begin
(None, FStar_Extraction_ML_Syntax.E_PURE)
end
| Some (w) -> begin
(

let _77_1403 = (term_as_mlexpr env w)
in (match (_77_1403) with
| (w, f_w, t_w) -> begin
(

let w = (maybe_coerce env w t_w FStar_Extraction_ML_Syntax.ml_bool_ty)
in (Some (w), f_w))
end))
end)
in (match (_77_1407) with
| (when_opt, f_when) -> begin
(

let _77_1411 = (term_as_mlexpr env branch)
in (match (_77_1411) with
| (mlbranch, f_branch, t_branch) -> begin
(let _166_454 = (FStar_All.pipe_right p (FStar_List.map (fun _77_1414 -> (match (_77_1414) with
| (p, wopt) -> begin
(

let when_clause = (FStar_Extraction_ML_Util.conjoin_opt wopt when_opt)
in (p, (when_clause, f_when), (mlbranch, f_branch, t_branch)))
end))))
in ((compat && pat_t_compat), _166_454))
end))
end))
end))
end))) true))
in (match (_77_1418) with
| (pat_t_compat, mlbranches) -> begin
(

let mlbranches = (FStar_List.flatten mlbranches)
in (

let e = if pat_t_compat then begin
e
end else begin
(FStar_All.pipe_left (FStar_Extraction_ML_Syntax.with_ty t_e) (FStar_Extraction_ML_Syntax.MLE_Coerce ((e, t_e, FStar_Extraction_ML_Syntax.MLTY_Top))))
end
in (match (mlbranches) with
| [] -> begin
(

let _77_1427 = (let _166_456 = (let _166_455 = (FStar_Syntax_Syntax.lid_as_fv FStar_Syntax_Const.failwith_lid FStar_Syntax_Syntax.Delta_constant None)
in (FStar_Extraction_ML_UEnv.lookup_fv g _166_455))
in (FStar_All.pipe_left FStar_Util.right _166_456))
in (match (_77_1427) with
| (fw, _77_1424, _77_1426) -> begin
(let _166_461 = (let _166_460 = (let _166_459 = (let _166_458 = (let _166_457 = (FStar_All.pipe_left (FStar_Extraction_ML_Syntax.with_ty FStar_Extraction_ML_Syntax.ml_string_ty) (FStar_Extraction_ML_Syntax.MLE_Const (FStar_Extraction_ML_Syntax.MLC_String ("unreachable"))))
in (_166_457)::[])
in (fw, _166_458))
in FStar_Extraction_ML_Syntax.MLE_App (_166_459))
in (FStar_All.pipe_left (FStar_Extraction_ML_Syntax.with_ty FStar_Extraction_ML_Syntax.ml_unit_ty) _166_460))
in (_166_461, FStar_Extraction_ML_Syntax.E_PURE, FStar_Extraction_ML_Syntax.ml_unit_ty))
end))
end
| (_77_1430, _77_1432, (_77_1434, f_first, t_first))::rest -> begin
(

let _77_1460 = (FStar_List.fold_left (fun _77_1442 _77_1452 -> (match ((_77_1442, _77_1452)) with
| ((topt, f), (_77_1444, _77_1446, (_77_1448, f_branch, t_branch))) -> begin
(

let f = (FStar_Extraction_ML_Util.join f f_branch)
in (

let topt = (match (topt) with
| None -> begin
None
end
| Some (t) -> begin
if (type_leq g t t_branch) then begin
Some (t_branch)
end else begin
if (type_leq g t_branch t) then begin
Some (t)
end else begin
None
end
end
end)
in (topt, f)))
end)) (Some (t_first), f_first) rest)
in (match (_77_1460) with
| (topt, f_match) -> begin
(

let mlbranches = (FStar_All.pipe_right mlbranches (FStar_List.map (fun _77_1471 -> (match (_77_1471) with
| (p, (wopt, _77_1464), (b, _77_1468, t)) -> begin
(

let b = (match (topt) with
| None -> begin
(FStar_Extraction_ML_Syntax.apply_obj_repr b t)
end
| Some (_77_1474) -> begin
b
end)
in (p, wopt, b))
end))))
in (

let t_match = (match (topt) with
| None -> begin
FStar_Extraction_ML_Syntax.MLTY_Top
end
| Some (t) -> begin
t
end)
in (let _166_465 = (FStar_All.pipe_left (FStar_Extraction_ML_Syntax.with_ty t_match) (FStar_Extraction_ML_Syntax.MLE_Match ((e, mlbranches))))
in (_166_465, f_match, t_match))))
end))
end)))
end))
end)
end))
end))
end))))


let fresh : Prims.string  ->  (Prims.string * Prims.int) = (

let c = (FStar_Util.mk_ref 0)
in (fun x -> (

let _77_1484 = (FStar_Util.incr c)
in (let _166_468 = (FStar_ST.read c)
in (x, _166_468)))))


let ind_discriminator_body : FStar_Extraction_ML_UEnv.env  ->  FStar_Ident.lident  ->  FStar_Ident.lident  ->  FStar_Extraction_ML_Syntax.mlmodule1 = (fun env discName constrName -> (

let _77_1492 = (FStar_TypeChecker_Env.lookup_lid env.FStar_Extraction_ML_UEnv.tcenv discName)
in (match (_77_1492) with
| (_77_1490, fstar_disc_type) -> begin
(

let wildcards = (match ((let _166_475 = (FStar_Syntax_Subst.compress fstar_disc_type)
in _166_475.FStar_Syntax_Syntax.n)) with
| FStar_Syntax_Syntax.Tm_arrow (binders, _77_1495) -> begin
(let _166_479 = (FStar_All.pipe_right binders (FStar_List.filter (fun _77_4 -> (match (_77_4) with
| (_77_1500, Some (FStar_Syntax_Syntax.Implicit (_77_1502))) -> begin
true
end
| _77_1507 -> begin
false
end))))
in (FStar_All.pipe_right _166_479 (FStar_List.map (fun _77_1508 -> (let _166_478 = (fresh "_")
in (_166_478, FStar_Extraction_ML_Syntax.MLTY_Top))))))
end
| _77_1511 -> begin
(FStar_All.failwith "Discriminator must be a function")
end)
in (

let mlid = (fresh "_discr_")
in (

let targ = FStar_Extraction_ML_Syntax.MLTY_Top
in (

let disc_ty = FStar_Extraction_ML_Syntax.MLTY_Top
in (

let discrBody = (let _166_494 = (let _166_493 = (let _166_492 = (let _166_491 = (let _166_490 = (let _166_489 = (FStar_All.pipe_left (FStar_Extraction_ML_Syntax.with_ty targ) (FStar_Extraction_ML_Syntax.MLE_Name (([], (FStar_Extraction_ML_Syntax.idsym mlid)))))
in (let _166_488 = (let _166_487 = (let _166_483 = (let _166_481 = (let _166_480 = (FStar_Extraction_ML_Syntax.mlpath_of_lident constrName)
in (_166_480, (FStar_Extraction_ML_Syntax.MLP_Wild)::[]))
in FStar_Extraction_ML_Syntax.MLP_CTor (_166_481))
in (let _166_482 = (FStar_All.pipe_left (FStar_Extraction_ML_Syntax.with_ty FStar_Extraction_ML_Syntax.ml_bool_ty) (FStar_Extraction_ML_Syntax.MLE_Const (FStar_Extraction_ML_Syntax.MLC_Bool (true))))
in (_166_483, None, _166_482)))
in (let _166_486 = (let _166_485 = (let _166_484 = (FStar_All.pipe_left (FStar_Extraction_ML_Syntax.with_ty FStar_Extraction_ML_Syntax.ml_bool_ty) (FStar_Extraction_ML_Syntax.MLE_Const (FStar_Extraction_ML_Syntax.MLC_Bool (false))))
in (FStar_Extraction_ML_Syntax.MLP_Wild, None, _166_484))
in (_166_485)::[])
in (_166_487)::_166_486))
in (_166_489, _166_488)))
in FStar_Extraction_ML_Syntax.MLE_Match (_166_490))
in (FStar_All.pipe_left (FStar_Extraction_ML_Syntax.with_ty FStar_Extraction_ML_Syntax.ml_bool_ty) _166_491))
in ((FStar_List.append wildcards (((mlid, targ))::[])), _166_492))
in FStar_Extraction_ML_Syntax.MLE_Fun (_166_493))
in (FStar_All.pipe_left (FStar_Extraction_ML_Syntax.with_ty disc_ty) _166_494))
in FStar_Extraction_ML_Syntax.MLM_Let ((false, ({FStar_Extraction_ML_Syntax.mllb_name = (FStar_Extraction_ML_UEnv.convIdent discName.FStar_Ident.ident); FStar_Extraction_ML_Syntax.mllb_tysc = None; FStar_Extraction_ML_Syntax.mllb_add_unit = false; FStar_Extraction_ML_Syntax.mllb_def = discrBody; FStar_Extraction_ML_Syntax.print_typ = false})::[])))))))
end)))




