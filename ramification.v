Require Import msl.msl_classical.
Require Import overlapping.
Require Import ramify_tactics.
Require Import msl.sepalg_list.

Definition ramify {A: Type}{JA: Join A}{PA: Perm_alg A}{AG: ageable A}{XA: Age_alg A}
           (R P Q R' : pred A) := R |-- P * (Q -* R').

Lemma ocon_ramification {A: Type}{JA: Join A}{PA: Perm_alg A}{CA: Cross_alg A}{CAA: Canc_alg A}{SA: Sep_alg A}{AG: ageable A}{XA: Age_alg A}:
  forall P Q R R' F, precise P -> precise Q -> ramify (P ⊗ R) P Q (Q ⊗ R') ->
                     ramify ((P * F) ⊗ R) P Q ((Q * F) ⊗ R').
Proof.
  intros; hnf; intros; simpl in H2;
  destruct H2 as [h1 [h2 [h3 [h12 [h23 [? [? [? [[y [z [? [HPy HFz]]]] HR23]]]]]]]]];
  destruct (cross_split h1 h2 y z h12 H2 H5) as [[[[h1y h1z] h2y] h2z] [? [? [? ?]]]].
  try_join h1y h2 h1y2; try_join h1y2 h3 h1y23; try_join h1y h2y y'; equate_join y y'.
  try_join h2z h3 h2z3; try_join_through h1y2 h2z h3 h2z3'; equate_join h2z3 h2z3';
  assert (HPR: (P ⊗ R)%pred h1y23) by (simpl; exists h1y, h2y, h2z3, y, h23; split; auto);
  specialize (H1 h1y23 HPR); destruct H1 as [y' [h2z3' [? [HPy' HPQ]]]]; equate_precise y y';
  equate_canc h2z3 h2z3'; try_join z h3 hz3; exists y, hz3; repeat split; auto;
  intros hz3' m hz3'm HnecRz3 ? HQm; destruct (nec_join2 H1 HnecRz3) as [z' [h3' [? [HnecRz HnecR3]]]];
  assert (HFz': F z') by (apply pred_nec_hereditary with z; auto).
  try_join h2z h3 h2z3'; equate_join h2z3 h2z3';
  destruct (nec_join2 H22 HnecRz3) as [h1z' [h2z3' [? [HnecR1z' HnecR2z3']]]]; try_join h2z3' m h2z3'm;
  assert (HQR': (Q ⊗ R')%pred h2z3'm) by (apply HPQ with (x' := h2z3')(y := m); auto);
  destruct HQR' as [m1 [m2 [h2z3'' [m' [hm22z3' [? [? [? [HQm' HR']]]]]]]]]; equate_precise m m'; equate_canc h2z3' h2z3'';
  destruct (nec_join2 H14 HnecR2z3') as [h2z' [h3'' [? [HnecR2z' HnecR3'']]]];
  assert (Heq: h3'' = h3') by (apply @necR_linear' with (a := h3)(H := AG); auto;
                               apply join_level in H27; destruct H27 as [? Heq1]; rewrite Heq1;
                               apply join_level in H21; destruct H21 as [? Heq2]; rewrite Heq2;
                               apply join_level in H20; destruct H20 as [? Heq3]; auto); rewrite Heq in *;
  clear Heq HnecR3'' h3''; try_join h1z' h2z' z''; equate_canc z' z'';
  try_join h2z' m2 m22z'; try_join z' m hz'm; try_join m1 z' hz'm1; try_join h1z' m1 m11z';
  exists m11z', m22z', h3', hz'm, hm22z3'; repeat split; auto;
  [try_join h2z' m2 m22z''; equate_join m22z' m22z''| exists m, z'; split]; auto.
Qed.

Lemma andp_ramification1 {A: Type}{JA: Join A}{PA: Perm_alg A}{CAA: Canc_alg A}{SA: Sep_alg A}{AG: ageable A}{XA: Age_alg A}:
  forall P Q R R' F, precise P -> ramify R P Q R' -> ramify ((P * F) && R) P Q ((Q * F) && R').
Proof.
  intros; hnf; intros; destruct H1 as [[y [z [? [? ?]]]] ?].
  specialize (H0 a H4); destruct H0 as [y' [z' [? [? ?]]]]; equate_precise y y'; equate_canc z z'.
  exists y, z; do 2 (split; auto); intros z' m z'm; intros; specialize (H6 z' m z'm H0 H5 H7).
  split; auto; exists m, z'; repeat split; auto; apply pred_nec_hereditary with z; auto.
Qed.

Notation "P '-⊛' Q" := (ewand P Q) (at level 60, right associativity) : pred.

Lemma andp_ramification2 {A: Type}{JA: Join A}{PA: Perm_alg A}{SA: Sep_alg A}{AG: ageable A}{XA: Age_alg A}:
  forall P Q R R' F, (P -⊛ R |-- Q -* R') -> ramify ((P * F) && R) P Q ((Q * F) && R').
Proof.
  intros; hnf; intros; destruct H0 as [[y [z [? [? ?]]]] ?].
  assert ((P -⊛ R)%pred z) by (exists y, a; repeat split; auto).
  specialize (H z H4); exists y, z; do 2 (split; auto).
  intros z' m z'm; intros; specialize (H z' m z'm H5 H6 H7).
  split; auto; exists m, z'; repeat split; auto; apply pred_nec_hereditary with z; auto.
Qed.

Lemma disjoint_ramificatin {A: Type}{JA: Join A}{PA: Perm_alg A}{AG: ageable A}{XA: Age_alg A}:
  forall R P P' R' S Q Q' S', ramify R P P' R' -> ramify S Q Q' S' -> ramify (R * S) (P * Q) (P' * Q') (R' * S').
Proof.
  intros; hnf; intro ab; intros; destruct H1 as [a [b [? [? ?]]]].
  specialize (H a H2); specialize (H0 b H3).
  destruct H as [a1 [a2 [? [? ?]]]]; destruct H0 as [b1 [b2 [? [? ?]]]].
  try_join a1 b a1b; try_join a1 b1 a1b1; try_join a2 b2 a2b2.
  exists a1b1, a2b2; repeat split; auto. exists a1, b1; repeat split; auto.
  intros a2'b2' s1s2 w1w2; intros.
  destruct H16 as [s1 [s2 [? [? ?]]]]; destruct (nec_join2 H12 H14) as [b2' [a2' [? [? ?]]]].
  try_join a2' s1s2 a2's1s2; try_join a2' s1 a2's1; try_join b2' s2 b2's2.
  assert (R' a2's1) by (apply (H5 a2' s1); auto); assert (S' b2's2) by (apply (H7 b2' s2); auto).
  exists a2's1, b2's2; repeat split; auto.
Qed.

Lemma ocon_piecewise_ramification {A: Type}{JA: Join A}{PA: Perm_alg A}{CA: Cross_alg A}{CAA: Canc_alg A}{SA: Sep_alg A}{AG: ageable A}{XA: Age_alg A}:
  forall P P' Q1 Q2 Q1' Q2', precise P -> precise P' -> ramify (P ⊗ Q1) P P' (P' ⊗ Q1') -> ramify (P ⊗ Q2) P P' (P' ⊗ Q2')
                             -> ramify (P ⊗ Q1 ⊗ Q2) P P' (P' ⊗ Q1' ⊗ Q2').
Proof.
  intros; hnf; intros.
  destruct H3 as [h124 [h567 [h3 [h124567 [h3567 [? [? [? [[h15 [h47 [h26 [h1457 [h2467 [? [? [? [? ?]]]]]]]]] ?]]]]]]]]].
  destruct (cross_split _ _ _ _ _ H3 H8) as [[[[h14 h2] h57] h6] [? [? [? ?]]]].
  destruct (cross_split _ _ _ _ _ H6 H14) as [[[[h1 h5] h4] h7] [? [? [? ?]]]].
  try_join h26 h3 h236; exists h1457, h236; repeat split; auto.
  assert (HPQ1: (P ⊗ Q1)%pred h124567) by (exists h15, h47, h26, h1457, h2467; repeat split; auto).
  specialize (H1 h124567 HPQ1); destruct H1 as [h1457' [h26' [? [? ?]]]]; equate_precise h1457 h1457'; equate_canc h26 h26'.
  assert (join h14 h57 h1457) by (apply (cross_rev h1 h5 h4 h7 h15 h47); auto).
  try_join h3 h6 h36; try_join h36 h1457 h134567; try_join h14 h36 h1346.
  try_join_through h1346 h14 h57 h1457'; equate_join h1457 h1457'.
  try_join h3 h57 h357; try_join_through h357 h3 h6 h36'; equate_join h36 h36'.
  assert (HPQ2: (P ⊗ Q2)%pred h134567) by (exists h14, h57, h36, h1457, h3567; repeat split; auto).
  specialize (H2 h134567 HPQ2); destruct H2 as [h1457' [h36' [? [? ?]]]]; equate_precise h1457 h1457'; equate_canc h36 h36'.
  intros h236' h1457' a'; intros.
  destruct (nec_join2 H20 H2) as [h26' [h3' [? [? ?]]]]; destruct (nec_join2 H15 H37) as [h2' [h6' [? [? ?]]]].
  try_join h3' h6' h36'; assert (necR h36 h36') by (apply (join_necR h3 h6 _ h3' h6' _); auto).
  try_join h26' h1457' h124567'; try_join h36' h1457' h134567'.
  assert (HPQ1': (P' ⊗ Q1')%pred h124567') by (apply (H23 h26' h1457'); auto).
  assert (HPQ2': (P' ⊗ Q2')%pred h134567') by (apply (H34 h36' h1457'); auto).
  destruct HPQ1' as [h15' [h47' [h26'' [h1457'' [h2467' [? [? [? [? ?]]]]]]]]].
  equate_precise h1457' h1457''; equate_canc h26' h26''.
  destruct HPQ2' as [h14' [h57' [h36'' [h1457'' [h3567' [? [? [? [? ?]]]]]]]]].
  equate_precise h1457' h1457''; equate_canc h36' h36''.
  destruct (cross_split _ _ _ _ _ H49 H51) as [[[[h1' h5'] h4'] h7'] [? [? [? ?]]]].
  try_join h6' h57' h567'; try_join h2' h1457' h12457'; try_join h14' h2' h124'.
  try_join h124' h6' h1246'; try_join_through h1246' h6' h57' h567''; equate_join h567' h567''.
  exists h124', h567', h3', h124567', h3567'; repeat split; auto.
  exists h15', h47', h26', h1457', h2467'; repeat split; auto.
Qed.

(* Lemma exact_frame_ramification {A: Type}{JA: Join A}{PA: Perm_alg A}{CA: Cross_alg A}{CAA: Canc_alg A}{SA: Sep_alg A}{AG: ageable A}{XA: Age_alg A}: *)
(*   forall P Q R R' F, precise P -> (R |-- P * F * TT) -> (F -⊛ R' |-- F -* R') -> ramify R P Q R' -> ramify R (P * F) (Q * F) R'. *)
(* Proof. *)
(*   intros; hnf; intros; specialize (H0 a H3); specialize (H2 a H3). *)
(*   destruct H0 as [y [z [? [[y1 [y2 [? [? ?]]]] ?]]]]; destruct H2 as [y1' [y2z [? [? ?]]]]. *)
(*   try_join y2 z y2z'; equate_precise y1 y1'; equate_canc y2z y2z'. *)
(*   exists y, z; repeat split; auto. exists y1, y2; repeat split; auto. *)
(*   (* clear H5 H. *) *)
(*   replace (((Q * F) -* R')%pred) with ((Q -* (F -* R'))%pred). *)
(*   intros z' m' z'm' ? ? ?. apply H1. *)
(*   (* intros z' m' z'm'; intros; destruct H12 as [m1' [m2' [? [? ?]]]]. *) *)
(*   destruct (nec_join (join_comm H10) H8) as [y2' [y2z' [? [? ?]]]]. *)
(*   (* destruct (nec_join (join_comm H2) H17) as [y1' [a' [? [? ?]]]]. *) *)
(*   destruct (nec_join3 H11 H8) as [m [zm [? [? ?]]]]. *)
(*   destruct (nec_join4 _ _ _ _ H12 H22) as [m1 [m2 [? [? ?]]]]. *)
(*   simpl in H9; hnf in H1; simpl in H1. *)
(*   (* try_join m2' z' m2'z'; specialize (H9 m2'z' m1' z'm'); apply H9; auto. *) *)
(*   specialize (H9 y2z' y1' a' H17 H18). *)
(*   generalize (pred_nec_hereditary _ _ _ H16 H6); intro. *)
(*   admit. *)
(* Qed. *)


