import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/saca.dart';
import '../services/saca_service.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  bool _handled = false;

  void _onDetect(BarcodeCapture capture) {
    if (_handled) return;
    final barcode = capture.barcodes.firstOrNull;
    final raw = barcode?.rawValue;
    if (raw == null) return;
    _handled = true;

    // Tenta ler o QR como JSON: {"numero":"123","quantidade":60,"tipoBebida":"Arabica"}
    String numero = raw;
    num? quantidade;
    String tipoBebida = '';
    try {
      final data = jsonDecode(raw);
      if (data is Map) {
        numero = data['numero']?.toString() ?? raw;
        quantidade = num.tryParse(data['quantidade']?.toString() ?? '');
        tipoBebida = data['tipoBebida']?.toString() ?? '';
      }
    } catch (_) {
      // QR não é JSON: usa o conteúdo bruto como número da saca
    }

    Navigator.of(context).pop();
    showDialog(
      context: context,
      builder: (_) => _ConfirmSacaDialog(
        numero: numero,
        quantidade: quantidade,
        tipoBebida: tipoBebida,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Escanear QR Code')),
      body: MobileScanner(onDetect: _onDetect),
    );
  }
}

extension _FirstOrNull<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

class _ConfirmSacaDialog extends StatefulWidget {
  final String numero;
  final num? quantidade;
  final String tipoBebida;

  const _ConfirmSacaDialog({
    required this.numero,
    required this.quantidade,
    required this.tipoBebida,
  });

  @override
  State<_ConfirmSacaDialog> createState() => _ConfirmSacaDialogState();
}

class _ConfirmSacaDialogState extends State<_ConfirmSacaDialog> {
  late final TextEditingController _numeroController =
      TextEditingController(text: widget.numero);
  late final TextEditingController _quantidadeController =
      TextEditingController(text: widget.quantidade?.toString() ?? '');
  late final TextEditingController _tipoController =
      TextEditingController(text: widget.tipoBebida);
  final _service = SacaService();
  bool _saving = false;

  Future<void> _salvar() async {
    setState(() => _saving = true);
    final user = FirebaseAuth.instance.currentUser;
    final saca = Saca(
      numero: _numeroController.text.trim(),
      quantidade: num.tryParse(_quantidadeController.text.trim()) ?? 0,
      tipoBebida: _tipoController.text.trim(),
      dataEntrada: DateTime.now(),
      criadoPor: user?.email ?? 'desconhecido',
    );
    await _service.addSaca(saca);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Confirmar saca'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _numeroController,
            decoration: const InputDecoration(labelText: 'Número da saca'),
          ),
          TextField(
            controller: _quantidadeController,
            decoration: const InputDecoration(labelText: 'Quantidade'),
            keyboardType: TextInputType.number,
          ),
          TextField(
            controller: _tipoController,
            decoration: const InputDecoration(labelText: 'Tipo de bebida'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _saving ? null : _salvar,
          child: _saving
              ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Salvar'),
        ),
      ],
    );
  }
}
