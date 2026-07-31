import 'package:cloud_firestore/cloud_firestore.dart';

class Saca {
  final String? id;
  final String numero;
  final num quantidade;
  final String tipoBebida;
  final DateTime dataEntrada;
  final String criadoPor;

  Saca({
    this.id,
    required this.numero,
    required this.quantidade,
    required this.tipoBebida,
    required this.dataEntrada,
    required this.criadoPor,
  });

  Map<String, dynamic> toMap() {
    return {
      'numero': numero,
      'quantidade': quantidade,
      'tipoBebida': tipoBebida,
      'dataEntrada': Timestamp.fromDate(dataEntrada),
      'criadoPor': criadoPor,
    };
  }

  factory Saca.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Saca(
      id: doc.id,
      numero: data['numero']?.toString() ?? '',
      quantidade: data['quantidade'] ?? 0,
      tipoBebida: data['tipoBebida']?.toString() ?? '',
      dataEntrada: (data['dataEntrada'] as Timestamp?)?.toDate() ?? DateTime.now(),
      criadoPor: data['criadoPor']?.toString() ?? '',
    );
  }
}
