library big_decimal;

import 'dart:math' as math;

class BigDecimal {
  
  final BigInt significant;

  final int scale;

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
    int finalScale = scale + multiplicand.scale;
    BigInt finalSignificant = significant * multiplicand.significant;
    return BigDecimal._(finalSignificant, finalScale);
  }

  // BigDecimal divide(BigDecimal divisor, RoundingMode roundingMode) {
  //   int finalScale = scale - divisor.scale;
  //   Decimal result = _value / divisor._value;
  //   return Rounding.round(result, roundingMode, decimalPlaces);
  // }

  BigDecimal add(BigDecimal augend) {
    BigInt biggerSignificant = max(augend).significant;
    BigInt otherSignificant = biggerSignificant == significant ? augend.significant : significant;
    int scaleDiff = (scale.abs() - augend.scale.abs()).abs();
    int finalScale = scale.abs() > augend.scale.abs()
        ? scale
        : augend.scale;
    biggerSignificant *= BigInt.from(math.pow(10, scaleDiff));
    return BigDecimal._((biggerSignificant + otherSignificant), finalScale);
  }

  BigDecimal subtract(BigDecimal subtrahend) {
    int scaleDiff = (scale.abs() - subtrahend.scale.abs()).abs();
    int finalScale = scale.abs() > subtrahend.scale.abs()
        ? scale
        : subtrahend.scale;
    BigInt minuendSignificant = significant;
    BigInt subtrahendSignificant = subtrahend.significant;
    if (minuendSignificant == max(subtrahend).significant)
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

  BigDecimal negate() => BigDecimal._(-significant, scale);

  BigDecimal max(BigDecimal secondValue) => secondValue.doubleValue() > doubleValue()
      ? secondValue
      : this;

  BigDecimal min(BigDecimal secondValue) => secondValue.doubleValue() < doubleValue()
      ? secondValue
      : this;

  BigDecimal movePointToLeft(int places) => BigDecimal._(significant, scale - places);

  BigDecimal movePointToRight(int places) => BigDecimal._(significant, scale + places);

  BigDecimal abs() => BigDecimal._(significant.abs(), scale);

  // BigDecimal pow(int exponent) => BigDecimal._(_value.pow(exponent));

  int intValue() => doubleValue().truncate();

  double doubleValue() => (significant.toInt() * math.pow(10, scale)).toDouble();

  int signum() {
    if (significant == BigInt.zero) return 0;
    return significant > BigInt.zero
        ? 1
        : -1;
  }

  @override
  String toString() {
    return (significant.toInt() * math.pow(10, scale)).toString();
  }

  BigDecimal._(this.significant, this.scale);
}
