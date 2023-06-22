import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PhotoScreen extends StatefulWidget {
  const PhotoScreen({Key? key}) : super(key: key);

  @override
  _PhotoScreenState createState() => _PhotoScreenState();
}

class _PhotoScreenState extends State<PhotoScreen> {
  late Database _database;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  String locationMessage = "Kullanıcının Şuanki konumu";
  late String lat;
  late String long;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    initializeDatabase();
    initializeFirebase();
  }

  Future<void> initializeDatabase() async {
  final user = FirebaseAuth.instance.currentUser!;

  // Veritabanını oluşturma veya var olan veritabanını açma
  final directory = await getApplicationDocumentsDirectory();
  final path = directory.path + '/photos.db';
  _database = await openDatabase(
    path,
    version: 2, // Veritabanı sürümünü 2 olarak güncelledik
    onCreate: (db, version) async {
      // Tabloyu oluşturma
      await db.execute(
        'CREATE TABLE IF NOT EXISTS photos(id INTEGER PRIMARY KEY AUTOINCREMENT, path TEXT, userId TEXT)',
      );
    },
    onUpgrade: (db, oldVersion, newVersion) async {
      if (oldVersion < 2) {
        // Sadece eski sürüm 1'den yeni sürüm 2'ye yükseltme için çalışır
        // userId sütununu ekleyin
        await db.execute('ALTER TABLE photos ADD COLUMN userId TEXT');
      }
    },
  );
}

  Future<void> initializeFirebase() async {
    // Firebase'i başlatma
    await Firebase.initializeApp();
  }

  Future<void> takePhoto() async {
    // Kamera ile fotoğraf çekme
    final pickedFile = await _picker.getImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      savePhotoToSQLite(_imageFile!);
    }
  }

  Future<void> pickPhotoFromGallery() async {
    // Galeriden fotoğraf seçme
    final pickedFile = await _picker.getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      savePhotoToSQLite(_imageFile!);
    }
  }

  Future<void> savePhotoToSQLite(File imageFile) async {
    // Fotoğrafı SQLite veritabanına kaydetme
    final path = imageFile.path;
    final user = FirebaseAuth.instance.currentUser!;
    final id = await _database.insert('photos', {
      'path': path,
      'userId': user.uid,
    });
    print('Saved photo with ID: $id');
  }

  Future<void> uploadPhotoToFirebase() async {
    setState(() {
      _isLoading = true;
    });

    // Kullanıcının bilgilerini al
    final user = FirebaseAuth.instance.currentUser!;
    final username = user.displayName ?? 'Bilinmeyen Kullanıcı';
    final email = user.email!;
    final sanitizedEmail = email.replaceAll(RegExp(r'[^\w\s]+'), '');

    // Fotoğrafı Firebase Storage'a yükleme
    final storage = FirebaseStorage.instance;
    final storageRef = storage
        .ref()
        .child('photos')
        .child(sanitizedEmail)
        .child('${DateTime.now()}.jpg');
    final uploadTask = storageRef.putFile(_imageFile!);

    try {
      await uploadTask;
      final downloadURL = await storageRef.getDownloadURL();

      // Fotoğraf ve konumu Firestore veritabanına kaydetme
      final userRef = FirebaseFirestore.instance.collection('photos');
      final userData = {
        'email': email,
        'photoUrl': downloadURL,
        'latitude': lat,
        'longitude': long,
        'userId': user.uid,
      };
      await userRef.add(userData);

      setState(() {
        _isLoading = false;
      });

      // Uyarı mesajı göster
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Başarılı'),
          content: Text('Fotoğraf ve konum Firebase\'e yüklendi.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: Text('Tamam'),
            ),
          ],
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error uploading photo: $e');
      // Hata mesajı göster
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Hata'),
          content: Text('Fotoğraf ve konum yüklenirken bir hata oluştu.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: Text('Tamam'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> savePhotoToGallery() async {
    // Fotoğrafı galeriye kaydetme
    if (_imageFile != null) {
      final result = await GallerySaver.saveImage(_imageFile!.path);
    }
  }

  void _liveLocation() {
    LocationSettings locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100,
    );
    Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position position) {
      lat = position.latitude.toString();
      long = position.longitude.toString();
      setState(() {
        locationMessage = 'Latitude:$lat, Longitude $long';
      });
    });
  }

  Future<Position?> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
      if (permission == LocationPermission.deniedForever) {
        return Future.error(
            'Location permissions are permanently denied, we cannot request');
      }
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<void> _openMap(String lat, String long) async {
    String googleUrl =
        'https://www.google.com/maps/search/?api=1&query=$lat, $long';
    await canLaunchUrlString(googleUrl)
        ? await launchUrlString(googleUrl)
        : throw 'Could not launch $googleUrl';
  }

  final TextEditingController _controller = TextEditingController();
  void signUserOut() {
    FirebaseAuth.instance.signOut();
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HexColor("#fed8c3"),
      appBar: AppBar(
        actions: [
          IconButton(onPressed: signUserOut, icon: const Icon(Icons.logout))
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_imageFile != null)
                    Image.file(
                      _imageFile!,
                      height: 200,
                    ),
                  ElevatedButton(
                    onPressed: takePhoto,
                    child: Text('Fotoğraf Çek'),
                  ),
                  ElevatedButton(
                    onPressed: pickPhotoFromGallery,
                    child: Text('Galeriden Fotoğraf Seç'),
                  ),
                  ElevatedButton(
                    onPressed: savePhotoToGallery,
                    child: Text('Galeriye Kaydet'),
                  ),
                  Text("Konum: $locationMessage"),
                  ElevatedButton(
                    child: Text("Konumu Göster"),
                    onPressed: () {
                      _getCurrentLocation().then((value) {
                        if (value != null) {
                          lat = '${value.latitude}';
                          long = '${value.longitude}';
                          setState(() {
                            locationMessage =
                                'Enlem: $lat, Boylam: $long';
                          });
                          _liveLocation();
                        } else {
                          setState(() {
                            locationMessage = 'Konum bulunamadı';
                          });
                        }
                      }).catchError((error) {
                        setState(() {
                          locationMessage = 'Konum alınamadı: $error';
                        });
                      });
                    },
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _openMap(lat, long);
                    },
                    child: Text('Google Mapste Aç'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      uploadPhotoToFirebase(); // Fotoğraf ve konumu Firebase'e yükleme
                    },
                    child: Text('Yükle'),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
