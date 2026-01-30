import 'dart:io';
import 'package:flutter/foundation.dart';

class UserProfile {
  final String fullName;
  final String dob;
  final String gender;
  final String height;
  final String weight;
  final String phone;   
  final String email;   
  final String address; 
  final File? avatarFile;

  const UserProfile({
    required this.fullName,
    required this.dob,
    required this.gender,
    required this.height,
    required this.weight,
    required this.phone,    
    required this.email,  
    required this.address,
    this.avatarFile,
  });
}

class ProfileStore {
  static final ValueNotifier<UserProfile?> profile =
      ValueNotifier<UserProfile?>(null);
}
