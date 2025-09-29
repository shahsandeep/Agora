import 'package:agora_call/models/user_model.dart';
import 'package:agora_call/utils/const/const.dart';
import 'package:dio/dio.dart';

import '../service/local_storage.dart';

class ApiCalls {
 late final HiveLocalStorage localStorage;

late  final Dio _dio;

ApiCalls({required this.localStorage}) {



    _dio = Dio(
      BaseOptions(
        baseUrl: AgoraConstants.baseUrl,
    
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': 'reqres-free-v1'
        },
        
      ),
      
    );
    _dio.interceptors.add(LogInterceptor(responseBody: true, requestBody: true));
  }

  Future<String> login(String email,String password) async {
    try {
      final response = await _dio.post(AgoraConstants.login, data: {
        'email': email,

        'password': password,
      });
      if (response.statusCode == 200) {

        return response.data['token'];
      } else {
        throw Exception('Failed to login');
      }
    } catch (e) {
      if(e is DioException && e.response != null) {
        throw Exception('Login failed: ${e.response?.data['error'] ?? 'Unknown error'}');
      }
      throw Exception('Error during login: ${e.toString()}');
    }
  }


Future<List<UserModel>> fetchUsers({void Function(List<UserModel>)? onUpdated}) async {
  const hiveKey = 'users';

  
  List<UserModel>? localUsers =  localStorage.getData(hiveKey);
  if (localUsers != null && localUsers.isNotEmpty) {
   
    _fetchAndUpdateUsers(hiveKey, onUpdated);
    return localUsers;
  }

  
  return await _fetchAndUpdateUsers(hiveKey, onUpdated);
}


Future<List<UserModel>> _fetchAndUpdateUsers(String hiveKey, void Function(List<UserModel>)? onUpdated) async {
  try {
    final response = await _dio.get(AgoraConstants.fetchUsers);
    if (response.statusCode == 200) {
      List<UserModel> apiUsers = (response.data['data'] as List)
          .map((user) => UserModel.fromMap(user))
          .toList();
      await localStorage.saveData(hiveKey, apiUsers);
      if (onUpdated != null) onUpdated(apiUsers); // Notify UI
      return apiUsers;
    } else {
      throw Exception('Failed to fetch users');
    }
  } catch (e) {
    throw Exception('Error during fetching users: $e');
  }
}
}