import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:rburger/cubit/branch_selector_cubit.dart';
import 'package:rburger/routing.dart';
import 'package:rburger/services/data/branch_data.dart';
import 'package:rburger/services/data/burger_options_data.dart';
import 'package:rburger/services/login_service/auth_controller.dart';
import 'package:rburger/services/login_service/customer_auth_serv.dart';
import 'package:rburger/services/login_service/driver_auth_serv.dart';
import '/app_theme.dart';
import 'package:easy_localization/easy_localization.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await EasyLocalization.ensureInitialized();
  CustomerAuthService.initializeInterceptors();
  DriverAuthService.initializeInterceptors();


  await Future.wait([
    BranchService.getBranch(),
    OptionsService.getOptionGroups(),
  ]);
  await AuthController.instance.tryAutoLogin();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      startLocale: const Locale('en'),
      child: const RBurgerApp(),
    ),
  );
}

class RBurgerApp extends StatelessWidget {
  const RBurgerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BranchSelectorCubit(),
      child: MaterialApp.router(
        title: 'Republic',
        debugShowCheckedModeBanner: false,
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        theme: AppTheme.light,
        routerConfig: Routing().router,
      ),
    );
  }
}
//01112345678
// Abdo1234+

// Driver
//01099988877
//Driver@#1234
