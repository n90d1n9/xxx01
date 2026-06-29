import '../common/file_handling.dart';

class Capabilities {
  final bool? multimodal;
  final bool? streaming;
  final bool? functionCalling;
  final bool? codeExecution;
  final bool? webBrowsing;
  final bool? enterpriseIntegration;
  final FileHandling? fileHandling;

  Capabilities({
    this.multimodal = false,
    this.streaming = false,
    this.functionCalling = true,
    this.codeExecution = false,
    this.webBrowsing = false,
    this.enterpriseIntegration = false,
    this.fileHandling,
  });

  factory Capabilities.fromJson(Map<String, dynamic> json) {
    return Capabilities(
      multimodal: json['multimodal'] as bool?,
      streaming: json['streaming'] as bool?,
      functionCalling: json['functionCalling'] as bool?,
      codeExecution: json['codeExecution'] as bool?,
      webBrowsing: json['webBrowsing'] as bool?,
      enterpriseIntegration: json['enterpriseIntegration'] as bool?,
      fileHandling: json['fileHandling'] != null
          ? FileHandling.fromJson(json['fileHandling'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (multimodal != null) 'multimodal': multimodal,
      if (streaming != null) 'streaming': streaming,
      if (functionCalling != null) 'functionCalling': functionCalling,
      if (codeExecution != null) 'codeExecution': codeExecution,
      if (webBrowsing != null) 'webBrowsing': webBrowsing,
      if (enterpriseIntegration != null)
        'enterpriseIntegration': enterpriseIntegration,
      if (fileHandling != null) 'fileHandling': fileHandling!.toJson(),
    };
  }
}
