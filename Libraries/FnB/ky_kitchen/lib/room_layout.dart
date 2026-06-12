import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'dart:math' as math;

// MODELS
class Room {
  final String id;
  final String name;
  final double width;
  final double height;
  final List<TableGroup> tableGroups;

  Room({
    required this.id,
    required this.name,
    required this.width,
    required this.height,
    required this.tableGroups,
  });

  Room copyWith({
    String? id,
    String? name,
    double? width,
    double? height,
    List<TableGroup>? tableGroups,
  }) {
    return Room(
      id: id ?? this.id,
      name: name ?? this.name,
      width: width ?? this.width,
      height: height ?? this.height,
      tableGroups: tableGroups ?? this.tableGroups,
    );
  }
}

class TableGroup {
  final String id;
  final String name;
  final List<RestaurantTable> tables;
  final Color color;

  TableGroup({
    required this.id,
    required this.name,
    required this.tables,
    required this.color,
  });

  TableGroup copyWith({
    String? id,
    String? name,
    List<RestaurantTable>? tables,
    Color? color,
  }) {
    return TableGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      tables: tables ?? this.tables,
      color: color ?? this.color,
    );
  }
}

enum TableShape { round, rectangle }

class RestaurantTable {
  final String id;
  final String name;
  final double x;
  final double y;
  final double width;
  final double height;
  final TableShape shape;
  final int capacity;
  final bool isOccupied;

  RestaurantTable({
    required this.id,
    required this.name,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.shape,
    required this.capacity,
    this.isOccupied = false,
  });

  RestaurantTable copyWith({
    String? id,
    String? name,
    double? x,
    double? y,
    double? width,
    double? height,
    TableShape? shape,
    int? capacity,
    bool? isOccupied,
  }) {
    return RestaurantTable(
      id: id ?? this.id,
      name: name ?? this.name,
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
      shape: shape ?? this.shape,
      capacity: capacity ?? this.capacity,
      isOccupied: isOccupied ?? this.isOccupied,
    );
  }

  RestaurantTable moveBy(double dx, double dy) {
    return copyWith(x: x + dx, y: y + dy);
  }
}

// PROVIDERS
final roomsProvider = StateNotifierProvider<RoomsNotifier, List<Room>>((ref) {
  return RoomsNotifier();
});

final selectedRoomIdProvider = StateProvider<String?>((ref) => null);

final selectedRoomProvider = Provider<Room?>((ref) {
  final rooms = ref.watch(roomsProvider);
  final selectedId = ref.watch(selectedRoomIdProvider);
  if (selectedId == null) return null;
  return rooms.firstWhere(
    (room) => room.id == selectedId,
    orElse: () => rooms.first,
  );
});

final selectedTableIdProvider = StateProvider<String?>((ref) => null);

final editModeProvider = StateProvider<bool>((ref) => false);

class RoomsNotifier extends StateNotifier<List<Room>> {
  RoomsNotifier() : super(_initialRooms);

  void addRoom(Room room) {
    state = [...state, room];
  }

  void updateRoom(Room updatedRoom) {
    state = state
        .map((room) => room.id == updatedRoom.id ? updatedRoom : room)
        .toList();
  }

  void deleteRoom(String roomId) {
    state = state.where((room) => room.id != roomId).toList();
  }

  void addTableToGroup(String roomId, String groupId, RestaurantTable table) {
    state = state.map((room) {
      if (room.id != roomId) return room;

      final updatedGroups = room.tableGroups.map((group) {
        if (group.id != groupId) return group;
        return group.copyWith(tables: [...group.tables, table]);
      }).toList();

      return room.copyWith(tableGroups: updatedGroups);
    }).toList();
  }

  void updateTable(
    String roomId,
    String groupId,
    RestaurantTable updatedTable,
  ) {
    state = state.map((room) {
      if (room.id != roomId) return room;

      final updatedGroups = room.tableGroups.map((group) {
        if (group.id != groupId) return group;

        final updatedTables = group.tables.map((table) {
          return table.id == updatedTable.id ? updatedTable : table;
        }).toList();

        return group.copyWith(tables: updatedTables);
      }).toList();

      return room.copyWith(tableGroups: updatedGroups);
    }).toList();
  }

  void moveTable(
    String roomId,
    String groupId,
    String tableId,
    double dx,
    double dy,
  ) {
    state = state.map((room) {
      if (room.id != roomId) return room;

      final updatedGroups = room.tableGroups.map((group) {
        if (group.id != groupId) return group;

        final updatedTables = group.tables.map((table) {
          if (table.id != tableId) return table;
          return table.moveBy(dx, dy);
        }).toList();

        return group.copyWith(tables: updatedTables);
      }).toList();

      return room.copyWith(tableGroups: updatedGroups);
    }).toList();
  }

  void deleteTable(String roomId, String groupId, String tableId) {
    state = state.map((room) {
      if (room.id != roomId) return room;

      final updatedGroups = room.tableGroups.map((group) {
        if (group.id != groupId) return group;

        final updatedTables = group.tables
            .where((table) => table.id != tableId)
            .toList();
        return group.copyWith(tables: updatedTables);
      }).toList();

      return room.copyWith(tableGroups: updatedGroups);
    }).toList();
  }

  void toggleTableOccupation(String roomId, String groupId, String tableId) {
    state = state.map((room) {
      if (room.id != roomId) return room;

      final updatedGroups = room.tableGroups.map((group) {
        if (group.id != groupId) return group;

        final updatedTables = group.tables.map((table) {
          if (table.id != tableId) return table;
          return table.copyWith(isOccupied: !table.isOccupied);
        }).toList();

        return group.copyWith(tables: updatedTables);
      }).toList();

      return room.copyWith(tableGroups: updatedGroups);
    }).toList();
  }
}

// Initial demo data
final _initialRooms = [
  Room(
    id: "room1",
    name: "Main Dining Area",
    width: 800,
    height: 600,
    tableGroups: [
      TableGroup(
        id: "group1",
        name: "Standard Tables",
        color: Colors.blue.shade100,
        tables: [
          RestaurantTable(
            id: "table1",
            name: "T1",
            x: 100,
            y: 100,
            width: 80,
            height: 80,
            shape: TableShape.round,
            capacity: 4,
          ),
          RestaurantTable(
            id: "table2",
            name: "T2",
            x: 220,
            y: 100,
            width: 120,
            height: 80,
            shape: TableShape.rectangle,
            capacity: 6,
          ),
        ],
      ),
      TableGroup(
        id: "group2",
        name: "Window Seats",
        color: Colors.amber.shade100,
        tables: [
          RestaurantTable(
            id: "table3",
            name: "W1",
            x: 400,
            y: 120,
            width: 60,
            height: 60,
            shape: TableShape.round,
            capacity: 2,
            isOccupied: true,
          ),
        ],
      ),
    ],
  ),
  Room(
    id: "room2",
    name: "Private Dining",
    width: 500,
    height: 400,
    tableGroups: [
      TableGroup(
        id: "group3",
        name: "VIP Tables",
        color: Colors.purple.shade100,
        tables: [
          RestaurantTable(
            id: "table4",
            name: "VIP1",
            x: 150,
            y: 150,
            width: 200,
            height: 100,
            shape: TableShape.rectangle,
            capacity: 10,
          ),
        ],
      ),
    ],
  ),
];

// UI COMPONENTS
class RoomLayoutScreen extends ConsumerWidget {
  const RoomLayoutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rooms = ref.watch(roomsProvider);
    final selectedRoom = ref.watch(selectedRoomProvider);
    final editMode = ref.watch(editModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Room Layout Manager',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        actions: [
          IconButton(
            icon: Icon(editMode ? Icons.check : Icons.edit),
            onPressed: () {
              ref.read(editModeProvider.notifier).state = !editMode;
            },
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              // Save to backend (not implemented)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Layout saved successfully')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildRoomSelector(context, ref, rooms),
          Expanded(
            child: selectedRoom != null
                ? _buildRoomLayout(context, ref, selectedRoom)
                : const Center(child: Text('Select a room to view layout')),
          ),
        ],
      ),
      floatingActionButton: editMode
          ? FloatingActionButton(
              onPressed: () => _showAddTableDialog(context, ref),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildRoomSelector(
    BuildContext context,
    WidgetRef ref,
    List<Room> rooms,
  ) {
    final selectedRoomId = ref.watch(selectedRoomIdProvider);

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: rooms.length + 1, // +1 for the add button
        itemBuilder: (context, index) {
          if (index == rooms.length) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () => _showAddRoomDialog(context, ref),
                ),
              ),
            );
          }

          final room = rooms[index];
          final isSelected = room.id == selectedRoomId;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(room.name),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  ref.read(selectedRoomIdProvider.notifier).state = room.id;
                }
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildRoomLayout(BuildContext context, WidgetRef ref, Room room) {
    final editMode = ref.watch(editModeProvider);
    final selectedTableId = ref.watch(selectedTableIdProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              room.name,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                // Room background
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),

                // Tables
                for (final group in room.tableGroups)
                  for (final table in group.tables)
                    _buildTable(
                      context,
                      ref,
                      room.id,
                      group,
                      table,
                      selectedTableId,
                      editMode,
                    ),

                // Legend
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: _buildLegend(context, room),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTable(
    BuildContext context,
    WidgetRef ref,
    String roomId,
    TableGroup group,
    RestaurantTable table,
    String? selectedTableId,
    bool editMode,
  ) {
    final isSelected = table.id == selectedTableId;

    return Positioned(
      left: table.x,
      top: table.y,
      child: GestureDetector(
        onTap: () {
          if (editMode) {
            ref.read(selectedTableIdProvider.notifier).state = table.id;
          } else {
            // In view mode, toggle occupation state
            ref
                .read(roomsProvider.notifier)
                .toggleTableOccupation(roomId, group.id, table.id);
          }
        },
        onPanUpdate: editMode
            ? (details) {
                ref
                    .read(roomsProvider.notifier)
                    .moveTable(
                      roomId,
                      group.id,
                      table.id,
                      details.delta.dx,
                      details.delta.dy,
                    );
              }
            : null,
        child: Container(
          width: table.width,
          height: table.height,
          decoration: BoxDecoration(
            color: table.isOccupied ? Colors.grey.shade400 : group.color,
            shape: table.shape == TableShape.round
                ? BoxShape.circle
                : BoxShape.rectangle,
            border: Border.all(
              color: isSelected ? Colors.blue : Colors.grey.shade600,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  table.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: table.isOccupied ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  '${table.capacity}p',
                  style: TextStyle(
                    fontSize: 12,
                    color: table.isOccupied ? Colors.white : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLegend(BuildContext context, Room room) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Table Groups', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 4),
          ...room.tableGroups.map(
            (group) => Row(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: group.color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 8),
                Text(group.name),
              ],
            ),
          ),
          const Divider(),
          Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 8),
              const Text('Occupied'),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddRoomDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final widthController = TextEditingController(text: '800');
    final heightController = TextEditingController(text: '600');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Room'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Room Name'),
            ),
            TextField(
              controller: widthController,
              decoration: const InputDecoration(labelText: 'Width (px)'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: heightController,
              decoration: const InputDecoration(labelText: 'Height (px)'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isNotEmpty) {
                final newRoom = Room(
                  id: 'room${DateTime.now().millisecondsSinceEpoch}',
                  name: name,
                  width: double.tryParse(widthController.text) ?? 800,
                  height: double.tryParse(heightController.text) ?? 600,
                  tableGroups: [
                    TableGroup(
                      id: 'group${DateTime.now().millisecondsSinceEpoch}',
                      name: 'Default Group',
                      color: Colors.blue.shade100,
                      tables: [],
                    ),
                  ],
                );
                ref.read(roomsProvider.notifier).addRoom(newRoom);
                ref.read(selectedRoomIdProvider.notifier).state = newRoom.id;
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showAddTableDialog(BuildContext context, WidgetRef ref) {
    final selectedRoom = ref.read(selectedRoomProvider);
    if (selectedRoom == null) return;

    final nameController = TextEditingController();
    final widthController = TextEditingController(text: '80');
    final heightController = TextEditingController(text: '80');
    final capacityController = TextEditingController(text: '4');

    String selectedGroupId = selectedRoom.tableGroups.first.id;
    TableShape selectedShape = TableShape.round;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add New Table'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Table Name'),
              ),
              DropdownButtonFormField<String>(
                value: selectedGroupId,
                decoration: const InputDecoration(labelText: 'Table Group'),
                items: selectedRoom.tableGroups.map((group) {
                  return DropdownMenuItem<String>(
                    value: group.id,
                    child: Text(group.name),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedGroupId = value;
                    });
                  }
                },
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: widthController,
                      decoration: const InputDecoration(labelText: 'Width'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: heightController,
                      decoration: const InputDecoration(labelText: 'Height'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              TextField(
                controller: capacityController,
                decoration: const InputDecoration(labelText: 'Capacity'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('Shape: '),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Round'),
                    selected: selectedShape == TableShape.round,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          selectedShape = TableShape.round;
                        });
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Rectangle'),
                    selected: selectedShape == TableShape.rectangle,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          selectedShape = TableShape.rectangle;
                        });
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isNotEmpty) {
                  final newTable = RestaurantTable(
                    id: 'table${DateTime.now().millisecondsSinceEpoch}',
                    name: name,
                    x: 200,
                    y: 200,
                    width: double.tryParse(widthController.text) ?? 80,
                    height: double.tryParse(heightController.text) ?? 80,
                    shape: selectedShape,
                    capacity: int.tryParse(capacityController.text) ?? 4,
                  );
                  ref
                      .read(roomsProvider.notifier)
                      .addTableToGroup(
                        selectedRoom.id,
                        selectedGroupId,
                        newTable,
                      );
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}

// TABLE DETAILS PANEL
class TableDetailsPanel extends ConsumerWidget {
  const TableDetailsPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedRoom = ref.watch(selectedRoomProvider);
    final selectedTableId = ref.watch(selectedTableIdProvider);

    if (selectedRoom == null || selectedTableId == null) {
      return const SizedBox.shrink();
    }

    // Find the selected table
    RestaurantTable? selectedTable;
    TableGroup? selectedGroup;

    for (final group in selectedRoom.tableGroups) {
      for (final table in group.tables) {
        if (table.id == selectedTableId) {
          selectedTable = table;
          selectedGroup = group;
          break;
        }
      }
      if (selectedTable != null) break;
    }

    if (selectedTable == null || selectedGroup == null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(left: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Table Details',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  ref.read(selectedTableIdProvider.notifier).state = null;
                },
              ),
            ],
          ),
          const Divider(),
          _buildDetailItem('ID', selectedTable.id),
          _buildDetailItem('Name', selectedTable.name),
          _buildDetailItem('Group', selectedGroup.name),
          _buildDetailItem(
            'Shape',
            selectedTable.shape.toString().split('.').last,
          ),
          _buildDetailItem('Capacity', '${selectedTable.capacity} people'),
          _buildDetailItem(
            'Size',
            '${selectedTable.width}x${selectedTable.height}',
          ),
          _buildDetailItem(
            'Position',
            'X: ${selectedTable.x.toInt()}, Y: ${selectedTable.y.toInt()}',
          ),
          _buildDetailItem(
            'Status',
            selectedTable.isOccupied ? 'Occupied' : 'Available',
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.edit),
                label: const Text('Edit'),
                onPressed: () => _showEditTableDialog(
                  context,
                  ref,
                  selectedRoom,
                  selectedGroup!,
                  selectedTable!,
                ),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.delete),
                label: const Text('Delete'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade100,
                  foregroundColor: Colors.red.shade900,
                ),
                onPressed: () => _showDeleteConfirmation(
                  context,
                  ref,
                  selectedRoom,
                  selectedGroup!,
                  selectedTable!,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showEditTableDialog(
    BuildContext context,
    WidgetRef ref,
    Room room,
    TableGroup group,
    RestaurantTable table,
  ) {
    final nameController = TextEditingController(text: table.name);
    final widthController = TextEditingController(text: table.width.toString());
    final heightController = TextEditingController(
      text: table.height.toString(),
    );
    final capacityController = TextEditingController(
      text: table.capacity.toString(),
    );

    String selectedGroupId = group.id;
    TableShape selectedShape = table.shape;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Table'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Table Name'),
              ),
              DropdownButtonFormField<String>(
                value: selectedGroupId,
                decoration: const InputDecoration(labelText: 'Table Group'),
                items: room.tableGroups.map((g) {
                  return DropdownMenuItem<String>(
                    value: g.id,
                    child: Text(g.name),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedGroupId = value;
                    });
                  }
                },
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: widthController,
                      decoration: const InputDecoration(labelText: 'Width'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: heightController,
                      decoration: const InputDecoration(labelText: 'Height'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              TextField(
                controller: capacityController,
                decoration: const InputDecoration(labelText: 'Capacity'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('Shape: '),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Round'),
                    selected: selectedShape == TableShape.round,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          selectedShape = TableShape.round;
                        });
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Rectangle'),
                    selected: selectedShape == TableShape.rectangle,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          selectedShape = TableShape.rectangle;
                        });
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isNotEmpty) {
                  // If the group changed, we need to delete from old and add to new
                  if (selectedGroupId != group.id) {
                    // Create updated table
                    final updatedTable = table.copyWith(
                      name: name,
                      width:
                          double.tryParse(widthController.text) ?? table.width,
                      height:
                          double.tryParse(heightController.text) ??
                          table.height,
                      shape: selectedShape,
                      capacity:
                          int.tryParse(capacityController.text) ??
                          table.capacity,
                    );

                    // Delete from old group
                    ref
                        .read(roomsProvider.notifier)
                        .deleteTable(room.id, group.id, table.id);

                    // Add to new group
                    ref
                        .read(roomsProvider.notifier)
                        .addTableToGroup(
                          room.id,
                          selectedGroupId,
                          updatedTable,
                        );
                  } else {
                    // Just update the table in the same group
                    final updatedTable = table.copyWith(
                      name: name,
                      width:
                          double.tryParse(widthController.text) ?? table.width,
                      height:
                          double.tryParse(heightController.text) ??
                          table.height,
                      shape: selectedShape,
                      capacity:
                          int.tryParse(capacityController.text) ??
                          table.capacity,
                    );

                    ref
                        .read(roomsProvider.notifier)
                        .updateTable(room.id, group.id, updatedTable);
                  }

                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    Room room,
    TableGroup group,
    RestaurantTable table,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Table'),
        content: Text('Are you sure you want to delete table ${table.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              ref
                  .read(roomsProvider.notifier)
                  .deleteTable(room.id, group.id, table.id);
              ref.read(selectedTableIdProvider.notifier).state = null;
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// MAIN APPLICATION
class RestaurantLayoutApp extends StatelessWidget {
  const RestaurantLayoutApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'Restaurant Layout Manager',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(centerTitle: false, elevation: 0),
        ),
        home: const RoomLayoutMainScreen(),
      ),
    );
  }
}

class RoomLayoutMainScreen extends ConsumerWidget {
  const RoomLayoutMainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTableId = ref.watch(selectedTableIdProvider);
    final showDetails = selectedTableId != null;

    return Scaffold(
      body: Row(
        children: [
          Expanded(child: const RoomLayoutScreen()),
          if (showDetails) const TableDetailsPanel(),
        ],
      ),
    );
  }
}

// TABLE GROUP MANAGEMENT
class TableGroupsScreen extends ConsumerWidget {
  const TableGroupsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedRoom = ref.watch(selectedRoomProvider);

    if (selectedRoom == null) {
      return const Center(child: Text('Select a room to manage table groups'));
    }

    return Scaffold(
      appBar: AppBar(title: Text('Table Groups - ${selectedRoom.name}')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: selectedRoom.tableGroups.length + 1, // +1 for "Add" button
        itemBuilder: (context, index) {
          if (index == selectedRoom.tableGroups.length) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: OutlinedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add Group'),
                onPressed: () =>
                    _showAddGroupDialog(context, ref, selectedRoom),
              ),
            );
          }

          final group = selectedRoom.tableGroups[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: group.color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              title: Text(group.name),
              subtitle: Text('${group.tables.length} tables'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () =>
                        _showEditGroupDialog(context, ref, selectedRoom, group),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: group.tables.isEmpty
                        ? () => _showDeleteGroupConfirmation(
                            context,
                            ref,
                            selectedRoom,
                            group,
                          )
                        : null,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showAddGroupDialog(BuildContext context, WidgetRef ref, Room room) {
    final nameController = TextEditingController();
    Color selectedColor = Colors.blue.shade100;

    final List<Color> colorOptions = [
      Colors.blue.shade100,
      Colors.green.shade100,
      Colors.amber.shade100,
      Colors.purple.shade100,
      Colors.pink.shade100,
      Colors.teal.shade100,
      Colors.orange.shade100,
      Colors.indigo.shade100,
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Table Group'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Group Name'),
              ),
              const SizedBox(height: 16),
              const Text('Group Color:'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: colorOptions.map((color) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedColor = color;
                      });
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: color == selectedColor
                            ? Border.all(color: Colors.black, width: 2)
                            : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isNotEmpty) {
                  // Create a new room with the added group
                  final updatedRoom = room.copyWith(
                    tableGroups: [
                      ...room.tableGroups,
                      TableGroup(
                        id: 'group${DateTime.now().millisecondsSinceEpoch}',
                        name: name,
                        color: selectedColor,
                        tables: [],
                      ),
                    ],
                  );

                  ref.read(roomsProvider.notifier).updateRoom(updatedRoom);
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditGroupDialog(
    BuildContext context,
    WidgetRef ref,
    Room room,
    TableGroup group,
  ) {
    final nameController = TextEditingController(text: group.name);
    Color selectedColor = group.color;

    final List<Color> colorOptions = [
      Colors.blue.shade100,
      Colors.green.shade100,
      Colors.amber.shade100,
      Colors.purple.shade100,
      Colors.pink.shade100,
      Colors.teal.shade100,
      Colors.orange.shade100,
      Colors.indigo.shade100,
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Table Group'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Group Name'),
              ),
              const SizedBox(height: 16),
              const Text('Group Color:'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: colorOptions.map((color) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedColor = color;
                      });
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: color.value == selectedColor.value
                            ? Border.all(color: Colors.black, width: 2)
                            : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isNotEmpty) {
                  // Update the group
                  final updatedGroups = room.tableGroups.map((g) {
                    if (g.id == group.id) {
                      return g.copyWith(name: name, color: selectedColor);
                    }
                    return g;
                  }).toList();

                  final updatedRoom = room.copyWith(tableGroups: updatedGroups);
                  ref.read(roomsProvider.notifier).updateRoom(updatedRoom);
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteGroupConfirmation(
    BuildContext context,
    WidgetRef ref,
    Room room,
    TableGroup group,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Group'),
        content: Text('Are you sure you want to delete group "${group.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              // Create a new room without this group
              final updatedRoom = room.copyWith(
                tableGroups: room.tableGroups
                    .where((g) => g.id != group.id)
                    .toList(),
              );

              ref.read(roomsProvider.notifier).updateRoom(updatedRoom);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(const RestaurantLayoutApp());
}
