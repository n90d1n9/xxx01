
class Employee {
  Employee({
    required this.noProyek,
    required this.fasePekerjaan,
    required this.kodeBiaya,
    required this.anggaranBelanja,
    required this.realisasi,
  });

  final String noProyek;
  final String fasePekerjaan;
  final String kodeBiaya;
  final double anggaranBelanja;
  final double realisasi;
}

List<Employee> employeeData = [
  Employee(
    noProyek: 'Pemrosesan Kegiatan 1',
    fasePekerjaan: 'No Phase',
    kodeBiaya: 'No Cost Code',
    anggaranBelanja: 0.00,
    realisasi: 0.00,
  ),
  Employee(
    noProyek: 'Pemrosesan Kegiatan 1',
    fasePekerjaan: '03-Preparation',
    kodeBiaya: '01-Labor',
    anggaranBelanja: 3500000.00,
    realisasi: 4480000.00,
  ),
];