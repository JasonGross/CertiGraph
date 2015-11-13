Require Import Coq.Logic.ProofIrrelevance.
Require Import RamifyCoq.lib.Coqlib.
Require Import RamifyCoq.lib.EnumEnsembles.
Require Import RamifyCoq.lib.List_ext.
Require Import RamifyCoq.lib.EquivDec_ext.
Require Import RamifyCoq.graph.graph_model.
Require Import RamifyCoq.graph.find_not_in.
Require Import Coq.Lists.List.

Section PATH_LEM.

Context {V E: Type}.
Context {EV: EqDec V eq}.
Context {EE: EqDec E eq}.
Notation Gph := (PreGraph V E).

(******************************************

Definitions

******************************************)

Definition path : Type := list V.

Definition paths_meet_at (p1 p2 : path) := fun n => foot p1 = Some n /\ head p2 = Some n.

Definition paths_meet (p1 p2 : path) : Prop := exists n, paths_meet_at p1 p2 n.

Fixpoint valid_path (g: Gph) (p: path) : Prop :=
  match p with
    | nil => True
    | n :: nil => vvalid g n
    | n1 :: ((n2 :: _) as p') => g |= n1 ~> n2 /\ valid_path g p'
  end.

Definition graph_is_acyclic (g: Gph) : Prop :=
  forall p : list V, valid_path g p -> NoDup p.

Definition path_prop (P : Ensemble V) : (list V -> Prop) := Forall P.

Definition good_path (g: Gph) (P : Ensemble V) : (list V -> Prop) := fun p => valid_path g p /\ path_prop P p.

Definition path_endpoints (p: path) (n1 n2 : V) : Prop := head p = Some n1 /\ foot p = Some n2.

Definition reachable_by_path (g: Gph) (p: path) (n : V) (P : Ensemble V) : Ensemble V := fun n' => path_endpoints p n n' /\ good_path g P p.
Notation " g '|=' p 'is' n1 '~o~>' n2 'satisfying' P" := (reachable_by_path g p n1 P n2) (at level 1).

Definition reachable_by (g: Gph) (n : V) (P : Ensemble V) : Ensemble V :=
  fun n' => exists p, g |= p is n ~o~> n' satisfying P.
Notation " g '|=' n1 '~o~>' n2 'satisfying' P " := (reachable_by g n1 P n2) (at level 1).

Definition reachable_by_acyclic (g: Gph) (n : V) (P : Ensemble V) : Ensemble V :=
  fun n' => exists p, NoDup p /\ g |= p is n ~o~> n' satisfying P.
Notation " g '|=' n1 '~~>' n2 'satisfying' P " := (reachable_by_acyclic g n1 P n2) (at level 1).

Definition reachable (g: Gph) (n : V): Ensemble V:= reachable_by g n (fun _ => True).

Definition reachable_by_through_set (g: Gph) (S : list V) (P : Ensemble V) : Ensemble V:= fun n => exists s, In s S /\ reachable_by g s P n.

Definition reachable_through_set (g: Gph) (S : list V) : Ensemble V:= fun n => exists s, In s S /\ reachable g s n.

Definition reachable_list (g: Gph) (x : V) (L : list V) : Prop := forall y, In y L <-> reachable g x y.

Definition reachable_set_list (g: Gph) (S : list V) (l : list V) : Prop := forall x : V, In x l <-> reachable_through_set g S x.

(******************************************

Path Lemmas
 
******************************************)

Lemma path_endpoints_meet: forall p1 p2 n1 n2 n3,
  path_endpoints p1 n1 n2 ->
  path_endpoints p2 n2 n3 ->
  paths_meet p1 p2.
Proof.
  unfold path_endpoints, paths_meet; intros.
  destruct H, H0. exists n2. red. tauto.
Qed.

Lemma paths_foot_head_meet: forall p1 p2 n, paths_meet (p1 +:: n) (n :: p2).
Proof. intros. exists n. split. apply foot_last. trivial. Qed.

Definition path_glue (p1 p2 : path) : path := p1 ++ (tail p2).
Notation "p1 '+++' p2" := (path_glue p1 p2) (at level 20, left associativity).

Lemma path_glue_nil_l: forall p, nil +++ p = tail p.
Proof.
  unfold path_glue.  trivial.
Qed.

Lemma path_glue_nil_r: forall p, p +++ nil = p.
Proof.
  unfold path_glue. simpl. intro. rewrite app_nil_r. trivial.
Qed.

Lemma path_glue_assoc: forall p1 p2 p3 : path,
  paths_meet p1 p2 -> paths_meet p2 p3 -> (p1 +++ p2) +++ p3 = p1 +++ (p2 +++ p3).
Proof.
  unfold path_glue.
  induction p1; simpl; intros. icase H. icase H.
  icase p2. icase H. icase H. icase p3.
  do 2 rewrite app_nil_r. trivial.
  icase p2. simpl. rewrite app_nil_r. trivial. simpl.
  rewrite <- app_assoc. f_equal.
Qed.

Lemma path_glue_comm_cons: forall n p1 p2, (n :: p1 +++ p2) = ((n :: p1) +++ p2).
Proof.
  unfold path_glue. intros. rewrite app_comm_cons. trivial.
Qed.

Lemma path_endpoints_glue: forall n1 n2 n3 p1 p2,
  path_endpoints p1 n1 n2 -> path_endpoints p2 n2 n3 -> path_endpoints (p1 +++ p2) n1 n3.
Proof.
  split; destruct H, H0.
  icase p1. unfold path_glue.
  icase p2. icase p2. inv H0. inv H2. simpl. rewrite app_nil_r. trivial.
  rewrite foot_app; disc. apply H2.
Qed.

Lemma valid_path_tail: forall (g : Gph) p, valid_path g p -> valid_path g (tail p).
Proof.
  destruct p; auto. simpl. destruct p; auto.
  intro; simpl; auto. intros [? ?]; auto.
Qed.

Lemma valid_path_split: forall (g : Gph) p1 p2, valid_path g (p1 ++ p2) -> valid_path g p1 /\ valid_path g p2.
Proof.
  induction p1. simpl. tauto.
  intros. rewrite <- app_comm_cons in H.
  simpl in H. revert H. case_eq (p1 ++ p2); intros.
  apply app_eq_nil in H. destruct H. subst. simpl. tauto.
  destruct H0. rewrite <- H in H1.
  apply IHp1 in H1. destruct H1.
  split; trivial.
  simpl. destruct p1; auto.
  destruct H0; auto.
  rewrite <- app_comm_cons in H. inv H. tauto.
Qed.

Lemma valid_path_merge: forall (g : Gph) p1 p2,
                          paths_meet p1 p2 -> valid_path g p1 -> valid_path g p2 -> valid_path g (p1 +++ p2).
Proof.
  induction p1. simpl. intros. apply valid_path_tail. trivial.
  intros. rewrite <- path_glue_comm_cons.
  simpl.
  case_eq (p1 +++ p2); auto.
  intros. simpl in H0. destruct p1; auto; destruct H0; destruct H0; auto.
  intros. rewrite <- H2.
  split.
  icase p1. unfold path_glue in H2. simpl in H2.
  icase p2. inv H. simpl in H2. subst p2.
  simpl in H1. destruct H3. rewrite <- H in H2. simpl in H2. inv H2. tauto.
  rewrite <- path_glue_comm_cons in H2. inv H2.
  simpl in H0. tauto.
  icase p1.
  rewrite path_glue_nil_l. apply valid_path_tail; auto.
  apply IHp1; auto.
  change (v0 :: p1) with (tail (a :: v0 :: p1)). apply valid_path_tail; auto.
Qed.

Lemma valid_path_si: forall (g1 g2: Gph),
    structurally_identical g1 g2 -> forall p, valid_path g1 p <-> valid_path g2 p.
Proof.
  cut (forall g1 g2 : Gph, g1 ~=~ g2 -> forall p : list V, valid_path g1 p -> valid_path g2 p).
  1: intros; split; apply H; [| symmetry]; auto.
  induction p; simpl; auto.
  icase p.
  + pose proof (proj1 H a); tauto.
  + intros [? ?]. split; auto.
    rewrite (edge_si g1 g2) in H0; auto.
Qed.

Lemma valid_path_acyclic:
  forall (g : Gph) (p : path) n1 n2,
    path_endpoints p n1 n2 -> valid_path g p ->
    exists p', Sublist p' p /\ path_endpoints p' n1 n2 /\ NoDup p' /\ valid_path g p'.
Proof.
  intros until p. remember (length p). assert (length p <= n) by omega. clear Heqn. revert p H. induction n; intros.
  icase p; icase H0. inv H0. inv H.
  destruct (nodup_dec p) as [? | H2]. exists p. split. reflexivity. tauto.
  apply Dup_cyclic in H2. destruct H2 as [a [L1 [L2 [L3 ?]]]]. subst p. specialize (IHn (L1 ++ a :: L3)).
  spec IHn. do 2 rewrite app_length in H. rewrite app_length. simpl in *. omega. specialize (IHn n1 n2).
  spec IHn. destruct H0. split. icase L1. repeat (rewrite foot_app in *; disc). trivial.
  spec IHn. change (L1 ++ a :: L3) with (L1 ++ (a :: nil) ++ tail (a :: L3)).
  rewrite app_assoc. change (a :: L2) with ((a :: nil) ++ L2) in H1.
  do 2 rewrite app_assoc in H1. apply valid_path_split in H1. destruct H1.
  apply valid_path_merge; auto. apply paths_foot_head_meet. apply valid_path_split in H1. tauto.
  destruct IHn as [p' [? [? [? ?]]]]. exists p'. split. 2: tauto. transitivity (L1 ++ a :: L3); auto.
  apply Sublist_app. reflexivity. pattern (a :: L3) at 1. rewrite <- (app_nil_l (a :: L3)).
  apply Sublist_app. apply Sublist_nil. reflexivity.
Qed.

Lemma path_prop_weaken: forall (P1 P2 : Ensemble V) p,
  (forall d, P1 d -> P2 d) -> path_prop P1 p -> path_prop P2 p.
Proof. intros; hnf in *; intros; hnf in *; eapply Forall_impl; eauto. Qed.

Lemma path_prop_sublist: forall P p1 p2, Sublist p1 p2 -> path_prop P p2 -> path_prop P p1.
Proof. repeat intro. eapply Forall_sublist; eauto. Qed.

Lemma path_prop_tail: forall P n p, path_prop P (n :: p) -> path_prop P p.
Proof. repeat intro. inversion H; auto. Qed.

Lemma good_path_split: forall (g: Gph) p1 p2 P, good_path g P (p1 ++ p2) -> (good_path g P p1) /\ (good_path g P p2).
Proof.
  intros. destruct H. apply valid_path_split in H; destruct H. unfold good_path. unfold path_prop in *.
  rewrite !Forall_forall in *.
  intuition.
Qed.

Lemma good_path_merge: forall (g: Gph) p1 p2 P,
                         paths_meet p1 p2 -> good_path g P p1 -> good_path g P p2 -> good_path g P (p1 +++ p2).
Proof.
  intros. destruct H0. destruct H1. split. apply valid_path_merge; auto. unfold path_prop in *. intros.
  rewrite Forall_forall in *; intros.
  unfold path_glue in H4. apply in_app_or in H4. destruct H4. auto. apply H3. apply In_tail; auto.
Qed.

Lemma good_path_weaken: forall (g: Gph) p (P1 P2 : Ensemble V),
                          (forall d, P1 d -> P2 d) -> good_path g P1 p -> good_path g P2 p.
Proof.
  split; destruct H0; auto.
  apply path_prop_weaken with P1; auto.
Qed.

Lemma good_path_acyclic:
  forall (g: Gph) P p n1 n2,
    path_endpoints p n1 n2 -> good_path g P p -> exists p', path_endpoints p' n1 n2 /\ NoDup p' /\ good_path g P p'.
Proof.
  intros. destruct H0. apply valid_path_acyclic with (n1 := n1) (n2 := n2) in H0; trivial.
  destruct H0 as [p' [? [? [? ?]]]]. exists p'. split; trivial. split; trivial.
  split; trivial. apply path_prop_sublist with p; trivial.
Qed.

Lemma reachable_by_is_reachable (g: Gph):
  forall n1 n2 P, g |= n1 ~o~> n2 satisfying P -> reachable g n1 n2.
Proof.
  intros. unfold reachable. destruct H as [l [? [? ?]]]. exists l.
  split; auto. split. auto. hnf. rewrite Forall_forall; intros; auto.
Qed.

Lemma reachable_by_through_set_is_reachable_through_set (g: Gph):
  forall l n P, reachable_by_through_set g l P n -> reachable_through_set g l n.
Proof.
  intros.
  destruct H as [s [? ?]]; exists s; split; auto.
  apply reachable_by_is_reachable in H0; auto.
Qed.

Lemma reachable_by_path_is_reachable_by (g: Gph):
  forall p n1 n2 P, g |= p is n1 ~o~> n2 satisfying P -> g |= n1 ~o~> n2 satisfying P.
Proof. intros. exists p; auto. Qed.

Lemma reachable_by_path_is_reachable (g: Gph):
  forall p n1 n2 P, g |= p is n1 ~o~> n2 satisfying P -> reachable g n1 n2.
Proof. intros. apply reachable_by_path_is_reachable_by in H. apply reachable_by_is_reachable with P. auto. Qed.

Lemma reachable_Same_set (g: Gph) (S1 S2 : list V):
  S1 ~= S2 -> Same_set (reachable_through_set g S1) (reachable_through_set g S2).
Proof. intros; destruct H; split; repeat intro; destruct H1 as [y [HIn Hrch]]; exists y; split; auto. Qed.

Lemma reachable_by_path_nil: forall (g : Gph) n1 n2 P, ~ g |= nil is n1 ~o~> n2 satisfying P.
Proof. repeat intro. destruct H as [[? _] _]. disc. Qed.

Lemma reachable_by_path_head: forall (g: Gph) p n1 n2 P, g |= p is n1 ~o~> n2 satisfying P -> head p = Some n1.
Proof. intros. destruct H as [[? _] _]. trivial. Qed.

Lemma reachable_by_path_foot: forall (g: Gph) p n1 n2 P, g |= p is n1 ~o~> n2 satisfying P -> foot p = Some n2.
Proof. intros. destruct H as [[_ ?] _]. trivial. Qed.

Lemma reachable_by_path_merge: forall (g: Gph) p1 n1 n2 p2 n3 P,
                                 g |= p1 is n1 ~o~> n2 satisfying P ->
                                 g |= p2 is n2 ~o~> n3 satisfying P ->
                                 g |= (p1 +++ p2) is n1 ~o~> n3 satisfying P.
Proof.
  intros. destruct H. destruct H0.
  split. apply path_endpoints_glue with n2; auto.
  apply good_path_merge; auto.
  eapply path_endpoints_meet; eauto.
Qed.

Lemma reachable_by_path_split_glue:
  forall (g: Gph) P p1 p2 n1 n2 n, paths_meet_at p1 p2 n ->
                                   g |= (p1 +++ p2) is n1 ~o~> n2 satisfying P ->
                                   g |= p1 is n1 ~o~> n satisfying P /\
                                   g |= p2 is n ~o~> n2 satisfying P.
Proof.
  intros. unfold path_glue in H0. destruct H0.
  destruct H.
  destruct (foot_explicit _ _ H) as [L' ?]. subst p1.
  icase p2. inv H2.
  copy H1. apply good_path_split in H1. destruct H1 as [? _].
  rewrite <- app_assoc in H2, H0. simpl in H2, H0.
  apply good_path_split in H2. destruct H2 as [_ ?].
  destruct H0. rewrite foot_app in H3; disc.
  repeat (split; trivial). icase L'.
Qed.

Lemma reachable_by_path_split_in: forall (g : Gph) P p n n1 n2,
  g |= p is n1 ~o~> n2 satisfying P ->
  In n p -> exists p1 p2,
              p = p1 +++ p2 /\
              g |= p1 is n1 ~o~> n satisfying P /\
              g |= p2 is n ~o~> n2 satisfying P.
Proof.
  intros. destruct (in_split _ _ H0) as [p1 [p2 ?]]. subst p. clear H0.
  replace (p1 ++ n :: p2) with ((p1 ++ (n :: nil)) +++ (n :: p2)) in H.
  2: unfold path_glue; rewrite <- app_assoc; auto.
  apply reachable_by_path_split_glue with (n := n) in H.
  exists (p1 ++ n :: nil). exists (n :: p2).
  split; trivial.
  unfold path_glue. rewrite <- app_assoc. trivial.
  split; trivial. rewrite foot_app; disc. trivial.
Qed.

Lemma reachable_by_path_Forall: forall (g: Gph) p n1 n2 P,
  g |= p is n1 ~o~> n2 satisfying P -> Forall P p.
Proof. intros. destruct H as [_ [_ ?]]. apply H. Qed.

Lemma reachable_by_path_In: forall (g: Gph) p n1 n2 P n,
  g |= p is n1 ~o~> n2 satisfying P -> In n p -> P n.
Proof. intros. pose proof reachable_by_path_Forall _ _ _ _ _ H. rewrite Forall_forall in H1; auto. Qed.

Lemma reachable_by_path_si: forall (g1 g2: Gph) p n1 n2 P,
    structurally_identical g1 g2 -> (g1 |= p is n1 ~o~> n2 satisfying P <-> g2 |= p is n1 ~o~> n2 satisfying P).
Proof.
  cut (forall g1 g2 p n1 n2 P, structurally_identical g1 g2 -> g1 |= p is n1 ~o~> n2 satisfying P ->
                               g2 |= p is n1 ~o~> n2 satisfying P); intros.
  + split; intros; [apply (H g1 g2) | apply (H g2 g1)]; auto. symmetry; auto.
  + destruct H0 as [[? ?] [? ?]]. split; split; auto. rewrite <- (valid_path_si g1 g2 H); auto.
Qed.

Lemma valid_path_valid: forall (g : Gph) p, valid_path g p -> Forall (vvalid g) p.
Proof.
  induction p; intros; simpl in *. apply Forall_nil.
  destruct p; constructor; auto; destruct H as [[? ?] ?]; [| apply IHp]; auto.
Qed.

(******************************************

Reachable Lemmas
 
******************************************)

Lemma reachable_by_refl: forall (g : Gph) n (P: V -> Prop), vvalid g n -> P n -> g |= n ~o~> n satisfying P.
Proof.
  intros.
  exists (n :: nil). split. compute. auto.
  split. simpl. trivial. auto. auto.
  repeat constructor; tauto.
Qed.

Lemma reachable_by_trans: forall (g: Gph) n1 n2 n3 P,
  g |= n1 ~o~> n2 satisfying P ->
  g |= n2 ~o~> n3 satisfying P ->
  g |= n1 ~o~> n3 satisfying P.
Proof. do 2 destruct 1. exists (x +++ x0). apply reachable_by_path_merge with n2; auto. Qed.

Lemma reachable_by_through_set_reachable_by: forall (g: Gph) l x y P,
  reachable_by_through_set g l P x -> reachable_by g x P y -> reachable_by_through_set g l P y.
Proof.
  intros.
  destruct H as [s [? ?]]; exists s; split; auto.
  apply reachable_by_trans with x; auto.
Qed.

Lemma reachable_by_head_valid: forall (g : Gph) n1 n2 P, g |= n1 ~o~> n2 satisfying P -> vvalid g n1.
Proof.
  repeat intro. destruct H as [l [[? ?] [? ?]]]. destruct l. inversion H. simpl in H. inversion H. subst. simpl in H1.
  destruct l. auto. destruct H1 as [[? _] _]. auto.
Qed.

Lemma reachable_by_foot_valid: forall (g : Gph) n1 n2 P, g |= n1 ~o~> n2 satisfying P -> vvalid g n2.
Proof.
  repeat intro. destruct H as [l [[? ?] [? ?]]]. apply foot_in in H0. apply valid_path_valid in H1.
  rewrite Forall_forall in H1. apply H1. auto.
Qed.

Lemma reachable_by_head_prop: forall (g: Gph) n1 n2 P, g |= n1 ~o~> n2 satisfying P -> P n1.
Proof.
  intros. destruct H as [p ?]. eapply reachable_by_path_In; eauto.
  apply reachable_by_path_head in H. icase p. inv H. simpl. auto.
Qed.

Lemma reachable_by_foot_prop: forall (g: Gph) n1 n2 P, g |= n1 ~o~> n2 satisfying P -> P n2.
Proof.
  intros. destruct H as [p ?]. eapply reachable_by_path_In; eauto.
  apply reachable_by_path_foot in H. apply foot_in. trivial.
Qed.

Lemma reachable_by_through_set_foot_valid: forall (g : Gph) S n P, reachable_by_through_set g S P n -> vvalid g n.
Proof.
  intros.
  destruct H as [s [? ?]].
  eapply reachable_by_foot_valid with (n1 := s); eauto.
Qed.

Lemma reachable_by_through_set_foot_prop: forall (g : Gph) S n P, reachable_by_through_set g S P n -> P n.
Proof.
  intros.
  destruct H as [s [? ?]].
  eapply reachable_by_foot_prop with (n1 := s); eauto.
Qed.

Lemma edge_reachable_by:
  forall (g: Gph) n1 n2 n3 (P: Ensemble V),
     P n1 ->
     g |= n1 ~> n2 ->
     g |= n2 ~o~> n3 satisfying P ->
     g |= n1 ~o~> n3 satisfying P.
Proof.
  intros. apply reachable_by_trans with n2; auto.
  apply reachable_by_head_prop in H1.
  exists (n1 :: n2 :: nil). split. split; auto.
  split. simpl. split; auto. destruct H0 as [? [? ?]]. auto.
  repeat constructor; auto.
Qed.

Lemma step_reachable_by:
  forall (g: Gph) n1 n2 n3 (P: Ensemble V),
     vvalid g n1 ->
     P n1 ->
     step g n1 n2 ->
     g |= n2 ~o~> n3 satisfying P ->
     g |= n1 ~o~> n3 satisfying P.
Proof.
  intros.
  eapply edge_reachable_by; eauto.
  split; [| split]; auto.
  apply reachable_by_head_valid in H2; auto.
Qed.

Lemma reachable_by_edge:
  forall (g: Gph) n1 n2 n3 (P: Ensemble V),
     P n3 ->
     g |= n1 ~o~> n2 satisfying P ->
     g |= n2 ~> n3 ->
     g |= n1 ~o~> n3 satisfying P.
Proof.
  intros. apply reachable_by_trans with n2; auto.
  apply reachable_by_foot_prop in H0.
  exists (n2 :: n3 :: nil). split. split; auto.
  split. simpl. split; auto. destruct H1 as [? [? ?]]. auto.
  repeat constructor; auto.
Qed.

Lemma reachable_by_step:
  forall (g: Gph) n1 n2 n3 (P: Ensemble V),
     vvalid g n3 ->
     P n3 ->
     g |= n1 ~o~> n2 satisfying P ->
     step g n2 n3 ->
     g |= n1 ~o~> n3 satisfying P.
Proof.
  intros.
  eapply reachable_by_edge; eauto.
  split; [| split]; auto.
  apply reachable_by_foot_valid in H1; auto.
Qed.

Lemma reachable_by_through_set_edge:
  forall (g: Gph) l n2 n3 (P: Ensemble V),
     P n3 ->
     reachable_by_through_set g l P n2 ->
     edge g n2 n3 ->
     reachable_by_through_set g l P n3.
Proof.
  intros.
  destruct H0 as [s [? ?]].
  exists s; split; auto.
  apply reachable_by_edge with n2; auto.
Qed.

Lemma reachable_by_through_set_step:
  forall (g: Gph) l n2 n3 (P: Ensemble V),
     vvalid g n3 ->
     P n3 ->
     reachable_by_through_set g l P n2 ->
     step g n2 n3 ->
     reachable_by_through_set g l P n3.
Proof.
  intros.
  eapply reachable_by_through_set_edge; eauto.
  split; [| split]; auto.
  apply reachable_by_through_set_foot_valid in H1; auto.
Qed.

Lemma reachable_refl: forall (g: Gph) x, vvalid g x -> reachable g x x.
Proof. intros; apply reachable_by_refl; auto. Qed.

Lemma reachable_trans: forall (g: Gph) x y z,
  reachable g x y -> reachable g y z -> reachable g x z.
Proof. intros. eapply reachable_by_trans; eauto. Qed.

Lemma reachable_through_set_reachable: forall (g: Gph) l x y,
  reachable_through_set g l x -> reachable g x y -> reachable_through_set g l y.
Proof.
  intros.
  destruct H as [s [? ?]]; exists s; split; auto.
  apply reachable_trans with x; auto.
Qed.

Lemma reachable_head_valid: forall (g : Gph) n1 n2, reachable g n1 n2 -> vvalid g n1.
Proof. intros; eapply reachable_by_head_valid; eauto. Qed.

Lemma reachable_foot_valid: forall (g : Gph) n1 n2, reachable g n1 n2 -> vvalid g n2.
Proof. intros; eapply reachable_by_foot_valid; eauto. Qed.

Lemma reachable_through_set_foot_valid: forall (g : Gph) S n, reachable_through_set g S n -> vvalid g n.
Proof.
  intros.
  destruct H as [s ?].
  apply reachable_foot_valid with s; tauto.
Qed.

Lemma edge_reachable:
  forall (g : Gph) x y z, reachable g y z -> edge g x y -> reachable g x z.
Proof. intros. eapply edge_reachable_by; eauto. Qed.

Lemma step_reachable:
  forall (g : Gph) x y z, step g x y -> reachable g y z -> vvalid g x -> reachable g x z.
Proof. intros. eapply step_reachable_by; eauto. Qed.

Lemma reachable_edge:
  forall (g : Gph) x y z, reachable g x y -> edge g y z -> reachable g x z.
Proof. intros. eapply reachable_by_edge; eauto. Qed.

Lemma reachable_step:
  forall (g : Gph) x y z, reachable g x y -> step g y z -> vvalid g z -> reachable g x z.
Proof. intros. eapply reachable_by_step; eauto. Qed.

Lemma reachable_through_set_edge:
  forall (g: Gph) l n2 n3,
     reachable_through_set g l n2 ->
     edge g n2 n3 ->
     reachable_through_set g l n3.
Proof.
  intros.
  destruct H as [s [? ?]].
  exists s; split; auto.
  apply reachable_edge with n2; auto.
Qed.

Lemma reachable_through_set_step:
  forall (g: Gph) l n2 n3,
     vvalid g n3 ->
     reachable_through_set g l n2 ->
     step g n2 n3 ->
     reachable_through_set g l n3.
Proof.
  intros.
  eapply reachable_through_set_edge; eauto.
  split; [| split]; auto.
  apply reachable_through_set_foot_valid in H0; auto.
Qed.

(******************************************

Other Reachable Lemmas
 
******************************************)

Lemma reachable_acyclic: forall (g: Gph) n1 P n2,
  g |= n1 ~o~> n2 satisfying P <->
  g |= n1 ~~> n2 satisfying P.
Proof.
  split; intros.
  destruct H as [p [? ?]].
  apply (good_path_acyclic g P p n1 n2 H) in H0.
  destruct H0 as [p' [? ?]].
  exists p'. destruct H1. split; auto. split; auto.
  destruct H as [p [? ?]].
  exists p. trivial.
Qed.

Lemma reachable_by_subset_reachable: forall (g: Gph) n P,
  Included (reachable_by g n P) (reachable g n).
Proof.
  repeat intro. unfold reachable.
  destruct H as [p [? [? ?]]]. exists p.
  split; trivial.
  split; trivial. apply path_prop_weaken with P; auto.
Qed.

Lemma reachable_through_empty (g: Gph):
  Same_set (reachable_through_set g nil) (Empty_set V).
Proof.
  split; repeat intro.
  destruct H; destruct H; apply in_nil in H; tauto.
  hnf in H; tauto.
Qed.

Lemma reachable_through_empty_eq (g: Gph):
  forall S, Same_set (reachable_through_set g S) (Empty_set V) <-> forall y, In y S -> ~ vvalid g y.
Proof.
  intros; split.
  + induction S; intros; [unfold In; intros; tauto |].
    intros.
    destruct (in_inv H0).
    - subst a; intro.
      destruct H. specialize (H y).
      spec H; [| inversion H].
      unfold Ensembles.In. exists y.
      split; [apply in_eq | apply reachable_by_refl; [|hnf]; trivial].
    - assert (Same_set (reachable_through_set g (a :: S)) (reachable_through_set g S)).
      Focus 1. {
        split.
        + apply Extensionality_Ensembles in H; rewrite H.
          intro x; intro. inversion H2.
        + intro; intros. destruct H2 as [s [? ?]]. 
          exists s; split; trivial; apply in_cons; trivial.
      } Unfocus.
      rewrite <- H2 in IHS. pose proof (IHS H y).
      apply H3; trivial.
  + intros. split; repeat intro.
    destruct H0 as [y [? ?]]. apply H in H0. apply reachable_head_valid in H1; tauto. hnf in H0; tauto.
Qed.

Lemma reachable_by_path_split_dec:
  forall (g: Gph) p a b P rslt,
    g |= p is a ~o~> b satisfying P -> {Forall (fun m => In m (a :: rslt)) p} +
                                       {exists l1 l2 e1 s2, Forall (fun m => In m (a :: rslt)) l1 /\
                                                            g |= l1 is a ~o~> e1 satisfying P /\
                                                            g |= l2 is s2 ~o~> b satisfying P /\
                                                            edge g e1 s2 /\
                                                            ~ In s2 (a::rslt) /\ p = l1 ++ l2 /\
                                                            ~ In s2 l1}.
Proof.
  intros. remember (findNotIn p (a :: rslt) nil) as f. destruct f as [n [l1 l2]]. destruct n. right.
  apply eq_sym in Heqf. destruct (find_not_in_some _ _ _ _ _ Heqf) as [? [? [? ?]]]. exists l1, (v :: l2).
  rewrite Forall_forall in H0. destruct l1. rewrite app_nil_l in H1.
  generalize (reachable_by_path_head _ _ _ _ _ H); intro. rewrite H1 in *. simpl in H4. inversion H4.
  rewrite H6 in *. exfalso; apply H3; apply in_eq.
  generalize (reachable_by_path_head _ _ _ _ _ H); intro.
  rewrite <- app_comm_cons in H1. rewrite H1 in H4. simpl in H4. inversion H4. rewrite H6 in *. clear H4 H6 v0.
  remember (foot (a :: l1)). destruct o. exists v0, v. split. rewrite Forall_forall; auto.
  assert (paths_meet_at (a :: l1) (v0 :: v :: l2) v0) by (repeat split; auto).
  assert (g |= path_glue (a :: l1) (v0 :: v :: l2) is a ~o~> b satisfying P). unfold path_glue. simpl.
  rewrite <- H1. auto. destruct (reachable_by_path_split_glue _ _ _ _ _ _ _ H4 H5). clear H4 H5. split; auto.
  assert (paths_meet_at (v0 :: v :: nil) (v :: l2) v) by repeat split.
  assert (g |= path_glue (v0 :: v :: nil) (v :: l2) is v0 ~o~> b satisfying P). unfold path_glue. simpl. auto.
  destruct (reachable_by_path_split_glue _ _ _ _ _ _ _ H4 H5). clear H4 H5 H6 H7. split; auto.
  split. destruct H8. destruct H5. destruct H5. auto. split. auto. split; simpl; auto.
  apply eq_sym in Heqo. generalize (foot_none_nil (a :: l1) Heqo); intros. inversion H4.
  assert (fst (findNotIn p (a :: rslt) nil) = None) by (rewrite <- Heqf; simpl; auto). left.
  apply find_not_in_none with nil. auto.
Qed.

Lemma reachable_through_set_eq (g: Gph):
  forall a S x, reachable_through_set g (a :: S) x <-> reachable g a x \/ reachable_through_set g S x.
Proof.
  intros; split; intros. destruct H as [s [? ?]]. apply in_inv in H. destruct H. subst. left; auto. right. exists s.
  split; auto. destruct H. exists a. split. apply in_eq. auto. destruct H as [s [? ?]]. exists s. split. apply in_cons. auto.
  auto.
Qed.

Lemma reachable_path_in:
  forall (g: Gph) (p: list V) (l y : V), g |= p is l ~o~> y satisfying (fun _ : V => True) ->
                                                   forall z, In z p -> reachable g l z.
Proof.
  intros. destruct H as [[? ?] [? ?]]. apply in_split in H0. destruct H0 as [l1 [l2 ?]]. exists (l1 +:: z). subst. split.
  split. destruct l1; simpl; simpl in H; auto. rewrite foot_last. auto. split. rewrite app_cons_assoc in H2.
  apply valid_path_split in H2. destruct H2. auto. hnf. rewrite Forall_forall; intros; auto.
Qed.

Lemma reachable_by_path_in: forall (g: Gph) (p: list V) (l y : V) (P: V -> Prop),
    g |= p is l ~o~> y satisfying P -> forall z, In z p -> g |= l ~o~> z satisfying P.
Proof.
  intros. destruct H as [[? ?] [? ?]]. apply in_split in H0. destruct H0 as [l1 [l2 ?]]. exists (l1 +:: z). subst.
  split; split.
  + destruct l1; simpl; simpl in H; auto.
  + rewrite foot_last. auto.
  + rewrite app_cons_assoc in H2. apply valid_path_split in H2. destruct H2. auto.
  + unfold path_prop in H3 |-* . rewrite Forall_forall in H3 |-* . intros. apply H3.
    rewrite in_app_iff in H0 |-* . destruct H0; [left | right]; auto. simpl in H0.
    destruct H0. subst. apply in_eq. exfalso; auto.
Qed.

Lemma reachable_path_in':
  forall (g: Gph) (p: list V) (l y : V), g |= p is l ~o~> y satisfying (fun _ : V => True) ->
                                         forall z, In z p -> reachable g z y.
Proof.
  intros. destruct H as [[? ?] [? ?]]. apply in_split in H0.
  destruct H0 as [l1 [l2 ?]]. exists (z :: l2). subst. split; split.
  + simpl. auto.
  + rewrite foot_app in H1; auto. intro. inversion H0.
  + apply valid_path_split in H2. intuition.
  + hnf. rewrite Forall_forall; intros; auto.
Qed.

Lemma reachable_by_path_in': forall (g: Gph) (p: list V) (l y : V) (P: V -> Prop),
    g |= p is l ~o~> y satisfying P -> forall z, In z p -> g |= z ~o~> y satisfying P.
Proof.
  intros. destruct H as [[? ?] [? ?]]. apply in_split in H0.
  destruct H0 as [l1 [l2 ?]]. exists (z :: l2). subst. split; split.
  + simpl. auto.
  + rewrite foot_app in H1; auto. intro. inversion H0.
  + apply valid_path_split in H2. intuition.
  + unfold path_prop in H3 |-* . rewrite Forall_forall in H3 |-* . intros. apply H3.
    rewrite in_app_iff. right; auto.
Qed.

Lemma reachable_list_permutation:
  forall (g: Gph) x l1 l2,
    reachable_list g x l1 -> reachable_list g x l2 -> NoDup l1 -> NoDup l2 -> Permutation l1 l2.
Proof. intros. apply NoDup_Permutation; auto. intro y. rewrite (H y), (H0 y). tauto. Qed.

Lemma reachable_through_set_single:
  forall (g: Gph) x y, reachable_through_set g (x :: nil) y <-> reachable g x y.
Proof.
  intros.
  unfold reachable_through_set; split; intros.
  + destruct H as [? [[? | ?] ?]]; [subst; auto |].
    inversion H.
  + exists x; split; auto.
    left; auto.
Qed.

Lemma reachable_valid_and_through_single:
  forall (g: Gph) {x y}, reachable g x y -> (vvalid g y /\ reachable_through_set g (x :: nil) y).
Proof.
  intros. split.
  + apply reachable_foot_valid in H; auto.
  + exists x. split.
    - apply in_eq.
    - auto.         
Qed.

Lemma reachable_list_EnumCovered: forall (g: Gph) x l, reachable_list g x l -> EnumCovered V (reachable g x).
Proof.
  unfold reachable_list, EnumCovered, Ensembles.In.
  intros.
  exists (remove_dup equiv_dec l).
  split.
  + apply remove_dup_nodup.
  + intros y ?.
    specialize (H y).
    rewrite <- remove_dup_in_inv.
    tauto.
Qed.

Lemma reachable_set_list_EnumCovered: forall (g: Gph) S l, reachable_set_list g S l -> EnumCovered V (reachable_through_set g S).
Proof.
  unfold reachable_set_list, EnumCovered, Ensembles.In.
  intros.
  exists (remove_dup equiv_dec l).
  split.
  + apply remove_dup_nodup.
  + intros y ?.
    specialize (H y).
    rewrite <- remove_dup_in_inv.
    tauto.
Qed.

Lemma FiniteGraph_EnumCovered: forall (g: Gph) (fin: FiniteGraph g) x, EnumCovered V (reachable g x).
Proof.
  intros.
  destruct fin as [[xs [? ?]] _].
  exists xs.
  split; auto.
  intros y ?.
  apply reachable_foot_valid in H1.
  rewrite H0.
  exact H1.
Qed.

Lemma reachable_by_ind: forall (g: Gph) x y P,
                           g |= x ~o~> y satisfying P -> x = y \/
                                                         exists z, g |= x ~> z /\
                                                                   g |= z ~o~> y satisfying (fun n => P n /\ n <> x).
Proof.
  intros. rewrite reachable_acyclic in H. destruct (equiv_dec x y). left; auto. right.
  destruct H as [path [? [[? ?] [? ?]]]]. destruct path; inversion H0. subst.
  destruct path0. inversion H1. exfalso; auto. exists v. simpl in H2. destruct H2. split; auto.
  exists (v :: path0). simpl in H1. split; split; simpl; auto.
  hnf in H3. hnf. rewrite Forall_forall in *. intros; split.
  + apply H3. apply in_cons; auto.
  + apply NoDup_cons_2 in H. intro. subst. apply H; auto.
Qed.

Lemma reachable_by_weaken: forall (g: Gph) x y P Q,
                                  Included P Q ->
                                  g |= x ~o~> y satisfying P ->
                                  g |= x ~o~> y satisfying Q.
Proof.
  intros. destruct H0 as [p [? [? ?]]].
  exists p. do 2 (split; auto). hnf in *.
  rewrite Forall_forall in *. intros. apply H. apply H2. auto.
Qed.

Lemma reachable_by_ind_equiv:
  forall (g: PreGraph V E) n1 l n2 (P: Ensemble V),
     let P' := Intersection _ P (Complement _ (eq n1)) in
     vvalid g n1 ->
     step_list g n1 l ->
     P n1 ->
     (g |= n1 ~o~> n2 satisfying P <->
     n1 = n2 \/ reachable_by_through_set g l P' n2).
Proof.
  intros.
  split; intros.
  + apply reachable_by_ind in H2.
    destruct H2; [auto | right].
    destruct H2 as [n [[? [? ?]] ?]].
    exists n.
    split; [rewrite (H0 n); auto |].
    eapply reachable_by_weaken; [| eauto].
    clear.
    intro n; unfold P', Ensembles.In.
    rewrite Intersection_spec.
    unfold Complement, Ensembles.In.
    assert (n <> n1 <-> n1 <> n) by (split; intros; congruence).
    tauto.
  + destruct H2.
    - subst; eapply reachable_by_refl; auto.
    - destruct H2 as [n [? ?]].
      rewrite (H0 n) in H2.
      apply edge_reachable_by with n.
      * auto.
      * split; [| split]; auto.
        apply reachable_by_head_valid in H3; auto.
      * eapply reachable_by_weaken; [| eauto].
        apply Intersection1_Included, Included_refl.
Qed.

Lemma reachable_by_through_set_weaken:
  forall (g: Gph) l x P Q,
    Included P Q ->
    reachable_by_through_set g l P x ->
    reachable_by_through_set g l Q x.
Proof.
  intros.
  destruct H0 as [s [? ?]].
  exists s; split; auto.
  eapply reachable_by_weaken; eauto.
Qed.

Lemma reachable_by_eq: forall (g: Gph) x y P Q,
                                  (forall z, P z <-> Q z) ->
                                  (g |= x ~o~> y satisfying P <-> g |= x ~o~> y satisfying Q).
Proof.
  intros until y.
  intros; split; apply reachable_by_weaken; firstorder.
Qed.

Lemma reachable_through_set_app: forall g S1 S2 x,
  reachable_through_set g S1 x \/ reachable_through_set g S2 x <-> reachable_through_set g (S1 ++ S2) x.
Proof.
  intros; split; intros; [destruct H as [[s ?] | [s ?]] | destruct H as [s ?]].
  + exists s; split; [| tauto].
    rewrite in_app_iff; tauto.
  + exists s; split; [| tauto].
    rewrite in_app_iff; tauto.
  + rewrite in_app_iff in H; destruct H as [[? | ?] ?]; [left | right];
    exists s; tauto.
Qed.

Lemma reachable_through_set_app_left: forall g S1 S2 x,
  reachable_through_set g S1 x -> reachable_through_set g (S1 ++ S2) x.
Proof.
  intros.
  rewrite <- reachable_through_set_app; tauto.
Qed.

Lemma reachable_through_set_app_right: forall g S1 S2 x,
  reachable_through_set g S2 x -> reachable_through_set g (S1 ++ S2) x.
Proof.
  intros.
  rewrite <- reachable_through_set_app; tauto.
Qed.

Class ReachableFiniteGraph (pg: PreGraph V E) := {
  finiteR: forall x, vvalid pg x -> Enumerable V (reachable pg x)
}.

Lemma construct_reachable_list: forall (g: Gph) {rfg: ReachableFiniteGraph g} x, Decidable (vvalid g x) -> {l: list V | NoDup l /\ reachable_list g x l}.
Proof.
  intros.
  destruct H.
  + destruct (finiteR x v) as [l ?H].
    exists l.
    unfold reachable_list; auto.
  + exists nil.
    split; [constructor |].
    intro; simpl.
    pose proof reachable_head_valid g x y.
    tauto.
Qed.

Lemma RFG_reachable_decicable: forall (g: Gph) {rfg: ReachableFiniteGraph g} x y, vvalid g x -> Decidable (reachable g x y).
Proof.
  intros.
  pose proof finiteR x H.
  destruct X as [l [_ ?H]].
  unfold Ensembles.In in H0.
  destruct (in_dec equiv_dec y l); [left | right]; rewrite <- H0; auto.
Qed.

Lemma RFG_reachable_decicable': forall (g: Gph) {rfg: ReachableFiniteGraph g} x y, Decidable (vvalid g x) -> Decidable (reachable g x y).
Proof.
  intros.
  destruct H; [apply RFG_reachable_decicable; auto | right].
  intro.
  apply reachable_head_valid in H; tauto.
Qed.

Lemma construct_reachable_set_list: forall (g: Gph) {rfg: ReachableFiniteGraph g} S
  (V_DEC: forall x, In x S -> Decidable (vvalid g x)),
  {l: list V | NoDup l /\ reachable_set_list g S l}.
Proof.
  intros.
  induction S.
  + exists nil.
    split; [constructor |].
    intro.
    pose proof reachable_through_empty g.
    pose proof Empty_set_iff V.
    unfold Same_set, Included, Ensembles.In in *.
    simpl.
    firstorder.
  + spec IHS.
    - intros; apply V_DEC.
      right; auto.
    - destruct IHS as [l2 ?H].
      destruct (construct_reachable_list g a (V_DEC a (or_introl eq_refl))) as [l1 ?H].
      exists (remove_dup equiv_dec (l1 ++ l2)).
      split; [apply remove_dup_nodup |].
      destruct H as [_ ?].
      destruct H0 as [_ ?].
      unfold reachable_set_list, reachable_list in *.
      intros.
      rewrite <- remove_dup_in_inv.
      rewrite in_app_iff, reachable_through_set_eq.
      specialize (H x).
      specialize (H0 x).
      tauto.
Qed.

Lemma RFG_reachable_through_set_decicable: forall (g: Gph) {rfg: ReachableFiniteGraph g} S y, (forall x, In x S -> Decidable (vvalid g x)) -> Decidable (reachable_through_set g S y).
Proof.
  intros.
  destruct (construct_reachable_set_list g S X) as [l [_ ?]].
  destruct (in_dec equiv_dec y l); [left | right]; rewrite <- (H y); auto.
Qed.

Lemma reachable_by_through_nil: forall g P n, reachable_by_through_set g nil P n <-> False.
Proof.
  intros; split; intro.
  + destruct H as [s [? ?]]. inversion H.
  + exfalso; auto.
Qed.

Lemma reachable_by_through_singleton:
  forall g P n1 n2, reachable_by_through_set g (n1 :: nil) P n2 <-> g |= n1 ~o~> n2 satisfying P.
Proof.
  intros. unfold reachable_by_through_set; split; intro.
  + destruct H as [s [? ?]]. simpl in H. destruct H; [subst | exfalso]; auto.
  + exists n1. split; [apply in_eq | auto].
Qed.

Lemma reachable_by_through_singleton':
  forall g P n, Same_set (reachable_by_through_set g (n :: nil) P) (reachable_by g n P).
Proof.
  intros.
  rewrite Same_set_spec; intro n'.
  apply reachable_by_through_singleton.
Qed.

Lemma reachable_by_through_app: forall g P n l1 l2, reachable_by_through_set g (l1 ++ l2) P n <-> reachable_by_through_set g l1 P n \/ reachable_by_through_set g l2 P n.
Proof.
  intros.
  unfold reachable_by_through_set.
  split; [intros [s [? ?]] | intros [[s [? ?]] | [s [? ?]]]].
  + rewrite in_app_iff in H.
    destruct H; [left | right]; exists s; auto.
  + exists s.
    rewrite in_app_iff; auto.
  + exists s.
    rewrite in_app_iff; auto.
Qed.

Lemma reachable_by_through_app': forall g P l1 l2,
  Same_set
   (reachable_by_through_set g (l1 ++ l2) P)
   (Union _ (reachable_by_through_set g l1 P) (reachable_by_through_set g l2 P)).
Proof.
  intros.
  rewrite Same_set_spec; intro n; rewrite Union_spec.
  apply reachable_by_through_app.
Qed.

Lemma reachable_by_through_non_foot: forall g P n l l0, reachable_by_through_set g l P n -> reachable_by_through_set g (l ++ l0 :: nil) P n.
Proof.
  intros.
  rewrite reachable_by_through_app; tauto.
Qed.

Lemma reachable_by_through_foot: forall g P n l l0, reachable_by g l0 P n -> reachable_by_through_set g (l ++ l0 :: nil) P n.
Proof.
  intros.
  rewrite reachable_by_through_app, reachable_by_through_singleton; tauto.
Qed.

Definition ReachDecidable (g: Gph) (x : V) (P : V -> Prop) :=
  forall y, Decidable (g |= x ~o~> y satisfying P).

End PATH_LEM.

Arguments path_glue {_} _ _.

Module PathNotation.
Notation "p1 '+++' p2" := (path_glue p1 p2) (at level 20, left associativity).
End PathNotation.

Notation " g '|=' p 'is' n1 '~o~>' n2 'satisfying' P" := (reachable_by_path g p n1 P n2) (at level 1).
Notation " g '|=' n1 '~o~>' n2 'satisfying' P " := (reachable_by g n1 P n2) (at level 1).
Notation " g '|=' n1 '~~>' n2 'satisfying' P " := (reachable_by_acyclic g n1 P n2) (at level 1).

