import 'package:flutter/material.dart';
import '../models/crypto_currency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/favorite/favorite_bloc.dart';

// Экран детальной карточки криптовалюты
class CryptoDetailScreen extends StatelessWidget {
  final CryptoCurrency crypto;

  const CryptoDetailScreen({super.key, required this.crypto});

  Color _getChangeColor(double value) {
    return value >= 0 ? Colors.green : Colors.red;
  }

  String _formatPercentage(double value) {
    return '${value >= 0 ? '+' : ''}${value.toStringAsFixed(2)}%';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.network(
              crypto.fullImageUrl,
              width: 30,
              height: 30,
              errorBuilder: (_, __, ___) => const Icon(Icons.currency_bitcoin),
            ),
            const SizedBox(width: 12),
            Text(crypto.symbol),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.network(
                crypto.fullImageUrl,
                width: 120,
                height: 120,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.currency_bitcoin,
                  size: 100,
                ),
              ),
            ),
            const SizedBox(height: 30),
            _buildFavoriteButton(context),
            const SizedBox(height: 30),
            Text(
              'Текущая цена',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              '${crypto.price.toStringAsFixed(2)} RUB',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: _getChangeColor(crypto.change24h),
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 30),
            _buildChangeRow(
              context,
              label: 'Изменение за 24 часа:',
              value: crypto.change24h,
            ),
            const SizedBox(height: 10),
            _buildChangeRow(
              context,
              label: 'Изменение за 1 час:',
              value: crypto.change1h,
            ),
            const Spacer(),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.arrow_back),
                label: const Text('Назад к списку'),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoriteButton(BuildContext context) {
    return BlocConsumer<FavoriteBloc, FavoriteState>(
      listener: (context, state) {
        if (state is FavoriteError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        final isProcessing = state is FavoriteLoading &&
            (state.symbol == crypto.symbol || state.symbol == null);
        
        if (isProcessing) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final isFavorite = state.favorites.contains(crypto.symbol);
        return Center(
          child: FloatingActionButton.extended(
            icon: Icon(
              isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
              color: isFavorite ? Colors.amber : Colors.grey,
            ),
            label: Text(
              isFavorite ? 'В избранном' : 'Добавить в избранное',
              style: TextStyle(
                color: isFavorite ? Colors.amber : Colors.blueGrey,
              ),
            ),
            onPressed: () {
              context.read<FavoriteBloc>().add(
                    isFavorite
                        ? RemoveFavoriteEvent(crypto.symbol)
                        : AddFavoriteEvent(crypto.symbol),
                  );
            },
            backgroundColor: Colors.white,
            elevation: 4,
          ),
        );
      },
    );
  }

  Widget _buildChangeRow(BuildContext context,
      {required String label, required double value}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyLarge),
        Text(
          _formatPercentage(value),
          style: TextStyle(
            color: _getChangeColor(value),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}