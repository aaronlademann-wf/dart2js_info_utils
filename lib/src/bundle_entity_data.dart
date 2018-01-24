/// A library of classes and utilities used to parse and make use of the raw data that
/// the `dart2js_info` package produces when analyzing the unified wdesk "bundle"
/// (`build/web/main.dart.js`).
library wdesk.benchmark.dart2js_info.bundle_entity_data;

import 'dart:collection';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:meta/meta.dart';
import 'package:source_span/source_span.dart';
import 'package:yaml/yaml.dart';

part 'package:dart2js_info_utils/src/bundle_entity_data/abstract_entity_data.dart';
part 'package:dart2js_info_utils/src/bundle_entity_data/deferred_part_data.dart';
part 'package:dart2js_info_utils/src/bundle_entity_data/package_data.dart';
part 'package:dart2js_info_utils/src/bundle_entity_data/package_lib_data.dart';
part 'package:dart2js_info_utils/src/bundle_entity_data/views/deferred_library_layout_view.dart';

const String dart2jsInfoPath = './benchmark/dart2js_info';
const String dart2jsInfoOutputPath = '$dart2jsInfoPath/data';
const String dart2jsInfoParsedOutputDirName = 'parsed';
const String dart2jsInfoParsedOutputPath = '$dart2jsInfoOutputPath/$dart2jsInfoParsedOutputDirName';
const String deferredLibraryLayoutFileName = 'deferred_library_layout.yaml';
const String deferredLibraryLayoutOutput = '$dart2jsInfoOutputPath/$deferredLibraryLayoutFileName';
const String librarySizeSplitFileName = 'library_size_split.txt';
const String librarySizeSplitOutput = '$dart2jsInfoOutputPath/$librarySizeSplitFileName';

const String packageNameRegExPattern = r'(?:package:)(\w(\w|\d)*)(?=\/)(.*)(?:\.dart)';
const String looseFileRegExPattern = r'^(?:\s*file:\/\/\/)*((?!\s*package:|\s*dart:).*)(?:\.dart)';
const String dartLibNameRegExPattern = r'dart:\w(\w|\d)*';
const String dartLibNameAndSizeRegExPattern = r'(dart:\w(\w|\d)*)(?:\s+)(\d+)';
const String libraryNameAndSizeRegExPattern = r'(?:package:)(\w(\w|\d)*)(?=\/)(.*)(?:\.dart\s+)(\d+)';
const String packageSizeRegExPattern = r'^\s*(\w+)(?:\s+)(\d+)';

Map<String/*package library name*/, int/*size (in bytes)*/> packageLibrarySizeInfo = {};
Map<String/*package package name*/, int/*size (in bytes)*/> packageSizeInfo = {};
List<String> librarySizeSplitOutputSrc;

void setPackageLibrarySizeInfo({String librarySizeSplitOutput: librarySizeSplitOutput}) {
  var sizeInfoSrc = librarySizeSplitOutputSrc ?? new File(librarySizeSplitOutput).readAsLinesSync();

  sizeInfoSrc.forEach((line) {
    var libraryName = getPackageLibraryNameFromSrc(line);

    if (libraryName.isNotEmpty) {
      packageLibrarySizeInfo[libraryName] = getPackageLibrarySizeInBytesFromSrc(line);
    }
  });
}

String getPackageNameFromSrc(SourceSpan span) {
  final spanStr = span.text;
  Match packageMatch = new RegExp(packageNameRegExPattern).firstMatch(spanStr);
  Match looseFileMatch = new RegExp(looseFileRegExPattern).firstMatch(spanStr);
  Match dartLibMatch = new RegExp(dartLibNameRegExPattern).firstMatch(spanStr);

  if (packageMatch ?? looseFileMatch ?? dartLibMatch == null) {
    throw new ArgumentError('''The `SourceSpan` provided did not contain a dart package, dart core library, or `file:///` name:
      $spanStr
    ''');
  }

  if (packageMatch != null) {
    return packageMatch.group(1);
  } else if (looseFileMatch != null) {
    return looseFileMatch.group(1);
  } else {
    return dartLibMatch.group(0);
  }
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

int getPackageSizeInBytesFromSrc(String packageName) {
  var sizeInfoSrc = librarySizeSplitOutputSrc ?? new File(librarySizeSplitOutput).readAsLinesSync();

  if (packageSizeInfo.isEmpty) {
    sizeInfoSrc.forEach((line) {
      Match packageMatch = new RegExp(packageSizeRegExPattern).firstMatch(line);

      if (packageMatch != null) {
        var _packageName = packageMatch.group(1);

        if (_packageName.isNotEmpty) {
          var packageSize = int.parse(packageMatch.group(2));

          if (packageSize > 0) {
            packageSizeInfo[_packageName] = packageSize;
          }
        }
      }
    });
  }

  return packageSizeInfo[packageName] ?? 0;
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
  var percentageText = '(${((partPackageSize / totalPackageSize) * 100).toStringAsFixed(2)}%)';
  var longestPossibleText = '(100.00%)';

  if (percentageText.length < longestPossibleText.length) {
    percentageText = '\u00a0' * (longestPossibleText.length - percentageText.length) + percentageText;
  }

  return percentageText;
}
