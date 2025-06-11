import 'package:flutter/material.dart';

class AppSizes {
  static const bodyPadding = 16.0;
  static const insidePadding = 10.0;

  
  static const radiusSmall = 8.0;
  static const radiusMedium = 12.0;
  static const radiusLarge = 16.0;
  static const double cardRadius = 10;
  static const double textFieldRadius = 6;

  static const iconSmall = 16.0;
  static const iconMedium = 20.0;
  static const iconBig = 24.0;

  static const double fontSizeExtraSmall = 10;
  static const double fontSizeSmall = 12;
  static const double fontSizeDefault = 14;
  static const double fontSizeLarge = 16;
  static const double fontSizeExtraLarge = 18;
  static const double fontSizeOverLarge = 24;
  static const double fontSizeMaxLarge = 30;

  static const double buttonRadius = 10;
  static const double buttonHeight = 50;
  static const double buttonText = 15;
  
  static const double subModuleLeftPadding = 30;

  static double height(context, double value)=>MediaQuery.sizeOf(context).height * (value/900);
  static double width(context, double value)=>MediaQuery.sizeOf(context).width * (value/300);
}