import "dart:math";

import "package:discloud/extensions/num.dart";
import "package:discloud/utils/formatters.dart";
import "package:intl/intl.dart";

/// binary: KB = 1024 B
/// decimal: KB = 1000 B
enum Dimension(final int value) {
  /// KB = 1024 B
  binary(1024),

  /// KB = 1000 B
  decimal(1000),
}

class const Bytes<N extends num>(
  final N n, {
  final Dimension dimension = .binary,
  final NumberFormat? numberFormatter,
}) {
  const factory bits(
    N n, {
    Dimension dimension,
    NumberFormat? numberFormatter,
  }) = _Bits;

  UnitType get type => .byte;

  int get index {
    if (_isInvalid) return 0;
    return log(n) ~/ log(dimension.value);
  }

  double get bytes {
    if (_isInvalid) return 0;
    return n / pow(dimension.value, unitIndex);
  }

  int get unitIndex => index.clamp(0, type.units.length - 1);

  bool get _isInvalid => n.isNaN || n.isInfinite || n.isZero || n.isNegative;

  @override
  String toString([String separator = ""]) {
    final unit = type.units[unitIndex];
    return "${(numberFormatter ?? decimalFormatter).format(bytes)}$separator${unit.name}";
  }

  Bytes operator +(Object? other) {
    return switch (other) {
      final _Bits other => .new(other.n / 8 + n),
      final Bytes other => .new(other.n + n),
      final num other => .new(other + n),
      _ => this,
    };
  }

  Bytes operator -(Object? other) {
    return switch (other) {
      final _Bits other => .new(other.n / 8 - n),
      final Bytes other => .new(other.n - n),
      final num other => .new(other - n),
      _ => this,
    };
  }

  Bytes operator *(Object? other) {
    return switch (other) {
      final _Bits other => .new(other.n / 8 * n),
      final Bytes other => .new(other.n * n),
      final num other => .new(other * n),
      _ => this,
    };
  }

  Bytes operator /(Object? other) {
    return switch (other) {
      final _Bits other => .new(other.n / 8 / n),
      final Bytes other => .new(other.n / n),
      final num other => .new(other / n),
      _ => this,
    };
  }

  Bytes operator ~/(Object? other) {
    return switch (other) {
      final _Bits other => .new(other.n / 8 ~/ n),
      final Bytes other => .new(other.n ~/ n),
      final num other => .new(other ~/ n),
      _ => this,
    };
  }

  Bytes operator %(Object? other) {
    return switch (other) {
      final _Bits other => .new(other.n / 8 % n),
      final Bytes other => .new(other.n % n),
      final num other => .new(other % n),
      _ => this,
    };
  }

  bool operator >(Object? other) {
    return switch (other) {
      final _Bits other => other.n / 8 > n,
      final Bytes other => other.n > n,
      final num other => other > n,
      _ => false,
    };
  }

  bool operator >=(Object? other) {
    return switch (other) {
      final _Bits other => other.n / 8 >= n,
      final Bytes other => other.n >= n,
      final num other => other >= n,
      _ => false,
    };
  }

  bool operator <(Object? other) {
    return switch (other) {
      final _Bits other => other.n / 8 < n,
      final Bytes other => other.n < n,
      final num other => other < n,
      _ => false,
    };
  }

  bool operator <=(Object? other) {
    return switch (other) {
      final _Bits other => other.n / 8 <= n,
      final Bytes other => other.n <= n,
      final num other => other <= n,
      _ => false,
    };
  }

  @override
  bool operator ==(other) {
    return switch (other) {
      final _Bits other => other.n / 8 == n,
      final Bytes other => other.n == n,
      final num other => other == n,
      _ => false,
    };
  }

  @override
  // ignore: unnecessary_overrides
  int get hashCode => super.hashCode;
}

class const _Bits<N extends num>(
  super.n, {
  super.dimension = .binary,
  super.numberFormatter,
}) extends Bytes<N> {
  @override
  UnitType get type => .bit;

  @override
  int get unitIndex => index.clamp(0, type.units.length - 1);

  @override
  String toString([String separator = ""]) {
    final unit = type.units[unitIndex];
    return "${(numberFormatter ?? decimalFormatter).format(bytes)}$separator${unit.name}";
  }

  @override
  _Bits operator +(Object? other) {
    return switch (other) {
      final _Bits other => .new(other.n + n),
      final Bytes other => .new(other.n * 8 + n),
      final num other => .new(other + n),
      _ => this,
    };
  }

  @override
  _Bits operator -(Object? other) {
    return switch (other) {
      final _Bits other => .new(other.n - n),
      final Bytes other => .new(other.n * 8 - n),
      final num other => .new(other - n),
      _ => this,
    };
  }

  @override
  _Bits operator *(Object? other) {
    return switch (other) {
      final _Bits other => .new(other.n * n),
      final Bytes other => .new(other.n * 8 * n),
      final num other => .new(other * n),
      _ => this,
    };
  }

  @override
  _Bits operator /(Object? other) {
    return switch (other) {
      final _Bits other => .new(other.n / n),
      final Bytes other => .new(other.n * 8 / n),
      final num other => .new(other / n),
      _ => this,
    };
  }

  @override
  _Bits operator ~/(Object? other) {
    return switch (other) {
      final _Bits other => .new(other.n ~/ n),
      final Bytes other => .new(other.n * 8 ~/ n),
      final num other => .new(other ~/ n),
      _ => this,
    };
  }

  @override
  _Bits operator %(Object? other) {
    return switch (other) {
      final _Bits other => .new(other.n % n),
      final Bytes other => .new(other.n * 8 % n),
      final num other => .new(other % n),
      _ => this,
    };
  }

  @override
  bool operator >(Object? other) {
    return switch (other) {
      final _Bits other => other.n > n,
      final Bytes other => other.n * 8 > n,
      final num other => other > n,
      _ => false,
    };
  }

  @override
  bool operator >=(Object? other) {
    return switch (other) {
      final _Bits other => other.n >= n,
      final Bytes other => other.n * 8 >= n,
      final num other => other >= n,
      _ => false,
    };
  }

  @override
  bool operator <(Object? other) {
    return switch (other) {
      final _Bits other => other.n < n,
      final Bytes other => other.n * 8 < n,
      final num other => other < n,
      _ => false,
    };
  }

  @override
  bool operator <=(Object? other) {
    return switch (other) {
      final _Bits other => other.n <= n,
      final Bytes other => other.n * 8 <= n,
      final num other => other <= n,
      _ => false,
    };
  }

  @override
  bool operator ==(other) {
    return switch (other) {
      final _Bits other => other.n == n,
      final Bytes other => other.n * 8 == n,
      final num other => other == n,
      _ => false,
    };
  }

  @override
  // ignore: unnecessary_overrides
  int get hashCode => super.hashCode;
}

// ignore: constant_identifier_names
enum _ByteUnit { B, KB, MB, GB, TB, PB, EB, ZB, YB }

// ignore: constant_identifier_names
enum _BitUnit { b, Kb, Mb, Gb, Tb, Pb, Eb, Zb, Yb }

enum UnitType(final List<Enum> units) {
  bit(_BitUnit.values),
  byte(_ByteUnit.values),
}
