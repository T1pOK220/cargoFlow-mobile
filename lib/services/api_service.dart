import 'dart:convert';
import 'package:http/http.dart' as http;
import '/services/token_storage.dart';
import 'package:cargo_flow/models/json_model.dart';
import 'package:cargo_flow/models/multipart.dart';
import 'package:http_parser/http_parser.dart';
import 'package:cargo_flow/utils/exception.dart';
class ApiService {
  final String baseUrl = 'http://localhost:5000/api/';
  // https://cargoflow-oyra.onrender.com/api/
  final TokenStorage _tokenStorage = TokenStorage();
  Future<dynamic> get(String path) async {
    final Map<String,String>headers = await getHeaders();
    try{
      final response = await http
          .get(Uri.parse('$baseUrl$path'),
        headers:headers,
      );

      print('8. HTTP статус: ${response.statusCode}');
      print('9. Відповідь: ${response.body}');

      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        return jsonDecode(response.body);
      }
      if (response.statusCode >= 400 && response.statusCode < 500) {
        throw GetException(extractMessage(response));
      }

      throw Exception('HTTP error: ${response.statusCode}');
    } catch (e) {
      print('Помилка API: $e');
      rethrow;
    }
  }
  String extractMessage(http.Response response) {
    try {
      final body = jsonDecode(utf8.decode(response.bodyBytes));
      if (body is Map && body['message'] is String) {
        return body['message'] as String;
      }
    } catch (_) {
      // тіло не JSON, нижче повернемо запасний текст
    }
    return 'Помилка сервера (${response.statusCode})';
  }
  Future<dynamic> postLogin(String path,Object? obj) async {
    try{
      final response = await http
          .post(Uri.parse('$baseUrl$path'),
        headers:{ 'Content-Type': 'application/json',
        },
          body: jsonEncode(obj),
      );

      print('8. HTTP статус: ${response.statusCode}');
      print('9. Відповідь: ${response.body}');

      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        return jsonDecode(response.body);
      }

      throw Exception('HTTP error: ${response.statusCode}');
    }catch(e){
      print('Помилка API: $e');
      rethrow;
    }
  }
  Future<dynamic> delete(String path) async {
    final Map<String,String>headers = await getHeaders();
    try{
      final response = await http
          .delete(Uri.parse('$baseUrl$path'),
        headers:headers,
      );

      print('8. HTTP статус: ${response.statusCode}');
      print('9. Відповідь: ${response.body}');

      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        return jsonDecode(response.body);
      }
      if (response.statusCode >= 400 && response.statusCode < 500) {
        throw GetException(extractMessage(response));
      }
      throw Exception('HTTP error: ${response.statusCode}');
    }catch(e){
      print('Помилка API: $e');
      rethrow;
    }
  }
  Future<dynamic> patch(String path,Object?obj) async {
    final Map<String,String>headers = await getHeaders();
    try{
      final response = await http
          .patch(Uri.parse('$baseUrl$path'),
        headers:headers,
        body: jsonEncode(obj),
      );

      print('8. HTTP статус: ${response.statusCode}');
      print('9. Відповідь: ${response.body}');

      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        return jsonDecode(response.body);
      }
      if (response.statusCode >= 400 && response.statusCode < 500) {
        throw GetException(extractMessage(response));
      }
      throw Exception('HTTP error: ${response.statusCode}');
    }catch(e){
      print('Помилка API: $e');
      rethrow;
    }
  }
  Future<Map<String, String>> getHeaders() async {
    final token = await _tokenStorage.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Користувач не авторизований');
    }

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
  Future<void> multipartRequest(
      String path,
      MultipartModel obj,
      String methods,
      ) async {
   try{
     final token = await _tokenStorage.getToken();

     final request = http.MultipartRequest(methods,
       Uri.parse('$baseUrl$path'),
     );

     request.headers['Authorization'] = 'Bearer $token';
     request.fields.addAll(
       (obj as JsonModel).toJson().map(
             (key, value) => MapEntry(
           key,
           value?.toString() ?? '',
         ),
       ),
     );
     final file = obj.file;
     if (file != null) {
       request.files.add(
         http.MultipartFile.fromBytes(
           'avatar',
           await file.readAsBytes(),
           filename: file.name,
           contentType: MediaType.parse(file.mimeType ?? 'image/jpeg'),
         ),
       );
     }
     final streamedResponse = await request.send();
     final response = await http.Response.fromStream(streamedResponse);
     print('8. HTTP статус: ${response.statusCode}');
     print('9. Відповідь: ${response.body}');

     if (response.statusCode >= 200 &&
         response.statusCode < 300) {
       return jsonDecode(response.body);
     }
     if (response.statusCode >= 400 && response.statusCode < 500) {
       throw GetException(extractMessage(response));
     }

     throw Exception('HTTP error: ${response.statusCode}');
   }catch(e){
     print('Помилка API: $e');
     rethrow;
   }
  }
Future<dynamic> post(String path,Object? obj) async {
    final Map<String,String>headers = await getHeaders();
    print(headers);
try{
final response = await http
.post(Uri.parse('$baseUrl$path'),
headers:headers,
body: jsonEncode(obj),
);

print('8. HTTP статус: ${response.statusCode}');
print('9. Відповідь: ${response.body}');

if (response.statusCode >= 200 &&
response.statusCode < 300) {
return jsonDecode(response.body);
}
if (response.statusCode >= 400 && response.statusCode < 500) {
  throw GetException(extractMessage(response));
}

throw Exception('HTTP error: ${response.statusCode}');
}catch(e){
print('Помилка API: $e');
rethrow;
}
}}