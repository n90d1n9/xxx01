import 'package:flutter/material.dart';

import 'board_controller.dart';

class BoardScreen extends StatefulWidget {
  const BoardScreen({super.key});

  @override
  ScrumBoardScreenState createState() => ScrumBoardScreenState();
}

class ScrumBoardScreenState extends State<BoardScreen> {
  final BoardController _controller = BoardController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scrum Board')),
      body: Row(
        children: [
          _buildColumn("To Do"),
          _buildColumn("In Progress"),
          _buildColumn("Done"),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _controller.addTask("To Do", "New Task ${DateTime.now()}");
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildColumn(String column) {
    return Expanded(
      child: Column(
        children: [
          Text(column, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Expanded(
            child: DragTarget<String>(
              onWillAcceptWithDetails: (task) => true,
              onAccept: (task) {
                _controller.moveTask(_controller.getTaskColumn(task), column, task);
              },
              builder: (context, candidateData, rejectedData) {
                return AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) {
                    final tasks = _controller.getTasks(column);
                    return ListView.builder(
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final task = tasks[index];
                        return Draggable<String>(
                          data: task,
                          child: ListTile(
                            title: Text(task),
                            trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          _controller.removeTask(column, task);
                        },
                      ),
                          ),
                          feedback: Material(
                            child: Container(
                              color: Colors.blue,
                              child: Text(
                                task,
                                style: const TextStyle(color: Colors.white),
                              ),
                              padding: const EdgeInsets.all(8),
                            ),
                          ),
                          childWhenDragging: Container(),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }


  /* Widget _buildColumn(String column) {
    return Expanded(
      child: Column(
        children: [
          Text(column, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Expanded(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final tasks = _controller.getTasks(column);
                return ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return ListTile(
                      title: Text(task),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          _controller.removeTask(column, task);
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  } */
}
