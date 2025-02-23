import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/crypto_currency.dart';
import '../../repositories/crypto_repository.dart';

part 'crypto_event.dart';
part 'crypto_state.dart';

// Bloc для списка криптовалют
class CryptoBloc extends Bloc<CryptoEvent, CryptoState> {
  final CryptoRepository repository;

  CryptoBloc(this.repository) : super(CryptoInitial()) {
    on<LoadCryptoEvent>(_onLoadCrypto);
  }

  Future<void> _onLoadCrypto(
    LoadCryptoEvent event,
    Emitter<CryptoState> emit,
  ) async {
    emit(CryptoLoading());
    try {
      final cryptoList = await repository.getCryptoPrices(event.symbols);
      emit(CryptoLoaded(cryptoList));
    } catch (e) {
      emit(CryptoError(e.toString()));
    }
  }
}