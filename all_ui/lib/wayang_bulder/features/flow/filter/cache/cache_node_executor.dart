import 'dart:convert';

import 'cache_entry.dart';
import 'dart:async';

import 'cache_node_definition.dart';
import 'cache_strategy.dart';

class CacheNodeExecutor {
  final CacheNodeDefinition definition;
  final Map<String, CacheEntry> _cache = {};

  CacheNodeExecutor(this.definition);

  Future<Map<String, dynamic>> execute(
    Map<String, dynamic> input,
    Future<Map<String, dynamic>> Function(Map<String, dynamic>) operation,
  ) async {
    final cacheKey = _getCacheKey(input);

    // Check cache
    final cachedValue = _getFromCache(cacheKey);
    if (cachedValue != null) {
      return {
        'success': true,
        'cache_hit': true,
        'output_port': 'cached',
        'data': cachedValue,
      };
    }

    // Execute operation
    try {
      final result = await operation(input);

      // Only cache if operation succeeded or if cacheOnError is enabled
      if (result['success'] == true || definition.cacheOnError) {
        _putInCache(cacheKey, result);
      }

      return {
        'success': true,
        'cache_hit': false,
        'output_port': 'executed',
        'data': result,
      };
    } catch (e, stack) {
      return {
        'success': false,
        'cache_hit': false,
        'error': e.toString(),
        'stack_trace': stack.toString(),
        'data': input,
      };
    }
  }

  String _getCacheKey(Map<String, dynamic> input) {
    if (input.containsKey(definition.cacheKeyField)) {
      return input[definition.cacheKeyField].toString();
    }
    // Normalize input for consistent hashing
    final sortedKeys = input.keys.toList()..sort();
    final normalized = {for (final k in sortedKeys) k: input[k]};
    return jsonEncode(normalized);
  }

  dynamic _getFromCache(String key) {
    final entry = _cache[key];
    if (entry == null) return null;

    // Handle TTL eviction
    if (definition.strategy == CacheStrategy.timeToLive) {
      if (entry.isExpired(definition.ttl)) {
        _cache.remove(key);
        return null;
      }
    }

    // Update access metadata
    entry.lastAccessedAt = DateTime.now();
    entry.accessCount++;

    return entry.value;
  }

  void _putInCache(String key, dynamic value) {
    // Evict if at capacity
    if (_cache.length >= definition.maxSize) {
      _evict();
    }

    _cache[key] = CacheEntry(value);
  }

  void _evict() {
    if (_cache.isEmpty) return;

    String? keyToRemove;

    switch (definition.strategy) {
      case CacheStrategy.fifo:
        keyToRemove = _cache.entries
            .reduce(
              (a, b) => a.value.createdAt.isBefore(b.value.createdAt) ? a : b,
            )
            .key;
        break;

      case CacheStrategy.timeToLive:
        keyToRemove = _cache.entries
            .reduce(
              (a, b) => a.value.createdAt.isBefore(b.value.createdAt) ? a : b,
            )
            .key;
        break;

      case CacheStrategy.lru:
        keyToRemove = _cache.entries
            .reduce(
              (a, b) => a.value.lastAccessedAt.isBefore(b.value.lastAccessedAt)
                  ? a
                  : b,
            )
            .key;
        break;

      case CacheStrategy.lfu:
        keyToRemove = _cache.entries
            .reduce((a, b) => a.value.accessCount < b.value.accessCount ? a : b)
            .key;
        break;
    }

    _cache.remove(keyToRemove);
  }

  void clear() {
    _cache.clear();
  }

  int get cacheSize => _cache.length;

  Map<String, dynamic> getStats() {
    return {
      'size': _cache.length,
      'max_size': definition.maxSize,
      'strategy': definition.strategy.name,
      'ttl_seconds': definition.ttl.inSeconds,
    };
  }
}
