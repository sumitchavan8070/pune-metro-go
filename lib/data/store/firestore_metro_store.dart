import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pune_metro_guide/data/store/metro_store.dart';

class FirestoreMetroStore extends MetroStore {
  FirestoreMetroStore(this._firestore, {required this.deviceId});

  final FirebaseFirestore _firestore;
  final String deviceId;

  static const _deviceTables = {'favourites', 'recent_journeys'};

  CollectionReference<Map<String, dynamic>> _collection(String table) {
    if (_deviceTables.contains(table)) {
      return _firestore.collection('devices').doc(deviceId).collection(table);
    }
    return _firestore.collection(table);
  }

  @override
  Future<void> hydrate() async {
    for (final table in MetroStore.tables) {
      final snapshot = await _collection(table).get();
      replaceTable(table, [
        for (final doc in snapshot.docs) _rowFromDoc(table, doc),
      ]);
    }
  }

  @override
  Future<void> flushDirty() async {
    final dirty = takeDirty();
    for (final table in dirty) {
      await _push(table);
    }
  }

  Future<void> _push(String table) async {
    final rows = all(table);
    final collection = _collection(table);
    final existing = await collection.get();
    final keep = <String>{};
    WriteBatch batch = _firestore.batch();
    var operations = 0;

    Future<void> commitIfNeeded({bool force = false}) async {
      if (operations == 0) {
        return;
      }
      if (!force && operations < 400) {
        return;
      }
      await batch.commit();
      batch = _firestore.batch();
      operations = 0;
    }

    for (final row in rows) {
      final id = table == 'meta' ? row['key'].toString() : row['id'].toString();
      keep.add(id);
      batch.set(collection.doc(id), row);
      operations++;
      await commitIfNeeded();
    }
    for (final doc in existing.docs) {
      if (!keep.contains(doc.id)) {
        batch.delete(doc.reference);
        operations++;
        await commitIfNeeded();
      }
    }
    await commitIfNeeded(force: true);
  }

  Map<String, dynamic> _rowFromDoc(String table, QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = Map<String, dynamic>.from(doc.data());
    if (table == 'meta') {
      data['key'] ??= doc.id;
      return data;
    }
    final id = data['id'];
    if (id is num) {
      data['id'] = id.toInt();
    } else {
      data['id'] = int.tryParse(doc.id) ?? data['id'];
    }
    for (final entry in data.entries.toList()) {
      final value = entry.value;
      if (value is num && value is! double) {
        data[entry.key] = value.toInt();
      }
    }
    return data;
  }
}
