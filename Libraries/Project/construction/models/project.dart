enum ProjectStatus { perencanaan, pelaksanaan, selesai, ditunda }

class Project {
  final String id;
  final String nama;
  final String lokasi;
  final String klien;
  final DateTime tanggalMulai;
  final DateTime tanggalSelesai;
  final ProjectStatus status;
  final double totalBudget;
  final String? deskripsi;

  Project({
    required this.id,
    required this.nama,
    required this.lokasi,
    required this.klien,
    required this.tanggalMulai,
    required this.tanggalSelesai,
    required this.status,
    required this.totalBudget,
    this.deskripsi,
  });

  Project copyWith({
    String? nama,
    String? lokasi,
    String? klien,
    DateTime? tanggalMulai,
    DateTime? tanggalSelesai,
    ProjectStatus? status,
    double? totalBudget,
    String? deskripsi,
  }) {
    return Project(
      id: id,
      nama: nama ?? this.nama,
      lokasi: lokasi ?? this.lokasi,
      klien: klien ?? this.klien,
      tanggalMulai: tanggalMulai ?? this.tanggalMulai,
      tanggalSelesai: tanggalSelesai ?? this.tanggalSelesai,
      status: status ?? this.status,
      totalBudget: totalBudget ?? this.totalBudget,
      deskripsi: deskripsi ?? this.deskripsi,
    );
  }
}
