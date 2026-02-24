import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/theme/app_theme.dart';
import 'core/routing/app_routes.dart';

import 'features/auth/presentation/login_screen.dart';
import 'features/home/presentation/main_screen.dart';
import 'features/inventory/presentation/add_item_screen.dart';
import 'features/booking/presentation/item_details_screen.dart';
import 'features/booking/presentation/measurement_form.dart';

import 'package:provider/provider.dart';
import 'core/providers/app_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: const DressRentalApp(),
    ),
  );
}

class DressRentalApp extends StatelessWidget {
  const DressRentalApp({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    return MaterialApp(
      title: 'EVOCA FASHION STORE',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme.copyWith(
        textTheme: GoogleFonts.outfitTextTheme(AppTheme.lightTheme.textTheme),
      ),
      darkTheme: AppTheme.darkTheme.copyWith(
        textTheme: GoogleFonts.outfitTextTheme(AppTheme.darkTheme.textTheme),
      ),
      themeMode: provider.themeMode,
      initialRoute: AppRoutes.home,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case AppRoutes.login:
            return MaterialPageRoute(builder: (_) => const LoginScreen());
          case AppRoutes.home:
            return MaterialPageRoute(builder: (_) => const MainScreen());
          case AppRoutes.addItem:
            return MaterialPageRoute(builder: (_) => const AddItemScreen());
          case AppRoutes.itemDetails:
            final itemIndex = settings.arguments as int? ?? 0;
            return MaterialPageRoute(builder: (_) => ItemDetailsScreen(itemIndex: itemIndex));
          case AppRoutes.measurementForm:
            return MaterialPageRoute(builder: (_) => const MeasurementFormScreen());
          default:
            return MaterialPageRoute(builder: (_) => const LoginScreen());
        }
      },
    );
  }
}
