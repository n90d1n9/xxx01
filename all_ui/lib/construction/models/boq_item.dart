import 'boq_category.dart';

class BoQItem {
  final String id;
  final String projectId;
  final BoQCategory kategori;
  final String item;
  final String satuan;
  final double volume;
  final double hargaSatuan;
  final String? keterangan;

  BoQItem({
    required this.id,
    required this.projectId,
    required this.kategori,
    required this.item,
    required this.satuan,
    required this.volume,
    required this.hargaSatuan,
    this.keterangan,
  });

  double get totalHarga => volume * hargaSatuan;

  BoQItem copyWith({
    String? projectId,
    BoQCategory? kategori,
    String? item,
    String? satuan,
    double? volume,
    double? hargaSatuan,
    String? keterangan,
  }) {
    return BoQItem(
      id: id,
      projectId: projectId ?? this.projectId,
      kategori: kategori ?? this.kategori,
      item: item ?? this.item,
      satuan: satuan ?? this.satuan,
      volume: volume ?? this.volume,
      hargaSatuan: hargaSatuan ?? this.hargaSatuan,
      keterangan: keterangan ?? this.keterangan,
    );
  }
}
