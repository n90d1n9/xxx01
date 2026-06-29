import 'package:ai_edge/ai_edge.dart';

void main(List<String> args) async {
  // Initialize the AI model
  final aiEdge = AiEdge.instance;
  await aiEdge.initialize(
    modelPath: '/path/to/your/model.task',
    maxTokens: 512,
  );

  // Generate a response
  final response = await aiEdge.generateResponse('What is Flutter?');
  print(response);

  // Clean up when done
  await aiEdge.close();
}
