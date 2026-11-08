import './api_service.dart';
import 'package:cargo_flow/models/user.dart';
import './token_storage.dart';
class AuthService {
  final ApiService _apiService;
  final TokenStorage _tokenStorage;
  bool? _isLoading;
  AuthService(this._apiService,this._tokenStorage);
  bool? get isLoading => _isLoading;
  Future<dynamic>register(User user) async{
    return await _apiService.postLogin("registration",user.toJson());
  }
  Future<dynamic>login(String email,String password) async{
    var loginRequest = {
      "email":email,
    "password":password
    };
     var result = await _apiService.postLogin("login",loginRequest);
     _tokenStorage.saveToken(result['token']);
     return {"user":result["user"],"success":true
     };
  }
  Future<dynamic>verifyToken()async{
    try{
      await _apiService.get("verify-token");
      return true;
    }
    catch(e){
      return false;
    }
  }
  Future<void> logOut()async{
    _tokenStorage.deleteToken();
  }
 Future<Map<String,dynamic>>getUser()async{
    return await _apiService.get("user");
 }
 Future<dynamic> updateProfile(dynamic user)async{
    return await _apiService.patch("user/update",user);
 }
 Future<void> deleteAccount()async{
    return await _apiService.delete("user/delete");
 }
 Future<void> changePassword(Map<String,dynamic> changeRequest)async{
    return await _apiService.patch("user/changePassword", changeRequest);
 }
}