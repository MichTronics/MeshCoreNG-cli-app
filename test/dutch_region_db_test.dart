import 'package:flutter_test/flutter_test.dart';
import 'package:meshcli_ng/core/regions/dutch_region_db.dart';

void main() {
  test('Dutch region database exposes expected metadata', () {
    expect(DutchRegionDb.entryCount, 2484);
    expect(DutchRegionDb.provinceCount, 12);
    expect(DutchRegionDb.info(), contains('2484 locations'));
    expect(DutchRegionDb.provinces(), contains('Noord-Holland (nh) nl-nh'));
  });

  test('Dutch region database finds locations by prefix', () {
    final result = DutchRegionDb.find('bovenkarspel');
    expect(result, contains('nl-nh-bov'));
    expect(result, contains('Bovenkarspel'));
  });

  test('Dutch region database handles CLI commands locally', () {
    expect(DutchRegionDb.handleCommand('regiondb find alkmaar'),
        contains('nl-nh-alk'));
    expect(DutchRegionDb.handleCommand('regiondb get 1500'),
        contains('Bovenkarspel'));
    expect(DutchRegionDb.handleCommand('regiondb code nl-nh-bov'),
        contains('Bovenkarspel'));
  });
}
