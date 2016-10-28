Require Import Coq.Logic.Classical.
Require Import Coq.Lists.List.
Require Import Coq.Sets.Ensembles.
Require Import VST.msl.seplog.
Require Import VST.msl.log_normalize.
Require Import RamifyCoq.lib.Coqlib.
Require Import RamifyCoq.lib.Ensembles_ext.
Require Import RamifyCoq.lib.EquivDec_ext.
Require Import RamifyCoq.lib.Relation_ext.
Require Import RamifyCoq.msl_ext.seplog.
Require Import RamifyCoq.graph.graph_model.
Require Import RamifyCoq.graph.weak_mark_lemmas.
Require Import RamifyCoq.graph.path_lemmas.
Require Import RamifyCoq.graph.graph_gen.
Require Import RamifyCoq.graph.graph_relation.
Require Import RamifyCoq.graph.subgraph2.
Require Import RamifyCoq.graph.reachable_computable.
Require Import RamifyCoq.graph.FiniteGraph.
Require Import RamifyCoq.graph.MathGraph.
Require Import RamifyCoq.msl_application.Graph.
Require Import RamifyCoq.graph.GraphAsList.

Local Open Scope logic.

Class pSpatialGraph_GList: Type :=
  {
    addr: Type;
    null: addr;
    pred: Type;
    SGBA: SpatialGraphBasicAssum addr (addr * unit)
  }.

Existing Instance SGBA.

Definition is_null_SGBA {pSGG: pSpatialGraph_GList} : DecidablePred addr := (existT (fun P => forall a, {P a} + {~ P a}) (fun x => x = null) (fun x => SGBA_VE x null)).

Class sSpatialGraph_GList {pSGG_Bi: pSpatialGraph_GList} (DV DE: Type): Type :=
  {
    SGP: SpatialGraphPred addr (addr * unit) (DV * addr) unit pred;
    SGA: SpatialGraphAssum SGP;
    SGAvs: SpatialGraphAssum_vs SGP;
    SGAvn: SpatialGraphAssum_vn SGP null
  }.

Existing Instances SGP SGA SGAvs.

Section GRAPH_GList.

  Context {pSGG: pSpatialGraph_GList}.
  Context {DV DE: Type}.

  Class MaFin (g: PreGraph addr (addr * unit)) :=
    {
      ma: MathGraph g is_null_SGBA;
      fin: FiniteGraph g
    }.

  Definition Graph := (GeneralGraph addr (addr * unit) DV DE (fun g => MaFin (pg_lg g))).
  Definition LGraph := (LabeledGraph addr (addr * unit) DV DE).
  Definition SGraph := (SpatialGraph addr (addr * unit) (DV * addr) unit).

  Instance SGC_Bi: SpatialGraphConstructor addr (addr * unit) DV DE (DV * addr) unit.
  Proof.
    refine (Build_SpatialGraphConstructor _ _ _ _ _ _ SGBA _ _).
    + exact (fun G v => (vlabel G v, v)).
    + exact (fun _ _ => tt).
  Defined.

  Instance L_SGC_Bi: Local_SpatialGraphConstructor addr (addr * unit) DV DE (DV * addr) unit.
  Proof.
    refine (Build_Local_SpatialGraphConstructor
              _ _ _ _ _ _ SGBA SGC_Bi
              (fun G v => evalid (pg_lg G) (v, tt) /\ src (pg_lg G) (v, tt) = v) _
              (fun _ _ => True) _).
    + intros.
      simpl.
      destruct H as [? ?], H0 as [? ?].
      f_equal; auto.
    + intros; simpl.
      auto.
  Defined.

  Global Existing Instances SGC_Bi L_SGC_Bi.

  Definition Graph_LGraph (G: Graph): LGraph := lg_gg G.
  Definition LGraph_SGraph (G: LGraph): SGraph := Graph_SpatialGraph G.

  Local Coercion Graph_LGraph: Graph >-> LGraph.
  Local Coercion LGraph_SGraph: LGraph >-> SGraph.
  Local Identity Coercion Graph_GeneralGraph: Graph >-> GeneralGraph.
  Local Identity Coercion LGraph_LabeledGraph: LGraph >-> LabeledGraph.
  Local Identity Coercion SGraph_SpatialGraph: SGraph >-> SpatialGraph.
  Local Coercion pg_lg: LabeledGraph >-> PreGraph.

  Instance maGraph(G: Graph): MathGraph G is_null_SGBA :=
    @ma G (@sound_gg _ _ _ _ _ _ _ G).

  Instance finGraph (G: Graph): FiniteGraph G :=
    @fin G (@sound_gg _ _ _ _ _ _ _ G).