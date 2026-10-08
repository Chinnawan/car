import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constant/my_constant.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // 🟢 สีพื้นหลังคลีนๆ เหมือนหน้าอื่น
      appBar: AppBar(
        title: Text(
          'Vehicle Management',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: darkColor,
          ),
        ),
        backgroundColor: Colors.transparent, // 🟢 AppBar โปร่งใส
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: darkColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('product').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: primaryColor));
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.car_rental, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 15),
                  Text(
                    'No vehicles in system',
                    style: GoogleFonts.poppins(fontSize: 18, color: subTextColor),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(left: 24, right: 24, top: 10, bottom: 100), // 🟢 เผื่อที่ให้ปุ่มบวก
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var doc = docs[index];
              var data = doc.data() as Map<String, dynamic>;

              return Container(
                margin: const EdgeInsets.only(bottom: 15),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: lightColor,
                  borderRadius: BorderRadius.circular(20), // 🟢 โค้ง 20
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.05),
                      spreadRadius: 2,
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 60,
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          data['image'] ?? '',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => Icon(Icons.directions_car, color: subTextColor, size: 30),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data['title'] ?? 'ไม่มีชื่อ',
                            style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: darkColor),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${data['priceText']} | ${data['licensePlate']}',
                            style: GoogleFonts.poppins(fontSize: 11, color: subTextColor),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, color: Colors.blue, size: 20),
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ProductFormScreen(doc: doc)),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                          onPressed: () => _showDeleteDialog(context, doc.id, data['title'] ?? ''),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primaryColor,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProductFormScreen(doc: null)),
        ),
        icon: Icon(Icons.add, color: lightColor),
        label: Text('Add Vehicle', style: GoogleFonts.poppins(color: lightColor, fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String docId, String carName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete Vehicle?', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.red)),
        content: Text('Are you sure you want to delete "$carName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.poppins(color: subTextColor)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              FirebaseFirestore.instance.collection('product').doc(docId).delete();
              Navigator.pop(context);
            },
            child: Text('Delete', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

// 🟢 หน้าฟอร์ม (Form)
class ProductFormScreen extends StatefulWidget {
  final DocumentSnapshot? doc;
  const ProductFormScreen({super.key, this.doc});
  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();
  final TextEditingController _licensePlateController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _priceTextController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  
  final TextEditingController _modelYearController = TextEditingController();
  final TextEditingController _horsePowerController = TextEditingController();
  final TextEditingController _transmissionController = TextEditingController();
  
  String _selectedCategory = 'Sport'; 
  final List<String> _categories = ['Sport', 'Eco Car', 'Truck', 'Motorcycle'];

  @override
  void initState() {
    super.initState();
    if (widget.doc != null) {
      var data = widget.doc!.data() as Map<String, dynamic>;
      _titleController.text = data['title'] ?? '';
      _imageController.text = data['image'] ?? '';
      _licensePlateController.text = data['licensePlate'] ?? '';
      _priceController.text = data['price']?.toString() ?? '';
      _priceTextController.text = data['priceText'] ?? '';
      _descriptionController.text = data['description'] ?? '';
      
      _modelYearController.text = data['modelYear'] ?? '';
      _horsePowerController.text = data['horsePower'] ?? '';
      _transmissionController.text = data['transmission'] ?? '';
      
      if (_categories.contains(data['category'])) {
        _selectedCategory = data['category'];
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _imageController.dispose();
    _licensePlateController.dispose();
    _priceController.dispose();
    _priceTextController.dispose();
    _descriptionController.dispose();
    _modelYearController.dispose();
    _horsePowerController.dispose();
    _transmissionController.dispose();
    super.dispose();
  }

  Future<void> _saveData() async {
    if (_formKey.currentState!.validate()) {
      Map<String, dynamic> carData = {
        'title': _titleController.text.trim(),
        'image': _imageController.text.trim(),
        'licensePlate': _licensePlateController.text.trim(),
        'price': double.tryParse(_priceController.text.trim()) ?? 0, 
        'priceText': _priceTextController.text.trim(),
        'category': _selectedCategory,
        'description': _descriptionController.text.trim(),
        'modelYear': _modelYearController.text.trim(),
        'horsePower': _horsePowerController.text.trim(),
        'transmission': _transmissionController.text.trim(),
      };

      try {
        if (widget.doc == null) {
          await FirebaseFirestore.instance.collection('product').add(carData);
        } else {
          await FirebaseFirestore.instance.collection('product').doc(widget.doc!.id).update(carData);
        }
        
        if (mounted) {
          Navigator.pop(context); 
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved successfully!', style: TextStyle(color: Colors.white)), backgroundColor: Colors.green));
        }
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isEditing = widget.doc != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Vehicle' : 'Add Vehicle', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18, color: darkColor)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios_new, color: darkColor, size: 20), onPressed: () => Navigator.pop(context)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text("General Info", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14, color: subTextColor)),
            const SizedBox(height: 10),
            _buildTextField(controller: _titleController, label: 'Title', icon: Icons.car_rental),
            _buildTextField(controller: _imageController, label: 'Image Path (lib/images/...)', icon: Icons.image),
            _buildTextField(controller: _licensePlateController, label: 'License Plate', icon: Icons.badge),
            _buildTextField(controller: _priceController, label: 'Price Value (e.g. 11500000)', icon: Icons.numbers, isNumber: true),
            _buildTextField(controller: _priceTextController, label: 'Display Price (e.g. ฿11,500,000)', icon: Icons.attach_money),
            
            const SizedBox(height: 20),
            Text("Specifications", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14, color: subTextColor)),
            const SizedBox(height: 10),
            _buildTextField(controller: _modelYearController, label: 'Model Year', icon: Icons.calendar_month),
            _buildTextField(controller: _horsePowerController, label: 'Horse Power', icon: Icons.speed),
            _buildTextField(controller: _transmissionController, label: 'Transmission', icon: Icons.settings),
            _buildTextField(controller: _descriptionController, label: 'Description', icon: Icons.description, maxLines: 3),
            
            const SizedBox(height: 15),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(
                labelText: 'Category',
                labelStyle: GoogleFonts.poppins(color: subTextColor),
                prefixIcon: Icon(Icons.category_outlined, color: primaryColor),
                filled: true,
                fillColor: Colors.white,
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey.withOpacity(0.3))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: primaryColor, width: 2)),
              ),
              items: _categories.map((String category) {
                return DropdownMenuItem<String>(value: category, child: Text(category, style: GoogleFonts.poppins()));
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCategory = newValue!;
                });
              },
            ),

            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _saveData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 0,
                ),
                child: Text('Save Data', style: GoogleFonts.poppins(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String label, required IconData icon, bool isNumber = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        maxLines: maxLines, 
        style: GoogleFonts.poppins(),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(color: subTextColor, fontSize: 14),
          prefixIcon: Icon(icon, color: primaryColor),
          filled: true,
          fillColor: Colors.white, // 🟢 ช่องกรอกเป็นสีขาว คลีนๆ
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: primaryColor, width: 2),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Required';
          }
          return null;
        },
      ),
    );
  }
}