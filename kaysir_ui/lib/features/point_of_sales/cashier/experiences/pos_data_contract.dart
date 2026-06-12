import 'pos_core_data_contracts.dart';
import 'pos_data_contract_model.dart';
import 'pos_data_trait.dart';
import 'pos_inventory_data_contracts.dart';
import 'pos_service_data_contracts.dart';

export 'pos_data_contract_model.dart';

abstract final class POSDataTraitContracts {
  static const catalog = POSCoreDataContracts.catalog;
  static const menu = POSCoreDataContracts.menu;
  static const orders = POSCoreDataContracts.orders;
  static const customers = POSCoreDataContracts.customers;
  static const payments = POSCoreDataContracts.payments;
  static const promotions = POSCoreDataContracts.promotions;

  static const inventory = POSInventoryDataContracts.inventory;
  static const variants = POSInventoryDataContracts.variants;
  static const weightedItems = POSInventoryDataContracts.weightedItems;
  static const serialTracked = POSInventoryDataContracts.serialTracked;
  static const batchTracked = POSInventoryDataContracts.batchTracked;
  static const bundles = POSInventoryDataContracts.bundles;

  static const modifierGroups = POSServiceDataContracts.modifierGroups;
  static const tableService = POSServiceDataContracts.tableService;
  static const appointments = POSServiceDataContracts.appointments;
  static const deposits = POSServiceDataContracts.deposits;
  static const ageRestricted = POSServiceDataContracts.ageRestricted;
  static const serviceTickets = POSServiceDataContracts.serviceTickets;

  static const all = [
    ...POSCoreDataContracts.all,
    ...POSInventoryDataContracts.all,
    ...POSServiceDataContracts.all,
  ];

  static POSDataTraitContract? resolve(
    String traitKey, {
    Iterable<POSDataTraitContract> extraContracts = const [],
  }) {
    final normalizedKey = traitKey.trim();
    for (final contract in extraContracts) {
      if (contract.traitKey == normalizedKey) return contract;
    }

    for (final contract in all) {
      if (contract.traitKey == normalizedKey) return contract;
    }

    return null;
  }

  static List<POSDataTraitContract> forTraits(
    Iterable<String> traitKeys, {
    Iterable<POSDataTraitContract> extraContracts = const [],
  }) {
    return traitKeys
        .map((traitKey) => resolve(traitKey, extraContracts: extraContracts))
        .whereType<POSDataTraitContract>()
        .toList(growable: false);
  }

  static List<String> missingContractLabels(
    Iterable<String> traitKeys, {
    Iterable<POSDataTraitContract> extraContracts = const [],
  }) {
    return traitKeys
        .where(
          (traitKey) =>
              resolve(traitKey, extraContracts: extraContracts) == null,
        )
        .map(POSDataTraits.labelFor)
        .toList(growable: false);
  }

  static List<POSDataContractCoverage> evaluateCoverage({
    required Iterable<String> traitKeys,
    Iterable<POSDataTraitAdapter> adapters = const [],
    Iterable<POSDataTraitContract> extraContracts = const [],
    bool requireAdapters = true,
  }) {
    return traitKeys
        .map(
          (traitKey) => _coverageFor(
            traitKey: traitKey,
            adapters: adapters,
            extraContracts: extraContracts,
            requireAdapters: requireAdapters,
          ),
        )
        .toList(growable: false);
  }

  static POSDataContractCoverage _coverageFor({
    required String traitKey,
    required Iterable<POSDataTraitAdapter> adapters,
    required Iterable<POSDataTraitContract> extraContracts,
    required bool requireAdapters,
  }) {
    final contract = resolve(traitKey, extraContracts: extraContracts);
    if (contract == null) {
      return POSDataContractCoverage(
        traitKey: traitKey,
        contract: null,
        adapter: null,
        missingRequiredFields: const [],
        adapterRequired: requireAdapters,
      );
    }

    POSDataTraitAdapter? bestAdapter;
    List<POSDataContractField> bestMissing = contract.requiredFields;

    for (final adapter in adapters.where(
      (adapter) => adapter.supportsTrait(contract.traitKey),
    )) {
      final missing = adapter.missingRequiredFields(contract);
      if (bestAdapter == null || missing.length < bestMissing.length) {
        bestAdapter = adapter;
        bestMissing = missing;
      }
      if (missing.isEmpty) break;
    }

    return POSDataContractCoverage(
      traitKey: traitKey,
      contract: contract,
      adapter: bestAdapter,
      missingRequiredFields: List.unmodifiable(bestMissing),
      adapterRequired: requireAdapters,
    );
  }
}
