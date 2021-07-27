library big_decimal;

import 'dart:math';

import 'package:decimal/decimal.dart';

class BigDecimal {
  final Decimal _valor;

  static final BigDecimal ZERO = instanciar(0);

  static final BigDecimal UM = instanciar(1);

  static final BigDecimal DEZ = instanciar(10);

  static final BigDecimal CEM = instanciar(100);

  static BigDecimal instanciar(double valor) => BigDecimal._(Decimal.parse(valor.toString()));

  static BigDecimal _arredondamentoHalfEven(Decimal numero, int casasDecimais) {
    Decimal parteInteira = numero.floor();
    Decimal parteDecimal = _obterParteDecimal(numero);
    int seguinteAoUltimo = (parteDecimal * _potenciaDe10(casasDecimais + 1) % Decimal.fromInt(10)).toInt();
    Decimal multiploParteDecimal = _potenciaDe10(casasDecimais);
    Decimal parteDecimalArredondada = ((parteDecimal * multiploParteDecimal).floor() / multiploParteDecimal);
    bool possuiAlgarismosRestantes = _obterParteDecimal(parteDecimal * _potenciaDe10(casasDecimais + 1)) != Decimal.zero;
    if (seguinteAoUltimo < 5) return BigDecimal._(parteInteira + parteDecimalArredondada);
    if (seguinteAoUltimo > 5 || possuiAlgarismosRestantes) parteDecimalArredondada = _somarUmDecimal(parteDecimalArredondada, casasDecimais);
    else {
      int ultimoConservado = (parteDecimal * _potenciaDe10(casasDecimais) % Decimal.fromInt(10)).toInt();
      if (ultimoConservado.isOdd) parteDecimalArredondada = _somarUmDecimal(parteDecimalArredondada, casasDecimais);
    }
    return BigDecimal._(parteInteira + parteDecimalArredondada);
  }

  static Decimal _potenciaDe10(int numero) => Decimal.parse(pow(10, numero).toString());

  static Decimal _obterParteDecimal(Decimal numero) => numero - numero.floor();

  static Decimal _somarUmDecimal(Decimal numero, int casasDecimais) {
    int quantidadeDigitos = numero == Decimal.zero
        ? casasDecimais
        : numero.toString().length - 2;
    Decimal deslocamento = _potenciaDe10(-quantidadeDigitos);
    return numero + deslocamento;
  }

  BigDecimal multiplicar(BigDecimal segundoNumero, [int casasDecimais = 2]) {
    Decimal resultado = _valor * segundoNumero._valor;
    return _arredondamentoHalfEven(resultado, casasDecimais);
  }

  BigDecimal dividir(BigDecimal segundoNumero, [int casasDecimais = 2]) {
    Decimal resultado = _valor / segundoNumero._valor;
    return _arredondamentoHalfEven(resultado, casasDecimais);
  }

  BigDecimal somar(BigDecimal segundoNumero) {
    Decimal resultado = _valor + segundoNumero._valor;
    return BigDecimal._(resultado);
  }

  BigDecimal subtrair(BigDecimal segundoNumero) {
    Decimal resultado = _valor - segundoNumero._valor;
    return BigDecimal._(resultado);
  }

  BigDecimal obterPorcentagem(BigDecimal porcentagem, [int casasDecimais = 2]) {
    Decimal multiplicacao = _valor * porcentagem._valor;
    return BigDecimal._(multiplicacao).dividir(CEM, casasDecimais);
  }

  BigDecimal obterPorcentagemDe(BigDecimal segundoNumero, [int casasDecimais = 2]) {
    Decimal divisao = _valor / segundoNumero._valor;
    return BigDecimal._(divisao).multiplicar(CEM, casasDecimais);
  }

  BigDecimal modulo(BigDecimal segundoNumero) => BigDecimal._(_valor % segundoNumero._valor);

  BigDecimal divisaoInteira(BigDecimal segundoNumero) => BigDecimal._(_valor ~/ segundoNumero._valor);

  bool divisivelPor(BigDecimal segundoNumero) => modulo(segundoNumero) == ZERO;

  BigDecimal._(this._valor);

  @override
  String toString() {
    return _valor.toString();
  }

  bool operator >(BigDecimal segundoNumero) => _valor > segundoNumero._valor;

  bool operator <(BigDecimal segundoNumero) => _valor < segundoNumero._valor;

  bool operator >=(BigDecimal segundoNumero) => _valor >= segundoNumero._valor;

  bool operator <=(BigDecimal segundoNumero) => _valor <= segundoNumero._valor;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is BigDecimal &&
              runtimeType == other.runtimeType &&
              _valor == other._valor;

  @override
  int get hashCode => _valor.hashCode;
}
