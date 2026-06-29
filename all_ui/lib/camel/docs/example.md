Now let me add a comprehensive example demonstrating all the features:

```dart
// Complete Example Usage
void main() {
  final camelDefinition = CamelDefinition(
    // Global beans configuration
    beans: {
      'orderProcessor': {
        'type': 'com.example.OrderProcessor',
        'properties': {
          'timeout': 5000,
          'retryCount': 3,
        }
      },
      'dataSource': {
        'type': 'org.apache.commons.dbcp2.BasicDataSource',
        'properties': {
          'driverClassName': 'com.mysql.jdbc.Driver',
          'url': 'jdbc:mysql://localhost:3306/orders',
        }
      },
    },
    
    // Global error handler
    errorHandler: ErrorHandlerDefinition(
      type: 'defaultErrorHandler',
      configuration: {
        'deadLetterUri': 'kafka:dead-letter-queue',
        'maximumRedeliveries': 3,
        'redeliveryDelay': 1000,
        'logStackTrace': true,
      },
    ),
    
    // Global exception handling
    onExceptions: [
      OnExceptionDefinition(
        exception: 'java.sql.SQLException',
        steps: [
          AdvancedEipPatterns.log('Database error occurred: \${exception.message}', loggingLevel: 'ERROR'),
          ProcessorDefinition(
            type: 'to',
            configuration: {'uri': 'direct:handleDatabaseError'},
          ),
        ],
        retryPolicy: {
          'maximumRedeliveries': 5,
          'redeliveryDelay': 2000,
          'backOffMultiplier': 2.0,
        },
      ),
      OnExceptionDefinition(
        exception: 'java.net.ConnectException',
        steps: [
          AdvancedEipPatterns.log('Connection error: \${exception.message}', loggingLevel: 'WARN'),
          AdvancedEipPatterns.delay('5000'),
        ],
        handled: {'constant': true},
      ),
    ],
    
    // Global options
    globalOptions: {
      'streamCaching': true,
      'autoStartup': true,
      'useMDCLogging': true,
      'logExhaustedMessageHistory': true,
    },
    
    // REST API Configuration
    rest: RestDefinition(
      path: '/api',
      methods: [
        RestMethodDefinition(
          method: 'GET',
          path: '/orders/{id}',
          to: [
            ProcessorDefinition(
              type: 'to',
              configuration: {'uri': 'direct:getOrder'},
            ),
          ],
          configuration: {
            'consumes': 'application/json',
            'produces': 'application/json',
          },
        ),
        RestMethodDefinition(
          method: 'POST',
          path: '/orders',
          to: [
            ProcessorDefinition(
              type: 'to',
              configuration: {'uri': 'direct:createOrder'},
            ),
          ],
        ),
      ],
      configuration: {
        'bindingMode': 'json',
        'component': 'servlet',
      },
    ),
    
    // Route Definitions
    routes: [
      // Order Processing Route with Complete EIP Patterns
      RouteDefinition(
        id: 'order-processing-route',
        description: 'Main order processing pipeline with advanced EIPs',
        from: FromDefinition(
          uri: 'kafka:orders-topic',
          parameters: {
            'brokers': 'localhost:9092',
            'groupId': 'order-processor-group',
            'autoOffsetReset': 'earliest',
            'maxPollRecords': 100,
          },
        ),
        steps: [
          // Logging
          AdvancedEipPatterns.log('Received order: \${body}'),
          
          // Unmarshal JSON
          AdvancedEipPatterns.unmarshal('json', {
            'unmarshalTypeName': 'com.example.Order',
          }),
          
          // Idempotent Consumer Pattern
          AdvancedEipPatterns.idempotentConsumer(
            '\${body.orderId}',
            'orderIdempotentRepository',
          ),
          
          // Set Headers
          AdvancedEipPatterns.setHeader('orderTimestamp', '\${date:now}'),
          AdvancedEipPatterns.setProperty('originalBody', '\${body}'),
          
          // Validation
          AdvancedEipPatterns.validate('\${body.amount} > 0'),
          
          // Content Based Router
          EipPatterns.contentBasedRouter(
            [
              WhenDefinition(
                expression: '\${body.orderType} == "PRIORITY"',
                steps: [
                  AdvancedEipPatterns.setHeader('priority', 'high'),
                  ProcessorDefinition(
                    type: 'to',
                    configuration: {'uri': 'direct:priorityProcessing'},
                  ),
                ],
              ),
              WhenDefinition(
                expression: '\${body.amount} > 10000',
                steps: [
                  AdvancedEipPatterns.log('High value order detected'),
                  ProcessorDefinition(
                    type: 'to',
                    configuration: {'uri': 'direct:highValueProcessing'},
                  ),
                ],
              ),
            ],
            [
              ProcessorDefinition(
                type: 'to',
                configuration: {'uri': 'direct:standardProcessing'},
              ),
            ],
          ),
          
          // Enrich content
          EipPatterns.contentEnricher(
            'direct:enrichCustomerData',
            {'customerId': '\${body.customerId}'},
          ),
          
          // WireTap for auditing
          EipPatterns.wiretap('kafka:audit-topic', {
            'copy': true,
          }),
          
          // Multicast to multiple endpoints
          EipPatterns.multicast(
            [
              [
                ProcessorDefinition(
                  type: 'to',
                  configuration: {'uri': 'direct:updateInventory'},
                ),
              ],
              [
                ProcessorDefinition(
                  type: 'to',
                  configuration: {'uri': 'direct:sendNotification'},
                ),
              ],
            ],
            {
              'parallelProcessing': true,
              'streaming': true,
              'stopOnException': false,
            },
          ),
          
          // Circuit Breaker for external service
          EipPatterns.circuitBreaker(
            [
              ProcessorDefinition(
                type: 'to',
                configuration: {'uri': 'http://payment-service/process'},
              ),
            ],
            {
              'configuration': 'paymentServiceCircuitBreaker',
              'halfOpenAfter': '5s',
              'threshold': 3,
            },
          ),
          
          // Aggregation
          EipPatterns.aggregator(
            correlationExpression: '\${header.customerId}',
            completionSize: '10',
            completionTimeout: '5000',
            strategy: {'ref': 'orderAggregationStrategy'},
          ),
          
          // Marshal to JSON
          AdvancedEipPatterns.marshal('json', {
            'prettyPrint': true,
          }),
          
          // Final destination
          ProcessorDefinition(
            type: 'to',
            configuration: {'uri': 'kafka:processed-orders'},
          ),
        ],
        
        // Route-level exception handling
        onExceptions: [
          OnExceptionDefinition(
            exception: 'com.example.PaymentException',
            steps: [
              AdvancedEipPatterns.log('Payment failed: \${exception.message}'),
              AdvancedEipPatterns.setHeader('failureReason', '\${exception.message}'),
              ProcessorDefinition(
                type: 'to',
                configuration: {'uri': 'direct:paymentFailureHandler'},
              ),
            ],
          ),
        ],
      ),
      
      // Splitter Route
      RouteDefinition(
        id: 'batch-order-splitting',
        description: 'Splits batch orders into individual orders',
        from: FromDefinition(uri: 'direct:batchOrders'),
        steps: [
          AdvancedEipPatterns.log('Processing batch with \${body.size} orders'),
          
          // Split the batch
          EipPatterns.splitter('\${body.orders}', {
            'parallelProcessing': true,
            'streaming': true,
            'aggregationStrategy': 'batchAggregationStrategy',
          }),
          
          // Process each order
          AdvancedEipPatterns.log('Processing individual order: \${body.orderId}'),
          
          ProcessorDefinition(
            type: 'to',
            configuration: {'uri': 'direct:order-processing-route'},
          ),
        ],
      ),
      
      // Dynamic Router Route
      RouteDefinition(
        id: 'dynamic-routing',
        description: 'Routes messages dynamically based on content',
        from: FromDefinition(uri: 'direct:dynamicStart'),
        steps: [
          EipPatterns.dynamicRouter('\${bean:routingStrategy.determineRoute}'),
        ],
      ),
      
      // Load Balancer Route
      RouteDefinition(
        id: 'load-balanced-processing',
        description: 'Distributes load across multiple endpoints',
        from: FromDefinition(uri: 'direct:loadBalance'),
        steps: [
          EipPatterns.loadBalancer(
            [
              'direct:processor1',
              'direct:processor2',
              'direct:processor3',
            ],
            'roundRobin',
            {'sticky': false},
          ),
        ],
      ),
      
      // Saga Pattern Route
      RouteDefinition(
        id: 'order-saga',
        description: 'Distributed transaction using Saga pattern',
        from: FromDefinition(uri: 'direct:orderSaga'),
        steps: [
          AdvancedEipPatterns.saga(
            sagaId: 'orderSagaId',
            steps: [
              ProcessorDefinition(
                type: 'to',
                configuration: {'uri': 'direct:reserveInventory'},
              ),
              ProcessorDefinition(
                type: 'to',
                configuration: {'uri': 'direct:processPayment'},
              ),
              ProcessorDefinition(
                type: 'to',
                configuration: {'uri': 'direct:createShipment'},
              ),
            ],
            compensation: [
              ProcessorDefinition(
                type: 'to',
                configuration: {'uri': 'direct:releaseInventory'},
              ),
              ProcessorDefinition(
                type: 'to',
                configuration: {'uri': 'direct:refundPayment'},
              ),
              ProcessorDefinition(
                type: 'to',
                configuration: {'uri': 'direct:cancelShipment'},
              ),
            ],
          ),
        ],
      ),
      
      // Throttling Route
      RouteDefinition(
        id: 'rate-limited-api',
        description: 'Rate limits incoming requests',
        from: FromDefinition(uri: 'direct:api'),
        steps: [
          EipPatterns.throttler('100', '60000'), // 100 requests per minute
          
          ProcessorDefinition(
            type: 'to',
            configuration: {'uri': 'direct:processRequest'},
          ),
        ],
      ),
      
      // Resequencer Route
      RouteDefinition(
        id: 'message-resequencing',
        description: 'Reorders messages based on sequence number',
        from: FromDefinition(uri: 'direct:unordered'),
        steps: [
          EipPatterns.resequencer('\${header.sequenceNumber}', {
            'capacity': 1000,
            'timeout': 5000,
          }),
          
          ProcessorDefinition(
            type: 'to',
            configuration: {'uri': 'direct:orderedProcessing'},
          ),
        ],
      ),
      
      // Transaction Route
      RouteDefinition(
        id: 'transactional-processing',
        description: 'Processes messages within a transaction',
        from: FromDefinition(
          uri: 'jms:queue:orders',
          parameters: {'transacted': 'true'},
        ),
        steps: [
          AdvancedEipPatterns.transacted('PROPAGATION_REQUIRED'),
          
          AdvancedEipPatterns.bean('orderProcessor', 'process'),
          
          ProcessorDefinition(
            type: 'to',
            configuration: {'uri': 'sql:INSERT INTO orders VALUES(:#\${body})'},
          ),
          
          // Conditional rollback
          EipPatterns.contentBasedRouter(
            [
              WhenDefinition(
                expression: '\${body.status} == "INVALID"',
                steps: [
                  AdvancedEipPatterns.rollback('Invalid order status'),
                ],
              ),
            ],
            null,
          ),
        ],
      ),
    ],
    
    // Thread Pool Configuration
    threadPools: {
      'orderProcessingPool': {
        'poolSize': 10,
        'maxPoolSize': 20,
        'maxQueueSize': 100,
      },
    },
    
    // Data Formats
    dataFormats: {
      'json': {
        'library': 'Jackson',
        'prettyPrint': true,
      },
      'xml': {
        'contextPath': 'com.example.model',
      },
    },
  );
  
  // Generate YAML
  final yamlOutput = camelDefinition.toYaml();
  print(yamlOutput);
  
  // Parse back from JSON
  final jsonMap = camelDefinition.toJson();
  final parsedDefinition = CamelDefinition.fromJson(jsonMap);
  
  print('Successfully created Camel definition with ${parsedDefinition.routes.length} routes');
}
```

This comprehensive model now includes:

**All Major EIP Patterns:**
- Message Routing (Content-Based Router, Dynamic Router, Recipient List)
- Message Transformation (Content Enricher, Normalizer)
- Message Splitting/Aggregation (Splitter, Multicast, Aggregator)
- Reliability (Circuit Breaker, Bulkhead, Retry, Error Handling)
- Load Balancing (Round Robin, Random, Sticky, Custom)
- System Management (Throttler, Wire Tap, Sampling)
- Advanced Patterns (Saga, Idempotent Consumer, Claim Check)

**Complete Camel Features:**
- REST API definitions
- Global and route-level exception handling
- Transaction management
- Bean integration
- Data format marshalling/unmarshalling
- Thread pool configuration
- Intercepts and monitoring
- Properties and headers manipulation

Would you like me to add any specific patterns or features?