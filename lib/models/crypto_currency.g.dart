// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'crypto_currency.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CryptoCurrency _$CryptoCurrencyFromJson(Map<String, dynamic> json) =>
    CryptoCurrency(
      symbol: json['FROMSYMBOL'] as String,
      price: (json['PRICE'] as num).toDouble(),
    );

Map<String, dynamic> _$CryptoCurrencyToJson(CryptoCurrency instance) =>
    <String, dynamic>{
      'FROMSYMBOL': instance.symbol,
      'PRICE': instance.price,
    };
