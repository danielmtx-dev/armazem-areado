import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/saca.dart';

class SacaService {
  final CollectionReference _col =
      FirebaseFirestore.instance.collection('sacas');

  Stream<List<Saca>> streamSacas() {
    return _col.orderBy('dataEntrada', descending: true).snapshots().map(
        (snap) => snap.docs.map((d) => Saca.fromDoc(d)).toList());
  }

  Future<void> addSaca(Saca saca) async {
    await _col.add(saca.toMap());
  }

  Future<void> deleteSaca(String id) async {
    await _col.doc(id).delete();
  }
}
