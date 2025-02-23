import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:io';
import 'dart:typed_data';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  static const _maxImageSize = 2 * 1024 * 1024;
  final FirebaseFirestore firestore;
  final ImagePicker picker;
  final String userId;

  ProfileBloc({
    required this.firestore,
    required this.picker,
    required this.userId,
  }) : super(ProfileInitial()) {
    on<ProfileLoadRequested>(_onLoadRequested);
    on<ProfileImageUpdateRequested>(_onImageUpdateRequested);
    on<ProfileNameUpdateRequested>(_onNameUpdateRequested);
  }

  Future<void> _onLoadRequested(
    ProfileLoadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      emit(ProfileLoading(
        cachedName:
            (state is ProfileReady) ? (state as ProfileReady).name : null,
        cachedImage:
            (state is ProfileReady) ? (state as ProfileReady).image : null,
      ));

      final userDoc = await firestore.collection('users').doc(userId).get();
      final imageBytes = await _loadLocalImage();

      emit(ProfileReady(
        name: userDoc.data()?['name'] ?? 'Гость',
        image: imageBytes,
      ));
    } catch (e) {
      emit(ProfileError('Ошибка загрузки: $e', state));
    }
  }

  Future<void> _onImageUpdateRequested(
    ProfileImageUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is! ProfileReady) return;
    final currentState = state as ProfileReady;

    try {
      // Начало загрузки - показываем индикатор
      emit(currentState.copyWith(isUpdatingImage: true));

      await Future.delayed(
          const Duration(milliseconds: 300)); // Имитация загрузки
      await _validateImage(event.imageData);
      await _saveImageLocally(event.imageData);

      // Успешное завершение - обновляем изображение
      emit(currentState.copyWith(
        image: event.imageData,
        isUpdatingImage: false,
      ));
    } catch (e) {
      // Ошибка - сохраняем предыдущее изображение
      emit(currentState.copyWith(isUpdatingImage: false));
      emit(ProfileError('Ошибка обновления фото: $e', currentState));
    }
  }

  Future<void> _onNameUpdateRequested(
    ProfileNameUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is! ProfileReady) return;
    final currentState = state as ProfileReady;

    try {
      emit(currentState.copyWith(isUpdatingName: true));

      await firestore.collection('users').doc(userId).update({
        'name': event.newName,
      });

      emit(currentState.copyWith(
        name: event.newName,
        isUpdatingName: false,
      ));
    } catch (e) {
      emit(currentState.copyWith(isUpdatingName: false));
      emit(ProfileError('Ошибка обновления имени: $e', currentState));
    }
  }

  Future<Uint8List?> _loadLocalImage() async {
    try {
      if (kIsWeb) {
        final base64 = html.window.localStorage['user_avatar'];
        return base64 != null ? base64Decode(base64) : null;
      }

      final prefs = await SharedPreferences.getInstance();
      final path = prefs.getString('avatar_path');
      return path != null ? await File(path).readAsBytes() : null;
    } catch (e) {
      throw Exception('Ошибка загрузки изображения: $e');
    }
  }

  Future<void> _saveImageLocally(Uint8List bytes) async {
    if (bytes.length > _maxImageSize) {
      throw Exception('Максимальный размер изображения 2MB');
    }

    if (kIsWeb) {
      html.window.localStorage['user_avatar'] = base64Encode(bytes);
    } else {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/user_avatar.jpg');
      await file.writeAsBytes(bytes, flush: true);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('avatar_path', file.path);
    }
  }

  Future<void> _validateImage(Uint8List bytes) async {
    if (bytes.isEmpty) throw Exception('Пустое изображение');
    if (bytes.length > _maxImageSize) throw Exception('Слишком большой файл');
  }
}
