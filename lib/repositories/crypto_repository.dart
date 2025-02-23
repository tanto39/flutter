import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/crypto_currency.dart';

const List<String> defaultSymbols = ['BTC','TON','ETH','USDT','BNB','DOGE','ADA','TRX','SOL','ETC','SMART','KCS','LTC','ONDO','BERA','EOS','AID','CAG','DOV','XMR','BGB','AI16Z'];

// API получения списка криптовалют
class CryptoRepository {
  static const _baseUrl = 'https://min-api.cryptocompare.com/data/pricemultifull';

  Future<List<CryptoCurrency>> getCryptoPrices(List<String> symbols) async {
    if (symbols.isEmpty) return [];
    final response = await http
        .get(Uri.parse('$_baseUrl?fsyms=${symbols.join(',')}&tsyms=RUB'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body)['RAW'];
      return data.entries.map<CryptoCurrency>((e) {
        final rubData = e.value['RUB'] as Map<String, dynamic>;
        return CryptoCurrency.fromJson(rubData);
      }).toList();
    }
    throw Exception('Failed to load crypto prices');
  }
}
