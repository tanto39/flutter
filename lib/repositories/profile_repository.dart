import 'dart:convert';
import 'dart:html' as html;
import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileRepository {
  final FirebaseFirestore _firestore;
  final ImagePicker _picker;

  ProfileRepository({
    required FirebaseFirestore firestore,
    required ImagePicker picker,
  })  : _firestore = firestore,
        _picker = picker;

  // Работа с Firestore
  Future<Map<String, dynamic>> loadProfile(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    return doc.data() ?? {};
  }

  Future<void> updateName(String userId, String newName) async {
    await _firestore.collection('users').doc(userId).update({'name': newName});
  }

  // Работа с изображениями
  Future<Uint8List?> pickImage() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1024,
      maxHeight: 1024,
    );
    return image?.readAsBytes();
  }

  Future<Uint8List?> loadLocalImage() async {
    try {
      if (kIsWeb) {
        final base64Image = html.window.localStorage['user_avatar'];
        return base64Image != null ? base64Decode(base64Image) : null;
      } else {
        final prefs = await SharedPreferences.getInstance();
        final path = prefs.getString('avatar_path');
        return path != null && await File(path).exists()
            ? await File(path).readAsBytes()
            : null;
      }
    } catch (e) {
      throw Exception('Ошибка загрузки изображения: $e');
    }
  }

  Future<void> saveImage(Uint8List bytes) async {
    const maxSize = 2 * 1024 * 1024;
    if (bytes.length > maxSize) {
      throw Exception('Максимальный размер изображения 2MB');
    }

    if (kIsWeb) {
      html.window.localStorage['user_avatar'] = base64Encode(bytes);
    } else {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/user_avatar.jpg');
      await file.writeAsBytes(bytes);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('avatar_path', file.path);
    }
  }
}