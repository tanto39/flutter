part of 'crypto_bloc.dart';

abstract class CryptoState extends Equatable {
  final List<CryptoCurrency> cryptoList;
  
  const CryptoState({this.cryptoList = const []});

  @override
  List<Object> get props => [cryptoList];
}

class CryptoInitial extends CryptoState {}

class CryptoLoading extends CryptoState {}

class CryptoLoaded extends CryptoState {
  const CryptoLoaded(List<CryptoCurrency> cryptoList)
    : super(cryptoList: cryptoList);
}

class CryptoError extends CryptoState {
  final String message;
  
  const CryptoError(this.message) : super();

  @override
  List<Object> get props => [message];
}