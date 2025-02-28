Require Import Coq.Logic.Classical.
Require Import Coq.Lists.List.
Require Import Coq.Sets.Ensembles.
Require Import Coq.ZArith.ZArith.
Require Import Coq.micromega.Lia.
Require Import VST.msl.seplog.
Require Import VST.msl.log_normalize.
Require Import VST.zlist.sublist.
Require Import compcert.lib.Integers.
Require Import CertiGraph.lib.Coqlib.
Require Import CertiGraph.lib.Ensembles_ext.
Require Import CertiGraph.lib.EquivDec_ext.
Require Import CertiGraph.lib.Relation_ext.
Require Import CertiGraph.lib.List_ext.
Require Import CertiGraph.graph.graph_model.
Require Import CertiGraph.graph.weak_mark_lemmas.
Require Import CertiGraph.graph.path_lemmas.
Require Import CertiGraph.graph.graph_gen.
Require Import CertiGraph.graph.graph_relation.
Require Import CertiGraph.graph.subgraph2.
Require Import CertiGraph.graph.reachable_computable.
Require Export CertiGraph.graph.FiniteGraph.
Require Export CertiGraph.graph.MathGraph.
Require Export CertiGraph.graph.LstGraph.
Require Export CertiGraph.msl_application.UnionFindGraph.

Local Open Scope logic.
Local Open Scope Z_scope.

#[export] Instance Z_EqDec : EqDec Z eq := Z.eq_dec.

Definition is_null_Z: DecidablePred Z := existT (fun P : Z -> Prop => forall a : Z, {P a} + {~ P a}) (fun x : Z => x < 0) (fun a : Z => Z_lt_dec a 0).

Definition UFGraph := (@UFGraph Z Z _ _ is_null_Z id nat unit unit).
Definition LGraph := (@LGraph Z Z _ _ nat unit unit).
Definition UFGraph_LGraph (G: UFGraph): LGraph := lg_gg G.

Local Coercion UFGraph_LGraph: UFGraph >-> LGraph.
Local Identity Coercion ULGraph_LGraph: LGraph >-> UnionFindGraph.LGraph.
Local Identity Coercion LGraph_LabeledGraph: UnionFindGraph.LGraph >-> LabeledGraph.
Local Coercion pg_lg: LabeledGraph >-> PreGraph.

#[export] Instance maGraph(G: UFGraph): MathGraph G is_null_Z := maGraph G.
#[export] Instance finGraph (G: UFGraph): FiniteGraph G := finGraph G.
#[export] Instance liGraph (G: UFGraph):  LstGraph G id := liGraph G.

Definition vgamma := (@vgamma Z Z _ _ is_null_Z id nat unit unit).
Definition Graph_gen_redirect_parent (g: UFGraph) (x: Z) (pa: Z) (H: weak_valid g pa) (Hv: vvalid g x) (Hn: ~ reachable g pa x): UFGraph :=
    Graph_gen_redirect_parent g x pa H Hv Hn.

Class SpatialArrayGraphAssum (Pred : Type):=
  {
    SGP_ND: NatDed Pred;
    SGP_SL : SepLog Pred;
    SGP_ClSL: ClassicalSep Pred;
    SGP_CoSL: CorableSepLog Pred
  }.

Fixpoint makeSet_discrete_PreGraph (size: nat) : PreGraph Z Z :=
  match size with
  | O => Build_PreGraph Z_EqDec Z_EqDec (fun _ => False) (fun _ => False) (fun _ => -1) (fun _ => -1)
  | S n => pregraph_add_edge (pregraph_add_vertex (makeSet_discrete_PreGraph n) (Z.of_nat n)) (Z.of_nat n) (Z.of_nat n) (-1)
  end.

Lemma makeSet_vvalid: forall size x, vvalid (makeSet_discrete_PreGraph size) x <-> 0 <= x < Z.of_nat size.
Proof.
  induction size; simpl; intros; split; intros.
  - exfalso; auto.
  - destruct H. intuition.
  - unfold addValidFunc in H. rewrite Zpos_P_of_succ_nat, <- Z.add_1_r. destruct H; [rewrite IHsize in H|]; intuition.
  - unfold addValidFunc. rewrite Zpos_P_of_succ_nat, <- Z.add_1_r in H. rewrite IHsize. lia.
Qed.

Lemma makeSet_evalid: forall size e, evalid (makeSet_discrete_PreGraph size) e <-> 0 <= e < Z.of_nat size.
Proof.
  induction size; simpl; intros; split; intros.
  - exfalso. auto.
  - destruct H; intuition.
  - unfold addValidFunc in H. rewrite Zpos_P_of_succ_nat, <- Z.add_1_r. destruct H; [apply IHsize in H | subst e]; intuition.
  - unfold addValidFunc. rewrite Zpos_P_of_succ_nat, <- Z.add_1_r in H. rewrite IHsize. lia.
Qed.

Lemma makeSet_evalid_src: forall size e, evalid (makeSet_discrete_PreGraph size) e -> src (makeSet_discrete_PreGraph size) e = e.
Proof.
  induction size; simpl; intros.
  - exfalso; auto.
  - unfold addValidFunc in H. unfold updateEdgeFunc. destruct (equiv_dec (Z.of_nat size) e).
    + unfold Equivalence.equiv in e0. auto.
    + unfold Equivalence.equiv in c. unfold complement in c. destruct H. 1: apply IHsize; auto. exfalso; intuition.
Qed.

Lemma makeSet_dst: forall size e, dst (makeSet_discrete_PreGraph size) e = -1.
Proof. induction size; simpl; intros; auto. unfold updateEdgeFunc. destruct (equiv_dec (Z.of_nat size) e); auto. Qed.

Definition makeSet_discrete_MathGraph (size: nat) : MathGraph (makeSet_discrete_PreGraph size) is_null_Z.
Proof.
  constructor; intros; [split|].
  - rewrite (makeSet_evalid_src _ _ H). rewrite makeSet_evalid in H. rewrite makeSet_vvalid. auto.
  - left. rewrite makeSet_dst. hnf. rewrite Z.compare_lt_iff. intuition.
  - rewrite makeSet_vvalid in H. hnf in H0. rewrite Z.compare_lt_iff in H0. intuition.
Qed.

Definition makeSet_discrete_LstGraph (size: nat) : LstGraph (makeSet_discrete_PreGraph size) id.
Proof.
  constructor; intros.
  - unfold id. split; intros.
    + destruct H0. apply makeSet_evalid_src in H1. intuition.
    + subst e. split.
      * rewrite makeSet_vvalid, <- makeSet_evalid in H. apply makeSet_evalid_src; auto.
      * rewrite makeSet_vvalid in H. rewrite makeSet_evalid. auto.
  - destruct p as [v p]. destruct H as [[? ?] [? ?]]. simpl in H. subst v. clear H2. destruct p; auto. simpl in H1. destruct H1.
    assert (strong_evalid (makeSet_discrete_PreGraph size) z) by (destruct p; [|destruct H1]; auto). clear H1. destruct H2 as [_ [_ ?]].
    rewrite makeSet_dst in H1. rewrite makeSet_vvalid in H1. exfalso; intuition.
Qed.

Fixpoint makeSet_discrete_list (size: nat) :=
  match size with
  | O => nil
  | S n => Z.of_nat n :: makeSet_discrete_list n
  end.

Lemma makeSet_discrete_list_iff: forall size x, List.In x (makeSet_discrete_list size) <-> 0 <= x < Z.of_nat size.
Proof.
  induction size; intros; simpl; split; intros.
  - exfalso; auto.
  - destruct H; intuition.
  - rewrite Zpos_P_of_succ_nat, <- Z.add_1_r. rewrite IHsize in H. intuition.
  - rewrite Zpos_P_of_succ_nat, <- Z.add_1_r in H. rewrite IHsize. lia.
Qed.

Lemma makeSet_discrete_list_NoDup: forall size, NoDup (makeSet_discrete_list size).
Proof. induction size; simpl; constructor; auto; intro. rewrite makeSet_discrete_list_iff in H. intuition. Qed.

Definition makeSet_discrete_FiniteGraph (size: nat) : FiniteGraph (makeSet_discrete_PreGraph size).
Proof.
  constructor; unfold EnumEnsembles.Enumerable, In; exists (makeSet_discrete_list size); split; intros.
  - apply makeSet_discrete_list_NoDup.
  - rewrite makeSet_discrete_list_iff, makeSet_vvalid. intuition.
  - apply makeSet_discrete_list_NoDup.
  - rewrite makeSet_discrete_list_iff, makeSet_evalid. intuition.
Qed.

Definition makeSet_discrete_sound (size: nat) : @LiMaFin _ _ _ _ is_null_Z id (makeSet_discrete_PreGraph size).
Proof. constructor. exact (makeSet_discrete_LstGraph size). exact (makeSet_discrete_MathGraph size). exact (makeSet_discrete_FiniteGraph size). Qed.

Definition makeSet_discrete_LabeledGraph (size: nat) : LGraph := Build_LabeledGraph _ _ _ (makeSet_discrete_PreGraph size) (fun _ => O) (fun _ => tt) tt.

Definition makeSet_discrete_Graph (size: nat) : UFGraph := Build_GeneralGraph _ _ _ _ (makeSet_discrete_LabeledGraph size) (makeSet_discrete_sound size).

Corollary makeSet_discrete_Graph_dst:
  forall size e, dst (makeSet_discrete_Graph size) e = -1.
Proof.
apply makeSet_dst.
Qed.

Class SpatialArrayGraph (Addr: Type) (Pred: Type) := vcell_array_at: Addr -> list (nat * Z) -> Pred.

#[local] Existing Instances SGP_ND SGP_SL SGP_ClSL SGP_CoSL.

Section SpaceArrayGraph.

  Context {Pred: Type}.

  Context {SAGP: SpatialArrayGraphAssum Pred}.

  Context {Addr: Type}.

  Context {SAG: SpatialArrayGraph Addr Pred}.

  Definition graph_vcell_at (g: UFGraph) (P: Z -> Prop) (x: Addr) :=
    EX l: list Z, !!(forall v, List.In v l <-> P v) && !! NoDup l && vcell_array_at x (map (fun x => vgamma (lg_gg g) x) l).

  Definition full_graph_at (g: UFGraph) (x: Addr) :=
    EX n: nat, !!(forall v, 0 <= v < Z.of_nat n <-> vvalid (pg_lg (lg_gg g)) v) && !!(Z.of_nat n <= Int.max_signed / 8) && vcell_array_at x (map (fun x => vgamma (lg_gg g) x) (nat_inc_list n)).

End SpaceArrayGraph.
