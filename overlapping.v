Require Import msl.msl_classical.
Require Import ramify_tactics.

Lemma join_age {A}{JA: Join A}{PA: Perm_alg A}{AG: ageable A}{XA: Age_alg A}:
  forall h1 h2 h12 h1' h2' h12', join h1 h2 h12 -> join h1' h2' h12' -> age h1 h1' -> age h2 h2' -> age h12 h12'.
Proof.
  intros; destruct (age1_join _ H H1) as [w2 [w12 [? [? ?]]]];
  equate_age h2' w2; equate_join h12' w12; auto.
Qed.

Program Definition ocon {A: Type}{JA: Join A}{PA: Perm_alg A}{AG: ageable A}{XA: Age_alg A} (p q:pred A) : pred A :=
  fun h:A => exists h1 h2 h3 h12 h23, join h1 h2 h12 /\ join h2 h3 h23 /\ join h12 h3 h /\ p h12 /\ q h23.
Next Obligation.
  destruct H0 as [h1 [h2 [h3 [h12 [h23 [? [? [? [? ?]]]]]]]]].
  try_join h2 h3 h23'; equate_join h23 h23'.
  destruct (age1_join2 _ H2 H) as [w12 [w3 [? [? ?]]]].
  destruct (age1_join2 _ H0 H7) as [w1 [w2 [? [? ?]]]].
  try_join w2 w3 w23.
  exists w1, w2, w3, w12, w23.
  repeat split; auto.
  apply pred_hereditary with h12; auto.
  apply pred_hereditary with h23; auto.
  apply (join_age h2 h3 _ w2 w3 _); auto.
Qed.

Notation "P ⊗ Q" := (ocon P Q) (at level 40, left associativity) : pred.

Lemma ocon_emp {A}{JA: Join A}{PA: Perm_alg A}{SA: Sep_alg A}{CA: Canc_alg A}{AG: ageable A}{XA: Age_alg A}:
  forall P: pred A, (P ⊗ emp = P)%pred.
Proof.
  intros; apply pred_ext; hnf; intros; simpl in *; intros.
  destruct H as [h1 [h2 [h3 [h12 [h23 [? [? [? [? ?]]]]]]]]].
  try_join h2 h3 h23'; equate_join h23 h23'.
  rewrite (H3 _ _ (join_comm H5)) in H.
  generalize (join_positivity H H1); intro; rewrite H4; trivial.
  exists a, (core a), (core a), a, (core a).
  generalize (core_unit a); intro.
  unfold unit_for in H0.
  repeat split; auto.
  apply core_duplicable.
  apply core_identity.
Qed.

Lemma andp_ocon {A}{JA: Join A}{PA: Perm_alg A}{SA: Sep_alg A}{AG: ageable A}{XA: Age_alg A}:
  forall P Q, P && Q |-- P ⊗ Q.
Proof.
  intros.
  hnf; intros; simpl in *; intros.
  destruct H.
  remember (core a) as u.
  exists u, a, u, a, a.
  repeat split; try rewrite Hequ; auto;
  try apply core_unit;
  apply join_comm; apply core_unit.
Qed.

Lemma sepcon_ocon {A}{JA: Join A}{PA: Perm_alg A}{SA: Sep_alg A}{AG: ageable A}{XA: Age_alg A}:
  forall P Q, P * Q |-- P ⊗ Q.
Proof.
  intros; hnf; intros; simpl in *; intros.
  destruct H as [y [z [? [? ?]]]].
  remember (core z) as u.
  exists y, u, z, y, z.
  repeat split; auto.
  generalize (join_core H); intro.
  generalize (join_core (join_comm H)); intro.
  rewrite Hequ.
  replace (core z) with (core y).
  apply join_comm, core_unit.
  rewrite H2, H3; trivial.
  rewrite Hequ. apply core_unit.
Qed.

Lemma ocon_sep_true {A}{JA: Join A}{PA: Perm_alg A}{AG: ageable A}{XA: Age_alg A}:
  forall P Q, P ⊗ Q |-- P * TT.
Proof.
  intros; hnf; intros; simpl in *; intros.
  destruct H as [h1 [h2 [h3 [h12 [h23 [? [? [? [? ?]]]]]]]]].
  exists h12, h3.
  repeat split; auto.
Qed.


Lemma join_necR {A}{JA: Join A}{PA: Perm_alg A}{AG: ageable A}{XA: Age_alg A}:
  forall h1 h2 h12 h1' h2' h12', join h1 h2 h12 -> join h1' h2' h12' -> necR h1 h1' -> necR h2 h2' -> necR h12 h12'.
Proof.
  intros; destruct (nec_join H H1) as [w2 [w12 [? [? ?]]]];
  destruct (join_level _ _ _ H3); rewrite <- H7 in H6;
  destruct (join_level _ _ _ H0); rewrite <- H9 in H8;
  rewrite H8 in H6; generalize (necR_linear' H2 H4 H6); intro;
  rewrite <- H10 in H3; equate_join h12' w12; auto.
Qed.

Lemma ocon_wand {A}{JA: Join A}{PA: Perm_alg A}{AG: ageable A}{XA: Age_alg A}:
  forall P Q, (P ⊗ Q = EX R : pred A, (R -* P) * (R -* Q) * R)%pred.
Proof.
  intros; apply pred_ext; hnf; intros; simpl in *.
  destruct H as [h1 [h2 [h3 [h12 [h23 [? [? [? [? ?]]]]]]]]].
  try_join h2 h3 h23'; equate_join h23 h23'; try_join h1 h3 h13.
  exists (exactly h2), h13, h2; repeat split; simpl; auto; exists h1, h3; repeat split; auto.
  intros h1' h2' h12'; intros; apply (pred_nec_hereditary P h12); auto; apply (join_necR h1 h2 _ h1' h2' _); auto.
  intros h3' h2' h23'; intros; apply (pred_nec_hereditary Q h23); auto; apply (join_necR h2 h3 _ h2' h3' _); auto.
  (* another direction *)
  destruct H as [R [w13 [w2 [? [[w1 [w3 [? [HP HQ]]]] HR]]]]].
  try_join w2 w3 w23; try_join w1 w2 w12.
  exists w1, w2, w3, w12, w23; repeat split; auto.
  apply (HP w1 w2); auto. apply (HQ w3 w2); auto.
Qed.

Lemma ocon_comm {A}{JA: Join A}{PA: Perm_alg A}{AG: ageable A}{XA: Age_alg A}:
  forall P Q, (P ⊗ Q = Q ⊗ P)%pred.
Proof.
  intros; apply pred_ext; hnf; intros; simpl in *; intros;
  destruct H as [h1 [h2 [h3 [h12 [h23 [? [? [? [? ?]]]]]]]]];
  exists h3, h2, h1, h23, h12;
  repeat split; auto; try_join h2 h3 h23'; equate_join h23 h23'; auto.
Qed.

Lemma cross_rev {A}{JA: Join A}{PA: Perm_alg A}: forall h1 h2 h3 h4
  h12 h34 h13 h24 h1234, join h1 h2 h12 -> join h1 h3 h13 -> join h3 h4
  h34 -> join h2 h4 h24 -> join h12 h34 h1234 -> join h13 h24 h1234.
Proof.
  intros; try_join h2 h34 h234;
  try_join h2 h4 h24'; equate_join h24 h24';
  try_join h1 h3 h13'; equate_join h13 h13'; auto.
Qed.

Lemma ocon_assoc {A}{JA: Join A}{PA: Perm_alg A}{CA: Cross_alg A}{AG: ageable A}{XA: Age_alg A}:
  forall P Q R: pred A, (P ⊗ Q ⊗ R = P ⊗ (Q ⊗ R))%pred.
Proof.
  intros; apply pred_ext; hnf; intros; simpl in *; intros.
  destruct H as [w124 [w567 [w3 [w124567 [w3567 [? [? [? [[w15 [w47 [w26 [w1457 [w2467 [? [? [? [? ?]]]]]]]]] ?]]]]]]]]].
  destruct (cross_split _ _ _ _ _ H H4) as [[[[w14 w2] w57] w6] [? [? [? ?]]]].
  destruct (cross_split _ _ _ _ _ H2 H10) as [[[[w1 w5] w4] w7] [? [? [? ?]]]].
  try_join w5 w47 w457; try_join w3 w26 w236; try_join w236 w457 w234567.
  exists w1, w457, w236, w1457, w234567; repeat split; auto.
  try_join w2 w4 w24; try_join w6 w7 w67; try_join w3 w5 w35.
  exists w24, w67, w35, w2467, w3567; repeat split; auto.
  apply (cross_rev w2 w6 w4 w7 w26 w47); auto. apply (cross_rev w47 w5 w26 w3 w457 w236); auto.
  (* another direction *)
  destruct H as [w1 [w457 [w236 [w1457 [w234567 [? [? [? [? [w24 [w67 [w35 [w2467 [w3567 [? [? [? [? ?]]]]]]]]]]]]]]]]]].
  destruct (cross_split _ _ _ _ _ H0 H5) as [[[[w47 w5] w26] w3] [? [? [? ?]]]].
  destruct (cross_split _ _ _ _ _ H3 H10) as [[[[w4 w2] w7] w6] [? [? [? ?]]]].
  try_join w26 w1457 w124567; try_join w5 w67 w567; try_join w5 w7 w57; try_join w1 w4 w14;
  try_join w14 w26 w1246; try_join w2 w14 w124.
  exists w124, w567, w3, w124567, w3567; repeat split; auto.
  apply join_comm; apply (cross_rev w6 w2 w57 w14 w26 w1457); auto.
  try_join_through w67 w5 w7 w57'; equate_join w57 w57'; auto.
  try_join w1 w5 w15; exists w15, w47, w26, w1457, w2467;
  repeat split; auto.
Qed.

Definition covariant {B A : Type} {AG: ageable A} (F: (B -> pred A) -> (B -> pred A)) : Prop :=
forall (P Q: B -> pred A), (forall x, P x |-- Q x) -> (forall x, F P x |-- F Q x).

Lemma ocon_derives {A} {JA: Join A}{PA: Perm_alg A}{AG: ageable A}{XA: Age_alg A}:
  forall p q p' q', (p |-- p') -> (q |-- q') -> (p ⊗ q |-- p' ⊗ q').
Proof.
  repeat (intros; hnf).
  simpl in H1.
  destruct H1 as [w1 [w2 [w3 [w12 [w23 [? [? [? [? ?]]]]]]]]].
  exists w1,w2,w3,w12,w23.
  repeat split; auto.
Qed.

Lemma covariant_ocon {B}{A} {JA: Join A}{PA: Perm_alg A}{AG: ageable A}{XA: Age_alg A}:
   forall F1 F2 : (B -> pred A) -> (B -> pred A),
    covariant F1 -> covariant F2 ->
    covariant (fun (x : B -> pred A) b => F1 x b ⊗ F2 x b)%pred.
Proof.
  intros; hnf.
  intros P Q ? ?.
  eapply ocon_derives.
  apply H, H1.
  apply H0, H1.
Qed.

Definition contravariant {B A : Type} {AG: ageable A} (F: (B -> pred A) -> (B -> pred A)) : Prop :=
forall (P Q: B -> pred A), (forall x, P x |-- Q x) -> (forall x, F Q x |-- F P x).

Lemma contravariant_ocon {B}{A} {JA: Join A}{PA: Perm_alg A}{AG: ageable A}{XA: Age_alg A}:
   forall F1 F2 : (B -> pred A) -> (B -> pred A),
    contravariant F1 -> contravariant F2 ->
    contravariant (fun (x : B -> pred A) b => F1 x b ⊗ F2 x b)%pred.
Proof.
  intros; hnf.
  intros P Q ? ?.
  eapply ocon_derives.
  apply H, H1.
  apply H0, H1.
Qed.

Lemma later_ocon {A}{JA: Join A}{PA: Perm_alg A}{SA: Sep_alg A}{AG: ageable A}{XA: Age_alg A}:
  forall P Q, ((|> (P ⊗ Q)) = |> Q ⊗ |> P)%pred.
Proof.
  intros; repeat rewrite later_age; apply pred_ext; hnf; intros; simpl in *.
  case_eq (age1 a); intros.
  destruct (H a0) as [h1' [h2' [h3' [h12' [h23' [? [? [? [? ?]]]]]]]]]; auto.
  destruct (unage_join2 _ H3 H0) as [x12 [x3 [? [? ?]]]].
  destruct (unage_join2 _ H1 H7) as [x1 [x2 [? [? ?]]]].
  try_join x2 x3 x23; exists x3, x2, x1, x23, x12; repeat (split; auto).
  assert (age x23 h23') by (apply (join_age x2 x3 _ h2' h3' _); auto); intro h23; intros; equate_age h23' h23; auto.
  assert (age x12 h12') by (apply (join_age x1 x2 _ h1' h2' _); auto); intro h12; intros; equate_age h12' h12; auto.
  exists (core a), a, (core a), a, a. repeat split.
  apply core_unit. apply join_comm, core_unit. apply join_comm, core_unit.
  intros; unfold age in H1; rewrite H0 in H1; discriminate H1.
  intros; unfold age in H1; rewrite H0 in H1; discriminate H1.
  (* another direction *)
  destruct H as [x1 [x2 [x3 [x12 [x23 [? [? [? [? ?]]]]]]]]]; intros.
  destruct (age1_join2 _ H1 H4) as [h12 [h3 [? [? ?]]]].
  destruct (age1_join2 _ H H6) as [h1 [h2 [? [? ?]]]].
  try_join h2 h3 h23; exists h3, h2, h1, h23, h12; repeat (split; auto).
  apply H3; apply (join_age x2 x3 _ h2 h3 _); auto.
Qed.

Lemma subp_ocon {A} {JA : Join A} {PA : Perm_alg A} {SA: Sep_alg A} {AG: ageable A} {XA: Age_alg A} :
  forall G P P' Q Q',
    G |-- P >=> P' ->
    G |-- Q >=> Q' ->
    G |-- P ⊗ Q >=> P' ⊗ Q'.
Proof.
  repeat intro.
  destruct H4 as [x0 [x1 [x2 [x3 [x4 [? [? [? [? ?]]]]]]]]].
  destruct (join_level _ _ _ H5); destruct (join_level _ _ _ H6); apply necR_level in H3.
  exists x0, x1, x2, x3, x4; repeat (split; auto);
  [specialize (H a H1 x3); apply H | specialize (H0 a H1 x4); apply H0]; intuition.
Qed.


(* Require Import msl.cjoins. *)
(* Require Import msl.cross_split. *)

(* Lemma assoc_ocon_cross {A}{JA: Join A}{PA: Perm_alg A}{AG: ageable A}{XA: Age_alg A}: *)
(*   (forall P Q R: pred A, (P ⊗ Q ⊗ R = P ⊗ (Q ⊗ R))%pred) -> sa_distributive A. *)
(* Proof. *)
(*   intros; hnf; intros. *)
