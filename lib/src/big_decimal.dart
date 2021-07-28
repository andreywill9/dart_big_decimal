library big_decimal;


import 'package:big_decimal/big_decimal.dart';
import 'package:decimal/decimal.dart';

import 'rouding.dart';
import 'rounding_mode.dart';

class BigDecimal {
  final Decimal _value;

  static final BigDecimal ZERO = fromDouble(0);

  static final BigDecimal ONE = fromDouble(1);

  static final BigDecimal TEN = fromDouble(10);

  static final BigDecimal ONE_HUNDRED = fromDouble(100);
  
  static BigDecimal fromDouble(double valor) => BigDecimal._(Decimal.parse(valor.toString()));

  BigDecimal multiply(BigDecimal secondValue, RoundingMode roundingMode) {
    Decimal result = _value * secondValue._value;
    return BigDecimal._(result);
  }

  BigDecimal divide(BigDecimal secondValue, RoundingMode roundingMode, [int decimalPlaces = 2]) {
    Decimal result = _value / secondValue._value;
    return Rounding.round(result, roundingMode, decimalPlaces);
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

  BigDecimal movePointToLeft(int places) => BigDecimal._(_value * (TEN.pow(places * -1, RoundingMode.ROUND_DOWN, 0))._value);

  BigDecimal movePointToRight(int places) => BigDecimal._(_value * (TEN.pow(places, RoundingMode.ROUND_DOWN, 0))._value);

  BigDecimal abs() => BigDecimal._(_value.abs());

  BigDecimal pow(int exponent, RoundingMode roundingMode, [int decimalPlaces = 2]) {
    Decimal result = _value.pow(exponent);
    return Rounding.round(result, roundingMode, decimalPlaces);
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
