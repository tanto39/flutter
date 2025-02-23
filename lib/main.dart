import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ithub/bloc/favorite/favorite_bloc.dart';
import 'package:flutter_ithub/repositories/favorite_repository.dart';
import 'bloc/crypto/crypto_bloc.dart';
import 'models/crypto_currency.dart';
import 'repositories/crypto_repository.dart';
import 'screens/crypto_detail_screen.dart';
import 'screens/main_navigator.dart';
import 'package:image_picker/image_picker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: "AIzaSyD01umSwp2Q9UpSLcQCYz6c6NtocIJwZLQ",
            authDomain: "flutter-83894.firebaseapp.com",
            projectId: "flutter-83894",
            storageBucket: "flutter-83894.firebasestorage.app",
            messagingSenderId: "557147264910",
            appId: "1:557147264910:web:2338d11da784a1e548f6df"));
  } else {
    await Firebase.initializeApp();
  }

  runApp(MultiBlocProvider(
    providers: [
      BlocProvider(
        create: (context) => FavoriteBloc(
          favoriteRepository: FavoriteRepository(),
          cryptoRepository: CryptoRepository(),
        )..add(LoadFavoritesEvent()),
      ),
      BlocProvider(create: (context) => CryptoBloc(CryptoRepository())),
    ],
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) => CryptoRepository(),
      child: BlocProvider(
        create: (context) => CryptoBloc(context.read<CryptoRepository>())
          ..add(LoadCryptoEvent()),
        child: MaterialApp(
          title: 'Курсы криптовалют',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          home: MainNavigator(),
          routes: {
            '/crypto-detail': (context) => CryptoDetailScreen(
                  crypto: ModalRoute.of(context)!.settings.arguments
                      as CryptoCurrency,
                ),
          },
        ),
      ),
    );
  }
}
