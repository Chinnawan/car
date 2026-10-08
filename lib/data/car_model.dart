class CarModel {
  final String name;
  final String licensePlate;
  final String imagePath;
  final String price;
  final String category;
  final String description;
  final String modelYear;     // 🟢 เพิ่ม Model Year
  final String horsePower;    // 🟢 เพิ่ม Horse Power
  final String transmission;  // 🟢 เพิ่ม Transmission

  CarModel({
    required this.name,
    required this.licensePlate,
    required this.imagePath,
    required this.price,
    required this.category,
    required this.description,
    required this.modelYear,
    required this.horsePower,
    required this.transmission,
  });

  factory CarModel.fromJson(Map<String, dynamic> json) {
    return CarModel(
      name: json['name'] ?? '',
      licensePlate: json['licensePlate'] ?? '',
      imagePath: json['imagePath'] ?? '',
      price: json['price'] ?? '',
      category: json['category'] ?? 'All',
      description: json['description'] ?? 'ไม่มีคำอธิบายเพิ่มเติมสำหรับรถคันนี้',
      modelYear: json['modelYear'] ?? '-',       // ดึงข้อมูลปีรถ
      horsePower: json['horsePower'] ?? '-',     // ดึงข้อมูลแรงม้า
      transmission: json['transmission'] ?? '-', // ดึงข้อมูลเกียร์
    );
  }
}