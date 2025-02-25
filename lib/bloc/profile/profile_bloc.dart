import 'dart:async';
import 'dart:typed_data';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import '../../repositories/profile_repository.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository _repository;
  final String userId;

  ProfileRepository get repository => _repository;

  ProfileBloc({
    required ProfileRepository repository,
    required this.userId,
  })  : _repository = repository,
        super(ProfileInitial()) {
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

      final profileData = await _repository.loadProfile(userId);
      final imageBytes = await _repository.loadLocalImage();

      emit(ProfileReady(
        name: profileData['name'] ?? 'Гость',
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
      // Немедленно обновляем состояние для отображения индикатора
      emit(currentState.copyWith(isUpdatingImage: true));
      await _repository.saveImage(event.imageData);

      // Обновляем изображение и скрываем индикатор
      emit(currentState.copyWith(
        image: event.imageData,
        isUpdatingImage: false,
      ));
    } catch (e) {
      // Восстанавливаем состояние и показываем ошибку
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
      await _repository.updateName(userId, event.newName);
      emit(currentState.copyWith(
        name: event.newName,
        isUpdatingName: false,
      ));
    } catch (e) {
      emit(currentState.copyWith(isUpdatingName: false));
      emit(ProfileError('Ошибка обновления имени: $e', currentState));
    }
  }
}
