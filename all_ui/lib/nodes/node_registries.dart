import 'package:flutter/material.dart';

import 'node.dart';
import 'default_nodes.dart';
import 'start_shape.dart';

class NodeSpec {
  final NodeType type;
  final Widget shape;
  final List<PortConfig> ports;
  final double width;
  final double height;

  NodeSpec({
    required this.type,
    required this.shape,
    required this.ports,
    required this.width,
    required this.height,
  });
}

List<NodeSpec> nodeRegistries(NodeConfig config) => [
  NodeSpec(
    type: NodeType.agent,
    shape: DefaultNodeShape(
      borderColor: config.borderColor,
      backgroundColor: config.fillColor,
    ),
    width: 266.0,
    height: 116.0,
    ports: [
      PortConfig(
        portId: 'input1',
        portPosition: PortPosition.left,
        portType: PortType.input,
      ),
      PortConfig(
        portId: 'output1',
        portPosition: PortPosition.right,
        portType: PortType.output,
      ),
      PortConfig(
        portId: 'model1',
        label: 'Model',
        portPosition: PortPosition.bottom,
        portType: PortType.feature,
      ),

      PortConfig(
        portId: 'memory1',
        label: 'Memory',
        portPosition: PortPosition.bottom,
        portType: PortType.feature,
      ),
      PortConfig(
        portId: 'tools1',
        label: 'Tools',
        portPosition: PortPosition.bottom,
        portType: PortType.feature,
      ),
    ],
  ),
  NodeSpec(
    type: NodeType.start,
    shape: CustomPaint(
      size: Size(80, 50),
      painter: StartShapePainter(
        borderColor: config.borderColor,
        fillColor: config.fillColor,
      ),
    ),
    width: 80,
    height: 50,
    ports: [
      PortConfig(
        portId: 'startOutput',
        portPosition: PortPosition.right,
        portType: PortType.output,
      ),
    ],
  ),

  NodeSpec(
    type: NodeType.llm,
    shape: CircleNodeShape(
      borderColor: config.borderColor,
      backgroundColor: config.fillColor,
    ),
    width: 50,
    height: 50,
    ports: [
      PortConfig(
        portId: 'llmOutput',
        portPosition: PortPosition.top,
        portType: PortType.output,
      ),
    ],
  ),
];
