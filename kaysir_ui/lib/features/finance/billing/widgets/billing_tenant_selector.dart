import 'package:flutter/material.dart';

import '../models/billing_tenant_account.dart';
import 'billing_tenant_avatar.dart';

class BillingTenantSelector extends StatelessWidget {
  final List<BillingTenantAccount> tenants;
  final BillingTenantAccount selectedTenant;
  final ValueChanged<String> onTenantChanged;

  const BillingTenantSelector({
    super.key,
    required this.tenants,
    required this.selectedTenant,
    required this.onTenantChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child:
          tenants.isEmpty
              ? const Text(
                'No billing tenants available',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                ),
              )
              : Row(
                children: [
                  const Icon(
                    Icons.business_outlined,
                    color: Color(0xFF6366F1),
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Tenant',
                    style: TextStyle(
                      color: Color(0xFF475569),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedTenant.id,
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                        onChanged: (newValue) {
                          if (newValue == null) return;
                          onTenantChanged(newValue);
                        },
                        items:
                            tenants.map((tenant) {
                              return DropdownMenuItem<String>(
                                value: tenant.id,
                                child: Row(
                                  children: [
                                    BillingTenantAvatar(
                                      name: tenant.name,
                                      logoUrl: tenant.logoUrl,
                                      radius: 14,
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        tenant.name,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
    );
  }
}
