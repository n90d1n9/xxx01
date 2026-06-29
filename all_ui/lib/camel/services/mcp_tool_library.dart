import '../models/mcp/mcp_parameter.dart';
import '../models/mcp/mcp_tool.dart';

class MCPToolsLibrary {
  static List<MCPTool> getBuiltInTools() {
    return [
      // Web & API Tools
      _httpRequest(),
      _webScraper(),
      _apiCaller(),

      // Data Tools
      _dataTransformer(),
      _jsonParser(),
      _csvProcessor(),
      _xmlParser(),

      // File Tools
      _fileReader(),
      _fileWriter(),
      _fileUploader(),

      // Database Tools
      _sqlExecutor(),
      _mongoQuery(),
      _redisOperation(),

      // AI Tools
      _textGenerator(),
      _imageAnalyzer(),
      _sentimentAnalyzer(),
      _entityExtractor(),

      // Integration Tools
      _camelRouteExecutor(),
      _workflowTrigger(),
      _eventPublisher(),

      // Utility Tools
      _dateTimeFormatter(),
      _stringManipulator(),
      _mathCalculator(),
      _validator(),
    ];
  }

  static MCPTool _httpRequest() => MCPTool(
    id: 'http-request',
    name: 'HTTP Request',
    description: 'Make HTTP requests to external APIs',
    type: MCPToolType.http,
    parameters: [
      MCPParameter(
        name: 'url',
        description: 'Target URL',
        type: MCPParameterType.string,
        required: true,
      ),
      MCPParameter(
        name: 'method',
        description: 'HTTP method',
        type: MCPParameterType.string,
        required: false,
        defaultValue: 'GET',
        enumValues: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'],
      ),
      MCPParameter(
        name: 'headers',
        description: 'Request headers',
        type: MCPParameterType.object,
        required: false,
      ),
      MCPParameter(
        name: 'body',
        description: 'Request body',
        type: MCPParameterType.object,
        required: false,
      ),
    ],
    config: {},
  );

  static MCPTool _webScraper() => MCPTool(
    id: 'web-scraper',
    name: 'Web Scraper',
    description: 'Extract data from web pages',
    type: MCPToolType.http,
    parameters: [
      MCPParameter(
        name: 'url',
        description: 'URL to scrape',
        type: MCPParameterType.string,
        required: true,
      ),
      MCPParameter(
        name: 'selector',
        description: 'CSS selector',
        type: MCPParameterType.string,
        required: true,
      ),
    ],
    config: {},
  );

  static MCPTool _apiCaller() => MCPTool(
    id: 'api-caller',
    name: 'API Caller',
    description: 'Call REST APIs with authentication',
    type: MCPToolType.http,
    parameters: [
      MCPParameter(
        name: 'endpoint',
        description: 'API endpoint',
        type: MCPParameterType.string,
        required: true,
      ),
      MCPParameter(
        name: 'authType',
        description: 'Authentication type',
        type: MCPParameterType.string,
        enumValues: ['none', 'apiKey', 'oauth', 'bearer'],
      ),
    ],
    config: {},
  );

  static MCPTool _dataTransformer() => MCPTool(
    id: 'data-transformer',
    name: 'Data Transformer',
    description: 'Transform data between formats',
    type: MCPToolType.custom,
    parameters: [
      MCPParameter(
        name: 'input',
        description: 'Input data',
        type: MCPParameterType.object,
        required: true,
      ),
      MCPParameter(
        name: 'transformations',
        description: 'Transformation rules',
        type: MCPParameterType.array,
        required: true,
      ),
    ],
    config: {},
  );

  static MCPTool _jsonParser() => MCPTool(
    id: 'json-parser',
    name: 'JSON Parser',
    description: 'Parse and manipulate JSON',
    type: MCPToolType.custom,
    parameters: [
      MCPParameter(
        name: 'json',
        description: 'JSON string or object',
        type: MCPParameterType.string,
        required: true,
      ),
      MCPParameter(
        name: 'query',
        description: 'JSONPath query',
        type: MCPParameterType.string,
      ),
    ],
    config: {},
  );

  static MCPTool _csvProcessor() => MCPTool(
    id: 'csv-processor',
    name: 'CSV Processor',
    description: 'Process CSV files',
    type: MCPToolType.fileSystem,
    parameters: [
      MCPParameter(
        name: 'file',
        description: 'CSV file path or content',
        type: MCPParameterType.string,
        required: true,
      ),
      MCPParameter(
        name: 'operation',
        description: 'Operation to perform',
        type: MCPParameterType.string,
        enumValues: ['parse', 'filter', 'transform', 'aggregate'],
      ),
    ],
    config: {},
  );

  static MCPTool _xmlParser() => MCPTool(
    id: 'xml-parser',
    name: 'XML Parser',
    description: 'Parse and query XML',
    type: MCPToolType.custom,
    parameters: [
      MCPParameter(
        name: 'xml',
        description: 'XML string',
        type: MCPParameterType.string,
        required: true,
      ),
      MCPParameter(
        name: 'xpath',
        description: 'XPath query',
        type: MCPParameterType.string,
      ),
    ],
    config: {},
  );

  static MCPTool _fileReader() => MCPTool(
    id: 'file-reader',
    name: 'File Reader',
    description: 'Read files from filesystem',
    type: MCPToolType.fileSystem,
    parameters: [
      MCPParameter(
        name: 'path',
        description: 'File path',
        type: MCPParameterType.string,
        required: true,
      ),
      MCPParameter(
        name: 'encoding',
        description: 'File encoding',
        type: MCPParameterType.string,
        defaultValue: 'utf-8',
      ),
    ],
    config: {},
  );

  static MCPTool _fileWriter() => MCPTool(
    id: 'file-writer',
    name: 'File Writer',
    description: 'Write files to filesystem',
    type: MCPToolType.fileSystem,
    parameters: [
      MCPParameter(
        name: 'path',
        description: 'File path',
        type: MCPParameterType.string,
        required: true,
      ),
      MCPParameter(
        name: 'content',
        description: 'File content',
        type: MCPParameterType.string,
        required: true,
      ),
    ],
    config: {},
  );

  static MCPTool _fileUploader() => MCPTool(
    id: 'file-uploader',
    name: 'File Uploader',
    description: 'Upload files to cloud storage',
    type: MCPToolType.fileSystem,
    parameters: [
      MCPParameter(
        name: 'file',
        description: 'File to upload',
        type: MCPParameterType.string,
        required: true,
      ),
      MCPParameter(
        name: 'destination',
        description: 'Upload destination',
        type: MCPParameterType.string,
        required: true,
      ),
    ],
    config: {},
  );

  static MCPTool _sqlExecutor() => MCPTool(
    id: 'sql-executor',
    name: 'SQL Executor',
    description: 'Execute SQL queries',
    type: MCPToolType.database,
    parameters: [
      MCPParameter(
        name: 'query',
        description: 'SQL query',
        type: MCPParameterType.string,
        required: true,
      ),
      MCPParameter(
        name: 'database',
        description: 'Database connection',
        type: MCPParameterType.string,
        required: true,
      ),
    ],
    config: {},
  );

  static MCPTool _mongoQuery() => MCPTool(
    id: 'mongo-query',
    name: 'MongoDB Query',
    description: 'Query MongoDB',
    type: MCPToolType.database,
    parameters: [
      MCPParameter(
        name: 'collection',
        description: 'Collection name',
        type: MCPParameterType.string,
        required: true,
      ),
      MCPParameter(
        name: 'query',
        description: 'MongoDB query',
        type: MCPParameterType.object,
        required: true,
      ),
    ],
    config: {},
  );

  static MCPTool _redisOperation() => MCPTool(
    id: 'redis-operation',
    name: 'Redis Operation',
    description: 'Perform Redis operations',
    type: MCPToolType.database,
    parameters: [
      MCPParameter(
        name: 'operation',
        description: 'Redis operation',
        type: MCPParameterType.string,
        required: true,
        enumValues: ['GET', 'SET', 'DEL', 'INCR', 'EXPIRE'],
      ),
      MCPParameter(
        name: 'key',
        description: 'Redis key',
        type: MCPParameterType.string,
        required: true,
      ),
    ],
    config: {},
  );

  static MCPTool _textGenerator() => MCPTool(
    id: 'text-generator',
    name: 'Text Generator',
    description: 'Generate text using AI',
    type: MCPToolType.ai,
    parameters: [
      MCPParameter(
        name: 'prompt',
        description: 'Text prompt',
        type: MCPParameterType.string,
        required: true,
      ),
      MCPParameter(
        name: 'maxTokens',
        description: 'Maximum tokens',
        type: MCPParameterType.number,
        defaultValue: 1000,
      ),
    ],
    config: {},
  );

  static MCPTool _imageAnalyzer() => MCPTool(
    id: 'image-analyzer',
    name: 'Image Analyzer',
    description: 'Analyze images using AI',
    type: MCPToolType.ai,
    parameters: [
      MCPParameter(
        name: 'imageUrl',
        description: 'Image URL or base64',
        type: MCPParameterType.string,
        required: true,
      ),
      MCPParameter(
        name: 'task',
        description: 'Analysis task',
        type: MCPParameterType.string,
        enumValues: ['classify', 'detect', 'segment', 'describe'],
      ),
    ],
    config: {},
  );

  static MCPTool _sentimentAnalyzer() => MCPTool(
    id: 'sentiment-analyzer',
    name: 'Sentiment Analyzer',
    description: 'Analyze sentiment of text',
    type: MCPToolType.ai,
    parameters: [
      MCPParameter(
        name: 'text',
        description: 'Text to analyze',
        type: MCPParameterType.string,
        required: true,
      ),
    ],
    config: {},
  );

  static MCPTool _entityExtractor() => MCPTool(
    id: 'entity-extractor',
    name: 'Entity Extractor',
    description: 'Extract named entities',
    type: MCPToolType.ai,
    parameters: [
      MCPParameter(
        name: 'text',
        description: 'Text to analyze',
        type: MCPParameterType.string,
        required: true,
      ),
      MCPParameter(
        name: 'entityTypes',
        description: 'Entity types to extract',
        type: MCPParameterType.array,
      ),
    ],
    config: {},
  );

  static MCPTool _camelRouteExecutor() => MCPTool(
    id: 'camel-route-executor',
    name: 'Camel Route Executor',
    description: 'Execute Apache Camel route',
    type: MCPToolType.integration,
    parameters: [
      MCPParameter(
        name: 'routeId',
        description: 'Route ID',
        type: MCPParameterType.string,
        required: true,
      ),
      MCPParameter(
        name: 'input',
        description: 'Input data',
        type: MCPParameterType.object,
      ),
    ],
    config: {},
  );

  static MCPTool _workflowTrigger() => MCPTool(
    id: 'workflow-trigger',
    name: 'Workflow Trigger',
    description: 'Trigger workflow execution',
    type: MCPToolType.integration,
    parameters: [
      MCPParameter(
        name: 'workflowId',
        description: 'Workflow ID',
        type: MCPParameterType.string,
        required: true,
      ),
      MCPParameter(
        name: 'parameters',
        description: 'Workflow parameters',
        type: MCPParameterType.object,
      ),
    ],
    config: {},
  );

  static MCPTool _eventPublisher() => MCPTool(
    id: 'event-publisher',
    name: 'Event Publisher',
    description: 'Publish events to message broker',
    type: MCPToolType.integration,
    parameters: [
      MCPParameter(
        name: 'topic',
        description: 'Event topic',
        type: MCPParameterType.string,
        required: true,
      ),
      MCPParameter(
        name: 'event',
        description: 'Event data',
        type: MCPParameterType.object,
        required: true,
      ),
    ],
    config: {},
  );

  static MCPTool _dateTimeFormatter() => MCPTool(
    id: 'datetime-formatter',
    name: 'DateTime Formatter',
    description: 'Format date and time',
    type: MCPToolType.custom,
    parameters: [
      MCPParameter(
        name: 'datetime',
        description: 'DateTime value',
        type: MCPParameterType.string,
        required: true,
      ),
      MCPParameter(
        name: 'format',
        description: 'Output format',
        type: MCPParameterType.string,
        required: true,
      ),
    ],
    config: {},
  );

  static MCPTool _stringManipulator() => MCPTool(
    id: 'string-manipulator',
    name: 'String Manipulator',
    description: 'Manipulate strings',
    type: MCPToolType.custom,
    parameters: [
      MCPParameter(
        name: 'input',
        description: 'Input string',
        type: MCPParameterType.string,
        required: true,
      ),
      MCPParameter(
        name: 'operation',
        description: 'String operation',
        type: MCPParameterType.string,
        enumValues: ['uppercase', 'lowercase', 'trim', 'split', 'replace'],
      ),
    ],
    config: {},
  );

  static MCPTool _mathCalculator() => MCPTool(
    id: 'math-calculator',
    name: 'Math Calculator',
    description: 'Perform mathematical calculations',
    type: MCPToolType.custom,
    parameters: [
      MCPParameter(
        name: 'expression',
        description: 'Math expression',
        type: MCPParameterType.string,
        required: true,
      ),
    ],
    config: {},
  );

  static MCPTool _validator() => MCPTool(
    id: 'validator',
    name: 'Validator',
    description: 'Validate data against schema',
    type: MCPToolType.custom,
    parameters: [
      MCPParameter(
        name: 'data',
        description: 'Data to validate',
        type: MCPParameterType.object,
        required: true,
      ),
      MCPParameter(
        name: 'schema',
        description: 'Validation schema',
        type: MCPParameterType.object,
        required: true,
      ),
    ],
    config: {},
  );
}
