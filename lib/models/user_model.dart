class UserModel {
  final int? id;          
  final int? userId;      
  final String? token;     
  final String? ip;        
  final String userLogin;  
  final String userName;   
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    this.id,
    this.userId,
    this.token,
    this.ip,
    required this.userLogin,
    required this.userName,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    print('Parsing UserModel from JSON: $json');

    String login = json['login'] ?? 
                  json['user_login'] ?? 
                  json['follower_login'] ??  // ← NOVO: para followers
                  json['followed_login'] ??  // ← NOVO: para o usuário seguido
                  '';
  
    String name = json['name'] ?? 
                  json['user_name'] ?? 
                  json['follower_name'] ?? 
                  '';
    
    return UserModel(
      id: json['id'],  
      userId: json['user_id'],  
      token: json['token'],  
      ip: json['ip'],  
      userLogin: login,
      userName: name,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),  
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : DateTime.now(),  
    );
  }


  static List<UserModel> fromFollowersList(List<dynamic> jsonList) {
    return jsonList.map((json) => UserModel.fromJson(json)).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'login': userLogin,
      'name': userName,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };

    if (id != null) data['id'] = id;
    if (userId != null) data['user_id'] = userId;
    if (token != null) data['token'] = token;
    if (ip != null) data['ip'] = ip;

    return data;
  }
}