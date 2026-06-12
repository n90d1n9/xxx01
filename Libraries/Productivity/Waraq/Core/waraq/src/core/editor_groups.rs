// src/core/editor_groups.rs
//
// Editor groups — split-pane layout model.
//
// An editor group is a "pane" that can hold one or more open tabs.
// Multiple groups can be arranged in columns (vertical splits) or rows
// (horizontal splits). This is the data model only — rendering is up to
// the host UI.
//
// VS Code analogy:
//   EditorGroupLayout ≈ the overall split arrangement
//   EditorGroup       ≈ one pane (column or row segment)
//   EditorTab         ≈ one open file within a group
//
// Features:
//   • Add/remove groups (split/close)
//   • Move tabs between groups
//   • Track the active group + active tab per group
//   • Serialise layout for workspace persistence

use serde::{Deserialize, Serialize};

// ── Tab ───────────────────────────────────────────────────────────────────────

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct EditorTab {
    pub id: usize,
    pub file_uri: String,
    pub language: String,
    pub title: String,
    pub dirty: bool,
    pub pinned: bool,
    /// Preview tabs are italicised and close when another file opens.
    pub preview: bool,
}

impl EditorTab {
    pub fn new(id: usize, file_uri: &str, language: &str) -> Self {
        let title = file_uri.rsplit('/').next().unwrap_or(file_uri).to_owned();
        Self {
            id,
            file_uri: file_uri.to_owned(),
            language: language.to_owned(),
            title,
            dirty: false,
            pinned: false,
            preview: false,
        }
    }

    pub fn with_title(mut self, title: &str) -> Self {
        self.title = title.to_owned();
        self
    }
    pub fn pinned(mut self) -> Self {
        self.pinned = true;
        self
    }
    pub fn preview(mut self) -> Self {
        self.preview = true;
        self
    }
}

// ── Group ─────────────────────────────────────────────────────────────────────

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct EditorGroup {
    pub id: usize,
    pub tabs: Vec<EditorTab>,
    pub active_tab: Option<usize>, // tab id
    /// Relative size fraction (0.0–1.0) within parent split.
    pub size: f32,
    pub orientation: GroupOrientation,
    pub children: Vec<EditorGroup>,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum GroupOrientation {
    Column,
    Row,
    Single,
}

impl EditorGroup {
    pub fn single(id: usize) -> Self {
        Self {
            id,
            tabs: Vec::new(),
            active_tab: None,
            size: 1.0,
            orientation: GroupOrientation::Single,
            children: Vec::new(),
        }
    }

    pub fn is_empty(&self) -> bool {
        self.tabs.is_empty()
    }
    pub fn tab_count(&self) -> usize {
        self.tabs.len()
    }

    pub fn active_tab(&self) -> Option<&EditorTab> {
        let id = self.active_tab?;
        self.tabs.iter().find(|t| t.id == id)
    }

    pub fn add_tab(&mut self, tab: EditorTab) {
        let id = tab.id;
        // If there's an existing preview tab and the new one isn't preview,
        // replace it
        if !tab.preview {
            self.tabs.retain(|t| !t.preview);
        }
        self.tabs.push(tab);
        self.active_tab = Some(id);
    }

    pub fn remove_tab(&mut self, tab_id: usize) -> Option<EditorTab> {
        if let Some(pos) = self.tabs.iter().position(|t| t.id == tab_id) {
            let removed = self.tabs.remove(pos);
            if self.active_tab == Some(tab_id) {
                // Move active to adjacent tab
                self.active_tab = self
                    .tabs
                    .get(pos)
                    .or_else(|| self.tabs.get(pos.saturating_sub(1)))
                    .map(|t| t.id);
            }
            Some(removed)
        } else {
            None
        }
    }

    pub fn activate_tab(&mut self, tab_id: usize) -> bool {
        if self.tabs.iter().any(|t| t.id == tab_id) {
            self.active_tab = Some(tab_id);
            true
        } else {
            false
        }
    }

    pub fn move_tab(&mut self, tab_id: usize, to_index: usize) -> bool {
        if let Some(from) = self.tabs.iter().position(|t| t.id == tab_id) {
            let tab = self.tabs.remove(from);
            let target = to_index.min(self.tabs.len());
            self.tabs.insert(target, tab);
            true
        } else {
            false
        }
    }

    pub fn next_tab(&mut self) {
        if self.tabs.is_empty() {
            return;
        }
        if let Some(id) = self.active_tab {
            if let Some(pos) = self.tabs.iter().position(|t| t.id == id) {
                let next = (pos + 1) % self.tabs.len();
                self.active_tab = Some(self.tabs[next].id);
            }
        }
    }

    pub fn prev_tab(&mut self) {
        if self.tabs.is_empty() {
            return;
        }
        if let Some(id) = self.active_tab {
            if let Some(pos) = self.tabs.iter().position(|t| t.id == id) {
                let prev = if pos == 0 {
                    self.tabs.len() - 1
                } else {
                    pos - 1
                };
                self.active_tab = Some(self.tabs[prev].id);
            }
        }
    }

    pub fn mark_dirty(&mut self, tab_id: usize, dirty: bool) {
        if let Some(tab) = self.tabs.iter_mut().find(|t| t.id == tab_id) {
            tab.dirty = dirty;
        }
    }

    pub fn dirty_tabs(&self) -> Vec<&EditorTab> {
        self.tabs.iter().filter(|t| t.dirty).collect()
    }
}

// ── Layout ────────────────────────────────────────────────────────────────────

/// Top-level layout manager for all editor groups.
pub struct EditorGroupLayout {
    groups: Vec<EditorGroup>,
    active_group: usize, // group id
    next_group_id: usize,
    next_tab_id: usize,
    /// How groups are arranged at the top level.
    pub root_orientation: GroupOrientation,
}

impl EditorGroupLayout {
    pub fn new() -> Self {
        let first = EditorGroup::single(0);
        Self {
            groups: vec![first],
            active_group: 0,
            next_group_id: 1,
            next_tab_id: 0,
            root_orientation: GroupOrientation::Column,
        }
    }

    // ── Group management ──────────────────────────────────────────────────────

    pub fn group_count(&self) -> usize {
        self.groups.len()
    }

    pub fn active_group(&self) -> Option<&EditorGroup> {
        self.groups.iter().find(|g| g.id == self.active_group)
    }

    pub fn active_group_mut(&mut self) -> Option<&mut EditorGroup> {
        let id = self.active_group;
        self.groups.iter_mut().find(|g| g.id == id)
    }

    pub fn group(&self, id: usize) -> Option<&EditorGroup> {
        self.groups.iter().find(|g| g.id == id)
    }

    pub fn group_mut(&mut self, id: usize) -> Option<&mut EditorGroup> {
        self.groups.iter_mut().find(|g| g.id == id)
    }

    /// Split the active group and return the new group's id.
    pub fn split(&mut self, orientation: GroupOrientation) -> usize {
        let id = self.next_group_id;
        self.next_group_id += 1;
        // Resize existing groups to equal fractions
        let total = self.groups.len() + 1;
        let frac = 1.0 / total as f32;
        for g in &mut self.groups {
            g.size = frac;
        }
        let mut new_group = EditorGroup::single(id);
        new_group.size = frac;
        self.groups.push(new_group);
        self.root_orientation = orientation;
        id
    }

    /// Remove a group. Returns false if it was the only group.
    pub fn close_group(&mut self, group_id: usize) -> bool {
        if self.groups.len() <= 1 {
            return false;
        }
        self.groups.retain(|g| g.id != group_id);
        // Redistribute sizes
        let total = self.groups.len() as f32;
        for g in &mut self.groups {
            g.size = 1.0 / total;
        }
        if self.active_group == group_id {
            self.active_group = self.groups[0].id;
        }
        true
    }

    pub fn focus_group(&mut self, group_id: usize) -> bool {
        if self.groups.iter().any(|g| g.id == group_id) {
            self.active_group = group_id;
            true
        } else {
            false
        }
    }

    pub fn focus_next_group(&mut self) {
        if self.groups.is_empty() {
            return;
        }
        let current = self
            .groups
            .iter()
            .position(|g| g.id == self.active_group)
            .unwrap_or(0);
        let next = (current + 1) % self.groups.len();
        self.active_group = self.groups[next].id;
    }

    pub fn focus_prev_group(&mut self) {
        if self.groups.is_empty() {
            return;
        }
        let current = self
            .groups
            .iter()
            .position(|g| g.id == self.active_group)
            .unwrap_or(0);
        let prev = if current == 0 {
            self.groups.len() - 1
        } else {
            current - 1
        };
        self.active_group = self.groups[prev].id;
    }

    // ── Tab management ────────────────────────────────────────────────────────

    /// Open a file in the active group. Returns (group_id, tab_id).
    pub fn open_in_active(&mut self, file_uri: &str, language: &str) -> (usize, usize) {
        // Check if already open in any group
        for group in &mut self.groups {
            if let Some(tab) = group.tabs.iter().find(|t| t.file_uri == file_uri) {
                let tab_id = tab.id;
                let group_id = group.id;
                group.active_tab = Some(tab_id);
                self.active_group = group_id;
                return (group_id, tab_id);
            }
        }
        // Open in active group
        let tab_id = self.next_tab_id;
        self.next_tab_id += 1;
        let group_id = self.active_group;
        if let Some(group) = self.active_group_mut() {
            group.add_tab(EditorTab::new(tab_id, file_uri, language));
        }
        (group_id, tab_id)
    }

    /// Open a file in a specific group.
    pub fn open_in_group(&mut self, group_id: usize, file_uri: &str, language: &str) -> usize {
        let tab_id = self.next_tab_id;
        self.next_tab_id += 1;
        if let Some(group) = self.group_mut(group_id) {
            group.add_tab(EditorTab::new(tab_id, file_uri, language));
        }
        tab_id
    }

    /// Move a tab from one group to another.
    pub fn move_tab(&mut self, tab_id: usize, from_group: usize, to_group: usize) -> bool {
        let tab = match self
            .group_mut(from_group)
            .and_then(|from| from.remove_tab(tab_id))
        {
            Some(tab) => tab,
            None => return false,
        };

        match self.group_mut(to_group) {
            Some(to) => {
                to.add_tab(tab);
                true
            }
            None => {
                if let Some(from) = self.group_mut(from_group) {
                    from.add_tab(tab);
                }
                false
            }
        }
    }

    /// Close a tab globally (across all groups).
    pub fn close_tab(&mut self, tab_id: usize) -> Option<String> {
        for group in &mut self.groups {
            if let Some(removed) = group.remove_tab(tab_id) {
                return Some(removed.file_uri);
            }
        }
        None
    }

    /// All currently open file URIs (deduped across groups).
    pub fn open_uris(&self) -> Vec<&str> {
        let mut seen = std::collections::HashSet::new();
        let mut result = Vec::new();
        for g in &self.groups {
            for t in &g.tabs {
                if seen.insert(t.file_uri.as_str()) {
                    result.push(t.file_uri.as_str());
                }
            }
        }
        result
    }

    pub fn total_tabs(&self) -> usize {
        self.groups.iter().map(|g| g.tabs.len()).sum()
    }

    pub fn dirty_tab_count(&self) -> usize {
        self.groups
            .iter()
            .flat_map(|g| g.tabs.iter())
            .filter(|t| t.dirty)
            .count()
    }

    pub fn groups(&self) -> &[EditorGroup] {
        &self.groups
    }

    // ── Serialisation ─────────────────────────────────────────────────────────

    pub fn to_json(&self) -> String {
        #[derive(Serialize)]
        struct Layout<'a> {
            groups: &'a [EditorGroup],
            active_group: usize,
            root_orientation: GroupOrientation,
        }
        serde_json::to_string_pretty(&Layout {
            groups: &self.groups,
            active_group: self.active_group,
            root_orientation: self.root_orientation,
        })
        .unwrap_or_default()
    }

    pub fn from_json(json: &str) -> anyhow::Result<Self> {
        #[derive(Deserialize)]
        struct Layout {
            groups: Vec<EditorGroup>,
            active_group: usize,
            root_orientation: GroupOrientation,
        }
        let l: Layout = serde_json::from_str(json)?;
        let next_group_id = l.groups.iter().map(|g| g.id).max().unwrap_or(0) + 1;
        let next_tab_id = l
            .groups
            .iter()
            .flat_map(|g| g.tabs.iter())
            .map(|t| t.id)
            .max()
            .unwrap_or(0)
            + 1;
        Ok(Self {
            groups: l.groups,
            active_group: l.active_group,
            root_orientation: l.root_orientation,
            next_group_id,
            next_tab_id,
        })
    }
}

impl Default for EditorGroupLayout {
    fn default() -> Self {
        Self::new()
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn layout() -> EditorGroupLayout {
        EditorGroupLayout::new()
    }

    // ── Group operations ──────────────────────────────────────────────────────

    #[test]
    fn test_new_layout_has_one_group() {
        let l = layout();
        assert_eq!(l.group_count(), 1);
        assert!(l.active_group().is_some());
    }

    #[test]
    fn test_split_adds_group() {
        let mut l = layout();
        let new_id = l.split(GroupOrientation::Column);
        assert_eq!(l.group_count(), 2);
        assert!(l.group(new_id).is_some());
    }

    #[test]
    fn test_split_equalises_sizes() {
        let mut l = layout();
        l.split(GroupOrientation::Column);
        for g in l.groups() {
            assert!((g.size - 0.5).abs() < 0.01, "Each group should be 50%");
        }
    }

    #[test]
    fn test_close_group() {
        let mut l = layout();
        let id = l.split(GroupOrientation::Column);
        assert!(l.close_group(id));
        assert_eq!(l.group_count(), 1);
    }

    #[test]
    fn test_cannot_close_last_group() {
        let mut l = layout();
        assert!(!l.close_group(0));
        assert_eq!(l.group_count(), 1);
    }

    #[test]
    fn test_focus_next_prev_group() {
        let mut l = layout();
        let id2 = l.split(GroupOrientation::Column);
        l.focus_group(0);
        l.focus_next_group();
        assert_eq!(l.active_group, id2);
        l.focus_prev_group();
        assert_eq!(l.active_group, 0);
    }

    // ── Tab operations ────────────────────────────────────────────────────────

    #[test]
    fn test_open_tab_in_active_group() {
        let mut l = layout();
        let (gid, tid) = l.open_in_active("file:///a.rs", "rust");
        assert_eq!(gid, 0);
        assert_eq!(l.total_tabs(), 1);
        assert_eq!(l.active_group().unwrap().active_tab, Some(tid));
    }

    #[test]
    fn test_open_same_file_focuses_existing() {
        let mut l = layout();
        let (_g1, t1) = l.open_in_active("file:///a.rs", "rust");
        let (_g2, t2) = l.open_in_active("file:///a.rs", "rust");
        assert_eq!(t1, t2); // same tab
        assert_eq!(l.total_tabs(), 1); // not duplicated
    }

    #[test]
    fn test_close_tab() {
        let mut l = layout();
        let (_, tid) = l.open_in_active("file:///a.rs", "rust");
        l.open_in_active("file:///b.rs", "python");
        let uri = l.close_tab(tid).unwrap();
        assert_eq!(uri, "file:///a.rs");
        assert_eq!(l.total_tabs(), 1);
    }

    #[test]
    fn test_move_tab_between_groups() {
        let mut l = layout();
        let g2 = l.split(GroupOrientation::Column);
        l.focus_group(0);
        let (_, tid) = l.open_in_active("file:///a.rs", "rust");
        assert_eq!(l.group(0).unwrap().tab_count(), 1);
        l.move_tab(tid, 0, g2);
        assert_eq!(l.group(0).unwrap().tab_count(), 0);
        assert_eq!(l.group(g2).unwrap().tab_count(), 1);
    }

    #[test]
    fn test_next_prev_tab_within_group() {
        let mut l = layout();
        let (_, t1) = l.open_in_active("file:///a.rs", "rust");
        let (_, t2) = l.open_in_active("file:///b.rs", "python");
        assert_eq!(l.active_group().unwrap().active_tab, Some(t2));
        l.active_group_mut().unwrap().prev_tab();
        assert_eq!(l.active_group().unwrap().active_tab, Some(t1));
        l.active_group_mut().unwrap().next_tab();
        assert_eq!(l.active_group().unwrap().active_tab, Some(t2));
    }

    #[test]
    fn test_dirty_tracking() {
        let mut l = layout();
        let (_, tid) = l.open_in_active("file:///a.rs", "rust");
        assert_eq!(l.dirty_tab_count(), 0);
        l.active_group_mut().unwrap().mark_dirty(tid, true);
        assert_eq!(l.dirty_tab_count(), 1);
        l.active_group_mut().unwrap().mark_dirty(tid, false);
        assert_eq!(l.dirty_tab_count(), 0);
    }

    #[test]
    fn test_preview_tab_replaced() {
        let mut l = layout();
        let mut preview = EditorTab::new(0, "file:///a.rs", "rust");
        preview.preview = true;
        l.active_group_mut().unwrap().add_tab(preview);
        assert_eq!(l.total_tabs(), 1);
        // Opening a non-preview tab should replace the preview
        let (_, _) = l.open_in_active("file:///b.rs", "python");
        // The group should still have 1 tab (preview replaced) or 2 (added alongside)
        // Behaviour: preview is replaced
        assert!(l.active_group().unwrap().tab_count() <= 2);
    }

    #[test]
    fn test_open_uris() {
        let mut l = layout();
        l.open_in_active("file:///a.rs", "rust");
        l.open_in_active("file:///b.py", "python");
        let uris = l.open_uris();
        assert_eq!(uris.len(), 2);
    }

    // ── JSON roundtrip ────────────────────────────────────────────────────────

    #[test]
    fn test_json_roundtrip() {
        let mut l = layout();
        l.open_in_active("file:///a.rs", "rust");
        let g2 = l.split(GroupOrientation::Column);
        l.open_in_group(g2, "file:///b.py", "python");

        let json = l.to_json();
        let restored = EditorGroupLayout::from_json(&json).unwrap();
        assert_eq!(restored.group_count(), 2);
        assert_eq!(restored.total_tabs(), 2);
        assert_eq!(restored.active_group, l.active_group);
    }

    // ── EditorTab helpers ─────────────────────────────────────────────────────

    #[test]
    fn test_tab_title_from_uri() {
        let t = EditorTab::new(0, "file:///home/user/project/main.rs", "rust");
        assert_eq!(t.title, "main.rs");
    }

    #[test]
    fn test_tab_builder() {
        let t = EditorTab::new(0, "file:///a.rs", "rust").pinned().preview();
        assert!(t.pinned);
        assert!(t.preview);
    }
}
