import 'package:sultan_app/core/constants/app_constants.dart';

abstract final class PriceFormatter {
  static String format(double value) =>
      '${value.toStringAsFixed(2)} ${AppConstants.currency}';
}
