import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:bitirme21/models/file_model.dart';

class SignUpController extends GetxController {
  static SignUpController get instance => Get.find();
  FileModel? _imageFile;
  FileModel? get imageFile => _imageFile;
  void setImageFile(FileModel? file) {
    _imageFile = file;
    debugPrint("Updated ImageFile: ${imageFile!.filename}");
    update();
  }



  String? _userType = "Kullanici";
  String? get userType => _userType;
  void setUserType(String? text) {
    _userType = text;
    debugPrint("Updated userType: $userType");
    update();
  }

  String? _name;
  String? get name => _name;
  void setName(String? text) {
    _name = text;
    debugPrint("Updated name: $name");
    update();
  }

  String? _email;
  String? get email => _email;
  void setEmail(String? text) {
    _email = text;
    debugPrint("Updated email: $email");
    update();
  }

  String? _password;
  String? get password => _password;
  void setPassword(String? text) {
    _password = text;
    debugPrint("Updated password: $password");
    update();
  }

  String? _mobileNumber;
  String? get mobileNumber => _mobileNumber;
  void setMobileNumber(String? text) {
    _mobileNumber = text;
    debugPrint("Updated mobileNumber: $mobileNumber");
    update();
  }

  String? _sehirAdi;
  String? get sehirAdi => _sehirAdi;
  void setSehirAdi(String? text) {
    _sehirAdi = text;
    debugPrint("Updated sehirAdi: $sehirAdi");
    update();
  }



  String? _dateYear;
  String? get dateYear => _dateYear;
  void setDateYear(String? text) {
    _dateYear = text;
    debugPrint("Updated dateYear: $dateYear");
    update();
  }

  Future postSignUpDetails() async {
    await FirebaseFirestore.instance.collection("user").add({
      "userType": userType,
      "name": name,
      "email": email,
      "password": password,
      "mobileNumber": mobileNumber,
      "sehirAdi": sehirAdi,
      "dateYear": dateYear,
    });
    uploadImageFile();
  
  }

  Future uploadImageFile() async {
    await FirebaseStorage.instance
        .ref('files/${imageFile!.filename}')
        .putData(imageFile!.fileBytes);
  }



  Future<bool> registerUser(String email, String password) async {
    try {
      var response = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      return true;
    } catch (error) {
      if (error is FirebaseAuthException) {
        Get.showSnackbar(GetSnackBar(
          message: error.toString(),
        ));
      }
    }
    return false;
  }
}
