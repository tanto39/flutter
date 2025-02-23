import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../repositories/favorite_repository.dart';
import '../../repositories/crypto_repository.dart';
import '../../models/crypto_currency.dart';

part 'favorite_event.dart';
part 'favorite_state.dart';

// Bloc для избранного
class FavoriteBloc extends Bloc<FavoriteEvent, FavoriteState> {
  final FavoriteRepository _favoriteRepository;
  final CryptoRepository _cryptoRepository;

  FavoriteBloc({
    required FavoriteRepository favoriteRepository,
    required CryptoRepository cryptoRepository,
  })  : _favoriteRepository = favoriteRepository,
        _cryptoRepository = cryptoRepository,
        super(FavoriteInitial()) {
    on<LoadFavoritesEvent>(_onLoadFavorites);
    on<AddFavoriteEvent>(_onAddFavorite);
    on<RemoveFavoriteEvent>(_onRemoveFavorite);
    on<LoadFavoriteCryptoEvent>(_onLoadFavoriteCrypto);
  }

  Future<void> _onLoadFavoriteCrypto(
    LoadFavoriteCryptoEvent event,
    Emitter<FavoriteState> emit,
  ) async {
    if (state is FavoriteLoaded) {
      final currentState = state as FavoriteLoaded;
      try {
        final cryptoList =
            await _cryptoRepository.getCryptoPrices(currentState.favorites);
        emit(currentState.copyWith(cryptoList: cryptoList));
      } catch (e) {
        emit(FavoriteError(message: 'Ошибка загрузки данных'));
      }
    }
  }

  Future<void> _onLoadFavorites(
    LoadFavoritesEvent event,
    Emitter<FavoriteState> emit,
  ) async {
    try {
      emit(FavoriteLoading());
      final favorites = await _favoriteRepository.getFavorites();
      final cryptoList = await _cryptoRepository.getCryptoPrices(favorites);
      emit(FavoriteLoaded(favorites: favorites, cryptoList: cryptoList));
    } catch (e) {
      emit(FavoriteError(message: 'Ошибка загрузки: ${e.toString()}'));
    }
  }

  Future<void> _onAddFavorite(
    AddFavoriteEvent event,
    Emitter<FavoriteState> emit,
  ) async {
    try {
      // Добавляем состояние загрузки
      emit(FavoriteLoading(symbol: event.symbol));

      final currentFavorites = await _favoriteRepository.getFavorites();
      if (currentFavorites.contains(event.symbol)) return;

      await _favoriteRepository.addFavorite(event.symbol);
      final List<String> newFavorites = List.from(currentFavorites)
        ..add(event.symbol);
      final cryptoList = await _cryptoRepository.getCryptoPrices(newFavorites);

      emit(FavoriteLoaded(favorites: newFavorites, cryptoList: cryptoList));
    } catch (e) {
      emit(FavoriteError(message: 'Ошибка добавления: ${e.toString()}'));
    }
  }

  Future<void> _onRemoveFavorite(
    RemoveFavoriteEvent event,
    Emitter<FavoriteState> emit,
  ) async {
    try {
      // Добавляем состояние загрузки
      emit(FavoriteLoading(symbol: event.symbol));

      final currentFavorites = await _favoriteRepository.getFavorites();
      if (!currentFavorites.contains(event.symbol)) return;

      await _favoriteRepository.removeFavorite(event.symbol);
      final List<String> newFavorites = List.from(currentFavorites)
        ..remove(event.symbol);
      final List<CryptoCurrency> cryptoList = newFavorites.isNotEmpty
          ? await _cryptoRepository.getCryptoPrices(newFavorites)
          : [];

      emit(FavoriteLoaded(favorites: newFavorites, cryptoList: cryptoList));
    } catch (e) {
      emit(FavoriteError(message: 'Ошибка удаления: ${e.toString()}'));
    }
  }
}
