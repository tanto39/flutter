import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:html' as html; // Только для веба
import 'dart:convert';
import 'dart:typed_data';

// Экран профиля пользователя
class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final String userId = 'user1';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();
  Uint8List? _imageBytes;
  final int _maxImageSize = 2 * 1024 * 1024; // 2 MB

  @override
  void initState() {
    super.initState();
    _loadLocalImage();
  }

  Future<void> _loadLocalImage() async {
    try {
      if (kIsWeb) {
        final base64Image = html.window.localStorage['user_avatar'];
        if (base64Image != null) {
          setState(() => _imageBytes = base64Decode(base64Image));
        }
      } else {
        final prefs = await SharedPreferences.getInstance();
        final path = prefs.getString('avatar_path');
        if (path != null && await File(path).exists()) {
          final bytes = await File(path).readAsBytes();
          setState(() => _imageBytes = bytes);
        }
      }
    } catch (e) {
      print('Ошибка загрузки изображения: $e');
    }
  }

  Future<void> _pickImage() async {
    try {
      Uint8List? bytes;

      if (kIsWeb) {
        bytes = await _pickImageWeb();
      } else {
        bytes = await _pickImageMobile();
      }

      if (bytes != null) {
        await _saveImage(bytes);
        setState(() => _imageBytes = bytes);
      }
    } catch (e) {
      _showErrorDialog('Ошибка: ${e.toString()}');
    }
  }

  Future<Uint8List?> _pickImageWeb() async {
    final input = html.FileUploadInputElement()
      ..accept = 'image/*'
      ..multiple = false;
    input.click();

    final file = await input.onChange.first.then((_) => input.files!.first);
    final reader = html.FileReader();

    reader.readAsArrayBuffer(file);
    await reader.onLoadEnd.first;
    return reader.result as Uint8List?;
  }

  Future<Uint8List?> _pickImageMobile() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1024,
      maxHeight: 1024,
    );
    return pickedFile?.readAsBytes();
  }

  Future<void> _saveImage(Uint8List bytes) async {
    if (bytes.length > _maxImageSize) {
      throw Exception(
          'Размер изображения слишком большой (${bytes.length ~/ 1024} KB). '
          'Максимум: ${_maxImageSize ~/ 1024} KB');
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

  Future<void> _updateName(String newName) async {
    try {
      await _firestore.collection('users').doc(userId).set({
        'name': newName,
      }, SetOptions(merge: true));
    } catch (e) {
      _showErrorDialog('Ошибка сохранения имени: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Профиль')),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _firestore.collection('users').doc(userId).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

          final userData = snapshot.data!.data() as Map<String, dynamic>?;
          return Column(
            children: [
              const SizedBox(height: 20),
              CircleAvatar(
                radius: 100,
                backgroundImage:
                    _imageBytes != null ? MemoryImage(_imageBytes!) : null,
                child: _imageBytes == null
                    ? const Icon(Icons.person, size: 100)
                    : null,
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: _pickImage,
                child: const Text('Изменить фотографию'),
              ),
              const SizedBox(height: 20),
              const Text(
              'Имя пользователя:',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                title: Text(
                  userData?['name'] ?? 'Гость',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showEditDialog(context),
                ),
              ),
            ),
            ],
          );
        },
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Редактировать имя пользователя'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Новое имя'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отменить'),
          ),
          TextButton(
            onPressed: () {
              _updateName(controller.text);
              Navigator.pop(context);
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ошибка'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          )
        ],
      ),
    );
  }
}
