import '../models/diagram_type.dart';
import '../models/mermaid_diagram.dart';
import '../models/timeline_event.dart';
import 'base_parser.dart';

class TimelineParser implements DiagramParser {
  @override
  bool canParse(List<String> lines) {
    if (lines.isEmpty) return false;
    final firstLine = lines[0].toLowerCase();
    return firstLine.contains('timeline');
  }

  @override
  MermaidDiagram parse(List<String> lines, String code) {
    final events = <TimelineEvent>[];
    String? currentPeriod;
    String? currentTitle;
    List<String> currentEvents = [];

    for (var i = 1; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      if (_isNewPeriod(line)) {
        // Save previous period
        if (currentPeriod != null) {
          events.add(
            _createTimelineEvent(currentPeriod, currentTitle, currentEvents),
          );
        }

        // Start new period
        currentPeriod = _parsePeriod(line);
        currentTitle = null;
        currentEvents = [];
      } else if (line.startsWith(':')) {
        final content = line.substring(1).trim();
        if (currentTitle == null) {
          currentTitle = content;
        } else {
          currentEvents.add(content);
        }
      }
    }

    // Add the last event
    if (currentPeriod != null) {
      events.add(
        _createTimelineEvent(currentPeriod, currentTitle, currentEvents),
      );
    }

    return MermaidDiagram(
      type: DiagramType.timeline,
      timelineEvents: events,
      rawCode: code,
    );
  }

  bool _isNewPeriod(String line) {
    return !line.startsWith('    ') &&
        !line.startsWith(':') &&
        !line.startsWith('%%');
  }

  String _parsePeriod(String line) {
    return line.trim();
  }

  TimelineEvent _createTimelineEvent(
    String period,
    String? title,
    List<String> events,
  ) {
    return TimelineEvent(
      period: period,
      title: title ?? '',
      events: List.from(events),
    );
  }
}
