import 'package:flutter/material.dart';

import '../model/report.dart';

class DomainCard extends StatelessWidget {
  final ReportDomain domain;
  final VoidCallback onTap;

  const DomainCard({super.key, required this.domain, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        elevation: 3,
        child: Container(
          width: 220,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _getColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_getIcon(), size: 48, color: _getColor()),
              ),
              const SizedBox(height: 16),
              Text(
                _getLabel(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _getDescription(),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIcon() {
    switch (domain) {
      case ReportDomain.sales:
        return Icons.shopping_cart;
      case ReportDomain.finance:
        return Icons.account_balance;
      case ReportDomain.operations:
        return Icons.settings;
      case ReportDomain.hr:
        return Icons.people;
      case ReportDomain.marketing:
        return Icons.campaign;
      case ReportDomain.analytics:
        return Icons.analytics;
      case ReportDomain.inventory:
        return Icons.inventory_2;
      case ReportDomain.customer:
        return Icons.person;
    }
  }

  Color _getColor() {
    switch (domain) {
      case ReportDomain.sales:
        return Colors.blue;
      case ReportDomain.finance:
        return Colors.green;
      case ReportDomain.operations:
        return Colors.orange;
      case ReportDomain.hr:
        return Colors.purple;
      case ReportDomain.marketing:
        return Colors.pink;
      case ReportDomain.analytics:
        return Colors.teal;
      case ReportDomain.inventory:
        return Colors.brown;
      case ReportDomain.customer:
        return Colors.indigo;
    }
  }

  String _getLabel() {
    return domain.name[0].toUpperCase() + domain.name.substring(1);
  }

  String _getDescription() {
    switch (domain) {
      case ReportDomain.sales:
        return 'Orders, revenue, and sales metrics';
      case ReportDomain.finance:
        return 'Transactions, accounts, and balances';
      case ReportDomain.operations:
        return 'Operational metrics and KPIs';
      case ReportDomain.hr:
        return 'Employee data and HR metrics';
      case ReportDomain.marketing:
        return 'Campaign performance and analytics';
      case ReportDomain.analytics:
        return 'Custom analytics and insights';
      case ReportDomain.inventory:
        return 'Stock levels and inventory tracking';
      case ReportDomain.customer:
        return 'Customer data and behavior';
    }
  }
}
