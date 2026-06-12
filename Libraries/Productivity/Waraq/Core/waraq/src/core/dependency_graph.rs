// src/core/dependency_graph.rs
//
// Domain-neutral dependency graph for structured editors.
//
// Examples:
//   • Sheet cell B1 depends on A1.
//   • Notebook cell 4 depends on cell 2.
//   • A doc cross-reference depends on a heading node.
//   • A slide chart depends on a sheet range.

use std::collections::{BTreeMap, BTreeSet, VecDeque};

use serde::{Deserialize, Serialize};

/// Stable graph node identifier. Domain engines decide the namespace.
pub type GraphNodeId = String;

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub enum DependencyKind {
    Formula,
    Execution,
    Reference,
    DataBinding,
    Layout,
    Custom(String),
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct DependencyEdge {
    /// The node that must be recomputed/refreshed.
    pub dependent: GraphNodeId,
    /// The node that `dependent` reads from or points at.
    pub dependency: GraphNodeId,
    pub kind: DependencyKind,
}

impl DependencyEdge {
    pub fn new(
        dependent: impl Into<GraphNodeId>,
        dependency: impl Into<GraphNodeId>,
        kind: DependencyKind,
    ) -> Self {
        Self {
            dependent: dependent.into(),
            dependency: dependency.into(),
            kind,
        }
    }
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct DependencyCycle {
    pub nodes: Vec<GraphNodeId>,
}

#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct DependencyGraph {
    nodes: BTreeSet<GraphNodeId>,
    edges: Vec<DependencyEdge>,
}

impl DependencyGraph {
    pub fn new() -> Self {
        Self::default()
    }

    pub fn is_empty(&self) -> bool {
        self.nodes.is_empty()
    }

    pub fn add_node(&mut self, id: impl Into<GraphNodeId>) -> bool {
        self.nodes.insert(id.into())
    }

    pub fn remove_node(&mut self, id: &str) -> bool {
        let removed = self.nodes.remove(id);
        if removed {
            self.edges
                .retain(|edge| edge.dependent != id && edge.dependency != id);
        }
        removed
    }

    pub fn add_edge(
        &mut self,
        dependent: impl Into<GraphNodeId>,
        dependency: impl Into<GraphNodeId>,
        kind: DependencyKind,
    ) {
        let edge = DependencyEdge::new(dependent, dependency, kind);
        self.nodes.insert(edge.dependent.clone());
        self.nodes.insert(edge.dependency.clone());
        if !self.edges.contains(&edge) {
            self.edges.push(edge);
        }
    }

    pub fn nodes(&self) -> impl Iterator<Item = &GraphNodeId> {
        self.nodes.iter()
    }

    pub fn edges(&self) -> &[DependencyEdge] {
        &self.edges
    }

    pub fn dependencies_of(&self, id: &str) -> Vec<&DependencyEdge> {
        self.edges
            .iter()
            .filter(|edge| edge.dependent == id)
            .collect()
    }

    pub fn dependents_of(&self, id: &str) -> Vec<&DependencyEdge> {
        self.edges
            .iter()
            .filter(|edge| edge.dependency == id)
            .collect()
    }

    /// Returns all nodes that should be refreshed after `changed` changes.
    pub fn affected_by(&self, changed: &str) -> Vec<GraphNodeId> {
        let mut affected = BTreeSet::new();
        let mut queue = VecDeque::from([changed.to_owned()]);

        while let Some(id) = queue.pop_front() {
            for edge in self.dependents_of(&id) {
                if affected.insert(edge.dependent.clone()) {
                    queue.push_back(edge.dependent.clone());
                }
            }
        }

        affected.into_iter().collect()
    }

    /// Returns an execution/recalculation order where dependencies appear first.
    pub fn topological_order(&self) -> Result<Vec<GraphNodeId>, DependencyCycle> {
        let mut incoming: BTreeMap<GraphNodeId, usize> =
            self.nodes.iter().map(|node| (node.clone(), 0)).collect();
        let mut outgoing: BTreeMap<GraphNodeId, Vec<GraphNodeId>> = BTreeMap::new();

        for edge in &self.edges {
            *incoming.entry(edge.dependent.clone()).or_insert(0) += 1;
            outgoing
                .entry(edge.dependency.clone())
                .or_default()
                .push(edge.dependent.clone());
        }

        let mut ready: VecDeque<_> = incoming
            .iter()
            .filter_map(|(node, count)| (*count == 0).then(|| node.clone()))
            .collect();
        let mut order = Vec::with_capacity(self.nodes.len());

        while let Some(node) = ready.pop_front() {
            order.push(node.clone());
            if let Some(dependents) = outgoing.get(&node) {
                for dependent in dependents {
                    if let Some(count) = incoming.get_mut(dependent) {
                        *count -= 1;
                        if *count == 0 {
                            ready.push_back(dependent.clone());
                        }
                    }
                }
            }
        }

        if order.len() == incoming.len() {
            Ok(order)
        } else {
            let nodes = incoming
                .into_iter()
                .filter_map(|(node, count)| (count > 0).then_some(node))
                .collect();
            Err(DependencyCycle { nodes })
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn topological_order_puts_dependencies_first() {
        let mut graph = DependencyGraph::new();
        graph.add_edge("A2", "A1", DependencyKind::Formula);
        graph.add_edge("A3", "A2", DependencyKind::Formula);

        assert_eq!(
            graph.topological_order().unwrap(),
            vec!["A1".to_owned(), "A2".to_owned(), "A3".to_owned()]
        );
    }

    #[test]
    fn affected_by_walks_transitive_dependents() {
        let mut graph = DependencyGraph::new();
        graph.add_edge("chart:1", "sheet:A1", DependencyKind::DataBinding);
        graph.add_edge("slide:1", "chart:1", DependencyKind::Reference);

        assert_eq!(
            graph.affected_by("sheet:A1"),
            vec!["chart:1".to_owned(), "slide:1".to_owned()]
        );
    }

    #[test]
    fn detects_cycles() {
        let mut graph = DependencyGraph::new();
        graph.add_edge("cell:A1", "cell:B1", DependencyKind::Formula);
        graph.add_edge("cell:B1", "cell:A1", DependencyKind::Formula);

        let cycle = graph.topological_order().unwrap_err();
        assert_eq!(cycle.nodes.len(), 2);
    }
}
