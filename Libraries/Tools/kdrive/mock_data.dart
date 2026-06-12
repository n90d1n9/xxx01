// lib/models/mock_data.dart
import 'package:flutter/material.dart';
import 'file_item.dart';

final List<FileItem> mockFiles = [
  // ── Root folders ────────────────────────────────────────────────────────────
  FileItem(
    id: 'folder-1', name: 'Work Projects', type: FileType.folder,
    dateModified: DateTime.now().subtract(const Duration(hours: 2)),
    dateCreated: DateTime(2024, 1, 10), parentId: null,
    isStarred: true, owner: 'me',
    folderColor: const Color(0xFF4285F4), itemCount: 5,
    description: 'All work-related project files and deliverables.',
  ),
  FileItem(
    id: 'folder-2', name: 'Personal', type: FileType.folder,
    dateModified: DateTime.now().subtract(const Duration(days: 1)),
    dateCreated: DateTime(2024, 2, 5), parentId: null,
    owner: 'me', folderColor: const Color(0xFF34A853), itemCount: 2,
  ),
  FileItem(
    id: 'folder-3', name: 'Shared with me', type: FileType.folder,
    dateModified: DateTime.now().subtract(const Duration(days: 3)),
    dateCreated: DateTime(2024, 3, 1), parentId: null,
    isShared: true, owner: 'team@company.com',
    folderColor: const Color(0xFFFBBC04), itemCount: 3,
    sharedWith: ['alice@co.com', 'bob@co.com'],
  ),
  FileItem(
    id: 'folder-4', name: 'Design Assets', type: FileType.folder,
    dateModified: DateTime.now().subtract(const Duration(hours: 5)),
    dateCreated: DateTime(2024, 1, 15), parentId: null,
    isStarred: true, owner: 'me',
    folderColor: const Color(0xFFEA4335), itemCount: 2,
    description: 'Brand guidelines, icons, and visual assets.',
  ),
  FileItem(
    id: 'folder-5', name: 'Archive 2023', type: FileType.folder,
    dateModified: DateTime(2024, 1, 1), dateCreated: DateTime(2023, 12, 31),
    parentId: null, owner: 'me', itemCount: 0,
    description: 'Historical files from 2023.',
  ),
  FileItem(
    id: 'folder-6', name: 'Photography', type: FileType.folder,
    dateModified: DateTime.now().subtract(const Duration(days: 10)),
    dateCreated: DateTime(2024, 2, 20), parentId: null,
    owner: 'me', folderColor: const Color(0xFF9C27B0), itemCount: 4,
  ),

  // ── Work Projects subfolder ─────────────────────────────────────────────────
  FileItem(
    id: 'folder-1-1', name: 'Q1 Reports', type: FileType.folder,
    dateModified: DateTime.now().subtract(const Duration(days: 5)),
    dateCreated: DateTime(2024, 3, 1), parentId: 'folder-1',
    owner: 'me', folderColor: const Color(0xFF4285F4), itemCount: 2,
  ),
  FileItem(
    id: 'folder-1-2', name: 'Client Presentations', type: FileType.folder,
    dateModified: DateTime.now().subtract(const Duration(days: 2)),
    dateCreated: DateTime(2024, 2, 15), parentId: 'folder-1',
    owner: 'me', itemCount: 1,
  ),
  FileItem(
    id: 'doc-1', name: 'Project Proposal.docx', type: FileType.document,
    sizeBytes: 245760,
    dateModified: DateTime.now().subtract(const Duration(hours: 1)),
    dateCreated: DateTime(2024, 3, 10), parentId: 'folder-1',
    isStarred: true, owner: 'me',
    lastOpenedAt: DateTime.now().subtract(const Duration(hours: 1)),
    tags: ['important', 'client'],
    description: 'Initial proposal for the Q2 mobile redesign project.',
  ),
  FileItem(
    id: 'sheet-1', name: 'Budget 2024.xlsx', type: FileType.spreadsheet,
    sizeBytes: 89600,
    dateModified: DateTime.now().subtract(const Duration(hours: 3)),
    dateCreated: DateTime(2024, 1, 5), parentId: 'folder-1',
    isShared: true, owner: 'me',
    sharedWith: ['finance@co.com', 'ceo@co.com'],
    lastOpenedAt: DateTime.now().subtract(const Duration(hours: 3)),
    tags: ['finance'],
  ),
  FileItem(
    id: 'ppt-1', name: 'Product Roadmap.pptx', type: FileType.presentation,
    sizeBytes: 4194304,
    dateModified: DateTime.now().subtract(const Duration(days: 1)),
    dateCreated: DateTime(2024, 2, 20), parentId: 'folder-1',
    owner: 'me',
    lastOpenedAt: DateTime.now().subtract(const Duration(days: 1)),
    tags: ['roadmap', 'product'],
  ),

  // ── Q1 Reports ─────────────────────────────────────────────────────────────
  FileItem(
    id: 'pdf-q1-1', name: 'January Report.pdf', type: FileType.pdf,
    sizeBytes: 2097152,
    dateModified: DateTime(2024, 2, 1), dateCreated: DateTime(2024, 2, 1),
    parentId: 'folder-1-1', owner: 'me',
  ),
  FileItem(
    id: 'pdf-q1-2', name: 'February Report.pdf', type: FileType.pdf,
    sizeBytes: 1835008,
    dateModified: DateTime(2024, 3, 1), dateCreated: DateTime(2024, 3, 1),
    parentId: 'folder-1-1', owner: 'me',
  ),

  // ── Client Presentations ───────────────────────────────────────────────────
  FileItem(
    id: 'ppt-2', name: 'Client Demo Q1.pptx', type: FileType.presentation,
    sizeBytes: 8388608,
    dateModified: DateTime.now().subtract(const Duration(days: 2)),
    dateCreated: DateTime(2024, 3, 5), parentId: 'folder-1-2',
    isShared: true, owner: 'me',
    sharedWith: ['client@acme.com'],
  ),

  // ── Root level files ────────────────────────────────────────────────────────
  FileItem(
    id: 'pdf-1', name: 'Annual Report 2023.pdf', type: FileType.pdf,
    sizeBytes: 8388608,
    dateModified: DateTime(2024, 1, 15), dateCreated: DateTime(2024, 1, 15),
    parentId: null, isStarred: true, isShared: true,
    owner: 'me', sharedWith: ['board@co.com', 'investors@co.com'],
    lastOpenedAt: DateTime.now().subtract(const Duration(days: 2)),
    description: 'Official annual report for shareholders.',
    tags: ['annual', 'finance', 'important'],
  ),
  FileItem(
    id: 'img-1', name: 'Team Photo.jpg', type: FileType.image,
    sizeBytes: 3145728,
    dateModified: DateTime.now().subtract(const Duration(days: 7)),
    dateCreated: DateTime(2024, 2, 28), parentId: null, owner: 'me',
    lastOpenedAt: DateTime.now().subtract(const Duration(days: 7)),
  ),
  FileItem(
    id: 'img-2', name: 'Logo_Final.png', type: FileType.image,
    sizeBytes: 512000,
    dateModified: DateTime.now().subtract(const Duration(days: 4)),
    dateCreated: DateTime(2024, 3, 5), parentId: null,
    isStarred: true, owner: 'me',
    tags: ['brand'],
    lastOpenedAt: DateTime.now().subtract(const Duration(days: 1)),
  ),
  FileItem(
    id: 'video-1', name: 'Product Demo.mp4', type: FileType.video,
    sizeBytes: 104857600,
    dateModified: DateTime.now().subtract(const Duration(days: 6)),
    dateCreated: DateTime(2024, 2, 10), parentId: null,
    isShared: true, owner: 'me',
    sharedWith: ['marketing@co.com'],
    tags: ['demo', 'marketing'],
  ),
  FileItem(
    id: 'doc-2', name: 'Meeting Notes.docx', type: FileType.document,
    sizeBytes: 32768,
    dateModified: DateTime.now().subtract(const Duration(hours: 6)),
    dateCreated: DateTime.now().subtract(const Duration(days: 2)),
    parentId: null, owner: 'me',
    lastOpenedAt: DateTime.now().subtract(const Duration(hours: 6)),
  ),
  FileItem(
    id: 'code-1', name: 'app_config.json', type: FileType.code,
    sizeBytes: 4096,
    dateModified: DateTime.now().subtract(const Duration(days: 10)),
    dateCreated: DateTime(2024, 1, 20), parentId: null, owner: 'me',
    tags: ['config', 'dev'],
  ),
  FileItem(
    id: 'archive-1', name: 'source_code_v1.zip', type: FileType.archive,
    sizeBytes: 52428800,
    dateModified: DateTime.now().subtract(const Duration(days: 14)),
    dateCreated: DateTime(2024, 1, 10), parentId: null, owner: 'me',
    tags: ['dev', 'backup'],
  ),
  FileItem(
    id: 'audio-1', name: 'Presentation Narration.mp3', type: FileType.audio,
    sizeBytes: 10485760,
    dateModified: DateTime.now().subtract(const Duration(days: 8)),
    dateCreated: DateTime(2024, 2, 5), parentId: null, owner: 'me',
  ),
  FileItem(
    id: 'doc-3', name: 'README.md', type: FileType.code,
    sizeBytes: 8192,
    dateModified: DateTime.now().subtract(const Duration(days: 3)),
    dateCreated: DateTime(2024, 2, 1), parentId: null, owner: 'me',
    tags: ['dev'],
  ),

  // ── Personal folder ─────────────────────────────────────────────────────────
  FileItem(
    id: 'img-3', name: 'Vacation 2024.jpg', type: FileType.image,
    sizeBytes: 5242880,
    dateModified: DateTime.now().subtract(const Duration(days: 30)),
    dateCreated: DateTime(2024, 1, 25), parentId: 'folder-2', owner: 'me',
  ),
  FileItem(
    id: 'sheet-2', name: 'Personal Budget.xlsx', type: FileType.spreadsheet,
    sizeBytes: 65536,
    dateModified: DateTime.now().subtract(const Duration(days: 2)),
    dateCreated: DateTime(2024, 1, 1), parentId: 'folder-2', owner: 'me',
    lastOpenedAt: DateTime.now().subtract(const Duration(days: 2)),
    tags: ['finance', 'personal'],
  ),

  // ── Design Assets folder ────────────────────────────────────────────────────
  FileItem(
    id: 'pdf-2', name: 'Brand Guidelines.pdf', type: FileType.pdf,
    sizeBytes: 15728640,
    dateModified: DateTime.now().subtract(const Duration(days: 3)),
    dateCreated: DateTime(2024, 2, 1), parentId: 'folder-4',
    isStarred: true, owner: 'me',
    tags: ['brand', 'important'],
  ),
  FileItem(
    id: 'img-5', name: 'Icon Set.png', type: FileType.image,
    sizeBytes: 1048576,
    dateModified: DateTime.now().subtract(const Duration(days: 1)),
    dateCreated: DateTime(2024, 3, 1), parentId: 'folder-4', owner: 'me',
    tags: ['icons', 'brand'],
  ),

  // ── Photography folder ──────────────────────────────────────────────────────
  FileItem(
    id: 'img-p1', name: 'Sunset_RAW.jpg', type: FileType.image,
    sizeBytes: 12582912,
    dateModified: DateTime.now().subtract(const Duration(days: 5)),
    dateCreated: DateTime(2024, 3, 10), parentId: 'folder-6', owner: 'me',
  ),
  FileItem(
    id: 'img-p2', name: 'Portrait_Final.png', type: FileType.image,
    sizeBytes: 9437184,
    dateModified: DateTime.now().subtract(const Duration(days: 4)),
    dateCreated: DateTime(2024, 3, 9), parentId: 'folder-6', owner: 'me',
    isStarred: true,
  ),
  FileItem(
    id: 'img-p3', name: 'Cityscape.jpg', type: FileType.image,
    sizeBytes: 7340032,
    dateModified: DateTime.now().subtract(const Duration(days: 6)),
    dateCreated: DateTime(2024, 3, 8), parentId: 'folder-6', owner: 'me',
  ),
  FileItem(
    id: 'video-p1', name: 'Timelapse.mp4', type: FileType.video,
    sizeBytes: 78643200,
    dateModified: DateTime.now().subtract(const Duration(days: 3)),
    dateCreated: DateTime(2024, 3, 12), parentId: 'folder-6', owner: 'me',
  ),

  // ── Pre-trashed items ───────────────────────────────────────────────────────
  FileItem(
    id: 'trash-1', name: 'Old Proposal Draft.docx', type: FileType.document,
    sizeBytes: 98304,
    dateModified: DateTime.now().subtract(const Duration(days: 20)),
    dateCreated: DateTime(2023, 11, 1), parentId: null,
    owner: 'me', isTrashed: true,
    trashedAt: DateTime.now().subtract(const Duration(days: 5)),
  ),
  FileItem(
    id: 'trash-2', name: 'Duplicate Image.jpg', type: FileType.image,
    sizeBytes: 2097152,
    dateModified: DateTime.now().subtract(const Duration(days: 45)),
    dateCreated: DateTime(2023, 10, 15), parentId: null,
    owner: 'me', isTrashed: true,
    trashedAt: DateTime.now().subtract(const Duration(days: 12)),
  ),
  FileItem(
    id: 'trash-3', name: 'temp_notes.txt', type: FileType.document,
    sizeBytes: 1024,
    dateModified: DateTime.now().subtract(const Duration(days: 30)),
    dateCreated: DateTime(2023, 9, 1), parentId: null,
    owner: 'me', isTrashed: true,
    trashedAt: DateTime.now().subtract(const Duration(days: 28)),
  ),
];
