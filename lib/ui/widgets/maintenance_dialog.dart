import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MaintenanceDialog extends StatefulWidget {
  const MaintenanceDialog({
    super.key,
    required this.currentKm,
    required this.onSubmit,
  });

  final int currentKm;
  final void Function({
    required String title,
    required double cost,
    required DateTime date,
    required int kmAtService,
  }) onSubmit;

  @override
  State<MaintenanceDialog> createState() => _MaintenanceDialogState();
}

class _MaintenanceDialogState extends State<MaintenanceDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _costController = TextEditingController();
  final _kmController = TextEditingController();
  final _dateController = TextEditingController();
  DateTime? _selectedDate;
  bool _isValid = false;

  @override
  void dispose() {
    _titleController.dispose();
    _costController.dispose();
    _kmController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  void _updateValidity() {
    setState(() {
      _isValid = _formKey.currentState?.validate() ?? false;
    });
  }

  String? _requiredText(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Campo obligatorio';
    }
    return null;
  }

  String? _validateCost(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Campo obligatorio';
    }
    final parsed = double.tryParse(value.replaceAll(',', '.'));
    if (parsed == null) {
      return 'Ingresa un monto válido';
    }
    if (parsed <= 0) {
      return 'El costo debe ser mayor a 0';
    }
    return null;
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

  String? _validateDate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Campo obligatorio';
    }
    if (_selectedDate == null) {
      return 'Selecciona una fecha válida';
    }
    final now = DateTime.now();
    if (_selectedDate!.isAfter(DateTime(now.year, now.month, now.day, 23, 59))) {
      return 'La fecha de servicio no puede ser futura';
    }
    return null;
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
      _updateValidity();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Registrar mantenimiento'),
      content: Form(
        key: _formKey,
        onChanged: _updateValidity,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Servicio'),
                validator: _requiredText,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _costController,
                decoration: const InputDecoration(labelText: 'Costo'),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: _validateCost,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _kmController,
                decoration: const InputDecoration(labelText: 'Kilometraje'),
                keyboardType: TextInputType.number,
                validator: _validateKm,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _dateController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Fecha de servicio',
                  suffixIcon: Icon(Icons.calendar_today_outlined),
                ),
                onTap: _pickDate,
                validator: _validateDate,
              ),
            ],
          ),
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
                  widget.onSubmit(
                    title: _titleController.text.trim(),
                    cost: double.parse(
                      _costController.text.replaceAll(',', '.'),
                    ),
                    date: _selectedDate!,
                    kmAtService: int.parse(_kmController.text),
                  );
                  Navigator.of(context).pop();
                }
              : null,
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
