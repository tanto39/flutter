import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ithub/bloc/favorite/favorite_bloc.dart';
import '../bloc/crypto/crypto_bloc.dart';
import '../models/crypto_currency.dart';

// Экран списка криптовалют
class CryptoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Курсы криптовалют в рублях')),
      body: BlocBuilder<CryptoBloc, CryptoState>(
        builder: (context, state) {
          if (state is CryptoLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is CryptoLoaded) {
            return RefreshIndicator(
              onRefresh: () async =>
                  context.read<CryptoBloc>().add(LoadCryptoEvent()),
              child: ListView.builder(
                itemCount: state.cryptoList.length,
                itemBuilder: (context, index) => CryptoCard(
                    crypto: state.cryptoList[index],
                    onRemove: (symbol) {
                      context
                          .read<FavoriteBloc>()
                          .add(RemoveFavoriteEvent(symbol));
                    }),
              ),
            );
          }
          return Center(child: Text('Error loading data'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.read<CryptoBloc>().add(LoadCryptoEvent()),
        child: Icon(Icons.refresh),
      ),
    );
  }
}

class CryptoCard extends StatelessWidget {
  final CryptoCurrency crypto;
  final Function(String) onRemove;

  const CryptoCard({
    required this.crypto,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(crypto.symbol),
      direction: DismissDirection.endToStart,
      background: Container(color: Colors.red),
      onDismissed: (direction) => onRemove(crypto.symbol),
      child: ListTile(
        leading: Image.network(
          crypto.fullImageUrl,
          width: 30,
          height: 30,
          errorBuilder: (_, __, ___) => const Icon(Icons.currency_bitcoin),
        ),
        title: Text(crypto.symbol),
        trailing: Text('${crypto.price.toStringAsFixed(2)} RUB'),
        onTap: () => Navigator.pushNamed(
          context,
          '/crypto-detail',
          arguments: crypto,
        ),
      ),
    );
  }
}
