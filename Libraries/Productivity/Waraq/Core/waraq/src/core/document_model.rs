// src/core/document_model.rs
//
// Semantic document model shared by code, notebooks, sheets, slides, and docs.
//
// The text editor remains the right primitive for editable text regions. This
// model adds the higher-level structure needed by product editors: cells,
// slides, paragraphs, shapes, headings, code cells, formulas, and references.

use std::collections::BTreeMap;
use std::error::Error;
use std::fmt;

use serde::{Deserialize, Serialize};

use crate::core::dependency_graph::{DependencyGraph, DependencyKind};

#[derive(Debug, Clone, PartialEq, Eq, PartialOrd, Ord, Hash, Serialize, Deserialize)]
pub struct DocumentId(String);

impl DocumentId {
    pub fn new(id: impl Into<String>) -> Self {
        Self(id.into())
    }

    pub fn as_str(&self) -> &str {
        &self.0
    }
}

impl From<&str> for DocumentId {
    fn from(value: &str) -> Self {
        Self::new(value)
    }
}

#[derive(Debug, Clone, PartialEq, Eq, PartialOrd, Ord, Hash, Serialize, Deserialize)]
pub struct NodeId(String);

impl NodeId {
    pub fn new(id: impl Into<String>) -> Self {
        Self(id.into())
    }

    pub fn as_str(&self) -> &str {
        &self.0
    }
}

impl From<&str> for NodeId {
    fn from(value: &str) -> Self {
        Self::new(value)
    }
}

impl fmt::Display for NodeId {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.write_str(&self.0)
    }
}

#[derive(Debug, Clone, PartialEq, Eq, PartialOrd, Ord, Hash, Serialize, Deserialize)]
pub struct TextRegionId(String);

impl TextRegionId {
    pub fn new(id: impl Into<String>) -> Self {
        Self(id.into())
    }

    pub fn as_str(&self) -> &str {
        &self.0
    }
}

impl From<&str> for TextRegionId {
    fn from(value: &str) -> Self {
        Self::new(value)
    }
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub enum DocumentKind {
    Code,
    RichText,
    Sheet,
    SlideDeck,
    Notebook,
    Custom(String),
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub enum SemanticNodeKind {
    Root,
    Section,
    Heading { level: u8 },
    Paragraph,
    Table,
    TableRow,
    TableCell { row: u32, column: u32 },
    Sheet,
    SheetCell { row: u32, column: u32 },
    Slide,
    SlideShape,
    CodeFile,
    CodeCell,
    MarkdownCell,
    Output,
    Asset,
    Symbol,
    Custom(String),
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub enum TextRegionKind {
    PlainText,
    RichText,
    Code,
    Markdown,
    Formula,
    CellValue,
    SpeakerNotes,
    Metadata,
    Custom(String),
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub enum MetadataValue {
    String(String),
    Number(f64),
    Bool(bool),
}

pub type Metadata = BTreeMap<String, MetadataValue>;

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct TextRegion {
    pub id: TextRegionId,
    pub kind: TextRegionKind,
    pub text: String,
    pub language: Option<String>,
    pub metadata: Metadata,
}

impl TextRegion {
    pub fn new(id: impl Into<TextRegionId>, kind: TextRegionKind, text: impl Into<String>) -> Self {
        Self {
            id: id.into(),
            kind,
            text: text.into(),
            language: None,
            metadata: Metadata::new(),
        }
    }

    pub fn with_language(mut self, language: impl Into<String>) -> Self {
        self.language = Some(language.into());
        self
    }
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct DocumentNode {
    pub id: NodeId,
    pub kind: SemanticNodeKind,
    pub title: Option<String>,
    pub text_regions: Vec<TextRegion>,
    pub children: Vec<NodeId>,
    pub metadata: Metadata,
}

impl DocumentNode {
    pub fn new(id: impl Into<NodeId>, kind: SemanticNodeKind) -> Self {
        Self {
            id: id.into(),
            kind,
            title: None,
            text_regions: Vec::new(),
            children: Vec::new(),
            metadata: Metadata::new(),
        }
    }

    pub fn with_title(mut self, title: impl Into<String>) -> Self {
        self.title = Some(title.into());
        self
    }

    pub fn add_text_region(&mut self, region: TextRegion) {
        self.text_regions.push(region);
    }
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub enum DocumentModelError {
    CannotRemoveRoot(NodeId),
    DuplicateNode(NodeId),
    MissingNode(NodeId),
    MissingDependencyNode(NodeId),
}

impl fmt::Display for DocumentModelError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Self::CannotRemoveRoot(id) => write!(f, "cannot remove root node {id}"),
            Self::DuplicateNode(id) => write!(f, "duplicate document node {id}"),
            Self::MissingNode(id) => write!(f, "missing document node {id}"),
            Self::MissingDependencyNode(id) => {
                write!(f, "dependency references missing document node {id}")
            }
        }
    }
}

impl Error for DocumentModelError {}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct StructuredDocument {
    pub id: DocumentId,
    pub kind: DocumentKind,
    root_id: NodeId,
    nodes: BTreeMap<NodeId, DocumentNode>,
    dependencies: DependencyGraph,
    pub metadata: Metadata,
}

impl StructuredDocument {
    pub fn new(id: impl Into<DocumentId>, kind: DocumentKind) -> Self {
        let root_id = NodeId::new("root");
        let root = DocumentNode::new(root_id.clone(), SemanticNodeKind::Root);
        let mut nodes = BTreeMap::new();
        nodes.insert(root_id.clone(), root);

        Self {
            id: id.into(),
            kind,
            root_id,
            nodes,
            dependencies: DependencyGraph::new(),
            metadata: Metadata::new(),
        }
    }

    pub fn root_id(&self) -> &NodeId {
        &self.root_id
    }

    pub fn node(&self, id: &NodeId) -> Option<&DocumentNode> {
        self.nodes.get(id)
    }

    pub fn node_mut(&mut self, id: &NodeId) -> Option<&mut DocumentNode> {
        self.nodes.get_mut(id)
    }

    pub fn nodes(&self) -> impl Iterator<Item = &DocumentNode> {
        self.nodes.values()
    }

    pub fn children_of(&self, id: &NodeId) -> Vec<&DocumentNode> {
        self.node(id)
            .map(|node| {
                node.children
                    .iter()
                    .filter_map(|child_id| self.node(child_id))
                    .collect()
            })
            .unwrap_or_default()
    }

    pub fn add_node(
        &mut self,
        parent_id: &NodeId,
        node: DocumentNode,
    ) -> Result<(), DocumentModelError> {
        if !self.nodes.contains_key(parent_id) {
            return Err(DocumentModelError::MissingNode(parent_id.clone()));
        }
        if self.nodes.contains_key(&node.id) {
            return Err(DocumentModelError::DuplicateNode(node.id));
        }

        let id = node.id.clone();
        self.nodes.insert(id.clone(), node);
        self.dependencies.add_node(id.as_str());
        self.nodes
            .get_mut(parent_id)
            .expect("parent existence checked above")
            .children
            .push(id);
        Ok(())
    }

    pub fn remove_node(&mut self, id: &NodeId) -> Result<DocumentNode, DocumentModelError> {
        if id == &self.root_id {
            return Err(DocumentModelError::CannotRemoveRoot(id.clone()));
        }
        if !self.nodes.contains_key(id) {
            return Err(DocumentModelError::MissingNode(id.clone()));
        }

        for node in self.nodes.values_mut() {
            node.children.retain(|child_id| child_id != id);
        }

        let removed = self.nodes.remove(id).expect("node existence checked above");
        self.dependencies.remove_node(id.as_str());
        Ok(removed)
    }

    pub fn add_text_region(
        &mut self,
        node_id: &NodeId,
        region: TextRegion,
    ) -> Result<(), DocumentModelError> {
        let node = self
            .nodes
            .get_mut(node_id)
            .ok_or_else(|| DocumentModelError::MissingNode(node_id.clone()))?;
        node.add_text_region(region);
        Ok(())
    }

    pub fn dependencies(&self) -> &DependencyGraph {
        &self.dependencies
    }

    pub fn dependencies_mut(&mut self) -> &mut DependencyGraph {
        &mut self.dependencies
    }

    pub fn add_dependency(
        &mut self,
        dependent: &NodeId,
        dependency: &NodeId,
        kind: DependencyKind,
    ) -> Result<(), DocumentModelError> {
        if !self.nodes.contains_key(dependent) {
            return Err(DocumentModelError::MissingDependencyNode(dependent.clone()));
        }
        if !self.nodes.contains_key(dependency) {
            return Err(DocumentModelError::MissingDependencyNode(
                dependency.clone(),
            ));
        }
        self.dependencies
            .add_edge(dependent.as_str(), dependency.as_str(), kind);
        Ok(())
    }

    pub fn affected_nodes(&self, changed: &NodeId) -> Vec<NodeId> {
        self.dependencies
            .affected_by(changed.as_str())
            .into_iter()
            .map(NodeId::new)
            .collect()
    }
}

pub trait DocumentAdapter {
    type Error;

    fn load(&self, bytes: &[u8]) -> Result<StructuredDocument, Self::Error>;
    fn save(&self, document: &StructuredDocument) -> Result<Vec<u8>, Self::Error>;
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn sheet_model_can_track_formula_dependencies() {
        let mut doc = StructuredDocument::new("book:1", DocumentKind::Sheet);
        let root = doc.root_id().clone();
        let a1 = NodeId::new("sheet1:A1");
        let b1 = NodeId::new("sheet1:B1");

        doc.add_node(
            &root,
            DocumentNode::new(
                a1.clone(),
                SemanticNodeKind::SheetCell { row: 1, column: 1 },
            ),
        )
        .unwrap();
        doc.add_node(
            &root,
            DocumentNode::new(
                b1.clone(),
                SemanticNodeKind::SheetCell { row: 1, column: 2 },
            ),
        )
        .unwrap();
        doc.add_text_region(
            &a1,
            TextRegion::new("A1:value", TextRegionKind::CellValue, "10"),
        )
        .unwrap();
        doc.add_text_region(
            &b1,
            TextRegion::new("B1:formula", TextRegionKind::Formula, "=A1*2"),
        )
        .unwrap();
        doc.add_dependency(&b1, &a1, DependencyKind::Formula)
            .unwrap();

        assert_eq!(doc.affected_nodes(&a1), vec![b1]);
    }

    #[test]
    fn slide_and_doc_nodes_share_the_same_tree_primitives() {
        let mut doc = StructuredDocument::new("deck:1", DocumentKind::SlideDeck);
        let root = doc.root_id().clone();
        let slide = NodeId::new("slide:1");
        let notes = NodeId::new("slide:1:notes");

        doc.add_node(
            &root,
            DocumentNode::new(slide.clone(), SemanticNodeKind::Slide),
        )
        .unwrap();
        doc.add_node(
            &slide,
            DocumentNode::new(notes.clone(), SemanticNodeKind::Paragraph)
                .with_title("speaker notes"),
        )
        .unwrap();
        doc.add_text_region(
            &notes,
            TextRegion::new(
                "notes:text",
                TextRegionKind::SpeakerNotes,
                "Mention Q2 growth",
            ),
        )
        .unwrap();

        assert_eq!(doc.children_of(&slide)[0].id, notes);
    }

    #[test]
    fn duplicate_nodes_are_rejected() {
        let mut doc = StructuredDocument::new("doc:1", DocumentKind::RichText);
        let root = doc.root_id().clone();
        let node = DocumentNode::new("p:1", SemanticNodeKind::Paragraph);

        doc.add_node(&root, node.clone()).unwrap();
        assert!(matches!(
            doc.add_node(&root, node),
            Err(DocumentModelError::DuplicateNode(_))
        ));
    }
}
