import 'package:json_annotation/json_annotation.dart';

part 'crypto_currency.g.dart';

// Модель списка криптовалют
@JsonSerializable()
class CryptoCurrency {
  @JsonKey(name: 'FROMSYMBOL')
  final String symbol;
  
  @JsonKey(name: 'PRICE')
  final double price;

  @JsonKey(name: 'IMAGEURL', defaultValue: '/media/37746251/ton.png')
  final String imageUrl;

  @JsonKey(name: 'CHANGEPCT24HOUR', defaultValue: 0.0)
  final double change24h;

  @JsonKey(name: 'CHANGEPCTHOUR', defaultValue: 0.0)
  final double change1h;

  CryptoCurrency({
    required this.symbol,
    required this.price,
    required this.imageUrl,
    required this.change24h,
    required this.change1h,
  });

  factory CryptoCurrency.fromJson(Map<String, dynamic> json) =>
      _$CryptoCurrencyFromJson(json);

  Map<String, dynamic> toJson() => _$CryptoCurrencyToJson(this);

  String get fullImageUrl => 'https://www.cryptocompare.com${imageUrl}';
}