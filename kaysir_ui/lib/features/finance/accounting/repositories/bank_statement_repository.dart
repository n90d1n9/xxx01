import '../models/bank_reconciliation.dart';

abstract class BankStatementRepository {
  List<BankStatementLine> loadLines();

  void appendLine(BankStatementLine line);

  void appendLines(Iterable<BankStatementLine> lines);

  void removeLine(String id);

  void clear();
}

abstract class HydratableBankStatementRepository
    implements BankStatementRepository {
  Future<void> hydrate();

  Future<void> persist();
}

class InMemoryBankStatementRepository implements BankStatementRepository {
  final List<BankStatementLine> _lines;

  InMemoryBankStatementRepository({Iterable<BankStatementLine>? lines})
    : _lines = [...?lines];

  @override
  List<BankStatementLine> loadLines() {
    return List.unmodifiable(_lines);
  }

  @override
  void appendLine(BankStatementLine line) {
    _lines.add(line);
  }

  @override
  void appendLines(Iterable<BankStatementLine> lines) {
    _lines.addAll(lines);
  }

  @override
  void removeLine(String id) {
    _lines.removeWhere((line) => line.id == id);
  }

  void replaceAll(Iterable<BankStatementLine> lines) {
    _lines
      ..clear()
      ..addAll(lines);
  }

  @override
  void clear() {
    _lines.clear();
  }
}
