import 'dart:math';

import 'package:decimal/decimal.dart';

import 'big_decimal.dart';
import 'rounding_mode.dart';

abstract class Rounding {

  static BigDecimal round(Decimal value, RoundingMode mode, [int decimalPlaces = 2]) {
    switch (mode) {
      case RoundingMode.HALF_EVEN:
        return _roundHalfEven(value, decimalPlaces);
      case RoundingMode.HALF_DOWN:
        return _roundHalfDown(value, decimalPlaces);
      case RoundingMode.HALF_UP:
        return _roundHalfUp(value, decimalPlaces);
      default:
      // NOT IMPLEMENTED YET
        return BigDecimal.fromDouble(value.toDouble());
    }
  }

  static BigDecimal _roundHalfEven(Decimal value, int decimalPlaces) {
    Decimal integralPart = value.truncate();
    Decimal fractionalPart = _getFractionalPart(value);
    int nextToLast = _getNextToLast(fractionalPart, decimalPlaces);
    Decimal fractionalMultiple = _powOfTen(decimalPlaces);
    Decimal roundedFractionalPart = ((fractionalPart * fractionalMultiple).floor() / fractionalMultiple);
    bool hasRemainder = _getFractionalPart(fractionalPart * _powOfTen(decimalPlaces + 1)) != Decimal.zero;
    if (nextToLast < 5) return BigDecimal.fromDouble((integralPart + roundedFractionalPart).toDouble());
    if (nextToLast > 5 || hasRemainder) roundedFractionalPart = _carryLatest(roundedFractionalPart, decimalPlaces);
    else {
      int lastConserved = (fractionalPart * _powOfTen(decimalPlaces) % Decimal.fromInt(10)).toInt();
      if (lastConserved.isOdd) roundedFractionalPart = _carryLatest(roundedFractionalPart, decimalPlaces);
    }
    return BigDecimal.fromDouble((integralPart + roundedFractionalPart).toDouble());
  }

  static BigDecimal _roundHalfDown(Decimal value, int decimalPlaces) {
    Decimal integralPart = value.truncate();
    Decimal fractionalPart = _getFractionalPart(value);
    int nextToLast = _getNextToLast(fractionalPart, decimalPlaces);
    Decimal fractionalMultiple = _powOfTen(decimalPlaces);
    Decimal roundedFractionalPart = ((fractionalPart * fractionalMultiple).floor() / fractionalMultiple);
    if (nextToLast <= 5) return BigDecimal.fromDouble((integralPart + roundedFractionalPart).toDouble());
    roundedFractionalPart = _carryLatest(roundedFractionalPart, decimalPlaces);
    return BigDecimal.fromDouble((integralPart + roundedFractionalPart).toDouble());
  }

  static BigDecimal _roundHalfUp(Decimal value, int decimalPlaces) {
    Decimal integralPart = value.truncate();
    Decimal fractionalPart = _getFractionalPart(value);
    int nextToLast = _getNextToLast(fractionalPart, decimalPlaces);
    Decimal fractionalMultiple = _powOfTen(decimalPlaces);
    Decimal roundedFractionalPart = ((fractionalPart * fractionalMultiple).floor() / fractionalMultiple);
    if (nextToLast >= 5) roundedFractionalPart = _carryLatest(roundedFractionalPart, decimalPlaces);
    return BigDecimal.fromDouble((integralPart + roundedFractionalPart).toDouble());
  }

  static Decimal _powOfTen(int value) => Decimal.parse(pow(10, value).toString());

  static Decimal _getFractionalPart(Decimal value) => value - value.truncate();

  static int _getNextToLast(Decimal fractionalPart, int decimalPlaces) =>
      (fractionalPart * _powOfTen(decimalPlaces + 1) % Decimal.fromInt(10)).toInt();

  static Decimal _carryLatest(Decimal value, int decimalPlaces) {
    int amount = value == Decimal.zero
        ? decimalPlaces
        : value.toString().length - 2;
    Decimal offset = _powOfTen(-amount);
    return value + offset;
  }
}
