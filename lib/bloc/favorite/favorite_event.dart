part of 'favorite_bloc.dart';

abstract class FavoriteEvent extends Equatable {
  const FavoriteEvent();

  @override
  List<Object> get props => [];
}

class LoadFavoritesEvent extends FavoriteEvent {}

class LoadFavoriteCryptoEvent extends FavoriteEvent {} // Новое событие

class AddFavoriteEvent extends FavoriteEvent {
  final String symbol;

  const AddFavoriteEvent(this.symbol);

  @override
  List<Object> get props => [symbol];
}

class RemoveFavoriteEvent extends FavoriteEvent {
  final String symbol;

  const RemoveFavoriteEvent(this.symbol);

  @override
  List<Object> get props => [symbol];
}