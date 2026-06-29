// Cloud Sync Service
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';

import '../model/agenda_item.dart';

class CloudSyncService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get userId => _auth.currentUser?.uid;

  // Sync events to cloud
  Future<bool> syncToCloud(List<AgendaItem> items) async {
    if (userId == null) return false;

    try {
      final batch = _firestore.batch();
      final userEventsRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('events');

      for (final item in items) {
        final docRef = userEventsRef.doc(item.id);
        batch.set(docRef, item.toJson());
      }

      await batch.commit();

      // Update last sync time
      await _firestore.collection('users').doc(userId).set({
        'lastSync': FieldValue.serverTimestamp(),
        'email': _auth.currentUser?.email,
      }, SetOptions(merge: true));

      return true;
    } catch (e) {
      debugPrint('Sync to cloud error: $e');
      return false;
    }
  }

  // Download events from cloud
  Future<List<AgendaItem>> downloadFromCloud() async {
    if (userId == null) return [];

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('events')
          .get();

      return snapshot.docs
          .map((doc) => AgendaItem.fromJson(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Download from cloud error: $e');
      return [];
    }
  }

  // Real-time sync listener
  Stream<List<AgendaItem>> listenToCloudChanges() {
    if (userId == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('events')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => AgendaItem.fromJson(doc.data()))
              .toList(),
        );
  }

  // Share event with other users
  Future<String?> shareEvent(AgendaItem item) async {
    if (userId == null) return null;

    try {
      final shareRef = await _firestore.collection('shared_events').add({
        ...item.toJson(),
        'sharedBy': userId,
        'sharedAt': FieldValue.serverTimestamp(),
      });

      return shareRef.id;
    } catch (e) {
      debugPrint('Share event error: $e');
      return null;
    }
  }

  // Get shared event
  Future<AgendaItem?> getSharedEvent(String shareId) async {
    try {
      final doc = await _firestore
          .collection('shared_events')
          .doc(shareId)
          .get();

      if (doc.exists) {
        return AgendaItem.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      debugPrint('Get shared event error: $e');
      return null;
    }
  }

  // Create collaborative event
  Future<String?> createCollaborativeEvent(
    AgendaItem item,
    List<String> collaboratorIds,
  ) async {
    if (userId == null) return null;

    try {
      final eventRef = await _firestore.collection('collaborative_events').add({
        ...item.toJson(),
        'ownerId': userId,
        'collaborators': collaboratorIds,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Notify collaborators
      for (final collaboratorId in collaboratorIds) {
        await _firestore
            .collection('users')
            .doc(collaboratorId)
            .collection('notifications')
            .add({
              'type': 'event_invitation',
              'eventId': eventRef.id,
              'from': userId,
              'timestamp': FieldValue.serverTimestamp(),
            });
      }

      return eventRef.id;
    } catch (e) {
      debugPrint('Create collaborative event error: $e');
      return null;
    }
  }
}
