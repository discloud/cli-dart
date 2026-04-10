import "dart:math";

import "package:discloud/extensions/num.dart";
import "package:intl/intl.dart";

/// binary: KB = 1024 B
/// decimal: KB = 1000 B
enum Dimension {
  /// KB = 1024 B
  binary(1024),

  /// KB = 1000 B
  decimal(1000);

  const Dimension(this.value);

  final int value;
}

class Bytes<N extends num> {
  static final Map<int, NumberFormat> _formatters = .new();

  const Bytes(this.n, {this.dimension = .binary});

  final N n;
  final Dimension dimension;

  int get index {
    if (_isInvalid) return 0;
    return log(n) ~/ log(dimension.value);
  }

  double get bytes {
    if (_isInvalid) return 0;
    return n / pow(dimension.value.toDouble(), index);
  }

  ByteUnit get unit {
    final index = this.index;
    return index < ByteUnit.values.length ? .values[index] : .values.last;
  }

  bool get _isInvalid => n.isNaN || n.isInfinite || n.isZero || n.isNegative;

  @override
  String toString([int fractionDigits = 2]) {
    final formatter = _formatters.putIfAbsent(
      fractionDigits,
      () => .decimalPattern()..maximumFractionDigits = fractionDigits,
    );
    return "${formatter.format(bytes)} ${unit.name}";
  }

  Bytes operator +(Object? other) {
    return switch (other) {
      final num other => .new(other + n),
      final Bytes other => .new(other.n + n),
      _ => this,
    };
  }

  Bytes operator -(Object? other) {
    return switch (other) {
      final num other => .new(other - n),
      final Bytes other => .new(other.n - n),
      _ => this,
    };
  }

  Bytes operator *(Object? other) {
    return switch (other) {
      final num other => .new(other * n),
      final Bytes other => .new(other.n * n),
      _ => this,
    };
  }

  Bytes operator /(Object? other) {
    return switch (other) {
      final num other => .new(other / n),
      final Bytes other => .new(other.n / n),
      _ => this,
    };
  }

  Bytes operator ~/(Object? other) {
    return switch (other) {
      final num other => .new(other ~/ n),
      final Bytes other => .new(other.n ~/ n),
      _ => this,
    };
  }

  Bytes operator %(Object? other) {
    return switch (other) {
      final num other => .new(other % n),
      final Bytes other => .new(other.n % n),
      _ => this,
    };
  }

  bool operator >(Object? other) {
    return switch (other) {
      final num other => other > n,
      final Bytes other => other.n > n,
      _ => false,
    };
  }

  bool operator >=(Object? other) {
    return switch (other) {
      final num other => other >= n,
      final Bytes other => other.n >= n,
      _ => false,
    };
  }

  bool operator <(Object? other) {
    return switch (other) {
      final num other => other < n,
      final Bytes other => other.n < n,
      _ => false,
    };
  }

  bool operator <=(Object? other) {
    return switch (other) {
      final num other => other <= n,
      final Bytes other => other.n <= n,
      _ => false,
    };
  }

  @override
  bool operator ==(other) {
    return switch (other) {
      final num other => other == n,
      final Bytes other => other.n == n,
      _ => hashCode == other.hashCode,
    };
  }

  @override
  // ignore: unnecessary_overrides
  int get hashCode => super.hashCode;
}

enum ByteUnit<N extends num> {
  B(1),

  /// 1_024
  // ignore: constant_identifier_names
  KB(1_024),

  /// 1_048_576
  // ignore: constant_identifier_names
  MB(1_048_576),

  /// 1_073_741_824
  // ignore: constant_identifier_names
  GB(1_073_741_824),

  /// 1_099_511_627_776
  // ignore: constant_identifier_names
  TB(1_099_511_627_776),

  /// 1_125_899_906_842_624
  // ignore: constant_identifier_names
  PB(1_125_899_906_842_624),

  /// 1_152_921_504_606_846_976
  // ignore: constant_identifier_names
  EB(1_152_921_504_606_846_976),

  /// 1_180_591_620_717_411_303_424
  // ignore: constant_identifier_names
  ZB(1_180_591_620_717_411_303_424.0),

  /// 1_208_925_819_614_629_174_706_176
  // ignore: constant_identifier_names
  YB(1_208_925_819_614_629_174_706_176.0);

  const ByteUnit(this.value);

  final N value;
}
