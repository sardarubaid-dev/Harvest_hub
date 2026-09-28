import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ImageService {
  static Future<String?> uploadImage(File imageFile, String fileName) async {
    try {
      final String? privateKey = dotenv.env['IMAGEKIT_PRIVATE_KEY'];
      
      if (privateKey == null || privateKey.isEmpty) {
        throw Exception("ImageKit Private Key is missing from .env");
      }

      final uri = Uri.parse('https://upload.imagekit.io/api/v1/files/upload');
      
      final request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Basic ${base64Encode(utf8.encode('$privateKey:'))}'
        ..fields['fileName'] = fileName
        ..fields['folder'] = '/harvest_hub/products';

      request.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(responseData);
        return data['url'] as String;
      } else {
        throw Exception("ImageKit Upload Failed: $responseData");
      }
    } catch (e) {
      rethrow;
    }
  }
}
