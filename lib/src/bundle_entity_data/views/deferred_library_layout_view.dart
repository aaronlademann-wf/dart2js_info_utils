part of wdesk.benchmark.dart2js_info.bundle_entity_data;

/// A typedef used by the [DeferredLibraryLayoutView.groupByPart] / [DeferredLibraryLayoutView.groupByPackage]
/// factory constructor [DeferredLibraryLayoutView.viewOutputGenerator] callback.
typedef Map<String, Map<String, dynamic>>
    DeferredLibraryLayoutViewOutputGenerator(List<DeferredPartData> parts);

class DeferredLibraryLayoutView {
  final String outFile;
  final String outVarName;
  final DeferredLibraryLayoutViewOutputGenerator viewOutputGenerator;
  final String dart2JsInfoOutputDir;
  final bool showLibraryMembers;
  final List<String> deferredUnitIds;

  DeferredLibraryLayoutView({
      @required String jsFileName,
      @required
      this.dart2JsInfoOutputDir,
      @required
      this.outFile,
      @required
      this.outVarName,
      @required
      this.viewOutputGenerator,
      this.showLibraryMembers: false,
      this.deferredUnitIds: const <String>[]
  }) {
    final dart2JsInfoDeferredLibLayoutOutFile = new File('${this.dart2JsInfoOutputDir}/$dart2JsInfoDeferredLibLayoutOutFileName');
    this._entitySizeMap = getEntitySizeMap(getEntitySizeListSrc(this.dart2JsInfoOutputDir));

    YamlMap deferredLibraryLayoutSrc = loadYaml(dart2JsInfoDeferredLibLayoutOutFile.readAsStringSync());

    this._parts = <DeferredPartData>[];

    deferredLibraryLayoutSrc.forEach((String key, YamlMap value) {
      var partName = key.replaceAll('Output unit ', '');

      var isNonDeferredPart = false;
      int.parse(partName, onError: (_) {
        isNonDeferredPart = true;
      });

      if (isNonDeferredPart) {
        partName = '00_$jsFileName';
      } else {
        final partNum = int.parse(partName);
        if (partNum < 10) {
          partName = '0$partNum';
        }
      }

      if (this.deferredUnitIds != null && this.deferredUnitIds.isNotEmpty) {
        if (!this.deferredUnitIds.contains(partName)) return;
      }

      YamlList loadedBy;
      YamlList contains;

      value.forEach((String key, YamlList value) {
        if (key.contains('loaded by')) {
          loadedBy = value;
        }

        if (key == 'contains') {
          contains = value;
        }
      });

      this._parts.add(new DeferredPartData(partName,
          dart2JsInfoOutputDir: this.dart2JsInfoOutputDir,
          entitySizeMap: this.entitySizeMap,
          loadedBy: loadedBy,
          contains: contains,
      ));
    });
  }

  /// In this view, the first layer of data in the [toFile]d map will be keyed by [PackageData.name],
  /// then by [DeferredPartData.name] in the second layer.
  factory DeferredLibraryLayoutView.groupByPackage({
      @required String jsFileName,
      @required String dart2JsInfoOutputDir,
      @required String dart2JsInfoUtilMapViewDataOutputDir,
      bool showLibraryMembers: false,
      List<String> deferredUnitIds: const <String>[]
  }) {
    return new DeferredLibraryLayoutView(
        jsFileName: jsFileName,
        dart2JsInfoOutputDir: dart2JsInfoOutputDir,
        outFile: '$dart2JsInfoUtilMapViewDataOutputDir/$dart2JsInfoUtilMapViewByPackageFile',
        outVarName: 'deferredLibraryLayoutByPackage',
        viewOutputGenerator: ((List<DeferredPartData> parts) =>
            _generateGroupByPackageViewData(parts, showLibraryMembers: showLibraryMembers)),
        showLibraryMembers: showLibraryMembers,
        deferredUnitIds: deferredUnitIds,
    );
  }

  /// In this view, the first layer of data in the [toFile]d map will be keyed by [DeferredPartData.name],
  /// then by [PackageData.name] in the second layer.
  factory DeferredLibraryLayoutView.groupByPart({
      @required String jsFileName,
      @required String dart2JsInfoOutputDir,
      @required String dart2JsInfoUtilMapViewDataOutputDir,
      bool showLibraryMembers: false,
      List<String> deferredUnitIds: const <String>[]
  }) {
    return new DeferredLibraryLayoutView(
        jsFileName: jsFileName,
        dart2JsInfoOutputDir: dart2JsInfoOutputDir,
        outFile: '$dart2JsInfoUtilMapViewDataOutputDir/$dart2JsInfoUtilMapViewByPartFile',
        outVarName: 'deferredLibraryLayoutByPart',
        viewOutputGenerator: ((List<DeferredPartData> parts) =>
            _generateGroupByPartViewData(parts, showLibraryMembers: showLibraryMembers)),
        showLibraryMembers: showLibraryMembers,
        deferredUnitIds: deferredUnitIds,
    );
  }

  Map<String/*entity name*/, int/*entity size (in bytes)*/> get entitySizeMap => _entitySizeMap;
  Map<String, int> _entitySizeMap;

  List<DeferredPartData> get parts => _parts;
  List<DeferredPartData> _parts;

  static SplayTreeMap<String/*[PackageData.name]*/, SplayTreeMap<String/*PackageData field names*/,
            dynamic/*PackageData field values*/>> _generateGroupByPackageViewData(List<DeferredPartData> parts,
                {bool showLibraryMembers: false}) {
    var viewMap = <String, Map<String, dynamic>>{};

    parts.forEach((DeferredPartData partData) {
      partData.packageData.forEach((packageName, packageData) {
        var groupedData = <String/*[DeferredPartData.name]*/, Map<String, dynamic>>{
          partData.name: packageData.toMap(showLibraryMembers: showLibraryMembers)
        };

        if (viewMap[packageName] == null) {
          print('${packageData.name}: ${packageData.entitySizeMap[packageData.name]}');

          viewMap[packageName] = {
            'name': packageData.name,
            'size': packageData.entitySizeMap[packageData.name] ?? 0,
            'parts': new SplayTreeMap.from(groupedData),
          };
        } else {
          viewMap[packageName]['name'] = packageData.name;
          (viewMap[packageName]['parts'] as SplayTreeMap).addAll(groupedData); // ignore: avoid_as
        }
      });
    });

    return new SplayTreeMap.from(viewMap);
  }

  static SplayTreeMap<String/*[DeferredPartData.name]*/,
        SplayTreeMap<String/*DeferredPartData field names*/,
            dynamic/*DeferredPartData field values*/>> _generateGroupByPartViewData(List<DeferredPartData> parts,
                {bool showLibraryMembers: false}) {
    var viewMap = <String, Map<String, dynamic>>{};

    parts.forEach((DeferredPartData partData) {
      viewMap[partData.name] = new SplayTreeMap.from(partData.toMap(showLibraryMembers: showLibraryMembers));
    });

    return new SplayTreeMap.from(viewMap);
  }

  Map<String, Map<String, dynamic>> _mapCache = {};

  Map<String, Map<String, dynamic>> toMap() {
    if (_mapCache.isEmpty) {
      _mapCache = this.viewOutputGenerator(this.parts);
    }

    return _mapCache;
  }

  String toJSON() => JSON.encode(toMap());

  @override
  String toString() => toJSON();

  void toFile() {
    var file = new File(this.outFile);

    if (!file.existsSync()) {
      file.createSync(recursive: true);
    }

    file.writeAsStringSync('var ${this.outVarName} = ${this.toJSON()};');
  }
}

/// Provides a typed view for a `Map` generated by
/// [DeferredLibraryLayoutView.groupByPackage] or [DeferredLibraryLayoutView.groupByPart].
abstract class DeferredLibraryLayoutMapView extends MapView {
  DeferredLibraryLayoutMapView(Map map) : super(map);

  Map<String, DataEntityMapView> sortedBySize({bool ascending: false});
}

/// Map view shared between [DeferredPartDataMapView], [PackagePartsMapView] and [PackageDataMapView].
abstract class DataEntityMapView extends DeferredLibraryLayoutMapView {
  DataEntityMapView(Map map) : super(map);

  String get name;
  int get size;
}

/// Provides a typed view for a `Map` generated by [DeferredLibraryLayoutView.groupByPackage].
///
/// Useful when you want information about [PackageData] / [PackageLibData]
/// no matter which [DeferredPartData] instance they are found within.
class DeferredLibraryLayoutByPackageMapView extends DeferredLibraryLayoutMapView {
  DeferredLibraryLayoutByPackageMapView(Map map) : super(map);

  Map<String, PackagePartsMapView> get packages {
    final rawPackageData = this;
    Map<String, PackagePartsMapView> tPackageData = {};

    rawPackageData.forEach((packageName, packagePartDataMap) {
      tPackageData[packageName] = new PackagePartsMapView(packagePartDataMap);
    });

    return tPackageData;
  }

  @override
  Map<String, PackagePartsMapView> sortedBySize({bool ascending: false}) {
    var sortedList = new List<PackagePartsMapView>.from(this.packages.values);

    if (ascending) {
      sortedList.sort((a, b) => a.size.compareTo(b.size));
    } else {
      sortedList.sort((a, b) => b.size.compareTo(a.size));
    }

    Map<String, PackagePartsMapView> tPackageData = {};

    sortedList.forEach((packageDataMap) {
      tPackageData[packageDataMap.name] = packageDataMap;
    });

    return tPackageData;
  }
}

/// A map view for a single package within [DeferredLibraryLayoutByPackageMapView.packages].
class PackagePartsMapView extends DataEntityMapView {
  PackagePartsMapView(Map map) : super(map);

  @override
  String get name => this['name'];

  /// The aggregate size of this package, spread across all [parts].
  @override
  int get size => this['size'];

  /// A map keyed by the names of the [DeferredPartData] instances that the package is found within.
  Map<String, PackageDataMapView> get parts {
    Map<String, Map<String, dynamic>> rawPackagePartsData = this['parts'];
    Map<String, PackageDataMapView> tPackagePartsData = {};

    rawPackagePartsData.forEach((partName, packageDataMap) {
      tPackagePartsData[partName] = new PackageDataMapView(packageDataMap);
    });

    return tPackagePartsData;
  }

  @override
  Map<String, PackageDataMapView> sortedBySize({bool ascending: false}) {
    var sortedList = new List<PackageDataMapView>.from(this.parts.values);

    if (ascending) {
      sortedList.sort((a, b) => a.size.compareTo(b.size));
    } else {
      sortedList.sort((a, b) => b.size.compareTo(a.size));
    }

    Map<String, PackageDataMapView> tPackagePartsData = {};

    sortedList.forEach((packageDataMap) {
      tPackagePartsData[packageDataMap.deferredPartName] = packageDataMap;
    });

    return tPackagePartsData;
  }
}

/// Provides a typed view for a `Map` generated by [DeferredLibraryLayoutView.groupByPart].
///
/// Useful when you want information about [DeferredPartData], or about individual [PackageData] / [PackageLibData]
/// that are found within that part.
class DeferredLibraryLayoutByPartMapView extends DeferredLibraryLayoutMapView {
  DeferredLibraryLayoutByPartMapView(Map map) : super(map);

  Map<String, DeferredPartDataMapView> get parts {
    final rawDeferredPartData = this;
    Map<String, DeferredPartDataMapView> tDeferredPartData = {};

    rawDeferredPartData.forEach((partName, partDataMap) {
      tDeferredPartData[partName] = new DeferredPartDataMapView(partDataMap);
    });

    return tDeferredPartData;
  }

  @override
  Map<String, DeferredPartDataMapView> sortedBySize({bool ascending: false}) {
    var sortedList = new List<DeferredPartDataMapView>.from(this.parts.values);

    if (ascending) {
      sortedList.sort((a, b) => a.size.compareTo(b.size));
    } else {
      sortedList.sort((a, b) => b.size.compareTo(a.size));
    }

    Map<String, DeferredPartDataMapView> tDeferredPartData = {};

    sortedList.forEach((partDataMap) {
      tDeferredPartData[partDataMap.name] = partDataMap;
    });

    return tDeferredPartData;
  }
}
