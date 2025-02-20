import 'package:flutter/material.dart';
import 'package:flutter_ithub/bloc/crypto/crypto_bloc.dart';
import '../models/crypto_currency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/favorite/favorite_bloc.dart';

class CryptoDetailScreen extends StatelessWidget {
  final CryptoCurrency crypto;

  const CryptoDetailScreen({super.key, required this.crypto});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(crypto.symbol)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Цена: ${crypto.price.toStringAsFixed(2)} RUB',
              style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 20),
            Text('24h Change: +5.6%', // Пример дополнительных данных
              style: TextStyle(color: Colors.green)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back'),
            ),
            BlocBuilder<FavoriteBloc, FavoriteState>(
              builder: (context, state) {
                final isFavorite = state.favorites.contains(crypto.symbol);
                return IconButton(
                  icon: Icon(isFavorite ? Icons.star : Icons.star_border),
                  onPressed: () {
                    context.read<FavoriteBloc>().add(
                      isFavorite 
                        ? RemoveFavoriteEvent(crypto.symbol)
                        : AddFavoriteEvent(crypto.symbol)
                    );
                  },
                );
              },
            )
          ],
        ),
      ),
    );
  }
}