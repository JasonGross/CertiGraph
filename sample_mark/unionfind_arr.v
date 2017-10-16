
Require Import Clightdefs.
Local Open Scope Z_scope.
Definition _Union : ident := 61%positive.
Definition _V : ident := 62%positive.
Definition ___builtin_annot : ident := 6%positive.
Definition ___builtin_annot_intval : ident := 7%positive.
Definition ___builtin_bswap : ident := 30%positive.
Definition ___builtin_bswap16 : ident := 32%positive.
Definition ___builtin_bswap32 : ident := 31%positive.
Definition ___builtin_clz : ident := 33%positive.
Definition ___builtin_clzl : ident := 34%positive.
Definition ___builtin_clzll : ident := 35%positive.
Definition ___builtin_ctz : ident := 36%positive.
Definition ___builtin_ctzl : ident := 37%positive.
Definition ___builtin_ctzll : ident := 38%positive.
Definition ___builtin_debug : ident := 51%positive.
Definition ___builtin_fabs : ident := 4%positive.
Definition ___builtin_fmadd : ident := 42%positive.
Definition ___builtin_fmax : ident := 40%positive.
Definition ___builtin_fmin : ident := 41%positive.
Definition ___builtin_fmsub : ident := 43%positive.
Definition ___builtin_fnmadd : ident := 44%positive.
Definition ___builtin_fnmsub : ident := 45%positive.
Definition ___builtin_fsqrt : ident := 39%positive.
Definition ___builtin_membar : ident := 8%positive.
Definition ___builtin_memcpy_aligned : ident := 5%positive.
Definition ___builtin_nop : ident := 50%positive.
Definition ___builtin_read16_reversed : ident := 46%positive.
Definition ___builtin_read32_reversed : ident := 47%positive.
Definition ___builtin_va_arg : ident := 10%positive.
Definition ___builtin_va_copy : ident := 11%positive.
Definition ___builtin_va_end : ident := 12%positive.
Definition ___builtin_va_start : ident := 9%positive.
Definition ___builtin_write16_reversed : ident := 48%positive.
Definition ___builtin_write32_reversed : ident := 49%positive.
Definition ___compcert_va_composite : ident := 16%positive.
Definition ___compcert_va_float64 : ident := 15%positive.
Definition ___compcert_va_int32 : ident := 13%positive.
Definition ___compcert_va_int64 : ident := 14%positive.
Definition ___i64_dtos : ident := 17%positive.
Definition ___i64_dtou : ident := 18%positive.
Definition ___i64_sar : ident := 29%positive.
Definition ___i64_sdiv : ident := 23%positive.
Definition ___i64_shl : ident := 27%positive.
Definition ___i64_shr : ident := 28%positive.
Definition ___i64_smod : ident := 25%positive.
Definition ___i64_stod : ident := 19%positive.
Definition ___i64_stof : ident := 21%positive.
Definition ___i64_udiv : ident := 24%positive.
Definition ___i64_umod : ident := 26%positive.
Definition ___i64_utod : ident := 20%positive.
Definition ___i64_utof : ident := 22%positive.
Definition _find : ident := 56%positive.
Definition _i : ident := 54%positive.
Definition _main : ident := 65%positive.
Definition _makeSet : ident := 64%positive.
Definition _mallocN : ident := 52%positive.
Definition _p : ident := 55%positive.
Definition _parent : ident := 1%positive.
Definition _rank : ident := 2%positive.
Definition _subset : ident := 3%positive.
Definition _subsets : ident := 53%positive.
Definition _v : ident := 63%positive.
Definition _x : ident := 57%positive.
Definition _xroot : ident := 59%positive.
Definition _y : ident := 58%positive.
Definition _yroot : ident := 60%positive.
Definition _t'1 : ident := 66%positive.
Definition _t'2 : ident := 67%positive.

Definition f_find := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_subsets, (tptr (Tstruct _subset noattr))) :: (_i, tint) ::
                nil);
  fn_vars := nil;
  fn_temps := ((_p, tint) :: (_t'1, tint) :: nil);
  fn_body :=
(Ssequence
  (Sset _p
    (Efield
      (Ederef
        (Ebinop Oadd (Etempvar _subsets (tptr (Tstruct _subset noattr)))
          (Etempvar _i tint) (tptr (Tstruct _subset noattr)))
        (Tstruct _subset noattr)) _parent tint))
  (Ssequence
    (Sifthenelse (Ebinop One (Etempvar _p tint) (Etempvar _i tint) tint)
      (Ssequence
        (Scall (Some _t'1)
          (Evar _find (Tfunction
                        (Tcons (tptr (Tstruct _subset noattr))
                          (Tcons tint Tnil)) tint cc_default))
          ((Etempvar _subsets (tptr (Tstruct _subset noattr))) ::
           (Etempvar _p tint) :: nil))
        (Sassign
          (Efield
            (Ederef
              (Ebinop Oadd
                (Etempvar _subsets (tptr (Tstruct _subset noattr)))
                (Etempvar _i tint) (tptr (Tstruct _subset noattr)))
              (Tstruct _subset noattr)) _parent tint) (Etempvar _t'1 tint)))
      Sskip)
    (Sreturn (Some (Efield
                     (Ederef
                       (Ebinop Oadd
                         (Etempvar _subsets (tptr (Tstruct _subset noattr)))
                         (Etempvar _i tint) (tptr (Tstruct _subset noattr)))
                       (Tstruct _subset noattr)) _parent tint)))))
|}.

Definition f_Union := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_subsets, (tptr (Tstruct _subset noattr))) :: (_x, tint) ::
                (_y, tint) :: nil);
  fn_vars := nil;
  fn_temps := ((_xroot, tint) :: (_yroot, tint) :: (_t'2, tint) ::
               (_t'1, tint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Scall (Some _t'1)
      (Evar _find (Tfunction
                    (Tcons (tptr (Tstruct _subset noattr)) (Tcons tint Tnil))
                    tint cc_default))
      ((Etempvar _subsets (tptr (Tstruct _subset noattr))) ::
       (Etempvar _x tint) :: nil))
    (Sset _xroot (Etempvar _t'1 tint)))
  (Ssequence
    (Ssequence
      (Scall (Some _t'2)
        (Evar _find (Tfunction
                      (Tcons (tptr (Tstruct _subset noattr))
                        (Tcons tint Tnil)) tint cc_default))
        ((Etempvar _subsets (tptr (Tstruct _subset noattr))) ::
         (Etempvar _y tint) :: nil))
      (Sset _yroot (Etempvar _t'2 tint)))
    (Sifthenelse (Ebinop Olt
                   (Efield
                     (Ederef
                       (Ebinop Oadd
                         (Etempvar _subsets (tptr (Tstruct _subset noattr)))
                         (Etempvar _xroot tint)
                         (tptr (Tstruct _subset noattr)))
                       (Tstruct _subset noattr)) _rank tint)
                   (Efield
                     (Ederef
                       (Ebinop Oadd
                         (Etempvar _subsets (tptr (Tstruct _subset noattr)))
                         (Etempvar _yroot tint)
                         (tptr (Tstruct _subset noattr)))
                       (Tstruct _subset noattr)) _rank tint) tint)
      (Sassign
        (Efield
          (Ederef
            (Ebinop Oadd (Etempvar _subsets (tptr (Tstruct _subset noattr)))
              (Etempvar _xroot tint) (tptr (Tstruct _subset noattr)))
            (Tstruct _subset noattr)) _parent tint) (Etempvar _yroot tint))
      (Sifthenelse (Ebinop Ogt
                     (Efield
                       (Ederef
                         (Ebinop Oadd
                           (Etempvar _subsets (tptr (Tstruct _subset noattr)))
                           (Etempvar _xroot tint)
                           (tptr (Tstruct _subset noattr)))
                         (Tstruct _subset noattr)) _rank tint)
                     (Efield
                       (Ederef
                         (Ebinop Oadd
                           (Etempvar _subsets (tptr (Tstruct _subset noattr)))
                           (Etempvar _yroot tint)
                           (tptr (Tstruct _subset noattr)))
                         (Tstruct _subset noattr)) _rank tint) tint)
        (Sassign
          (Efield
            (Ederef
              (Ebinop Oadd
                (Etempvar _subsets (tptr (Tstruct _subset noattr)))
                (Etempvar _yroot tint) (tptr (Tstruct _subset noattr)))
              (Tstruct _subset noattr)) _parent tint) (Etempvar _xroot tint))
        (Ssequence
          (Sassign
            (Efield
              (Ederef
                (Ebinop Oadd
                  (Etempvar _subsets (tptr (Tstruct _subset noattr)))
                  (Etempvar _yroot tint) (tptr (Tstruct _subset noattr)))
                (Tstruct _subset noattr)) _parent tint)
            (Etempvar _xroot tint))
          (Sassign
            (Efield
              (Ederef
                (Ebinop Oadd
                  (Etempvar _subsets (tptr (Tstruct _subset noattr)))
                  (Etempvar _xroot tint) (tptr (Tstruct _subset noattr)))
                (Tstruct _subset noattr)) _rank tint)
            (Ebinop Oadd
              (Efield
                (Ederef
                  (Ebinop Oadd
                    (Etempvar _subsets (tptr (Tstruct _subset noattr)))
                    (Etempvar _xroot tint) (tptr (Tstruct _subset noattr)))
                  (Tstruct _subset noattr)) _rank tint)
              (Econst_int (Int.repr 1) tint) tint)))))))
|}.

Definition f_makeSet := {|
  fn_return := (tptr (Tstruct _subset noattr));
  fn_callconv := cc_default;
  fn_params := ((_V, tint) :: nil);
  fn_vars := nil;
  fn_temps := ((_subsets, (tptr (Tstruct _subset noattr))) :: (_v, tint) ::
               (_t'1, (tptr tvoid)) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Scall (Some _t'1)
      (Evar _mallocN (Tfunction (Tcons tint Tnil) (tptr tvoid) cc_default))
      ((Ebinop Omul (Etempvar _V tint)
         (Esizeof (Tstruct _subset noattr) tuint) tuint) :: nil))
    (Sset _subsets
      (Ecast (Etempvar _t'1 (tptr tvoid)) (tptr (Tstruct _subset noattr)))))
  (Ssequence
    (Ssequence
      (Sset _v (Econst_int (Int.repr 0) tint))
      (Sloop
        (Ssequence
          (Sifthenelse (Ebinop Olt (Etempvar _v tint) (Etempvar _V tint)
                         tint)
            Sskip
            Sbreak)
          (Ssequence
            (Sassign
              (Efield
                (Ederef
                  (Ebinop Oadd
                    (Etempvar _subsets (tptr (Tstruct _subset noattr)))
                    (Etempvar _v tint) (tptr (Tstruct _subset noattr)))
                  (Tstruct _subset noattr)) _parent tint) (Etempvar _v tint))
            (Sassign
              (Efield
                (Ederef
                  (Ebinop Oadd
                    (Etempvar _subsets (tptr (Tstruct _subset noattr)))
                    (Etempvar _v tint) (tptr (Tstruct _subset noattr)))
                  (Tstruct _subset noattr)) _rank tint)
              (Econst_int (Int.repr 0) tint))))
        (Sset _v
          (Ebinop Oadd (Etempvar _v tint) (Econst_int (Int.repr 1) tint)
            tint))))
    (Sreturn (Some (Etempvar _subsets (tptr (Tstruct _subset noattr)))))))
|}.

Definition composites : list composite_definition :=
(Composite _subset Struct ((_parent, tint) :: (_rank, tint) :: nil) noattr ::
 nil).

Definition prog : Clight.program := {|
prog_defs :=
((___builtin_fabs,
   Gfun(External (EF_builtin "__builtin_fabs"
                   (mksignature (AST.Tfloat :: nil) (Some AST.Tfloat)
                     cc_default)) (Tcons tdouble Tnil) tdouble cc_default)) ::
 (___builtin_memcpy_aligned,
   Gfun(External (EF_builtin "__builtin_memcpy_aligned"
                   (mksignature
                     (AST.Tint :: AST.Tint :: AST.Tint :: AST.Tint :: nil)
                     None cc_default))
     (Tcons (tptr tvoid)
       (Tcons (tptr tvoid) (Tcons tuint (Tcons tuint Tnil)))) tvoid
     cc_default)) ::
 (___builtin_annot,
   Gfun(External (EF_builtin "__builtin_annot"
                   (mksignature (AST.Tint :: nil) None
                     {|cc_vararg:=true; cc_unproto:=false; cc_structret:=false|}))
     (Tcons (tptr tschar) Tnil) tvoid
     {|cc_vararg:=true; cc_unproto:=false; cc_structret:=false|})) ::
 (___builtin_annot_intval,
   Gfun(External (EF_builtin "__builtin_annot_intval"
                   (mksignature (AST.Tint :: AST.Tint :: nil) (Some AST.Tint)
                     cc_default)) (Tcons (tptr tschar) (Tcons tint Tnil))
     tint cc_default)) ::
 (___builtin_membar,
   Gfun(External (EF_builtin "__builtin_membar"
                   (mksignature nil None cc_default)) Tnil tvoid cc_default)) ::
 (___builtin_va_start,
   Gfun(External (EF_builtin "__builtin_va_start"
                   (mksignature (AST.Tint :: nil) None cc_default))
     (Tcons (tptr tvoid) Tnil) tvoid cc_default)) ::
 (___builtin_va_arg,
   Gfun(External (EF_builtin "__builtin_va_arg"
                   (mksignature (AST.Tint :: AST.Tint :: nil) None
                     cc_default)) (Tcons (tptr tvoid) (Tcons tuint Tnil))
     tvoid cc_default)) ::
 (___builtin_va_copy,
   Gfun(External (EF_builtin "__builtin_va_copy"
                   (mksignature (AST.Tint :: AST.Tint :: nil) None
                     cc_default))
     (Tcons (tptr tvoid) (Tcons (tptr tvoid) Tnil)) tvoid cc_default)) ::
 (___builtin_va_end,
   Gfun(External (EF_builtin "__builtin_va_end"
                   (mksignature (AST.Tint :: nil) None cc_default))
     (Tcons (tptr tvoid) Tnil) tvoid cc_default)) ::
 (___compcert_va_int32,
   Gfun(External (EF_external "__compcert_va_int32"
                   (mksignature (AST.Tint :: nil) (Some AST.Tint) cc_default))
     (Tcons (tptr tvoid) Tnil) tuint cc_default)) ::
 (___compcert_va_int64,
   Gfun(External (EF_external "__compcert_va_int64"
                   (mksignature (AST.Tint :: nil) (Some AST.Tlong)
                     cc_default)) (Tcons (tptr tvoid) Tnil) tulong
     cc_default)) ::
 (___compcert_va_float64,
   Gfun(External (EF_external "__compcert_va_float64"
                   (mksignature (AST.Tint :: nil) (Some AST.Tfloat)
                     cc_default)) (Tcons (tptr tvoid) Tnil) tdouble
     cc_default)) ::
 (___compcert_va_composite,
   Gfun(External (EF_external "__compcert_va_composite"
                   (mksignature (AST.Tint :: AST.Tint :: nil) (Some AST.Tint)
                     cc_default)) (Tcons (tptr tvoid) (Tcons tuint Tnil))
     (tptr tvoid) cc_default)) ::
 (___i64_dtos,
   Gfun(External (EF_runtime "__i64_dtos"
                   (mksignature (AST.Tfloat :: nil) (Some AST.Tlong)
                     cc_default)) (Tcons tdouble Tnil) tlong cc_default)) ::
 (___i64_dtou,
   Gfun(External (EF_runtime "__i64_dtou"
                   (mksignature (AST.Tfloat :: nil) (Some AST.Tlong)
                     cc_default)) (Tcons tdouble Tnil) tulong cc_default)) ::
 (___i64_stod,
   Gfun(External (EF_runtime "__i64_stod"
                   (mksignature (AST.Tlong :: nil) (Some AST.Tfloat)
                     cc_default)) (Tcons tlong Tnil) tdouble cc_default)) ::
 (___i64_utod,
   Gfun(External (EF_runtime "__i64_utod"
                   (mksignature (AST.Tlong :: nil) (Some AST.Tfloat)
                     cc_default)) (Tcons tulong Tnil) tdouble cc_default)) ::
 (___i64_stof,
   Gfun(External (EF_runtime "__i64_stof"
                   (mksignature (AST.Tlong :: nil) (Some AST.Tsingle)
                     cc_default)) (Tcons tlong Tnil) tfloat cc_default)) ::
 (___i64_utof,
   Gfun(External (EF_runtime "__i64_utof"
                   (mksignature (AST.Tlong :: nil) (Some AST.Tsingle)
                     cc_default)) (Tcons tulong Tnil) tfloat cc_default)) ::
 (___i64_sdiv,
   Gfun(External (EF_runtime "__i64_sdiv"
                   (mksignature (AST.Tlong :: AST.Tlong :: nil)
                     (Some AST.Tlong) cc_default))
     (Tcons tlong (Tcons tlong Tnil)) tlong cc_default)) ::
 (___i64_udiv,
   Gfun(External (EF_runtime "__i64_udiv"
                   (mksignature (AST.Tlong :: AST.Tlong :: nil)
                     (Some AST.Tlong) cc_default))
     (Tcons tulong (Tcons tulong Tnil)) tulong cc_default)) ::
 (___i64_smod,
   Gfun(External (EF_runtime "__i64_smod"
                   (mksignature (AST.Tlong :: AST.Tlong :: nil)
                     (Some AST.Tlong) cc_default))
     (Tcons tlong (Tcons tlong Tnil)) tlong cc_default)) ::
 (___i64_umod,
   Gfun(External (EF_runtime "__i64_umod"
                   (mksignature (AST.Tlong :: AST.Tlong :: nil)
                     (Some AST.Tlong) cc_default))
     (Tcons tulong (Tcons tulong Tnil)) tulong cc_default)) ::
 (___i64_shl,
   Gfun(External (EF_runtime "__i64_shl"
                   (mksignature (AST.Tlong :: AST.Tint :: nil)
                     (Some AST.Tlong) cc_default))
     (Tcons tlong (Tcons tint Tnil)) tlong cc_default)) ::
 (___i64_shr,
   Gfun(External (EF_runtime "__i64_shr"
                   (mksignature (AST.Tlong :: AST.Tint :: nil)
                     (Some AST.Tlong) cc_default))
     (Tcons tulong (Tcons tint Tnil)) tulong cc_default)) ::
 (___i64_sar,
   Gfun(External (EF_runtime "__i64_sar"
                   (mksignature (AST.Tlong :: AST.Tint :: nil)
                     (Some AST.Tlong) cc_default))
     (Tcons tlong (Tcons tint Tnil)) tlong cc_default)) ::
 (___builtin_bswap,
   Gfun(External (EF_builtin "__builtin_bswap"
                   (mksignature (AST.Tint :: nil) (Some AST.Tint) cc_default))
     (Tcons tuint Tnil) tuint cc_default)) ::
 (___builtin_bswap32,
   Gfun(External (EF_builtin "__builtin_bswap32"
                   (mksignature (AST.Tint :: nil) (Some AST.Tint) cc_default))
     (Tcons tuint Tnil) tuint cc_default)) ::
 (___builtin_bswap16,
   Gfun(External (EF_builtin "__builtin_bswap16"
                   (mksignature (AST.Tint :: nil) (Some AST.Tint) cc_default))
     (Tcons tushort Tnil) tushort cc_default)) ::
 (___builtin_clz,
   Gfun(External (EF_builtin "__builtin_clz"
                   (mksignature (AST.Tint :: nil) (Some AST.Tint) cc_default))
     (Tcons tuint Tnil) tint cc_default)) ::
 (___builtin_clzl,
   Gfun(External (EF_builtin "__builtin_clzl"
                   (mksignature (AST.Tint :: nil) (Some AST.Tint) cc_default))
     (Tcons tuint Tnil) tint cc_default)) ::
 (___builtin_clzll,
   Gfun(External (EF_builtin "__builtin_clzll"
                   (mksignature (AST.Tlong :: nil) (Some AST.Tint)
                     cc_default)) (Tcons tulong Tnil) tint cc_default)) ::
 (___builtin_ctz,
   Gfun(External (EF_builtin "__builtin_ctz"
                   (mksignature (AST.Tint :: nil) (Some AST.Tint) cc_default))
     (Tcons tuint Tnil) tint cc_default)) ::
 (___builtin_ctzl,
   Gfun(External (EF_builtin "__builtin_ctzl"
                   (mksignature (AST.Tint :: nil) (Some AST.Tint) cc_default))
     (Tcons tuint Tnil) tint cc_default)) ::
 (___builtin_ctzll,
   Gfun(External (EF_builtin "__builtin_ctzll"
                   (mksignature (AST.Tlong :: nil) (Some AST.Tint)
                     cc_default)) (Tcons tulong Tnil) tint cc_default)) ::
 (___builtin_fsqrt,
   Gfun(External (EF_builtin "__builtin_fsqrt"
                   (mksignature (AST.Tfloat :: nil) (Some AST.Tfloat)
                     cc_default)) (Tcons tdouble Tnil) tdouble cc_default)) ::
 (___builtin_fmax,
   Gfun(External (EF_builtin "__builtin_fmax"
                   (mksignature (AST.Tfloat :: AST.Tfloat :: nil)
                     (Some AST.Tfloat) cc_default))
     (Tcons tdouble (Tcons tdouble Tnil)) tdouble cc_default)) ::
 (___builtin_fmin,
   Gfun(External (EF_builtin "__builtin_fmin"
                   (mksignature (AST.Tfloat :: AST.Tfloat :: nil)
                     (Some AST.Tfloat) cc_default))
     (Tcons tdouble (Tcons tdouble Tnil)) tdouble cc_default)) ::
 (___builtin_fmadd,
   Gfun(External (EF_builtin "__builtin_fmadd"
                   (mksignature
                     (AST.Tfloat :: AST.Tfloat :: AST.Tfloat :: nil)
                     (Some AST.Tfloat) cc_default))
     (Tcons tdouble (Tcons tdouble (Tcons tdouble Tnil))) tdouble
     cc_default)) ::
 (___builtin_fmsub,
   Gfun(External (EF_builtin "__builtin_fmsub"
                   (mksignature
                     (AST.Tfloat :: AST.Tfloat :: AST.Tfloat :: nil)
                     (Some AST.Tfloat) cc_default))
     (Tcons tdouble (Tcons tdouble (Tcons tdouble Tnil))) tdouble
     cc_default)) ::
 (___builtin_fnmadd,
   Gfun(External (EF_builtin "__builtin_fnmadd"
                   (mksignature
                     (AST.Tfloat :: AST.Tfloat :: AST.Tfloat :: nil)
                     (Some AST.Tfloat) cc_default))
     (Tcons tdouble (Tcons tdouble (Tcons tdouble Tnil))) tdouble
     cc_default)) ::
 (___builtin_fnmsub,
   Gfun(External (EF_builtin "__builtin_fnmsub"
                   (mksignature
                     (AST.Tfloat :: AST.Tfloat :: AST.Tfloat :: nil)
                     (Some AST.Tfloat) cc_default))
     (Tcons tdouble (Tcons tdouble (Tcons tdouble Tnil))) tdouble
     cc_default)) ::
 (___builtin_read16_reversed,
   Gfun(External (EF_builtin "__builtin_read16_reversed"
                   (mksignature (AST.Tint :: nil) (Some AST.Tint) cc_default))
     (Tcons (tptr tushort) Tnil) tushort cc_default)) ::
 (___builtin_read32_reversed,
   Gfun(External (EF_builtin "__builtin_read32_reversed"
                   (mksignature (AST.Tint :: nil) (Some AST.Tint) cc_default))
     (Tcons (tptr tuint) Tnil) tuint cc_default)) ::
 (___builtin_write16_reversed,
   Gfun(External (EF_builtin "__builtin_write16_reversed"
                   (mksignature (AST.Tint :: AST.Tint :: nil) None
                     cc_default)) (Tcons (tptr tushort) (Tcons tushort Tnil))
     tvoid cc_default)) ::
 (___builtin_write32_reversed,
   Gfun(External (EF_builtin "__builtin_write32_reversed"
                   (mksignature (AST.Tint :: AST.Tint :: nil) None
                     cc_default)) (Tcons (tptr tuint) (Tcons tuint Tnil))
     tvoid cc_default)) ::
 (___builtin_nop,
   Gfun(External (EF_builtin "__builtin_nop"
                   (mksignature nil None cc_default)) Tnil tvoid cc_default)) ::
 (___builtin_debug,
   Gfun(External (EF_external "__builtin_debug"
                   (mksignature (AST.Tint :: nil) None
                     {|cc_vararg:=true; cc_unproto:=false; cc_structret:=false|}))
     (Tcons tint Tnil) tvoid
     {|cc_vararg:=true; cc_unproto:=false; cc_structret:=false|})) ::
 (_mallocN,
   Gfun(External (EF_external "mallocN"
                   (mksignature (AST.Tint :: nil) (Some AST.Tint) cc_default))
     (Tcons tint Tnil) (tptr tvoid) cc_default)) ::
 (_find, Gfun(Internal f_find)) :: (_Union, Gfun(Internal f_Union)) ::
 (_makeSet, Gfun(Internal f_makeSet)) :: nil);
prog_public :=
(_makeSet :: _Union :: _find :: _mallocN :: ___builtin_debug ::
 ___builtin_nop :: ___builtin_write32_reversed ::
 ___builtin_write16_reversed :: ___builtin_read32_reversed ::
 ___builtin_read16_reversed :: ___builtin_fnmsub :: ___builtin_fnmadd ::
 ___builtin_fmsub :: ___builtin_fmadd :: ___builtin_fmin ::
 ___builtin_fmax :: ___builtin_fsqrt :: ___builtin_ctzll ::
 ___builtin_ctzl :: ___builtin_ctz :: ___builtin_clzll :: ___builtin_clzl ::
 ___builtin_clz :: ___builtin_bswap16 :: ___builtin_bswap32 ::
 ___builtin_bswap :: ___i64_sar :: ___i64_shr :: ___i64_shl :: ___i64_umod ::
 ___i64_smod :: ___i64_udiv :: ___i64_sdiv :: ___i64_utof :: ___i64_stof ::
 ___i64_utod :: ___i64_stod :: ___i64_dtou :: ___i64_dtos ::
 ___compcert_va_composite :: ___compcert_va_float64 ::
 ___compcert_va_int64 :: ___compcert_va_int32 :: ___builtin_va_end ::
 ___builtin_va_copy :: ___builtin_va_arg :: ___builtin_va_start ::
 ___builtin_membar :: ___builtin_annot_intval :: ___builtin_annot ::
 ___builtin_memcpy_aligned :: ___builtin_fabs :: nil);
prog_main := _main;
prog_types := composites;
prog_comp_env := make_composite_env composites;
prog_comp_env_eq := refl_equal _
|}.

