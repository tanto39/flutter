// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'crypto_currency.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CryptoCurrency _$CryptoCurrencyFromJson(Map<String, dynamic> json) =>
    CryptoCurrency(
      symbol: json['FROMSYMBOL'] as String,
      price: (json['PRICE'] as num).toDouble(),
      imageUrl: json['IMAGEURL'] as String? ?? '/media/37746251/ton.png',
      change24h: (json['CHANGEPCT24HOUR'] as num?)?.toDouble() ?? 0.0,
      change1h: (json['CHANGEPCTHOUR'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$CryptoCurrencyToJson(CryptoCurrency instance) =>
    <String, dynamic>{
      'FROMSYMBOL': instance.symbol,
      'PRICE': instance.price,
      'IMAGEURL': instance.imageUrl,
      'CHANGEPCT24HOUR': instance.change24h,
      'CHANGEPCTHOUR': instance.change1h,
    };
