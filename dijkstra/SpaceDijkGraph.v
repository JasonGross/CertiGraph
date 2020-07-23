Require Import VST.veric.SeparationLogic.
Require Import CertiGraph.floyd_ext.share.
Require Import CertiGraph.dijkstra.env_dijkstra_arr.
Require Import CertiGraph.dijkstra.MathDijkGraph.
Require Import CertiGraph.graph.AdjMatGraph.

Local Open Scope logic.

Lemma elabel_Znth_graph_to_mat:
  forall (g: DijkGG) src dst,
    vvalid g src ->
    vvalid g dst ->
    elabel g (src, dst) =
    Znth dst (Znth src (@graph_to_mat SIZE g id)).
Proof.
  intros.
  rewrite (vvalid_meaning g) in H, H0.
  unfold graph_to_mat.
  apply elabel_Znth_graph_to_mat with (f:=id); trivial.
  lia.
Qed.

Definition DijkGraph sh g gaddr : mpred := @SpaceAdjMatGraph SIZE sh _ id g gaddr.

