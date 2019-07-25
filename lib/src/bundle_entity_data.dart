/// A library of classes and utilities used to parse and make use of the raw data that
/// the `dart2js_info` package produces when analyzing the unified wdesk "bundle"
/// (`build/web/main.dart.js`).
library wdesk.benchmark.dart2js_info.bundle_entity_data;

import 'dart:collection';
import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:yaml/yaml.dart';

part 'package:dart2js_info_utils/src/bundle_entity_data/abstract_entity_data.dart';
part 'package:dart2js_info_utils/src/bundle_entity_data/deferred_part_data.dart';
part 'package:dart2js_info_utils/src/bundle_entity_data/package_data.dart';
part 'package:dart2js_info_utils/src/bundle_entity_data/package_lib_data.dart';
part 'package:dart2js_info_utils/src/bundle_entity_data/views/deferred_library_layout_view.dart';

const String dart2JsInfoDeferredLibLayoutOutFileName = 'deferred_library_layout.yaml';
const String dart2JsInfoLibSizeSplitOutFileName = 'library_size_split.txt';

const String dart2JsInfoUtilMapViewByPackageFile = 'deferred_library_layout__by_package.dart';
const String dart2JsInfoUtilMapViewByPartFile = 'deferred_library_layout__by_part.dart';

const String dart2jsInfoPath = './benchmark/dart2js_info';
const String dart2JsInfoOutputSubDir = 'lib/src/data';
const String dart2JsInfoUtilMapViewDataOutputSubDir = 'mapped';

const String packageNameRegExPattern = r'(?:package:)(\w(\w|\d)*)(?=\/)(.*)(?:\.dart)';
const String looseFileRegExPattern = r'^(?:\s*file:\/\/\/)*((?!\s*package:|\s*dart:).*)(?:\.dart)';
const String dartLibNameRegExPattern = r'dart:\w(\w|\d)*';
const String dartLibNameAndSizeRegExPattern = r'(dart:\w(\w|\d)*)(?:\s+)(\d+)';
const String libraryNameAndSizeRegExPattern = r'(?:package:)(\w(\w|\d)*)(?=\/)(.*)(?:\.dart\s+)(\d+)';
const String packageSizeRegExPattern = r'^\s*(\w+)(?:\s+)(\d+)';

Map<String/*entity name*/, int/*size (in bytes)*/> entitySizeInfo = {};
Map<String/*package package name*/, int/*size (in bytes)*/> packageSizeInfo = {};

/// `dart:<dart_lib>`
String getDartLibraryNameFromSrc(String str) => new RegExp(dartLibNameRegExPattern).firstMatch(str)?.group(0) ?? null;

/// `file:///` or `web/<some_dart_file>.dart`
String getLooseFilePackageNameFromSrc(String str) => new RegExp(looseFileRegExPattern).firstMatch(str)?.group(1) ?? null;

/// `package:<package_name>`
String getPackageNameFromSrc(String str) => new RegExp(packageNameRegExPattern).firstMatch(str)?.group(1) ?? null;

String getAnyPackageNameFromSrc(String str) {
  final name = getPackageNameFromSrc(str) ?? getLooseFilePackageNameFromSrc(str) ?? getDartLibraryNameFromSrc(str);

  if (name == null) {
    throw new ArgumentError('''The string provided did not contain a dart package, dart core library, or `file:///` name:
      $str
    ''');
  }

  return name;
}

String getPackageLibraryNameFromSrc(String str) {
  Match packageMatch = new RegExp(packageNameRegExPattern).firstMatch(str);
  Match dartLibMatch = new RegExp(dartLibNameRegExPattern).firstMatch(str);

  if (packageMatch != null) {
    return '${packageMatch.group(3)}.dart'.substring(1);
  } else if (dartLibMatch != null) {
    return dartLibMatch.group(0);
  } else {
    return '';
  }
}

int getPackageLibrarySizeInBytesFromSrc(String str) {
  Match packageMatch = new RegExp(libraryNameAndSizeRegExPattern).firstMatch(str);
  Match dartLibMatch = new RegExp(dartLibNameAndSizeRegExPattern).firstMatch(str);

  if (packageMatch != null) {
    return int.parse(packageMatch.group(4));
  } else if (dartLibMatch != null) {
    return int.parse(dartLibMatch.group(3));
  } else {
    return 0;
  }
}

int getDartLibrarySizeInBytesFromSrc(String str) {
  Match packageMatch = new RegExp(dartLibNameAndSizeRegExPattern).firstMatch(str);

  if (packageMatch == null) {
    return 0;
  }

  return int.parse(packageMatch.group(3));
}

Map<String/*entity name*/, int/*size (in bytes)*/> getEntitySizeMap(List<String> entitySizeListSrc) {
  var entitySizeMap = <String, int>{};

  entitySizeListSrc.forEach((line) {
    final looseFileName = getLooseFilePackageNameFromSrc(line);
    final libraryName = getPackageLibraryNameFromSrc(line);
    final dartLibraryName = getDartLibraryNameFromSrc(line);
    final packageMatch = new RegExp(packageSizeRegExPattern).firstMatch(line);

    if (packageMatch != null) {
      final packageName = packageMatch.group(1);
      final packageSize = int.parse(packageMatch.group(2));

      entitySizeMap[packageName] = packageSize;
    } else if (dartLibraryName != null) {
      entitySizeMap[libraryName] = getDartLibrarySizeInBytesFromSrc(line) ?? 0;
    } else if (libraryName != null) {
      entitySizeMap[libraryName] = getPackageLibrarySizeInBytesFromSrc(line) ?? 0;
    } else if (looseFileName != null) {
      // TODO
      entitySizeMap[looseFileName] = 0;
    }
  });

  return entitySizeMap;
}

const int aKilobyte = 1024;
const int aMegabyte = aKilobyte * 1024;

String getSizeWithUnitLabel(int sizeInBytes) {
  if (sizeInBytes >= aKilobyte) {
    if (sizeInBytes >= aMegabyte) {
      return '${(sizeInBytes / aMegabyte).toStringAsFixed(2)} mb';
    }

    return '${(sizeInBytes / aKilobyte).toStringAsFixed(2)} kb';
  }

  return '${sizeInBytes} b';
}

String getPercentageOfTotalSizeWithLabel(int partPackageSize, int totalPackageSize) {
  // Fix for dart:<*> libraries that are technically not "packages"
  if (partPackageSize > totalPackageSize && totalPackageSize == 0) {
    totalPackageSize = partPackageSize;
  }

  final percentage = ((partPackageSize / totalPackageSize) * 100).toStringAsFixed(2);

  var percentageText = '($percentage%)';
  var longestPossibleText = '(100.00%)';

  if (percentageText.length < longestPossibleText.length) {
    percentageText = '\u00a0' * (longestPossibleText.length - percentageText.length) + percentageText;
  }

  return percentageText;
}
