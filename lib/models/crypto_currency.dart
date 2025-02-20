import 'package:json_annotation/json_annotation.dart';

part 'crypto_currency.g.dart';

@JsonSerializable()
class CryptoCurrency {
  @JsonKey(name: 'FROMSYMBOL')
  final String symbol;
  
  @JsonKey(name: 'PRICE')
  final double price;

  CryptoCurrency({required this.symbol, required this.price});

  factory CryptoCurrency.fromJson(Map<String, dynamic> json) =>
      _$CryptoCurrencyFromJson(json);

  Map<String, dynamic> toJson() => _$CryptoCurrencyToJson(this);
}