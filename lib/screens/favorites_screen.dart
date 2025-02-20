import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/crypto/crypto_bloc.dart';
import '../bloc/favorite/favorite_bloc.dart';
import '../repositories/crypto_repository.dart';
import 'crypto_screen.dart';

class FavoritesScreen extends StatefulWidget {
  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late CryptoBloc _cryptoBloc;

  @override
  void initState() {
    super.initState();
    _cryptoBloc = CryptoBloc(context.read<CryptoRepository>());
    _loadData();
  }

  void _loadData() {
    final favorites = context.read<FavoriteBloc>().state.favorites;
    _cryptoBloc.add(LoadCryptoEvent(symbols: favorites));
  }

  @override
  void dispose() {
    _cryptoBloc.close();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Избранное')),
      body: BlocBuilder<FavoriteBloc, FavoriteState>(
        builder: (context, state) {
          if (state is FavoriteLoading) {
            return Center(child: CircularProgressIndicator());
          }
          if (state is FavoriteError) {
            return Center(child: Text(state.message));
          }
          if (state is FavoriteLoaded && state.favorites.isEmpty) {
            return Center(child: Text('Нет избранных криптовалют'));
          }
          if (state is FavoriteLoaded) {
            return BlocProvider(
              create: (context) => CryptoBloc(CryptoRepository())
                ..add(LoadCryptoEvent(symbols: state.favorites)), // Передаем символы
              child: BlocBuilder<CryptoBloc, CryptoState>(
                builder: (context, cryptoState) {
                  if (cryptoState is CryptoLoading) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (cryptoState is CryptoLoaded) {
                    return ListView.builder(
                      itemCount: cryptoState.cryptoList.length,
                      itemBuilder: (context, index) => CryptoCard(
                        crypto: cryptoState.cryptoList[index]
                      ),
                    );
                  }
                  return Center(child: Text('Ошибка загрузки данных'));
                },
              ),
            );
          }
          return Container();
        },
      )
    );
  }
}