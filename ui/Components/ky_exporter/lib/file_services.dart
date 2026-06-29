import 'dart:io';

import 'package:archive/archive.dart';
import 'package:mime/mime.dart';

import 'file_metadata.dart';
import 'file_processing.dart';

class AdvancedFileService {
  final FileStorageService _storage;
  final EncryptionService _encryption;

  AdvancedFileService(this._storage, this._encryption);

  Future<FileMetadata> uploadLargeFile(
    File file,
    String userId,
    {
    void Function(double progress)? onProgress,
    CompressionLevel compressionLevel = CompressionLevel.normal,
    }
  ) async {
    final fileStream = file.openRead();
    final totalSize = await file.length();
    var bytesProcessed = 0;

    // Create chunked upload
    final chunks = <List<int>>[];
    await for (final chunk in fileStream) {
      bytesProcessed += chunk.length;
      if (onProgress != null) {
        onProgress(bytesProcessed / totalSize);
      }
      
      // Compress chunk
      final compressed = await _compressData(chunk, compressionLevel);
      
      // Encrypt chunk
      final encrypted = _encryption.encryptBytes(compressed);
      chunks.add(encrypted);
    }

    // Combine chunks and create metadata
    final combinedData = await _combineChunks(chunks);
    return await _storage.saveFile(combinedData, file.path, userId);
  }

  Stream<List<int>> downloadFileStream(String fileId) async* {
    final metadata = await _storage.getMetadata(fileId);
    final chunkSize = 1024 * 1024; // 1MB chunks
    
    var offset = 0;
    while (offset < metadata.size) {
      final chunk = await _storage.readFileChunk(fileId, offset, chunkSize);
      
      // Decrypt chunk
      final decrypted = _encryption.decryptBytes(chunk);
      
      // Decompress chunk
      final decompressed = await _decompressData(decrypted);
      
      yield decompressed;
      offset += chunkSize;
    }
  }

  Future<void> validateFileIntegrity(String fileId) async {
    final metadata = await _storage.getMetadata(fileId);
    var hash = '';
    
    await for (final chunk in downloadFileStream(fileId)) {
      hash = _updateHash(hash, chunk);
    }
    
    if (hash != metadata.hash) {
      throw FileIntegrityException('File integrity check failed');
    }
  }

  Future<List<int>> _compressData(
    List<int> data,
    CompressionLevel level,
  ) async {
    final encoder = ZipEncoder();
    final archive = Archive();
    
    final archiveFile = ArchiveFile(
      'data',
      data.length,
      data,
    );
    archive.addFile(archiveFile);
    
    return encoder.encode(
      archive,
      level: level,
    )!;
  }

  Future<List<int>> _decompressData(List<int> data) async {
    final decoder = ZipDecoder();
    final archive = decoder.decodeBytes(data);
    return archive.first.content as List<int>;
  }
}
