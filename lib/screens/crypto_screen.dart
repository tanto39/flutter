import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/crypto/crypto_bloc.dart';
import '../models/crypto_currency.dart';

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
              onRefresh: () async => context.read<CryptoBloc>().add(LoadCryptoEvent()),
              child: ListView.builder(
                itemCount: state.cryptoList.length,
                itemBuilder: (context, index) => CryptoCard(
                  crypto: state.cryptoList[index]
                ),
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

  const CryptoCard({required this.crypto});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
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