import 'package:flutter/material.dart';

import 'evidence_capture_form_helpers.dart';

class EvidenceCaptureLocationFields extends StatelessWidget {
  final TextEditingController latitudeController;
  final TextEditingController longitudeController;
  final TextEditingController accuracyController;
  final TextEditingController altitudeController;
  final TextEditingController providerController;
  final bool isMocked;
  final ValueChanged<bool> onMockedChanged;

  const EvidenceCaptureLocationFields({
    super.key,
    required this.latitudeController,
    required this.longitudeController,
    required this.accuracyController,
    required this.altitudeController,
    required this.providerController,
    required this.isMocked,
    required this.onMockedChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: latitudeController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                decoration: evidenceCaptureInputDecoration(
                  label: 'Latitude',
                  icon: Icons.my_location_outlined,
                ),
                validator: (value) =>
                    EvidenceCaptureFieldValidators.requiredDouble(
                      value,
                      'latitude',
                    ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: longitudeController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                decoration: evidenceCaptureInputDecoration(
                  label: 'Longitude',
                  icon: Icons.explore_outlined,
                ),
                validator: (value) =>
                    EvidenceCaptureFieldValidators.requiredDouble(
                      value,
                      'longitude',
                    ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: accuracyController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: evidenceCaptureInputDecoration(
                  label: 'Accuracy meters',
                  icon: Icons.gps_fixed_outlined,
                ),
                validator: (value) =>
                    EvidenceCaptureFieldValidators.optionalNonNegativeDouble(
                      value,
                      'accuracy',
                    ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: altitudeController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                decoration: evidenceCaptureInputDecoration(
                  label: 'Altitude meters',
                  icon: Icons.terrain_outlined,
                ),
                validator: (value) =>
                    EvidenceCaptureFieldValidators.optionalDouble(
                      value,
                      'altitude',
                    ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: providerController,
          decoration: evidenceCaptureInputDecoration(
            label: 'Provider',
            icon: Icons.sensors_outlined,
          ),
        ),
        const SizedBox(height: 4),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: isMocked,
          onChanged: onMockedChanged,
          title: const Text('Mock location'),
          secondary: const Icon(Icons.developer_mode_outlined),
        ),
      ],
    );
  }
}
