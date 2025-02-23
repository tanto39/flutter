import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/favorite/favorite_bloc.dart';
import 'crypto_screen.dart';

// Экран избранного
class FavoritesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Избранное'),
      ),
      body: BlocConsumer<FavoriteBloc, FavoriteState>(
        listener: (context, state) {
          if (state is FavoriteError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is FavoriteLoading) {
            return Center(child: CircularProgressIndicator());
          }
          
          if (state is FavoriteError) {
            return Center(child: Text(state.message));
          }
          
          if (state is FavoriteLoaded) {
            if (state.favorites.isEmpty) {
              return Center(child: Text('Нет избранных криптовалют'));
            }
            
            return RefreshIndicator(
              onRefresh: () async {
                context.read<FavoriteBloc>().add(LoadFavoritesEvent());
              },
              child: ListView.builder(
                itemCount: state.cryptoList.length,
                itemBuilder: (context, index) => CryptoCard(
                  crypto: state.cryptoList[index],
                  onRemove: (symbol) {
                    context.read<FavoriteBloc>().add(RemoveFavoriteEvent(symbol));
                  },
                ),
              ),
            );
          }
          
          return Center(child: Text('Загрузите избранное'));
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => context.read<FavoriteBloc>().add(LoadFavoritesEvent()),
        child: Icon(Icons.refresh),
      ),
    );
  }
}
