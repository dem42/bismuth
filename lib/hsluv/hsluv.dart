import 'dart:math';

class Length {
  final bool greaterEqualZero;
  final double length;
  Length(this.length) : greaterEqualZero = length >= 0;
}

class HUSLColorConverter {

  static final _m = [
    [3.240969941904521, -1.537383177570093, -0.498610760293],
    [-0.96924363628087, 1.87596750150772, 0.041555057407175],
    [0.055630079696993, -0.20397695888897, 1.056971514242878],
  ];

  static final _minv = [
    [0.41239079926595, 0.35758433938387, 0.18048078840183],
    [0.21263900587151, 0.71516867876775, 0.072192315360733],
    [0.019330818715591, 0.11919477979462, 0.95053215224966],
  ];

  static final _refY = 1.0;

  static final _refU = 0.19783000664283;
  static final _refV = 0.46831999493879;

  static final _kappa = 903.2962962;
  static final _epsilon = 0.0088564516;

  static List<List<num>> _getBounds(num L) {
    List<List<num>> result = new List<List<num>>();

    final sub1 = pow(L + 16, 3) / 1560896;
    final sub2 = sub1 > _epsilon ? sub1 : L / _kappa;

    for (int c = 0; c < 3; ++c) {
      final m1 = _m[c][0];
      final m2 = _m[c][1];
      final m3 = _m[c][2];

      for (int t = 0; t < 2; ++t) {
        final top1 = (284517 * m1 - 94839 * m3) * sub2;
        final top2 = (838422 * m3 + 769860 * m2 + 731718 * m1) * L * sub2 - 769860 * t * L;
        final bottom = (632260 * m3 - 126452 * m2) * sub2 + 126452 * t;

        result.add([top1 / bottom, top2 / bottom]);
      }
    }

    return result;
  }

  static num _intersectLineLine(List<num> lineA, List<num> lineB) => (lineA[1] - lineB[1]) / (lineB[0] - lineA[0]);

  static num _distanceFromPole(List<num> point) => sqrt(pow(point[0], 2) + pow(point[1], 2));

  static Length _lengthOfRayUntilIntersect(num theta, List<num> line) {
    final length = line[1] / (sin(theta) - line[0] * cos(theta));
    return new Length(length);
  }

  static num _maxSafeChromaForL(num L) {
    List<List<num>> bounds = _getBounds(L);
    var minV = double.maxFinite;

    for (int i = 0; i < 2; ++i) {
      final m1 = bounds[i][0];
      final b1 = bounds[i][1];
      final line = [m1, b1];

      final x = _intersectLineLine(line, [-1 / m1, 0]);
      final length = _distanceFromPole([x, b1 + x * m1]);

      minV = min(minV, length);
    }

    return minV;
  }

  static num _maxChromaForLH(num L, num H) {
    final hrad = H / 360 * pi * 2;

    final bounds = _getBounds(L);
    var minV = double.maxFinite;

    for (final bound in bounds) {
      Length length = _lengthOfRayUntilIntersect(hrad, bound);
      if (length.greaterEqualZero) {
        minV = min(minV, length.length);
      }
    }

    return minV;
  }

  static num _dotProduct(List<num> a, List<num> b) {
    num sum = 0;
    for (int i = 0; i < a.length; ++i) {
      sum += a[i] * b[i];
    }
    return sum;
  }

  static num _round(num value, int places) {
    num n = pow(10, places);

    return (value * n).round() / n;
  }

  static num _fromLinear(num c) {
    if (c <= 0.0031308) {
      return 12.92 * c;
    } else {
      return 1.055 * pow(c, 1 / 2.4) - 0.055;
    }
  }

  static num _toLinear(num c) {
    if (c > 0.04045) {
      return pow((c + 0.055) / (1 + 0.055), 2.4);
    } else {
      return c / 12.92;
    }
  }

  static List<int> _rgbPrepare(List<num> tuple) {

    final results = List.filled(tuple.length, 0);

    for (int i = 0; i < tuple.length; ++i) {
      final chan = tuple[i];
      final rounded = _round(chan, 3);

      if (rounded < -0.0001 || rounded > 1.0001) {
        throw("Illegal rgb value: $rounded");
      }

      results[i] = (rounded * 255).round();
    }

    return results;
  }

  static List<num> xyzToRgb(List<num> tuple) =>
  [
    _fromLinear(_dotProduct(_m[0], tuple)),
    _fromLinear(_dotProduct(_m[1], tuple)),
    _fromLinear(_dotProduct(_m[2], tuple)),
  ];


  static List<num> rgbToXyz(List<num> tuple) {
    final rgbl =
    [
      _toLinear(tuple[0]),
      _toLinear(tuple[1]),
      _toLinear(tuple[2]),
    ];

    return
    [
      _dotProduct(_minv[0], rgbl),
      _dotProduct(_minv[1], rgbl),
      _dotProduct(_minv[2], rgbl),
    ];
  }

  static num _yToL(num Y) {
    if (Y <= _epsilon) {
      return (Y / _refY) * _kappa;
    } else {
      return 116 * pow(Y / _refY, 1.0 / 3.0) - 16;
    }
  }

  static num _lToY(num L) {
    if (L <= 8) {
      return _refY * L / _kappa;
    } else {
      return _refY * pow((L + 16) / 116, 3);
    }
  }

  static List<num> xyzToLuv(List<num> tuple) {
    final X = tuple[0];
    final Y = tuple[1];
    final Z = tuple[2];

    final varU = (4 * X) / (X + (15 * Y) + (3 * Z));
    final varV = (9 * Y) / (X + (15 * Y) + (3 * Z));

    final L = _yToL(Y);

    if (L == 0) {
      return [0, 0, 0];
    }

    final U = 13 * L * (varU - _refU);
    final V = 13 * L * (varV - _refV);

    return [L, U, V];
  }

  static List<num> luvToXyz(List<num> tuple) {
    final L = tuple[0];
    final U = tuple[1];
    final V = tuple[2];

    if (L == 0) {
      return [0, 0, 0];
    }

    final varU = U / (13 * L) + _refU;
    final varV = V / (13 * L) + _refV;

    final Y = _lToY(L);
    final X = 0 - (9 * Y * varU) / ((varU - 4) * varV - varU * varV);
    final Z = (9 * Y - (15 * varV * Y) - (varV * X)) / (3 * varV);

    return [X, Y, Z];
  }

  static List<num> luvToLch(List<num> tuple) {
    final L = tuple[0];
    final U = tuple[1];
    final V = tuple[2];

    final C = sqrt(U * U + V * V);
    var H;

    if (C < 0.00000001) {
      H = 0;
    } else {
      final Hrad = atan2(V, U);

      // pi to more digits than they provide it in the stdlib
      H = (Hrad * 180.0) / pi;

      if (H < 0) {
        H = 360 + H;
      }
    }

    return [L, C, H];
  }

  static List<num> lchToLuv(List<num> tuple) {
    final L = tuple[0];
    final C = tuple[1];
    final H = tuple[2];

    final Hrad = H / 360.0 * 2 * pi;
    final U = cos(Hrad) * C;
    final V = sin(Hrad) * C;

    return [L, U, V];
  }

  static List<num> hsluvToLch(List<num> tuple) {
    final H = tuple[0];
    final S = tuple[1];
    final L = tuple[2];

    if (L > 99.9999999) {
      return [100, 0, H];
    }

    if (L < 0.00000001) {
      return [0, 0, H];
    }

    final max = _maxChromaForLH(L, H);
    final C = max / 100 * S;

    return [L, C, H];
  }

  static List<num> lchToHsluv(List<num> tuple) {
    final L = tuple[0];
    final C = tuple[1];
    final H = tuple[2];

    if (L > 99.9999999) {
      return [H, 0, 100];
    }

    if (L < 0.00000001) {
      return [H, 0, 0];
    }

    final max = _maxChromaForLH(L, H);
    final S = C / max * 100;

    return [H, S, L];
  }

  static List<num> hpluvToLch(List<num> tuple) {
    final H = tuple[0];
    final S = tuple[1];
    final L = tuple[2];

    if (L > 99.9999999) {
      return [100, 0, H];
    }

    if (L < 0.00000001) {
      return [0, 0, H];
    }

    final max = _maxSafeChromaForL(L);
    final C = max / 100 * S;

  return [L, C, H];
  }

  static List<num> lchToHpluv(List<num> tuple) {
    final L = tuple[0];
    final C = tuple[1];
    final H = tuple[2];

    if (L > 99.9999999) {
      return [H, 0, 100];
    }

    if (L < 0.00000001) {
      return [H, 0, 0];
    }

    final max = _maxSafeChromaForL(L);
    final S = C / max * 100;

    return [H, S, L];
  }

  static String rgbToHex(List<num> tuple) {
    final prepared = _rgbPrepare(tuple);
    return "#${ths(prepared[0])}${ths(prepared[1])}${ths(prepared[2])}";
  }

  static String ths(num val) => val.toInt().toRadixString(16).padLeft(2, '0');

  static List<num> hexToRgb(String hex) =>
  [
    int.parse(hex.substring(1, 3), radix: 16) / 255.0,
    int.parse(hex.substring(3, 5), radix: 16) / 255.0,
    int.parse(hex.substring(5, 7), radix: 16) / 255.0,
  ];

  static List<num> lchToRgb(List<num> tuple) => xyzToRgb(luvToXyz(lchToLuv(tuple)));

  static List<num> rgbToLch(List<num> tuple) =>luvToLch(xyzToLuv(rgbToXyz(tuple)));

  // RGB <--> HUSL(p)

  static List<num> hsluvToRgb(List<num> tuple) =>lchToRgb(hsluvToLch(tuple));

  static List<num> rgbToHsluv(List<num> tuple) => lchToHsluv(rgbToLch(tuple));

  static List<num> hpluvToRgb(List<num> tuple) => lchToRgb(hpluvToLch(tuple));

  static List<num> rgbToHpluv(List<num> tuple) => lchToHpluv(rgbToLch(tuple));

  // Hex

  static String hsluvToHex(List<num> tuple) => rgbToHex(hsluvToRgb(tuple));

  static String hpluvToHex(List<num> tuple) => rgbToHex(hpluvToRgb(tuple));

  static List<num> hexToHsluv(String s) => rgbToHsluv(hexToRgb(s));

  static List<num> hexToHpluv(String s) => rgbToHpluv(hexToRgb(s));

}
