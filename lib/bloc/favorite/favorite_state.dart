part of 'favorite_bloc.dart';

abstract class FavoriteState extends Equatable {
  const FavoriteState();
  
  List<String> get favorites => const [];
  List<CryptoCurrency> get cryptoList => const [];
}

class FavoriteInitial extends FavoriteState {
  @override
  List<Object> get props => [];
}

class FavoriteLoading extends FavoriteState {
  final String? symbol;
  const FavoriteLoading({this.symbol});
  
  @override
  List<Object> get props => [symbol ?? ''];
}

class FavoriteLoaded extends FavoriteState {
  final List<String> favorites;
  final List<CryptoCurrency> cryptoList;
  
  const FavoriteLoaded({
    required this.favorites,
    required this.cryptoList,
  });

  FavoriteLoaded copyWith({
    List<String>? favorites,
    List<CryptoCurrency>? cryptoList,
  }) {
    return FavoriteLoaded(
      favorites: favorites ?? this.favorites,
      cryptoList: cryptoList ?? this.cryptoList,
    );
  }

  @override
  List<Object> get props => [favorites, cryptoList];
}

class FavoriteError extends FavoriteState {
  final String message;
  
  const FavoriteError({required this.message});

  @override
  List<Object> get props => [message];
}