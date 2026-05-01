import 'dart:convert';

import 'package:coach_app/infrastructure/services/health_service.dart';
import 'package:coach_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';

class HealthCheckScreen extends StatefulWidget {
  static const String name = '/health_check';

  const HealthCheckScreen({super.key});

  @override
  State<HealthCheckScreen> createState() => _HealthCheckScreenState();
}

class _HealthCheckScreenState extends State<HealthCheckScreen> {
  late HealthService _service;
  late Future<HealthCheckResult> _healthFuture;
  late TextEditingController _hostCtrl;
  late TextEditingController _portCtrl;

  @override
  void initState() {
    super.initState();
    _service = HealthService();
    _hostCtrl = TextEditingController(text: _service.host);
    _portCtrl = TextEditingController(text: _service.port.toString());
    _healthFuture = _fetchHealth();
  }

  Future<HealthCheckResult> _fetchHealth() async {
    try {
      return await _service.check();
    } catch (error) {
      return HealthCheckResult(
        message: error.toString(),
        raw: {'error': error.toString()},
      );
    }
  }

  void _reload() {
    setState(() {
      _healthFuture = _fetchHealth();
    });
  }

  void _applyTarget() {
    final host = _hostCtrl.text.trim();
    final parsedPort = int.tryParse(_portCtrl.text.trim());
    if (host.isEmpty || parsedPort == null) return;

    setState(() {
      _service = HealthService(hostOverride: host, portOverride: parsedPort);
      _healthFuture = _fetchHealth();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Check'),
        actions: [
          IconButton(
            tooltip: 'Recargar',
            onPressed: _reload,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextFormField(
                          controller: _hostCtrl,
                          hintText: '10.0.2.2 o IP local',
                          icon: Icons.dns_outlined,
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 90,
                        child: CustomTextFormField(
                          controller: _portCtrl,
                          keyboardType: TextInputType.number,
                          hintText: 'Puerto',
                          textAlign: TextAlign.center,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Aplicar destino',
                        onPressed: _applyTarget,
                        icon: const Icon(Icons.check_circle_outline),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Ping a ${_service.endpoint}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Misma URL que login/API (Environment)',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 16),
                  FutureBuilder<HealthCheckResult>(
                    future: _healthFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: CircularProgressIndicator(),
                        );
                      }

                      if (!snapshot.hasData) {
                        return const Text('Sin respuesta');
                      }

                      final result = snapshot.data!;
                      final isError = result.message.toLowerCase().contains(
                        'error',
                      );

                      return Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isError
                                    ? Icons.error_outline
                                    : Icons.check_circle_outline,
                                color: isError ? Colors.red : Colors.green,
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  result.message,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: isError ? Colors.red : Colors.green,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (result.raw != null) ...[
                            const SizedBox(height: 16),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Text(
                                const JsonEncoder.withIndent(
                                  '  ',
                                ).convert(result.raw),
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                          ],
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: _reload,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Volver a consultar'),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
