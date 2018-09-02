import 'dart:math';
import 'dart:io';
import 'dart:convert';

import 'package:bismuth/hsluv/hsluv.dart';
import 'package:flutter_test/flutter_test.dart';


final num MAXDIFF = 0.0000000001;
final num MAXRELDIFF = 0.000000001;

/**
 * modified from
 * https://randomascii.wordpress.com/2012/02/25/comparing-floating-point-numbers-2012-edition/
 */
bool assertAlmostEqualRelativeAndAbs(num a, num b) {
  // Check if the numbers are really close -- needed
  // when comparing numbers near zero.
  num diff = (a - b).abs();
  if (diff <= MAXDIFF) {
    return true;
  }

  a = a.abs();
  b = b.abs();
  num largest = (b > a) ? b : a;

  return diff <= largest * MAXRELDIFF;
}

void assertTuplesClose(String label, List<num> expected, List<num> actual) {
  bool mismatch = false;
  List<num> deltas = List.filled(expected.length, 0);

  for (int i = 0; i < expected.length; ++i) {
    deltas[i] = (expected[i] - actual[i]).abs();
    if (!assertAlmostEqualRelativeAndAbs(expected[i], actual[i])) {
      mismatch = true;
    }
  }
  if (mismatch) {
    print("MISMATCH $label\n");
    print(" expected: ${expected[0].toStringAsPrecision(10)},${expected[1].toStringAsPrecision(10)},${expected[2].toStringAsPrecision(10)}\n");
    print("   actual: ${actual[0].toStringAsPrecision(10)},${actual[1].toStringAsPrecision(10)},${actual[2].toStringAsPrecision(10)}\n");
    print("   deltas: ${deltas[0].toStringAsPrecision(10)},${deltas[1].toStringAsPrecision(10)},${deltas[2].toStringAsPrecision(10)}\n");
  }
  expect(mismatch, false);
}

List<num> tupleFromJsonArray(List<dynamic> arr) => [
  arr[0] as num,
  arr[1] as num,
  arr[2] as num,
];

void main() {

  test("Hsluv", () async {
    print("Running test");
    File testFile = new File("test/hsluv/tests.json");

    final contents = await testFile.readAsString();
    final tests = jsonDecode(contents) as Map<String, dynamic>;

    tests.forEach((hex, data) {
      final expected = data as Map<String, dynamic>;
      final rgb = tupleFromJsonArray(expected["rgb"]);
      final xyz = tupleFromJsonArray(expected["xyz"]);
      final luv = tupleFromJsonArray(expected["luv"]);
      final lch = tupleFromJsonArray(expected["lch"]);
      final hsluv = tupleFromJsonArray(expected["hsluv"]);
      final hpluv = tupleFromJsonArray(expected["hpluv"]);

      print("testing $hex");

      // forward functions

      final rgbFromHex = HUSLColorConverter.hexToRgb(hex);
      final xyzFromRgb = HUSLColorConverter.rgbToXyz(rgbFromHex);
      final luvFromXyz = HUSLColorConverter.xyzToLuv(xyzFromRgb);
      final lchFromLuv = HUSLColorConverter.luvToLch(luvFromXyz);
      final hsluvFromLch = HUSLColorConverter.lchToHsluv(lchFromLuv);
      final hpluvFromLch = HUSLColorConverter.lchToHpluv(lchFromLuv);
      final hsluvFromHex = HUSLColorConverter.hexToHsluv(hex);
      final hpluvFromHex = HUSLColorConverter.hexToHpluv(hex);

      assertTuplesClose("hexToRgb", rgb, rgbFromHex);
      assertTuplesClose("rgbToXyz", xyz, xyzFromRgb);
      assertTuplesClose("xyzToLuv", luv, luvFromXyz);
      assertTuplesClose("luvToLch", lch, lchFromLuv);
      assertTuplesClose("lchToHsluv", hsluv, hsluvFromLch);
      assertTuplesClose("lchToHpluv", hpluv, hpluvFromLch);
      assertTuplesClose("hexToHsluv", hsluv, hsluvFromHex);
      assertTuplesClose("hexToHpluv", hpluv, hpluvFromHex);

      // backward functions

      final lchFromHsluv = HUSLColorConverter.hsluvToLch(hsluv);
      final lchFromHpluv = HUSLColorConverter.hpluvToLch(hpluv);
      final luvFromLch = HUSLColorConverter.lchToLuv(lch);
      final xyzFromLuv = HUSLColorConverter.luvToXyz(luv);
      final rgbFromXyz = HUSLColorConverter.xyzToRgb(xyz);
      final hexFromRgb = HUSLColorConverter.rgbToHex(rgb);
      final hexFromHsluv = HUSLColorConverter.hsluvToHex(hsluv);
      final hexFromHpluv = HUSLColorConverter.hpluvToHex(hpluv);

      assertTuplesClose("hsluvToLch", lch, lchFromHsluv);
      assertTuplesClose("hpluvToLch", lch, lchFromHpluv);
      assertTuplesClose("lchToLuv", luv, luvFromLch);
      assertTuplesClose("luvToXyz", xyz, xyzFromLuv);
      assertTuplesClose("xyzToRgb", rgb, rgbFromXyz);
      expect(hex, hexFromRgb);
      expect(hex, hexFromHsluv);
      expect(hex, hexFromHpluv);
    });
  });
}
