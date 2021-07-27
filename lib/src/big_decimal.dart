library big_decimal;

import 'dart:math';

import 'package:decimal/decimal.dart';

import 'rounding_mode.dart';

class BigDecimal {
  final Decimal _value;

  static final BigDecimal ZERO = fromDouble(0);

  static final BigDecimal ONE = fromDouble(1);

  static final BigDecimal TEN = fromDouble(10);

  static final BigDecimal ONE_HUNDRED = fromDouble(100);
  
  static BigDecimal fromDouble(double valor) => BigDecimal._(Decimal.parse(valor.toString()));

  static BigDecimal _roundHalfEven(Decimal value, int decimalPlaces) {
    Decimal integralPart = value.truncate();
    Decimal fractionalPart = _getFractionalPart(value);
    int nextToLast = (fractionalPart * _powOfTen(decimalPlaces + 1) % Decimal.fromInt(10)).toInt();
    Decimal fractionalMultiple = _powOfTen(decimalPlaces);
    Decimal roundedFractionalPart = ((fractionalPart * fractionalMultiple).floor() / fractionalMultiple);
    bool hasRemainder = _getFractionalPart(fractionalPart * _powOfTen(decimalPlaces + 1)) != Decimal.zero;
    if (nextToLast < 5) return BigDecimal._(integralPart + roundedFractionalPart);
    if (nextToLast > 5 || hasRemainder) roundedFractionalPart = _carryLatest(roundedFractionalPart, decimalPlaces);
    else {
      int lastConserved = (fractionalPart * _powOfTen(decimalPlaces) % Decimal.fromInt(10)).toInt();
      if (lastConserved.isOdd) roundedFractionalPart = _carryLatest(roundedFractionalPart, decimalPlaces);
    }
    return BigDecimal._(integralPart + roundedFractionalPart);
  }

  static Decimal _powOfTen(int value) => Decimal.parse(pow(10, value).toString());

  static Decimal _getFractionalPart(Decimal value) => value - value.truncate();

  static Decimal _carryLatest(Decimal value, int decimalPlaces) {
    int amount = value == Decimal.zero
        ? decimalPlaces
        : value.toString().length - 2;
    Decimal offset = _powOfTen(-amount);
    return value + offset;
  }

  BigDecimal multiply(BigDecimal secondValue, RoundingMode roundingMode, [int decimalPlaces = 2]) {
    Decimal result = _value * secondValue._value;
    return BigDecimal._(result).round(roundingMode, decimalPlaces);
  }

  BigDecimal divide(BigDecimal secondValue, RoundingMode roundingMode, [int decimalPlaces = 2]) {
    Decimal result = _value / secondValue._value;
    return BigDecimal._(result).round(roundingMode, decimalPlaces);
  }

  BigDecimal add(BigDecimal secondValue) {
    Decimal result = _value + secondValue._value;
    return BigDecimal._(result);
  }

  BigDecimal subtract(BigDecimal secondValue) {
    Decimal result = _value - secondValue._value;
    return BigDecimal._(result);
  }

  BigDecimal getPercentage(BigDecimal percentage, RoundingMode roundingMode, [int decimalPlaces = 2]) {
    Decimal multiplicacao = _value * percentage._value;
    return BigDecimal._(multiplicacao).divide(ONE_HUNDRED, roundingMode, decimalPlaces);
  }

  BigDecimal remainder(BigDecimal secondValue) => BigDecimal._(_value % secondValue._value);

  BigDecimal divideToIntegralValue(BigDecimal secondValue) => BigDecimal._(_value ~/ secondValue._value);

  BigDecimal negate() => BigDecimal._(-_value);

  BigDecimal max(BigDecimal secondValue) => secondValue._value > _value ? secondValue : this;

  BigDecimal min(BigDecimal secondValue) => secondValue._value < _value ? secondValue : this;

  BigDecimal movePointToLeft(int places) => BigDecimal._(_value * (_powOfTen(places * -1)));

  BigDecimal movePointToRight(int places) => BigDecimal._(_value * (_powOfTen(places)));

  BigDecimal abs() => BigDecimal._(_value.abs());

  BigDecimal power(int exponent, RoundingMode roundingMode, [int decimalPlaces = 2]) {
    Decimal result = _value.pow(exponent);
    return BigDecimal._(result).round(roundingMode, decimalPlaces);
  }

  BigDecimal round(RoundingMode mode, int decimalPlaces) {
    switch (mode) {
      case RoundingMode.HALF_EVEN:
        return _roundHalfEven(_value, decimalPlaces);
      default:
      // NOT IMPLEMENTED YET
        return this;
    }
  }
  
  int compareTo(BigDecimal secondValue) => _value.compareTo(secondValue._value);

  bool operator >(BigDecimal secondValue) => _value > secondValue._value;

  bool operator <(BigDecimal secondValue) => _value < secondValue._value;

  bool operator >=(BigDecimal secondValue) => _value >= secondValue._value;

  bool operator <=(BigDecimal secondValue) => _value <= secondValue._value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is BigDecimal &&
              runtimeType == other.runtimeType &&
              _value == other._value;

  @override
  int get hashCode => _value.hashCode;

  @override
  String toString() {
    return _value.toString();
  }

  BigDecimal._(this._value);
}
