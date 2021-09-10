library big_decimal;

import 'dart:math' as math;

class BigDecimal {
  
  final BigInt _significant;

  final int _scale;

  static final BigDecimal ZERO = BigDecimal.fromString("0");

  static final BigDecimal ONE = BigDecimal.fromString("1");

  static final BigDecimal TEN = BigDecimal.fromString("10");

  static final BigDecimal ONE_HUNDRED = BigDecimal.fromString("100");

  static BigInt _calculateSignificant(String value) {
    String valueWOPoint = value.replaceAll(".", "");
    return BigInt.parse(valueWOPoint);
  }

  static int _calculateScale(String value, BigInt significant) {
    int scale = significant == BigInt.zero
        ? 0
        : (math.log(num.parse(value).abs() / significant.abs().toInt()) / math.ln10).round();
    scale += _zeroCount(value, scale.abs());
    return significant.isNegative ? -scale : scale;
  }

  static int _zeroCount(String value, int scale) {
    List<String> split = value.split(".");
    if (split.length == 1) return 0;
    return split[1].substring(scale).length;
  }

  factory BigDecimal.fromString(String value) {
    BigInt significant = _calculateSignificant(value);
    int scale = _calculateScale(value, significant);
    return BigDecimal._(significant, scale);
  }

  BigDecimal multiply(BigDecimal multiplicand) {
    int finalScale = _scale + multiplicand._scale;
    BigInt finalSignificant = _significant * multiplicand._significant;
    return BigDecimal._(finalSignificant, finalScale);
  }

  // BigDecimal divide(BigDecimal divisor, RoundingMode roundingMode) {
  //   int finalScale = scale - divisor.scale;
  //   Decimal result = _value / divisor._value;
  //   return Rounding.round(result, roundingMode, decimalPlaces);
  // }

  BigDecimal add(BigDecimal augend) {
    BigInt biggerSignificant = max(augend)._significant;
    BigInt otherSignificant = biggerSignificant == _significant ? augend._significant : _significant;
    int scaleDiff = (_scale.abs() - augend._scale.abs()).abs();
    int finalScale = _scale.abs() > augend._scale.abs()
        ? _scale
        : augend._scale;
    biggerSignificant *= BigInt.from(math.pow(10, scaleDiff));
    return BigDecimal._((biggerSignificant + otherSignificant), finalScale);
  }

  BigDecimal subtract(BigDecimal subtrahend) {
    int scaleDiff = (_scale.abs() - subtrahend._scale.abs()).abs();
    int finalScale = _scale.abs() > subtrahend._scale.abs()
        ? _scale
        : subtrahend._scale;
    BigInt minuendSignificant = _significant;
    BigInt subtrahendSignificant = subtrahend._significant;
    if (minuendSignificant == max(subtrahend)._significant)
      minuendSignificant *= BigInt.from(math.pow(10, scaleDiff));
    else subtrahendSignificant *= BigInt.from(math.pow(10, scaleDiff));
    return BigDecimal._((minuendSignificant - subtrahendSignificant), finalScale);
  }

  // BigDecimal getPercentage(BigDecimal percentage, RoundingMode roundingMode, [int decimalPlaces = 2]) {
  //   Decimal multiplicacao = _value * percentage._value;
  //   return BigDecimal._(multiplicacao).divide(ONE_HUNDRED, roundingMode, decimalPlaces);
  // }
  //
  // BigDecimal remainder(BigDecimal secondValue) => BigDecimal._(_value % secondValue._value);
  //
  // BigDecimal divideToIntegralValue(BigDecimal secondValue) => BigDecimal._(_value ~/ secondValue._value);

  BigDecimal negate() => BigDecimal._(-_significant, _scale);

  BigDecimal max(BigDecimal secondValue) => secondValue.doubleValue() > doubleValue()
      ? secondValue
      : this;

  BigDecimal min(BigDecimal secondValue) => secondValue.doubleValue() < doubleValue()
      ? secondValue
      : this;

  BigDecimal movePointToLeft(int places) => BigDecimal._(_significant, _scale - places);

  BigDecimal movePointToRight(int places) => BigDecimal._(_significant, _scale + places);

  BigDecimal abs() => BigDecimal._(_significant.abs(), _scale);

  // BigDecimal pow(int exponent) => BigDecimal._(_value.pow(exponent));

  BigInt toBigInt() {
    String significant = this._significant.toString();
    return BigInt.parse(significant.substring(0, significant.length - _scale.abs()));
  }

  int intValue() => doubleValue().truncate();

  double doubleValue() => (_significant.toInt() * math.pow(10, _scale)).toDouble();

  int signum() {
    if (_significant == BigInt.zero) return 0;
    return _significant > BigInt.zero
        ? 1
        : -1;
  }

  @override
  String toString() {
    return (_significant.toInt() * math.pow(10, _scale)).toString();
  }

  BigDecimal._(this._significant, this._scale);
}
