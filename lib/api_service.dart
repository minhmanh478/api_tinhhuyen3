import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio = Dio();

  Future<List<dynamic>> fetchProvinces() async {
    try {
      final response = await _dio.get('https://esgoo.net/api-tinhthanh/1/0.htm');
      if (response.statusCode == 200) {
        return response.data['data'] as List<dynamic>; // Giả sử API trả về danh sách tỉnh thành
      } else {
        return []; // Trả về danh sách rỗng nếu không thành công
      }
    } catch (e) {
      print('Error fetching provinces: $e');
      return []; // Trả về danh sách rỗng khi có lỗi
    }
  }

  // Hàm lấy danh sách quận huyện theo ID tỉnh
  Future<List<dynamic>> fetchDistricts(String provinceId) async {
    try {
      final response = await _dio.get('https://esgoo.net/api-tinhthanh/2/$provinceId.htm'); // Địa chỉ API cho quận huyện
      if (response.statusCode == 200) {
        return response.data['data'] as List<dynamic>;
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetching districts: $e');
      return [];
    }
  }

  // Hàm lấy danh sách phường xã theo ID quận
  Future<List<dynamic>> fetchWards(String districtId) async {
    try {
      final response = await _dio.get('https://esgoo.net/api-tinhthanh/3/$districtId.htm'); // Địa chỉ API cho phường xã
      if (response.statusCode == 200) {
        return response.data['data'] as List<dynamic>;
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetching wards: $e');
      return [];
    }
  }
}
