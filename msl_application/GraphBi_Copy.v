Require Import RamifyCoq.lib.Ensembles_ext.
Require Import Coq.Lists.List.
Require Import VST.msl.seplog.
Require Import VST.msl.log_normalize.
Require Import VST.msl.ramification_lemmas.
Require Import VST.msl.Coqlib2.
Require Import RamifyCoq.lib.Coqlib.
Require Import RamifyCoq.lib.EquivDec_ext.
Require Import RamifyCoq.lib.relation_list.
Require Import RamifyCoq.lib.Morphisms_ext.
Require Import RamifyCoq.msl_ext.abs_addr.
Require Import RamifyCoq.msl_ext.seplog.
Require Import RamifyCoq.msl_ext.log_normalize.
Require Import RamifyCoq.msl_ext.iter_sepcon.
Require Import RamifyCoq.graph.graph_model.
Require Import RamifyCoq.graph.path_lemmas.
Require Import RamifyCoq.graph.reachable_computable.
Require Import RamifyCoq.graph.reachable_ind.
Require Import RamifyCoq.graph.graph_gen.
Require Import RamifyCoq.graph.graph_relation.
Require Import RamifyCoq.graph.subgraph2.
Require Import RamifyCoq.graph.dag.
Require Import RamifyCoq.graph.weak_mark_lemmas.
Require Import RamifyCoq.graph.graph_morphism.
Require Import RamifyCoq.graph.local_graph_copy.
Require Import RamifyCoq.msl_application.Graph.
Require Import RamifyCoq.msl_application.GraphBi.
Require Import RamifyCoq.msl_application.Graph_Copy.
Require Import Coq.Logic.Classical.
Import RamifyCoq.msl_ext.seplog.OconNotation.

Open Scope logic.

Section SpatialGraph_Copy_Bi.

Context {pSGG_Bi: pSpatialGraph_Graph_Bi}.
Context {sSGG_Bi: sSpatialGraph_Graph_Bi addr (addr * LR)}.

Existing Instances pSGG_Bi sSGG_Bi.

Local Coercion Graph_LGraph: Graph >-> LGraph.
Local Coercion LGraph_SGraph: LGraph >-> SGraph.
Local Identity Coercion Graph_GeneralGraph: Graph >-> GeneralGraph.
Local Identity Coercion LGraph_LabeledGraph: LGraph >-> LabeledGraph.
Local Identity Coercion SGraph_SpatialGraph: SGraph >-> SpatialGraph.
Local Coercion pg_lg: LabeledGraph >-> PreGraph.

Notation Graph := (@Graph pSGG_Bi addr (addr * LR)).

Instance CCS: CompactCopySetting addr (addr * LR).
  apply (Build_CompactCopySetting _ _ null (null, L)).
Defined.

Global Existing Instance CCS.

Definition empty_Graph: Graph := empty_Graph null (null, L).

Definition initial_copied_Graph (x x0: addr) (g: Graph): LGraph := single_vertex_labeledgraph (LocalGraphCopy.vmap (Graph_vgen g x x0) x) null (null, L).

Opaque empty_Graph initial_copied_Graph.

Lemma copy_null_refl: forall (g: Graph),
  copy null g g empty_Graph.
Proof. intros; apply copy_invalid_refl, invalid_null; auto. Qed.

Lemma copy_vgamma_not_null_refl: forall (g: Graph) (root: addr) d l r,
  vgamma g root = (d, l, r) ->
  d <> null ->
  copy root g g empty_Graph.
Proof.
  intros; apply marked_root_copy_refl.
  simpl.
  inversion H.
  subst; congruence.
Qed.

Lemma vmap_weaken: forall (g1 g2: Graph) x x0 BLA,
  (x = null /\ x0 = null \/ x0 = BLA) ->
  (~ vvalid g1 x /\ ~ vvalid g2 x0 \/ x0 = BLA).
Proof.
  intros.
  destruct H; [left | right]; auto.
  destruct H.
  pose proof (@valid_not_null _ _ _ _ g1 _ (maGraph g1) x).
  pose proof (@valid_not_null _ _ _ _ g2 _ (maGraph g2) x0).
  unfold is_null_SGBA in *; simpl in *.
  auto.
Qed.

Lemma root_stable_ramify: forall (g: Graph) (x: addr) (gx: addr * addr * addr),
  vgamma g x = gx ->
  vvalid g x ->
  @derives pred _
    (reachable_vertices_at x g)
    (vertex_at x gx *
      (vertex_at x gx -* reachable_vertices_at x g)).
Proof. intros; apply va_reachable_root_stable_ramify; auto. Qed.

Lemma root_update_ramify: forall (g: Graph) (x x0: addr) (lx: addr) (gx gx': addr * addr * addr) F,
  vgamma g x = gx ->
  vgamma (Graph_vgen g x lx) x = gx' ->
  vvalid g x ->
  @derives pred _
    (F * reachable_vertices_at x g)
    (vertex_at x gx *
      (vertex_at x gx' -*
       F * (vertices_at (Intersection _ (vvalid (initial_copied_Graph x x0 g)) (fun u => x0 <> u)) (initial_copied_Graph x x0 g) * reachable_vertices_at x (Graph_vgen g x lx)))).
Proof.
  intros.
  rewrite !(sepcon_comm F).
  apply RAMIF_PLAIN.frame.
  assert (vertices_at (Intersection _ (vvalid (initial_copied_Graph x x0 g)) (fun u : addr => x0 <> u)) (initial_copied_Graph x x0 g) = emp).
  Focus 1. {
    erewrite <- vertices_at_False.
    apply vertices_at_Same_set.
    rewrite Same_set_spec; intros ?.
Transparent initial_copied_Graph. simpl. Opaque initial_copied_Graph.
    unfold update_vlabel.
    if_tac; [| congruence].
    split; [intros [? ?]; congruence | tauto].
  } Unfocus.
  rewrite H2, emp_sepcon.
  apply va_reachable_root_update_ramify; auto.
Qed.

Lemma not_null_copy1: forall (G: Graph) (x x0: addr) l r,
  vgamma G x = (null, l, r) ->
  vvalid G x ->
  x0 <> null ->
  vcopy1 x G (Graph_vgen G x x0) (initial_copied_Graph x x0 G) /\
  x0 = LocalGraphCopy.vmap (Graph_vgen G x x0) x /\
  is_guarded_BiMaFin (fun v => x0 <> v) (fun e => ~ In e nil) (initial_copied_Graph x x0 G).
Proof.
  intros.
  split; [split; [| split] | split].
  + reflexivity.
  + split; [| split].
    - reflexivity.
    - simpl.
      unfold update_vlabel.
      destruct_eq_dec x x; congruence.
    - intros.
      simpl.
      unfold update_vlabel; simpl.
      destruct_eq_dec x n'; [congruence |].
      tauto.
  + split; [| split; [| split]].
    - reflexivity.
    - apply guarded_pointwise_relation_spec; intros.
      simpl.
      unfold update_vlabel; simpl.
      destruct_eq_dec x x1; [congruence | auto].
    - apply guarded_pointwise_relation_spec; intros.
      auto.
    - reflexivity.
  + simpl.
    unfold update_vlabel; simpl.
    destruct_eq_dec x x; [auto | congruence].
  + assert (LocalGraphCopy.vmap (Graph_vgen G x x0) x = x0).
    Focus 1. {
      simpl.
      unfold update_vlabel; simpl.
      destruct_eq_dec x x; auto; congruence.
    } Unfocus.
    pattern x0 at 1; rewrite <- H2.
    apply single_vertex_guarded_BiMaFin.
Qed.

Lemma left_weak_valid: forall (G G1: Graph) (G1': LGraph) (x l r: addr),
  vgamma G x = (null, l, r) ->
  vvalid G x ->
  vcopy1 x G G1 G1' ->
  @weak_valid _ _ _ _ G1 _ (maGraph _) l.
Proof.
  intros.
  destruct H1 as [? _].
  eapply weak_valid_si; [symmetry; exact H1 |].
  eapply gamma_left_weak_valid; eauto.
Qed.

Lemma right_weak_valid: forall (G G1 G3: Graph) (G1' G3': LGraph) (x l r: addr),
  vgamma G x = (null, l, r) ->
  vvalid G x ->
  vcopy1 x G G1 G1' ->
  edge_copy G (x, L) (G1: LGraph, G1') (G3: LGraph, G3') ->
  @weak_valid _ _ _ _ G3 _ (maGraph _) r.
Proof.
  intros.
  destruct H1 as [? _].
  apply edge_copy_si in H2.
  rewrite <- H1 in H2.
  eapply weak_valid_si; [symmetry; eauto |].
  eapply gamma_right_weak_valid; eauto.
Qed.

Lemma graph_ramify_left: forall {RamUnit: Type} (g g1: Graph) (g1': LGraph) (x l r: addr) (F1 F2: pred),
  vvalid g x ->
  vgamma g x = (null, l, r) ->
  vcopy1 x g g1 g1' ->
  F1 * (F2 * reachable_vertices_at x g1) |--
  reachable_vertices_at l g1 *
   (ALL a: RamUnit * Graph * Graph * addr,
     !! (copy l g1 (snd (fst a)) (snd (fst (fst a))) /\ (l = null /\ snd a = null \/ snd a = LocalGraphCopy.vmap (snd (fst a)) l)) -->
     (reachable_vertices_at l (snd (fst a)) * reachable_vertices_at (snd a) (snd (fst (fst a))) -*
      F1 * (F2 * (reachable_vertices_at x (snd (fst a)) * reachable_vertices_at (snd a) (snd (fst (fst a))))))).
Proof.
  intros.
  destruct H1 as [? [? ?]].
  rewrite <- sepcon_assoc, (sepcon_comm (F1 * F2)).
  RAMIF_Q'.formalize.
  match goal with
  | |- _ |-- _ * allp (_ --> (_ -* ?A)) =>
    replace A with
    (fun p : RamUnit * Graph * Graph * addr =>
            reachable_vertices_at x (snd (fst p)) *
            reachable_vertices_at (snd p) (snd (fst (fst p))) * (F1 * F2)) by
    (extensionality p; rewrite <- (sepcon_assoc F1 F2), (sepcon_comm _ (F1 * F2)); auto)
  end.
  apply RAMIF_Q'.frame; [auto |].
  apply RAMIF_Q'.frame_post; [auto |].
  simpl.

  eapply vertices_at_ramif_xQ.
  eexists.
  split; [| split].
  + rewrite <- H1.
    eapply Prop_join_reachable_left; eauto.
  + intros.
    destruct H4 as [[? [? ?]] _].
    rewrite <- H4, <- H1.
    eapply Prop_join_reachable_left; eauto.
  + intros [[[? ?] ?] ?] [? _].
    simpl in H4 |- *; clear r0.
    rewrite vertices_identical_spec.
    intros.
    simpl.
    destruct H4 as [? [? ?]].
    f_equal; [f_equal |].
    - destruct H7 as [_ [? _]].
      rewrite guarded_pointwise_relation_spec in H7.
      apply H7; clear H7.
      unfold Complement, Ensembles.In.
      intro.
      apply reachable_by_is_reachable in H7.
      rewrite Intersection_spec in H5.
      rewrite <- H1 in H7.
      destruct H5; auto.
    - apply dst_L_eq; auto.
      rewrite Intersection_spec in H5.
      destruct H5 as [? _].
      rewrite H1 in H5.
      apply reachable_foot_valid in H5; auto.
    - apply dst_R_eq; auto.
      rewrite Intersection_spec in H5.
      destruct H5 as [? _].
      rewrite H1 in H5.
      apply reachable_foot_valid in H5; auto.
Qed.

Lemma graph_ramify_right: forall {RamUnit: Type} (g g1 g2: Graph) (g1' g2': LGraph) (x l r: addr) (F1 F2: pred),
  vvalid g x ->
  vgamma g x = (null, l, r) ->
  vcopy1 x g g1 g1' ->
  edge_copy g (x, L) (g1: LGraph, g1') (g2: LGraph, g2') ->
  F1 * (F2 * reachable_vertices_at x g2) |--
  reachable_vertices_at r g2 *
   (ALL a: RamUnit * Graph * Graph * addr,
     !! (copy r g2 (snd (fst a)) (snd (fst (fst a))) /\ (r = null /\ snd a = null \/ snd a = LocalGraphCopy.vmap (snd (fst a)) r)) -->
     (reachable_vertices_at r (snd (fst a)) * reachable_vertices_at (snd a) (snd (fst (fst a))) -*
      F1 * (F2 * (reachable_vertices_at x (snd (fst a)) * reachable_vertices_at (snd a) (snd (fst (fst a))))))).
Proof.
  intros.
  destruct H1 as [? [? ?]].
  rewrite <- sepcon_assoc, (sepcon_comm (F1 * F2)).
  RAMIF_Q'.formalize.
  match goal with
  | |- _ |-- _ * allp (_ --> (_ -* ?A)) =>
    replace A with
    (fun p : RamUnit * Graph * Graph * addr =>
            reachable_vertices_at x (snd (fst p)) *
            reachable_vertices_at (snd p) (snd (fst (fst p))) * (F1 * F2)) by
    (extensionality p; rewrite <- (sepcon_assoc F1 F2), (sepcon_comm _ (F1 * F2)); auto)
  end.
  apply RAMIF_Q'.frame; [auto |].
  apply RAMIF_Q'.frame_post; [auto |].
  simpl.

  eapply vertices_at_ramif_xQ.
  eexists.
  split; [| split].
  + apply edge_copy_si in H2; rewrite <- H2, <- H1.
    eapply Prop_join_reachable_right; eauto.
  + intros.
    destruct H5 as [[? [? ?]] _].
    apply edge_copy_si in H2; rewrite <- H5, <- H2, <- H1.
    eapply Prop_join_reachable_right; eauto.
  + intros [[[? ?] ?] ?] [? _].
    rewrite (edge_copy_si _ _ _ _ _ _ H2) in H1.
    simpl in H5 |- *; clear r0.
    rewrite vertices_identical_spec.
    intros.
    simpl.
    destruct H5 as [? [? ?]].
    f_equal; [f_equal |].
    - destruct H8 as [_ [? _]].
      rewrite guarded_pointwise_relation_spec in H8.
      apply H8; clear H8.
      unfold Complement, Ensembles.In.
      intro.
      apply reachable_by_is_reachable in H8.
      rewrite Intersection_spec in H6.
      rewrite <- H1 in H8.
      destruct H6; auto.
    - apply dst_L_eq; auto.
      rewrite Intersection_spec in H6.
      destruct H6 as [? _].
      rewrite H1 in H6.
      apply reachable_foot_valid in H6; auto.
    - apply dst_R_eq; auto.
      rewrite Intersection_spec in H6.
      destruct H6 as [? _].
      rewrite H1 in H6.
      apply reachable_foot_valid in H6; auto.
Qed.

Lemma is_BiMaFin_disjoint_guard: forall (g1':  @LGraph pSGG_Bi (@addr pSGG_Bi) (prod (@addr pSGG_Bi) LR)) (g2'': Graph) x0 es0,
  is_guarded_BiMaFin (fun v => x0 <> v) (fun e => ~ In e es0) g1' ->
  vvalid g1' x0 ->
  (forall e, In e es0 -> fst e = x0) ->
  Disjoint addr (vvalid g2'') (vvalid g1') ->
  disjointed_guard (vvalid g2'') (vvalid g1') (evalid g2'') (evalid g1').
Proof.
  intros.
  split; auto.
  rewrite Disjoint_spec in *.
  intros e ? ?.
  destruct (@valid_graph _ _ _ _ g2'' _ (maGraph _) e H3) as [? _].
  apply (H2 _ H5).
  destruct (in_dec equiv_dec e es0); destruct e as [v lr].
  + specialize (H1 _ i).
    simpl in H1.
    rewrite left_right_sound0 by auto.
    subst; auto.
  + destruct H as [X _].
    pose (pg1 := Build_GeneralGraph _ _ (fun g: LGraph => BiMaFin g) (gpredicate_sub_labeledgraph (fun v => x0 <> v) (fun e => ~ In e es0) g1') X: Graph).
    assert (evalid pg1 (v, lr)) by (simpl; rewrite Intersection_spec; split; auto).
    assert (src g2'' (v, lr) = src pg1 (v, lr)) by (rewrite !left_right_sound0; auto).
    apply (@valid_graph _ _ _ _ pg1 _ (maGraph _)) in H.
    destruct H as [? _].
    rewrite H6; auto.
    destruct H; auto.
Qed.

Lemma is_BiMaFin_not_evalid: forall (g1': @LGraph pSGG_Bi (@addr pSGG_Bi) (prod (@addr pSGG_Bi) LR))x0 es0 e0,
  is_guarded_BiMaFin (fun v => x0 <> v) (fun e => ~ In e es0) g1' ->
  vvalid g1' x0 ->
  (forall e, In e es0 -> fst e = x0) ->
  fst e0 = x0 ->
  ~ In e0 es0 ->
  ~ evalid g1' e0.
Proof.
  intros.
  intro.
  destruct H as [X ?].
  set (G := (Build_GeneralGraph _ _ (fun g => BiMaFin (pg_lg g)) _ X: Graph)).
  assert (evalid G e0).
  Focus 1. {
    simpl.
    rewrite Intersection_spec; auto.
  } Unfocus.
  pose proof @valid_graph _ _ _ _ G _ (maGraph _) _ H5.
  destruct H6.
  destruct e0.
  simpl in H2; subst a.
  rewrite (left_right_sound0 _ _ _ H5) in H6.
  simpl in H6.
  rewrite Intersection_spec in H6.
  destruct H6.
  auto.
Qed.

Lemma labeledgraph_add_edge_ecopy1_left: forall (g g1 g2: Graph) (g1' g2': LGraph) (x l r x0 l0: addr),
  vvalid g x ->
  vgamma g x = (null, l, r) ->
  vcopy1 x g g1 g1' ->
  extended_copy l (g1: LGraph, g1') (g2: LGraph, g2') ->
  x0 = LocalGraphCopy.vmap g1 x ->
  l = null /\ l0 = null \/ l0 = LocalGraphCopy.vmap g2 l ->
  is_guarded_BiMaFin (fun v => x0 <> v) (fun e => ~ In e nil) g2' ->
  x0 <> null ->
  let g3 := Graph_egen g2 (x, L) (x0, L): Graph in
  let g3' := labeledgraph_add_edge g2' (x0, L) x0 l0 (null, L): LGraph in
  ecopy1 (x, L) (g2: LGraph, g2') (g3: LGraph, g3').
Proof.
  intros.
  unfold ecopy1.
  split; [| split].
  + reflexivity.
  + apply WeakMarkGraph.labeledgraph_egen_do_nothing.
  + destruct H4.
    - pose proof LocalGraphCopy.labeledgraph_egen_ecopy1_not_vvalid g2 g2' (x, L) (x0, L) x0 l0.
      apply H7; clear H7.
      * simpl.
        eapply is_BiMaFin_not_evalid; eauto; [| intros ? []].
        destruct H1 as [_ [_ ?]], H2 as [_ [_ ?]].
        eapply LocalGraphCopy.extended_copy_vvalid_mono in H2; [exact H2 |].
        eapply LocalGraphCopy.vcopy1_copied_root_valid in H1; auto.
        subst x0; auto.
      * rewrite left_right_sound.
        Focus 1. {
          destruct H1 as [_ [? _]], H2 as [_ [_ ?]].
          subst x0.
          destruct H2 as [_ [? _]].
          rewrite guarded_pointwise_relation_spec in H2.
          apply H2.
          unfold Complement, Ensembles.In; intro.
          apply reachable_by_foot_prop in H3.
          apply H3.
          destruct H1 as [_ [? _]]; auto.
        } Unfocus.
        Focus 1. {
          destruct H1 as [? _], H2 as [? _].
          rewrite <- (proj1 H2), <- (proj1 H1); auto.
        } Unfocus.
      * destruct H4.
        subst l0.
        destruct H5 as [[? ? ?] _].
        pose proof @valid_not_null _ _ _ _ (gpredicate_sub_labeledgraph (fun v : addr => x0 <> v)
            (fun e : addr * LR => ~ In e nil) g2') _ ma null.
        intro.
        apply H5; [| reflexivity].
        simpl.
        rewrite Intersection_spec; split; auto.
      * inversion H0.
        destruct H1 as [? _], H2 as [? _].
        rewrite <- H1 in H2.
        rewrite <- (si_dst1 _ _ _ H2); [| apply (@left_valid _ _ _ _ _ _ g (biGraph _)); auto].
        destruct H4; rewrite H9; subst l.
        intro.
        apply (@valid_not_null _ _ _ _ g2 _ (maGraph _) null); auto; reflexivity.
    - pose proof LocalGraphCopy.labeledgraph_egen_ecopy1 g2 g2' (x, L) (x0, L) x0 l0.
      apply H7; clear H7.
      * simpl.
        eapply is_BiMaFin_not_evalid; eauto; [| intros ? []].
        destruct H1 as [_ [_ ?]], H2 as [_ [_ ?]].
        eapply LocalGraphCopy.extended_copy_vvalid_mono in H2; [exact H2 |].
        eapply LocalGraphCopy.vcopy1_copied_root_valid in H1; auto.
        subst x0; auto.
      * rewrite left_right_sound.
        Focus 1. {
          destruct H1 as [_ [? _]], H2 as [_ [_ ?]].
          subst x0.
          destruct H2 as [_ [? _]].
          rewrite guarded_pointwise_relation_spec in H2.
          apply H2.
          unfold Complement, Ensembles.In; intro.
          apply reachable_by_foot_prop in H3.
          apply H3.
          destruct H1 as [_ [? _]]; auto.
        } Unfocus.
        Focus 1. {
          destruct H1 as [? _], H2 as [? _].
          rewrite <- (proj1 H2), <- (proj1 H1); auto.
        } Unfocus.
      * subst l0.
        f_equal.
        inversion H0.
        destruct H1 as [? _], H2 as [? _].
        rewrite <- H1 in H2.
        rewrite (si_dst1 _ _ _ H2); auto.
        apply (@left_valid _ _ _ _ _ _ g (biGraph _)); auto.
Qed.

Lemma extend_copy_left: forall (g g1 g2: Graph) (g1': LGraph) (g2'': Graph) (x l r x0 l0: addr) d0,
  vvalid g x ->
  vgamma g x = (null, l, r) ->
  vcopy1 x g g1 g1' ->
  copy l g1 g2 g2'' ->
  x0 = LocalGraphCopy.vmap g1 x ->
  l = null /\ l0 = null \/ l0 = LocalGraphCopy.vmap g2 l ->
  is_guarded_BiMaFin (fun v => x0 <> v) (fun e => ~ In e nil) g1' ->
  @derives pred _
  (vertex_at x0 d0 * vertices_at (Intersection _ (vvalid g1') (fun x => x0 <> x)) g1' * reachable_vertices_at l0 g2'') 
  (EX g2': LGraph,
    !! (extended_copy l (g1: LGraph, g1') (g2: LGraph, g2') /\ is_guarded_BiMaFin (fun v => x0 <> v) (fun e => ~ In e nil) g2') && 
    (vertex_at x0 d0 * vertices_at (Intersection _ (vvalid g2') (fun x => x0 <> x)) g2')).
Proof.
  intros.
  rename H5 into BMF.
  inversion H0.
  pose proof @vcopy1_edge_copy_list_weak_copy_extended_copy _ _ _ _ _ BiMaFin_Normal x ((x, L) :: (x, R) :: nil) nil (x, L) ((x, R) :: nil) g g1 g1 g1' g1' g2 g2'' x0 H.
  spec H5; [simpl; unfold Complement, Ensembles.In; congruence |].
  spec H5; [reflexivity |].
  spec H5; [intros; apply (biGraph_out_edges g (biGraph _)); auto |].
  spec H5; [repeat constructor; [intros [|[]]; intro HH; inversion HH | intros []] |].
  spec H5; [auto |].
  spec H5; [hnf; auto |].
  spec H5; [auto |].
  spec H5; [subst l; auto |].

  unfold reachable_vertices_at.
  pose proof vertices_at_sepcon_unique_1x (Graph_SpatialGraph g2'') x0 (reachable g2'' l0) d0.
  pose proof vertices_at_sepcon_unique_xx g1' (Graph_SpatialGraph g2'') (Intersection _ (vvalid g1') (fun x => x0 <> x)) (reachable g2'' l0).

  rewrite sepcon_assoc, (add_andp _ _ H10); normalize.
  rewrite (sepcon_comm (vertices_at _ _)), <- sepcon_assoc, (add_andp _ _ H9); normalize.
  clear H9 H10.
  spec H5.
  Focus 1. {
    apply is_BiMaFin_disjoint_guard with (x0 := x0) (es0 := nil); auto.
    + destruct H1 as [_ [_ ?]].
      destruct H1 as [_ [_ [_ ?]]].
      subst g1' x0.
      simpl; auto.
    + intros ? [].
    + destruct H2 as [? [? ?]].
      apply (vmap_weaken g1 g2'') in H4.
      rewrite (LocalGraphCopy.copy_vvalid_weak_eq g1 g2 g2'' (WeakMarkGraph.marked g1) l l0 H4 H10).
      apply Disjoint_comm.
      apply (Disjoint_x1' _ _ _ H11 H12).
  } Unfocus.

  unfold map in H5; rewrite H3 in BMF.
  rewrite <- H3 in BMF;
  specialize (H5 BMF).
  specialize (H5 (Graph_is_BiMaFin _)).

  destruct H5 as [g2' [? [? [? ?]]]].
  apply (exp_right g2').

  destruct_eq_dec x0 null.
  Focus 1. {
    clear - H14.
    subst x0.
    pose proof @vertex_at_not_null _ _ _ _ _ _ _ _ null SGAvn d0.
    rewrite (add_andp _ _ H).
    normalize.
  } Unfocus.
  
  apply andp_right; [apply prop_right; split; auto | rewrite sepcon_assoc; apply sepcon_derives; auto].
  rewrite (vertices_at_vertices_identical (Graph_SpatialGraph g2'') (LGraph_SGraph g2')).
  rewrite (vertices_at_vertices_identical (LGraph_SGraph g1') (LGraph_SGraph g2')).
  - erewrite vertices_at_sepcon_xx; [apply derives_refl |].
    rewrite Prop_join_comm.
    destruct H2 as [_ [_ ?]].
    apply (vmap_weaken g1 g2'') in H4.
    rewrite <- (LocalGraphCopy.copy_vvalid_weak_eq g1 g2 g2'' (WeakMarkGraph.marked g1) l l0 H4 H2).
    apply Prop_join_shrink;
    admit. (* some how copy the proof in Graph_Copy.v *)
  - admit.
  - admit.
Qed.

Lemma va_labeledgraph_add_edge_left: forall (g g1 g2: Graph) (g1' g2': LGraph) (x l r x0 l0: addr),
  vvalid g x ->
  vgamma g x = (null, l, r) ->
  vcopy1 x g g1 g1' ->
  extended_copy l (g1: LGraph, g1') (g2: LGraph, g2') ->
  x0 = LocalGraphCopy.vmap g1 x ->
  is_guarded_BiMaFin (fun x => x0 <> x) (fun e => ~ In e nil) g2' ->
  vertices_at (Intersection _ (vvalid g2') (fun x => x0 <> x)) g2' = vertices_at (Intersection _ (vvalid (labeledgraph_add_edge g2' (x0, L) x0 l0 (null, L))) (fun x => x0 <> x)) (LGraph_SGraph (labeledgraph_add_edge g2' (x0, L) x0 l0 (null, L))).
Proof.
  intros.
  eapply va_labeledgraph_add_edge_eq; eauto.
  eapply is_BiMaFin_not_evalid; eauto.
  + (* apply extended_copy_valid_mono; eauto. *)
    admit.
  + intros ? [].
Qed.

Lemma va_labeledgraph_egen_left: forall (g2: Graph) (x x0: addr),
  reachable_vertices_at x g2 = reachable_vertices_at x (Graph_egen g2 (x, L) (x0, L)).
Proof.
  intros.
  apply va_labeledgraph_egen_eq.
Qed.

Lemma extend_copy_right: forall (g g1 g2 g3: Graph) (g1' g2': LGraph) (g3'': Graph) (x l r x0 r0: addr) d0,
  vvalid g x ->
  vgamma g x = (null, l, r) ->
  vcopy1 x g g1 g1' ->
  edge_copy g (x, L) (g1: LGraph, g1') (g2: LGraph, g2') ->
  copy r g2 g3 g3'' ->
  x0 = LocalGraphCopy.vmap g1 x ->
  r = null /\ r0 = null \/ r0 = LocalGraphCopy.vmap g3 r ->
  is_guarded_BiMaFin (fun v => x0 <> v) (fun e => ~ In e ((x0, L) :: nil)) g2' ->
  let g4 := Graph_egen g3 (x, R) (x0, R): Graph in
  @derives pred _
  (vertex_at x0 d0 * vertices_at (Intersection _ (vvalid g2') (fun x => x0 <> x)) g2' * reachable_vertices_at r0 g3'') 
  (EX g4': LGraph,
    !! (edge_copy g (x, R) (g2: LGraph, g2') (g4: LGraph, g4') /\ is_guarded_BiMaFin (fun v => x0 <> v) (fun e => ~ In e ((x0, L) :: (x0, R) :: nil)) g4') && 
    vertex_at x0 d0 * vertices_at (Intersection _ (vvalid g4') (fun x => x0 <> x)) g4').
Proof.
  intros.
  pose proof vcopy1_edge_copy_list_copy_extended_copy x ((x, L) :: (x, R) :: nil) ((x, L) :: nil) (x, R) nil g g1 g2 g1' g2' g3 g3''.
Admitted.

End SpatialGraph_Copy_Bi.


