import 'package:logging/logging.dart';
import 'local_storage_service.dart';

final _logger = Logger('MessageCache');

class MessageCache {
  static const String _namespace = 'chat_messages';
  static const int _maxMessagesPerRoom = 200; // Tuned down to reasonable offline size

  static String _getCacheKey(String roomId) => 'messages_$roomId';

  /// Cache a list of messages for a room, overwriting previous cache
  static Future<void> cacheMessages(String roomId, List<Map<String, dynamic>> messages) async {
    // Keep only the latest max messages
    final subset = messages.length > _maxMessagesPerRoom 
        ? messages.sublist(messages.length - _maxMessagesPerRoom) 
        : messages;
        
    await LocalDBService.cacheJson(
      key: _getCacheKey(roomId),
      value: subset,
      namespace: _namespace,
      expiration: const Duration(days: 7),
      priority: 5,
    );
    _logger.fine('Cached ${subset.length} messages for room $roomId');
  }

  /// Get cached messages for a room
  static Future<List<Map<String, dynamic>>?> getCachedMessages(String roomId) async {
    final raw = await LocalDBService.getCachedJson(
      key: _getCacheKey(roomId),
      parser: (json) {
        if (json is List) {
          return json.map((e) {
            if (e is Map) {
              return Map<String, dynamic>.from(e);
            }
            return <String, dynamic>{};
          }).toList();
        }
        return <Map<String, dynamic>>[];
      },
      namespace: _namespace,
    );
    if (raw == null || raw.isEmpty) return null;
    return raw;
  }

  /// Append a message to the cache (or update if exists)
  static Future<void> appendMessage(String roomId, Map<String, dynamic> message) async {
    final current = await getCachedMessages(roomId) ?? <Map<String, dynamic>>[];
    final messageId = message['id']?.toString() ?? '';
    final clientMessageId = message['clientMessageId']?.toString() ?? '';
    
    int existingIdx = -1;
    for (int i = 0; i < current.length; i++) {
        final mId = current[i]['id']?.toString() ?? '';
        final cId = current[i]['clientMessageId']?.toString() ?? '';
        
        // Match by server ID OR client ID
        if ((messageId.isNotEmpty && mId == messageId) || 
            (clientMessageId.isNotEmpty && cId == clientMessageId)) {
            existingIdx = i;
            break;
        }
    }
    
    if (existingIdx >= 0) {
        // Merge existing with new (preserve some local-only fields if needed)
        final merged = <String, dynamic>{...current[existingIdx], ...message};
        current[existingIdx] = merged;
    } else {
        current.add(message);
    }
    
    // Sort by timestamp if available
    current.sort((a, b) {
      final tA = DateTime.tryParse(a['createdAt']?.toString() ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
      final tB = DateTime.tryParse(b['createdAt']?.toString() ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
      return tA.compareTo(tB);
    });

    await cacheMessages(roomId, current);
  }

  /// Synchronize local cache with a fresh list of messages from the server
  static Future<void> syncByRoom(String roomId, List<Map<String, dynamic>> serverMessages) async {
    final current = await getCachedMessages(roomId) ?? <Map<String, dynamic>>[];
    
    // Create a map for quick lookup by ID
    final mergedMap = <String, Map<String, dynamic>>{};
    
    // Add current local messages (including pending ones)
    for (final m in current) {
      final key = m['id']?.toString() ?? m['clientMessageId']?.toString() ?? '';
      if (key.isNotEmpty) mergedMap[key] = m;
    }
    
    // Overlay server messages (they win for confirmed status)
    for (final m in serverMessages) {
      final key = m['id']?.toString() ?? '';
      if (key.isNotEmpty) {
        // If we had a pending message with same clientMessageId, remove it and use server version
        final cId = m['clientMessageId']?.toString();
        if (cId != null && mergedMap.containsKey(cId)) {
          mergedMap.remove(cId);
        }
        mergedMap[key] = m;
      }
    }
    
    final finalMessages = mergedMap.values.toList();
    finalMessages.sort((a, b) {
      final tA = DateTime.tryParse(a['createdAt']?.toString() ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
      final tB = DateTime.tryParse(b['createdAt']?.toString() ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
      return tA.compareTo(tB);
    });
    
    await cacheMessages(roomId, finalMessages);
    _logger.info('Synchronized ${finalMessages.length} messages for room $roomId');
  }

  /// Invalidate cache for a room
  static Future<void> invalidate(String roomId) async {
    await LocalDBService.clearCache(key: _getCacheKey(roomId));
    _logger.fine('Invalidated message cache for room $roomId');
  }

  /// Invalidate all message caches
  static Future<void> invalidateAll() async {
    await LocalDBService.clearCacheNamespace(_namespace);
    _logger.fine('Invalidated all message caches');
  }
}
