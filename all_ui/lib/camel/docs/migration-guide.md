# Step-by-Step Integration Guide
## Complete Apache Camel ESB Visual Designer

---

## ✅ What You Now Have

### 1. **Complete Component Library** (`complete_camel_components`)
- 100+ Apache Camel components
- Full parameter definitions
- URI builders
- Documentation links

### 2. **EIP Processors** (`eip_processors`)
- 20+ Enterprise Integration Patterns
- Code generation for Java/YAML/XML
- All routing, transformation, and messaging patterns

### 3. **Validation & Testing** (`route_validation_testing`)
- Complete validation engine
- Route simulation framework
- Test suite management

### 4. **UI Components** (`route_management_ui`, `node_config_dialog`)
- Route configuration dialogs
- Dynamic node configuration
- Validation results viewer
- Testing interface

### 5. **State Management** (`enhanced_state_management`)
- Integration routes provider
- Connection management
- Schema management
- Code generation service
- Template library

### 6. **Canvas Integration** (`canvas_integration_complete`)
- Enhanced node widgets
- Connection handling
- Toolbar with all actions
- Code generation dialogs

---

## 🔧 Integration Steps

### Step 1: Replace Your Current State Management

Replace your existing `routesProvider` with the enhanced version:

```dart
// OLD: State<List<WNode>>
// NEW: State<List<IntegrationRoute>>

// In your main app file, add:
import 'enhanced_state_management.dart';

// Update providers
final routesProvider = integrationRoutesProvider;
final selectedRouteProvider = Provider<IntegrationRoute?>((ref) {
  final routeId = ref.watch(selectedRouteIdProvider);
  if (routeId == null) return null;
  final routes = ref.watch(integrationRoutesProvider);
  return routes.firstWhere((r) => r.id == routeId, orElse: () => null);
});
```

### Step 2: Update Your WNode Model

Extend your `WNode` to support the new features:

```dart
class IntegrationRoute extends WNode {
  final List<Connection> connections;
  final List<TransformationStep> transformations;
  final RoutingRule? routing;
  final ErrorHandler? errorHandler;
  final MonitoringConfig? monitoring;
  final EndpointDefinition? sourceEndpoint;
  final List<EndpointDefinition> targetEndpoints;

  IntegrationRoute({
    required super.id,
    required super.name,
    required super.description,
    required super.nodes,
    this.connections = const [],
    this.transformations = const [],
    this.routing,
    this.errorHandler,
    this.monitoring,
    this.sourceEndpoint,
    this.targetEndpoints = const [],
    Map<String, dynamic> metadata = const {},
  });

  @override
  IntegrationRoute copyWith({
    String? id,
    String? name,
    String? description,
    List<NodeCard>? nodes,
    List<Connection>? connections,
    List<TransformationStep>? transformations,
    RoutingRule? routing,
    ErrorHandler? errorHandler,
    MonitoringConfig? monitoring,
    EndpointDefinition? sourceEndpoint,
    List<EndpointDefinition>? targetEndpoints,
  }) {
    return IntegrationRoute(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      nodes: nodes ?? this.nodes,
      connections: connections ?? this.connections,
      transformations: transformations ?? this.transformations,
      routing: routing ?? this.routing,
      errorHandler: errorHandler ?? this.errorHandler,
      monitoring: monitoring ?? this.monitoring,
      sourceEndpoint: sourceEndpoint ?? this.sourceEndpoint,
      targetEndpoints: targetEndpoints ?? this.targetEndpoints,
    );
  }
}
```

### Step 3: Update Your NodeCard Model

Add configuration support to NodeCard:

```dart
class NodeCard {
  final String id;
  final String type;  // Component ID from CamelComponentsLibrary
  final String name;
  final IconData icon;
  final Color color;
  final Offset position;
  final Map<String, dynamic> config;  // Component configuration
  final String? groupId;
  final List<NodeConnection> connections;  // Keep for backward compatibility

  const NodeCard({
    required this.id,
    required this.type,
    required this.name,
    required this.icon,
    required this.color,
    required this.position,
    this.config = const {},
    this.groupId,
    this.connections = const [],
  });

  NodeCard copyWith({
    String? id,
    String? type,
    String? name,
    IconData? icon,
    Color? color,
    Offset? position,
    Map<String, dynamic>? config,
    String? groupId,
    List<NodeConnection>? connections,
  }) {
    return NodeCard(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      position: position ?? this.position,
      config: config ?? this.config,
      groupId: groupId ?? this.groupId,
      connections: connections ?? this.connections,
    );
  }
}
```

### Step 4: Add Connection Model

Create a proper Connection model:

```dart
class Connection {
  final String id;
  final String from;  // Source node ID
  final String to;    // Target node ID
  final String? label;
  final Map<String, dynamic>? config;

  const Connection({
    required this.id,
    required this.from,
    required this.to,
    this.label,
    this.config,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'from': from,
    'to': to,
    'label': label,
    'config': config,
  };

  factory Connection.fromJson(Map<String, dynamic> json) => Connection(
    id: json['id'],
    from: json['from'],
    to: json['to'],
    label: json['label'],
    config: json['config'],
  );
}
```

### Step 5: Replace Canvas Nodes Rendering

Update your `CanvasNodes` widget:

```dart
class CanvasNodes extends ConsumerWidget {
  const CanvasNodes({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final route = ref.watch(selectedRouteProvider);
    if (route == null) return const SizedBox.shrink();

    return Stack(
      children: route.nodes.map((node) {
        return CanvasNodeWidget(
          key: ValueKey(node.id),
          node: node,
          routeId: route.id,
        );
      }).toList(),
    );
  }
}
```

### Step 6: Update Component Palette

Replace your component palette with the enhanced version:

```dart
class EnhancedComponentPalette extends ConsumerStatefulWidget {
  const EnhancedComponentPalette({super.key});

  @override
  ConsumerState<EnhancedComponentPalette> createState() =>
      _EnhancedComponentPaletteState();
}

class _EnhancedComponentPaletteState
    extends ConsumerState<EnhancedComponentPalette> {
  String _selectedCategory = 'All';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final allComponents = CamelComponentsLibrary.getAllComponents();
    final filteredComponents = _getFilteredComponents(allComponents);

    return Column(
      children: [
        _buildSearchBar(),
        _buildCategoryFilter(allComponents.keys.toList()),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: filteredComponents.length,
            itemBuilder: (context, index) {
              return _buildComponentCard(filteredComponents[index]);
            },
          ),
        ),
      ],
    );
  }

  List<CamelComponent> _getFilteredComponents(
    Map<String, List<CamelComponent>> allComponents,
  ) {
    List<CamelComponent> components = [];
    
    if (_selectedCategory == 'All') {
      for (final category in allComponents.values) {
        components.addAll(category);
      }
    } else {
      components = allComponents[_selectedCategory] ?? [];
    }

    if (_searchQuery.isNotEmpty) {
      components = components.where((c) {
        return c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               c.description.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    return components;
  }

  Widget _buildComponentCard(CamelComponent component) {
    return Draggable<ComponentTemplate>(
      data: ComponentTemplate(
        id: component.id,
        name: component.name,
        description: component.description,
        icon: component.icon,
        color: component.color,
        defaultConfig: {},
      ),
      feedback: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: component.color,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(component.icon, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                component.name,
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
      child: Card(
        child: ListTile(
          leading: Icon(component.icon, color: component.color),
          title: Text(component.name),
          subtitle: Text(
            component.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Chip(
            label: Text(
              component.category,
              style: const TextStyle(fontSize: 10),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: TextField(
        decoration: const InputDecoration(
          hintText: 'Search components...',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(),
        ),
        onChanged: (value) => setState(() => _searchQuery = value),
      ),
    );
  }

  Widget _buildCategoryFilter(List<String> categories) {
    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        children: [
          _buildCategoryChip('All'),
          ...categories.map((cat) => _buildCategoryChip(cat)),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(category),
        selected: _selectedCategory == category,
        onSelected: (selected) {
          setState(() => _selectedCategory = category);
        },
      ),
    );
  }
}
```

### Step 7: Add Enhanced Toolbar

Replace your AppBar actions with the enhanced toolbar:

```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Apache Camel Visual Designer'),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: const EnhancedToolbar(),
      ),
    ),
    body: Row(
      children: [
        SizedBox(
          width: 250,
          child: EnhancedComponentPalette(),
        ),
        Expanded(child: CanvasArea()),
        SizedBox(
          width: 320,
          child: PropertiesPanel(),
        ),
      ],
    ),
  );
}
```

### Step 8: Add Connection Management

Update your connection rendering:

```dart
class CanvasConnections extends ConsumerWidget {
  const CanvasConnections({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final route = ref.watch(selectedRouteProvider);
    final transform = ref.watch(canvasTransformProvider);
    final connectionState = ref.watch(canvasConnectionStateProvider);
    
    if (route == null) return const SizedBox.shrink();

    return CustomPaint(
      painter: ConnectionPainter(
        connections: route.connections,
        nodes: route.nodes,
        transform: transform,
        connectingFrom: connectionState.sourceNodeId,
        currentMousePos: connectionState.currentMousePosition,
      ),
    );
  }
}

class ConnectionPainter extends CustomPainter {
  final List<Connection> connections;
  final List<NodeCard> nodes;
  final CanvasTransform transform;
  final String? connectingFrom;
  final Offset? currentMousePos;

  ConnectionPainter({
    required this.connections,
    required this.nodes,
    required this.transform,
    this.connectingFrom,
    this.currentMousePos,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Draw existing connections
    for (final connection in connections) {
      final from = nodes.firstWhere((n) => n.id == connection.from);
      final to = nodes.firstWhere((n) => n.id == connection.to);
      
      final start = _transformPoint(from.position + const Offset(90, 60));
      final end = _transformPoint(to.position + const Offset(90, 0));
      
      _drawConnection(canvas, paint, start, end);
    }

    // Draw connecting line (when dragging)
    if (connectingFrom != null && currentMousePos != null) {
      final from = nodes.firstWhere((n) => n.id == connectingFrom);
      final start = _transformPoint(from.position + const Offset(90, 60));
      
      paint.color = Colors.blue.withOpacity(0.5);
      _drawConnection(canvas, paint, start, currentMousePos!);
    }
  }

  void _drawConnection(Canvas canvas, Paint paint, Offset start, Offset end) {
    final path = Path();
    path.moveTo(start.dx, start.dy);
    
    // Bezier curve for smooth connection
    final controlPoint1 = Offset(start.dx, (start.dy + end.dy) / 2);
    final controlPoint2 = Offset(end.dx, (start.dy + end.dy) / 2);
    
    path.cubicTo(
      controlPoint1.dx, controlPoint1.dy,
      controlPoint2.dx, controlPoint2.dy,
      end.dx, end.dy,
    );
    
    canvas.drawPath(path, paint);
    
    // Draw arrow
    _drawArrow(canvas, paint, end, controlPoint2);
  }

  void _drawArrow(Canvas canvas, Paint paint, Offset tip, Offset from) {
    const arrowSize = 10.0;
    final angle = (tip - from).direction;
    
    final path = Path();
    path.moveTo(tip.dx, tip.dy);
    path.lineTo(
      tip.dx - arrowSize * cos(angle - 0.5),
      tip.dy - arrowSize * sin(angle - 0.5),
    );
    path.lineTo(
      tip.dx - arrowSize * cos(angle + 0.5),
      tip.dy - arrowSize * sin(angle + 0.5),
    );
    path.close();
    
    canvas.drawPath(path, paint..style = PaintingStyle.fill);
  }

  Offset _transformPoint(Offset point) {
    return Offset(
      point.dx * transform.scale + transform.offset.dx,
      point.dy * transform.scale + transform.offset.dy,
    );
  }

  @override
  bool shouldRepaint(ConnectionPainter oldDelegate) => true;
}
```

---

## 🎯 Quick Start Checklist

### Phase 1: Basic Integration (Day 1)
- [ ] Update state management providers
- [ ] Replace WNode with IntegrationRoute
- [ ] Add Connection model
- [ ] Update NodeCard with config support
- [ ] Test basic drag-and-drop

### Phase 2: Component Configuration (Day 2)
- [ ] Integrate CamelComponentsLibrary
- [ ] Add NodeConfigurationDialog
- [ ] Update double-click to show config
- [ ] Test parameter validation

### Phase 3: Connection Management (Day 3)
- [ ] Add ConnectionManager
- [ ] Implement canConnect validation
- [ ] Add connection UI (dots on nodes)
- [ ] Test connection creation

### Phase 4: Code Generation (Day 4)
- [ ] Integrate CodeGenerationEngine
- [ ] Add Generate Code button
- [ ] Test Java/YAML/XML output
- [ ] Add copy/download functionality

### Phase 5: Advanced Features (Day 5)
- [ ] Add validation engine
- [ ] Integrate testing framework
- [ ] Add data mapper
- [ ] Add expression builder
- [ ] Add templates library

---

## 🚀 Testing Your Integration

### Test 1: Create a Simple Route
```dart
// 1. Drag REST endpoint to canvas
// 2. Double-click to configure (method: POST, path: /users)
// 3. Drag Database endpoint
// 4. Click connection dot on REST → click input dot on Database
// 5. Click "Validate" button
// 6. Click "Generate Code" → Select "Java DSL"
// 7. Verify generated code
```

### Test 2: Use a Template
```dart
// 1. Click Templates button
// 2. Select "REST API to Database"
// 3. Verify nodes appear on canvas
// 4. Modify node configurations
// 5. Generate code
```

### Test 3: Test Route
```dart
// 1. Create a route with REST → Transform → Database
// 2. Click "Test" button
// 3. Enter test data: {"name": "John", "email": "john@example.com"}
// 4. Click "Run Test"
// 5. Verify execution steps
```

---

## 📊 Expected Results

After integration, you'll have:

✅ **100+ drag-and-drop components** with full configuration
✅ **Visual connection management** with validation
✅ **Dynamic configuration dialogs** for each component type
✅ **Code generation** for Java, YAML, XML, Spring Boot
✅ **Route validation** with error highlighting
✅ **Route testing** with simulation
✅ **Data mapping** visual editor
✅ **Expression builder** for routing logic
✅ **Template library** for quick starts
✅ **Undo/redo** with full history
✅ **Export/import** for collaboration

---

## 🐛 Common Issues & Solutions

### Issue 1: Type Mismatch Errors
**Solution**: Ensure all models extend from the base classes provided

### Issue 2: Provider Not Found
**Solution**: Add all providers to your ProviderScope

### Issue 3: Component Not Rendering
**Solution**: Check if CamelComponent has correct icon/color

### Issue 4: Connection Not Working
**Solution**: Verify ConnectionManager is properly initialized

### Issue 5: Code Generation Fails
**Solution**: Ensure route has valid nodes and connections

---

## 📚 Next Steps

1. **Customize UI** - Adjust colors, layouts to match your branding
2. **Add More Components** - Extend CamelComponentsLibrary with custom components
3. **Enhance Validation** - Add custom validation rules
4. **Add Deployment** - Integrate with CI/CD pipelines
5. **Add Monitoring** - Connect to metrics dashboards

---

## 🎓 Learning Resources

- Review each artifact for detailed implementation
- Check inline documentation for usage examples
- Test each feature incrementally
- Refer to Apache Camel docs for component details

---

**Status**: Ready for Integration ✅  
**Complexity**: Moderate  
**Timeline**: 5 days for full integration  
**Support**: All code is documented with examples