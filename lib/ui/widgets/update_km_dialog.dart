import 'package:flutter/material.dart';

class UpdateKmDialog extends StatefulWidget {
  const UpdateKmDialog({
    super.key,
    required this.currentKm,
    required this.onSubmit,
  });

  final int currentKm;
  final void Function(int newKm) onSubmit;

  @override
  State<UpdateKmDialog> createState() => _UpdateKmDialogState();
}

class _UpdateKmDialogState extends State<UpdateKmDialog> {
  final _formKey = GlobalKey<FormState>();
  final _kmController = TextEditingController();
  bool _isValid = false;

  @override
  void dispose() {
    _kmController.dispose();
    super.dispose();
  }

  void _updateValidity() {
    setState(() {
      _isValid = _formKey.currentState?.validate() ?? false;
    });
  }

  String? _validateKm(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Campo obligatorio';
    }
    final parsed = int.tryParse(value);
    if (parsed == null) {
      return 'Ingresa un número válido';
    }
    if (parsed <= 0) {
      return 'El kilometraje debe ser mayor a 0';
    }
    if (parsed < widget.currentKm) {
      return 'El kilometraje no puede ser menor al actual';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Actualizar kilometraje'),
      content: Form(
        key: _formKey,
        onChanged: _updateValidity,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: TextFormField(
          controller: _kmController,
          decoration: InputDecoration(
            labelText: 'Kilometraje actual',
            helperText: 'Actual: ${widget.currentKm} km',
          ),
          keyboardType: TextInputType.number,
          validator: _validateKm,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _isValid
              ? () {
                  widget.onSubmit(int.parse(_kmController.text));
                  Navigator.of(context).pop();
                }
              : null,
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
