import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:bitirme21/components/my_button.dart';
import 'package:bitirme21/controller/flow_controller.dart';
import 'package:bitirme21/controller/sign_up_controller.dart';

List<String> list = <String>['Kullanici', 'Yonetici'];

class SignUpTwo extends StatefulWidget {
  const SignUpTwo({super.key});

  @override
  State<SignUpTwo> createState() => _SignUpTwoState();
}

class _SignUpTwoState extends State<SignUpTwo> {
  final mobileNumberController = TextEditingController().obs;
  final nameController = TextEditingController().obs;
  //final sehirAdiContoller = TextEditingController().obs;
  SignUpController signUpController = Get.put(SignUpController());
  FlowController flowController = Get.put(FlowController());

  String dropdownValue= list.first;
  String _errorMessage = "";

  @override
  Widget build(BuildContext context) {
    debugPrint(signUpController.sehirAdi);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(30, 20, 30, 20),
        child: Column(
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    flowController.setFlow(1);
                  },
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(
                  width: 67,
                ),
                Text(
                  "Kayıt Ol",
                  style: GoogleFonts.poppins(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: HexColor("#4f4f4f"),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 8,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 0, 0, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Telefon Numarası",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: HexColor("#8d8d8d"),
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  TextField(
                    onChanged: (value) {
                      valideteMobile(value);
                      signUpController.setMobileNumber(value);
                    },
                    onSubmitted: (value) {
                      signUpController.setMobileNumber(value);
                    },
                    controller: mobileNumberController.value,
                    keyboardType: TextInputType.number,
                    cursorColor: HexColor("#4f4f4f"),
                    decoration: InputDecoration(
                      hintText: "5252465163",
                      fillColor: HexColor("#f0f3f1"),
                      contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                      hintStyle: GoogleFonts.poppins(
                        fontSize: 15,
                        color: HexColor("#8d8d8d"),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                    ),
                  ),
                  Text(
                    "İsim",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: HexColor("#8d8d8d"),
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  TextField(
                    onChanged: (value) {
                      valideteIsim(value);
                      signUpController.setName(value);
                    },
                    onSubmitted: (value) {
                      signUpController.setName(value);
                    },
                    controller: nameController.value,
                    cursorColor: HexColor("#4f4f4f"),
                    decoration: InputDecoration(
                      hintText: "Salih",
                      fillColor: HexColor("#f0f3f1"),
                      contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                      hintStyle: GoogleFonts.poppins(
                        fontSize: 15,
                        color: HexColor("#8d8d8d"),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                    child: Text(
                      _errorMessage,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.red,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  /*Text(
                    "Şehir",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: HexColor("#8d8d8d"),
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  TextField(
                    onSubmitted: (value) {
                      signUpController.setSehirAdi(value);
                    },
                    onChanged: (value) {
                      signUpController.setSehirAdi(value);
                    },
                    controller: sehirAdiContoller.value,
                    cursorColor: HexColor("#4f4f4f"),
                    decoration: InputDecoration(
                      hintText: "İstabul",
                      fillColor: HexColor("#f0f3f1"),
                      contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                      hintStyle: GoogleFonts.poppins(
                        fontSize: 15,
                        color: HexColor("#8d8d8d"),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      focusColor: HexColor("#44564a"),
                    ),
                  ),*/
                  Text(
                    "Kullanici Tipi",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: HexColor("#8d8d8d"),
                    ),
                  ),
                  DropdownButton<String>(
                    value: dropdownValue,
                    icon: const Icon(Icons.arrow_drop_down),
                    elevation: 16,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: HexColor("#8d8d8d"),
                    ),
                    isExpanded: true,
                    underline: Container(
                      height: 2,
                      color: HexColor("#ffffff"),
                    ),
                    iconSize: 30,
                    borderRadius: BorderRadius.circular(20),
                    onChanged: (String? value) {
                      setState(() {
                        dropdownValue = value!;
                        signUpController.setSehirAdi(value);
                      });
                    },
                    items: list.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  const SizedBox(
                    height: 1,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  MyButton(
                    onPressed: () {
                      if (signUpController.mobileNumber != null &&
                          signUpController.name != null &&
                          signUpController.sehirAdi != null
                          /*signUpController.sehirAdi != null*/) {
                        flowController.setFlow(3);
                      } else {
                        Get.snackbar("Hata", "Lütfen tüm boşlukları doldurunuz");
                      }
                    },
                    buttonText: 'İleri',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  void valideteMobile(String val) {
    if(val.isEmpty) {
      setState(() {
        _errorMessage = "Numara boş bırakılamaz";
      });
    } else if (val.length > 11 || val.length<11 || val[0]=="0" || val.contains(RegExp(r'[a-z]'))){
      setState(() {
        _errorMessage= "Geçersiz Numara";
      });
    } else{setState(() {
      _errorMessage= "";
    });

    }
  }
  void valideteIsim(String val) {
    if(val.isEmpty) {
      setState(() {
        _errorMessage = "İsim boş bırakılamaz";
      });
    } else if (val.contains(RegExp(r'[0-9]')) ){
      setState(() {
        _errorMessage= "Geçersiz isim";
      });
    } else{setState(() {
      _errorMessage= "";
    });

    }
  }
  
  
}
