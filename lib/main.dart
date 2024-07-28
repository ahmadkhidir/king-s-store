import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sales_ai_examples/src/paystack/bloc/paystack_bloc.dart';
import 'package:sales_ai_examples/src/paystack/utils/helpers.dart';
import 'package:sales_ai_examples/src/paystack/utils/repository.dart';
import 'package:sales_ai_examples/src/products/utils/data_provider.dart';
import 'package:sales_ai_examples/src/sales_ai/bloc/sales_ai_bloc.dart';
import 'package:sales_ai_examples/src/sales_ai/utils/data_provider.dart';
import 'package:sales_ai_examples/src/sales_ai/utils/helpers.dart';
import 'package:sales_ai_examples/src/utils/helpers.dart';
import 'package:sales_ai_examples/src/utils/themes.dart';

import 'firebase_options.dart';
import 'src/products/bloc/products_bloc.dart';
import 'src/utils/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    requestAllNeededPermissions();
    // SystemChrome.setApplicationSwitcherDescription(const ApplicationSwitcherDescription(label: "Sales AI"));
    setSystemUIOverlayColor(Colors.transparent);
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<DBRepository>(
          create: (context) => DBRepository(),
        ),
        RepositoryProvider<SalesAIRepository>(
          create: (context) => SalesAIRepository(),
        ),
        RepositoryProvider(
          create: (context) =>
              PaystackRepository(secretKey: transactionSecretKey),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<ProductsBloc>(
            create: (context) => ProductsBloc(
              dbRepository: context.read<DBRepository>(),
            ),
          ),
          BlocProvider<SalesAiBloc>(
            create: (context) => SalesAiBloc(
              salesAIRepository: SalesAIRepository(),
            ),
          ),
          BlocProvider(
            create: (context) => PaystackBloc(
              paystackRepository: context.read<PaystackRepository>(),
            ),
          ),
        ],
        child: MaterialApp.router(
          title: 'King\'s Store',
          routerConfig: appRouter,
          theme: lightTheme,
        ),
      ),
    );
  }
}
