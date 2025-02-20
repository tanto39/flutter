part of 'crypto_bloc.dart';

abstract class CryptoEvent extends Equatable {
  const CryptoEvent();

  @override
  List<Object> get props => [];
}

class LoadCryptoEvent extends CryptoEvent {
  final List<String> symbols;

  LoadCryptoEvent({this.symbols = defaultSymbols});

  @override
  List<Object> get props => [symbols];
}