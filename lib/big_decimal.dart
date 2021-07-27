library big_decimal;

import 'dart:math';

import 'package:decimal/decimal.dart';

class BigDecimal {
  final Decimal _value;

  static final BigDecimal ZERO = fromDouble(0);

  static final BigDecimal ONE = fromDouble(1);

  static final BigDecimal TEN = fromDouble(10);

  static final BigDecimal ONE_HUNDRED = fromDouble(100);
  
  static BigDecimal fromDouble(double valor) => BigDecimal._(Decimal.parse(valor.toString()));

  static BigDecimal _halfEven(Decimal value, int decimalPlaces) {
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

  static Decimal _getFractionalPart(Decimal value) => value - value.floor();

  static Decimal _carryLatest(Decimal value, int decimalPlaces) {
    int amount = value == Decimal.zero
        ? decimalPlaces
        : value.toString().length - 2;
    Decimal offset = _powOfTen(-amount);
    return value + offset;
  }

  BigDecimal multiply(BigDecimal secondValue, [int decimalPlaces = 2]) {
    Decimal result = _value * secondValue._value;
    return _halfEven(result, decimalPlaces);
  }

  BigDecimal divide(BigDecimal secondValue, [int decimalPlaces = 2]) {
    Decimal result = _value / secondValue._value;
    return _halfEven(result, decimalPlaces);
  }

  BigDecimal add(BigDecimal secondValue) {
    Decimal result = _value + secondValue._value;
    return BigDecimal._(result);
  }

  BigDecimal subtract(BigDecimal secondValue) {
    Decimal result = _value - secondValue._value;
    return BigDecimal._(result);
  }

  BigDecimal getPercentage(BigDecimal percentage, [int decimalPlaces = 2]) {
    Decimal multiplicacao = _value * percentage._value;
    return BigDecimal._(multiplicacao).divide(ONE_HUNDRED, decimalPlaces);
  }

  BigDecimal remainder(BigDecimal secondValue) => BigDecimal._(_value % secondValue._value);

  BigDecimal divideToIntegralValue(BigDecimal secondValue) => BigDecimal._(_value ~/ secondValue._value);

  BigDecimal negate() => BigDecimal._(-_value);

  BigDecimal max(BigDecimal secondValue) => secondValue._value > _value ? secondValue : this;

  BigDecimal min(BigDecimal secondValue) => secondValue._value < _value ? secondValue : this;

  BigDecimal movePointToLeft(int places) => BigDecimal._(_value * (_powOfTen(places * -1)));

  BigDecimal movePointToRight(int places) => BigDecimal._(_value * (_powOfTen(places)));

  BigDecimal abs() => BigDecimal._(_value.abs());

  BigDecimal power(int exponent, [int decimalPlaces = 2]) => _halfEven(_value.pow(exponent), decimalPlaces);
  
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
