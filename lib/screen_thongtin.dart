import 'package:flutter/material.dart';
import 'api_service.dart';

class ScreenThongTin extends StatefulWidget {
  @override
  _ScreenThongTinState createState() => _ScreenThongTinState();
}

class _ScreenThongTinState extends State<ScreenThongTin> {
  final ApiService apiService = ApiService();

  String? selectedProvince;
  String? selectedDistrict;
  String? selectedWard;

  late Future<List<dynamic>> provincesFuture;
  late Future<List<dynamic>> districtsFuture;
  late Future<List<dynamic>> wardsFuture;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController idNumberController = TextEditingController();
  final TextEditingController issueDateController = TextEditingController();
  final TextEditingController expiryDateController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    provincesFuture = apiService.fetchProvinces(); // Gọi API để lấy danh sách tỉnh/thành phố
  }

  @override
  void dispose() {
    // Giải phóng controller khi không còn sử dụng
    nameController.dispose();
    dobController.dispose();
    idNumberController.dispose();
    issueDateController.dispose();
    expiryDateController.dispose();
    addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.0),
        child: Column(
          children: [
            AppBar(
              backgroundColor: Colors.white,
              title: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  Expanded(
                    child: Text(
                      'Chỉnh sửa thông tin',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 20.0,
                        fontWeight: FontWeight.w700,
                        height: 1.4,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 1,
              color: Colors.grey,
            ),
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: [
            SectionTitle(title: 'Thông tin cá nhân'),
            CustomTextField(controller: nameController, label: 'Họ tên', hint: 'Full name'),
            CustomTextField(controller: dobController, label: 'Ngày sinh', hint: 'Ngày sinh', hasCalendarIcon: true),
            DropdownField(label: 'Giới tính', options: ['Nam', 'Nữ', 'Khác']),
            SizedBox(height: 16.0),
            SectionTitle(title: 'Căn cước công dân'),
            CustomTextField(controller: idNumberController, label: 'Số giấy tờ', hint: ''),
            CustomTextField(controller: issueDateController, label: 'Ngày cấp', hint: 'Ngày cấp', hasCalendarIcon: true),
            CustomTextField(controller: expiryDateController, label: 'Ngày hết hạn', hint: 'Ngày hết hạn', hasCalendarIcon: true),
            DropdownField(label: 'Nơi cấp', options: [
              'Cục CS QLHC về trật tự xã hội Hà Nội',
              'Nơi cấp khác'
            ]),

            // Dropdown cho Tỉnh/Thành phố
            FutureBuilder<List<dynamic>>(
              future: provincesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return DropdownField(
                    label: 'Tỉnh/Thành phố',
                    options: snapshot.data!.map((province) => province['name'] as String).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedProvince = value;
                        var selected = snapshot.data!.firstWhere((province) => province['name'] == value);
                        // Gọi API để lấy quận/huyện khi tỉnh/thành phố được chọn
                        districtsFuture = apiService.fetchDistricts(selected['id'].toString());
                      });
                    },
                  );
                }
              },
            ),

            // Dropdown cho Quận/Huyện
            FutureBuilder<List<dynamic>>(
              future: selectedProvince != null ? districtsFuture : null,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return DropdownField(
                    label: 'Quận/Huyện',
                    options: snapshot.data != null ? snapshot.data!.map((district) => district['name'] as String).toList() : [],
                    onChanged: (value) {
                      setState(() {
                        selectedDistrict = value;
                        var selected = snapshot.data!.firstWhere((district) => district['name'] == value);
                        wardsFuture = apiService.fetchWards(selected['id'].toString());
                      });
                    },
                  );
                }
              },
            ),

            // Dropdown cho Phươngf xa
            FutureBuilder<List<dynamic>>(
              future: selectedDistrict != null ? wardsFuture : null,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return DropdownField(
                    label: 'Phường/Xã',
                    options: snapshot.data != null ? snapshot.data!.map((ward) => ward['name'] as String).toList() : [],
                    onChanged: (value) {
                      setState(() {
                        selectedWard = value;
                      });
                    },
                  );
                }
              },
            ),

            CustomTextField(controller: addressController, label: 'Địa chỉ', hint: ''),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                // Thêm logic để lưu thông tin
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF25A55E),
                padding: EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                elevation: 0,
              ),
              child: Text(
                'Lưu chỉnh sửa',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 20.0,
          fontWeight: FontWeight.w600,
          height: 1.4,
          color: Colors.black,
        ),
        textAlign: TextAlign.left,
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final String label;
  final String hint;
  final bool hasCalendarIcon;
  final TextEditingController? controller;

  const CustomTextField({
    required this.label,
    required this.hint,
    this.hasCalendarIcon = false,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.0,
            color: Colors.black,
            fontWeight: FontWeight.w600,
            height: 1.43,
          ),
        ),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black54),
            borderRadius: BorderRadius.circular(14.0),
          ),
          child: TextField(
            controller: controller,
            readOnly: hasCalendarIcon,
            onTap: hasCalendarIcon
                ? () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2101),
              );

              if (pickedDate != null) {
                controller?.text = "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
              }
            }
                : null,
            decoration: InputDecoration(
              hintText: hint,
              suffixIcon: hasCalendarIcon
                  ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Image.asset(
                      'assets/images/lich.png',
                      width: 19,
                      height: 19,
                    ),
                  ),
                ],
              )
                  : null,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
            ),
          ),
        ),
        SizedBox(height: 16.0),
      ],
    );
  }
}

class DropdownField extends StatelessWidget {
  final String label;
  final List<String> options;
  final String? selectedValue;
  final ValueChanged<String?>? onChanged;

  const DropdownField({
    required this.label,
    required this.options,
    this.selectedValue,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.0,
            color: Colors.black,
            fontWeight: FontWeight.w600,
            height: 1.43,
          ),
        ),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black54),
            borderRadius: BorderRadius.circular(14.0),
          ),
          child: DropdownButtonFormField<String>(
            value: selectedValue,
            items: options.map((option) {
              return DropdownMenuItem<String>(
                value: option,
                child: Text(option),
              );
            }).toList(),
            onChanged: onChanged,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
            ),
            icon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/xuong.png',
                  width: 20,
                  height: 20,
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 16.0),
      ],
    );
  }
}
