import 'dart:io';

import 'file_processing.dart';

class BatchFileProcessor {
  Future<void> processBatch({
    required List<File> files,
    required Function(File) processor,
    bool parallel = true,
    int? maxConcurrent,
  }) async {
    if (parallel) {
      final pool = Pool(maxConcurrent ?? 4);
      await pool.forEach(files, (File file) async {
        await processor(file);
      });
    } else {
      for (var file in files) {
        await processor(file);
      }
    }
  }
  
  Future<void> convertBatch({
    required List<File> files,
    required String targetFormat,
    CompressionLevel compression = CompressionLevel.medium,
  }) async {
    await processBatch(
      files: files,
      processor: (file) async {
        final converter = FileConverter(
          compression: compression,
          targetFormat: targetFormat,
        );
        await converter.convert(file);
      }
    );
  }
}


class AdvancedBatchProcessor extends BatchFileProcessor {
  Future<void> processWithValidation({
    required List<File> files,
    required ValidationStrategy strategy,
    required ErrorHandler errorHandler,
  }) async {
    final results = await processBatch(
      files: files,
      processor: (file) async {
        try {
          await strategy.validate(file);
          await processor(file);
        } catch (e) {
          await errorHandler.handleError(file, e);
        }
      }
    );
    
    await generateValidationReport(results);
  }

  Future<void> batchTransform({
    required List<File> files,
    required List<TransformOperation> operations,
    required TransformationConfig config,
  }) async {
    final transformer = DataTransformer(config);
    
    await processBatch(
      files: files,
      processor: (file) async {
        for (var operation in operations) {
          await transformer.applyTransformation(file, operation);
        }
      }
    );
  }
}
