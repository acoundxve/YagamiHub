import 'package:flutter/material.dart';

const licenseStatusOptions = ['ACTIVE', 'SUSPENDED', 'EXPIRED'];

String licenseStatusLabel(String status) => switch (status) {
      'ACTIVE' => 'Activa',
      'SUSPENDED' => 'Suspendida',
      'EXPIRED' => 'Vencida',
      _ => status,
    };

Color licenseStatusColor(String status) => switch (status) {
      'ACTIVE' => Colors.green,
      'SUSPENDED' => Colors.orange,
      'EXPIRED' => Colors.red,
      _ => Colors.grey,
    };

class LicenseStatusChip extends StatelessWidget {
  const LicenseStatusChip({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final color = licenseStatusColor(status);
    return Chip(
      label: Text(licenseStatusLabel(status)),
      backgroundColor: color.withOpacity(0.15),
      labelStyle: TextStyle(color: color, fontWeight: FontWeight.w600),
      side: BorderSide(color: color.withOpacity(0.4)),
    );
  }
}
