part of 'favorite_bloc.dart';

abstract class FavoriteState extends Equatable {
  const FavoriteState();
  
  // Добавляем общий геттер для всех состояний
  List<String> get favorites => const [];
}

class FavoriteInitial extends FavoriteState {
  @override
  List<Object> get props => [];
}

class FavoriteLoading extends FavoriteState {
  @override
  List<Object> get props => [];
}

class FavoriteLoaded extends FavoriteState {
  final List<String> favorites;
  
  const FavoriteLoaded({required this.favorites});

  @override
  List<Object> get props => [favorites];
}

class FavoriteError extends FavoriteState {
  final String message;
  
  const FavoriteError({required this.message});

  @override
  List<Object> get props => [message];
}