import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../repositories/favorite_repository.dart';

part 'favorite_event.dart';
part 'favorite_state.dart';

class FavoriteBloc extends Bloc<FavoriteEvent, FavoriteState> {
  final FavoriteRepository repository;

  FavoriteBloc({required this.repository}) : super(FavoriteInitial()) {
    on<LoadFavoritesEvent>(_onLoadFavorites);
    on<AddFavoriteEvent>(_onAddFavorite);
    on<RemoveFavoriteEvent>(_onRemoveFavorite);

    // Загружаем избранное при инициализации
    add(LoadFavoritesEvent());
  }

  Future<void> _onLoadFavorites(
    LoadFavoritesEvent event,
    Emitter<FavoriteState> emit,
  ) async {
    emit(FavoriteLoading());
    try {
      final favorites = await repository.getFavorites();
      emit(FavoriteLoaded(favorites: favorites));
    } catch (e) {
      emit(FavoriteError(message: 'Ошибка загрузки избранного'));
    }
  }

  Future<void> _onAddFavorite(
    AddFavoriteEvent event,
    Emitter<FavoriteState> emit,
  ) async {
    if (state is FavoriteLoaded) {
      final currentState = state as FavoriteLoaded;
      try {
        await repository.addFavorite(event.symbol);
        emit(FavoriteLoaded(
          favorites: List.from(currentState.favorites)..add(event.symbol),
        ));
      } catch (e) {
        emit(FavoriteError(message: 'Ошибка добавления в избранное'));
      }
    }
  }

  Future<void> _onRemoveFavorite(
    RemoveFavoriteEvent event,
    Emitter<FavoriteState> emit,
  ) async {
    if (state is FavoriteLoaded) {
      final currentState = state as FavoriteLoaded;
      final newFavorites = currentState.favorites.toList()..remove(event.symbol);
      try {
        await repository.removeFavorite(event.symbol);
        emit(FavoriteLoaded(favorites: newFavorites));

        // Форсируем обновление CryptoBloc
        //add(LoadFavoritesEvent());
      } catch (e) {
        emit(FavoriteError(
          message: 'Ошибка удаления из избранного',
        ));
      }
    }
  }
}
