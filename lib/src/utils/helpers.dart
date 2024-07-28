import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

void setSystemUIOverlayColor(Color color) {
  return SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      systemNavigationBarColor: color,
      statusBarColor: color,
    ),
  );
}

bool isRouteOnTop(BuildContext context) {
  final routerState = GoRouterState.of(context);
  return routerState.name == routerState.topRoute?.name;
}