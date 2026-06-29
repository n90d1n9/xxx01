class SnowflakeIdGenerator {
  static const int _epoch = 1609459200000; // Custom epoch (2021-01-01)
  static int _lastTimestamp = 0;
  static int _sequence = 0;
  final int _workerId;

  SnowflakeIdGenerator(this._workerId);

  int next() {
    var timestamp = DateTime.now().millisecondsSinceEpoch - _epoch;

    if (timestamp == _lastTimestamp) {
      _sequence = (_sequence + 1) & 0xFFF;
      if (_sequence == 0) {
        // Wait until next millisecond
        while (timestamp <= _lastTimestamp) {
          timestamp = DateTime.now().millisecondsSinceEpoch - _epoch;
        }
      }
    } else {
      _sequence = 0;
    }

    _lastTimestamp = timestamp;

    return (timestamp << 22) | (_workerId << 12) | _sequence;
  }
}

// Usage:
//final generator = SnowflakeIdGenerator(1); // Worker ID 1
//final id = generator.next();
