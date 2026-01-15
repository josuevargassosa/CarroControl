import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controllers/car_controller.dart';
import 'widgets/maintenance_dialog.dart';
import 'widgets/update_km_dialog.dart';

class HomePage extends GetView<CarController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final vehicle = controller.vehicle.value;
      return Scaffold(
        appBar: AppBar(
          title: const Text('CarroControl'),
          centerTitle: true,
          actions: vehicle == null
              ? null
              : [
                  IconButton(
                    tooltip: 'Registrar mantenimiento',
                    icon: const Icon(Icons.build_outlined),
                    onPressed: () {
                      showDialog<void>(
                        context: context,
                        builder: (_) => MaintenanceDialog(
                          currentKm: vehicle.currentKm,
                          onSubmit: controller.addMaintenance,
                        ),
                      );
                    },
                  ),
                ],
        ),
        floatingActionButton: vehicle == null
            ? null
            : FloatingActionButton.extended(
                icon: const Icon(Icons.speed_outlined),
                label: const Text('Actualizar Km'),
                onPressed: () {
                  showDialog<void>(
                    context: context,
                    builder: (_) => UpdateKmDialog(
                      currentKm: vehicle.currentKm,
                      onSubmit: controller.updateMileage,
                    ),
                  );
                },
              ),
        body: SafeArea(
          child: vehicle == null
              ? const _EmptyState()
              : _DashboardState(vehicleName: '${vehicle.brand} ${vehicle.model}'),
        ),
      );
    });
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Bienvenida',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 8),
          Text(
            'Registra tu vehículo para comenzar a controlar los mantenimientos.',
          ),
          SizedBox(height: 24),
          _VehicleRegistrationForm(),
        ],
      ),
    );
  }
}

class _DashboardState extends GetView<CarController> {
  const _DashboardState({required this.vehicleName});

  final String vehicleName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final history = controller.history;
    final lastMaintenance = history.isNotEmpty ? history.first : null;
    final nextService = lastMaintenance == null
        ? null
        : controller.predictNextService(10000, lastMaintenance.kmAtService);
    final daysRemaining = nextService == null
        ? null
        : nextService.difference(DateTime.now()).inDays;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            vehicleName,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          Card(
            elevation: 0,
            color: theme.colorScheme.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dashboard',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _KpiTile(
                          label: 'Días Restantes',
                          value: daysRemaining == null
                              ? 'Sin datos'
                              : daysRemaining.clamp(0, 9999).toString(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _KpiTile(
                          label: 'Próximo Servicio',
                          value: nextService == null
                              ? 'Sin datos'
                              : DateFormat('dd/MM/yyyy').format(nextService),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Historial reciente',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: history.isEmpty
                ? Center(
                    child: Text(
                      'Sin mantenimientos registrados.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  )
                : ListView.separated(
                    itemCount: history.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final maintenance = history[index];
                      return ListTile(
                        tileColor: theme.colorScheme.surfaceContainerHighest,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        title: Text(maintenance.title),
                        subtitle: Text(
                          '${maintenance.kmAtService} km · ${DateFormat('dd/MM/yyyy').format(maintenance.date)}',
                        ),
                        trailing: Text(
                          '\$${maintenance.cost.toStringAsFixed(2)}',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _KpiTile extends StatelessWidget {
  const _KpiTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _VehicleRegistrationForm extends StatefulWidget {
  const _VehicleRegistrationForm();

  @override
  State<_VehicleRegistrationForm> createState() =>
      _VehicleRegistrationFormState();
}

class _VehicleRegistrationFormState extends State<_VehicleRegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _costController = TextEditingController();
  final _kmController = TextEditingController();
  bool _isValid = false;

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _costController.dispose();
    _kmController.dispose();
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

  String? _validateYear(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Campo obligatorio';
    }
    final parsed = int.tryParse(value);
    if (parsed == null) {
      return 'Ingresa un número válido';
    }
    if (parsed <= 1900) {
      return 'El año debe ser mayor a 1900';
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
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CarController>();
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          onChanged: _updateValidity,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Registro de Vehículo',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _brandController,
                decoration: const InputDecoration(labelText: 'Marca'),
                validator: _requiredText,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _modelController,
                decoration: const InputDecoration(labelText: 'Modelo'),
                validator: _requiredText,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _yearController,
                      decoration: const InputDecoration(labelText: 'Año'),
                      keyboardType: TextInputType.number,
                      validator: _validateYear,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _costController,
                      decoration: const InputDecoration(labelText: 'Costo'),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: _validateCost,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _kmController,
                decoration: const InputDecoration(labelText: 'Kilometraje'),
                keyboardType: TextInputType.number,
                validator: _validateKm,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isValid
                      ? () {
                          controller.registerVehicle(
                            brand: _brandController.text.trim(),
                            model: _modelController.text.trim(),
                            year: int.parse(_yearController.text),
                            purchaseCost: double.parse(
                              _costController.text.replaceAll(',', '.'),
                            ),
                            currentKm: int.parse(_kmController.text),
                          );
                        }
                      : null,
                  child: const Text('Guardar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
