part of wdesk.benchmark.dart2js_info.bundle_entity_data;

/// Represents a single `main.dart.js` "part".
class DeferredPartData extends BundleEntityData {
  final YamlList loadedBy;
  final YamlList contains;

  DeferredPartData(String name, {
      @required
      String dart2JsInfoOutputDir,
      @required
      this.loadedBy,
      @required
      this.contains,
      Map<String, int> entitySizeMap,
      Map<String, PackageData> packageData,
      int size,
  }) : super(name, dart2JsInfoOutputDir: dart2JsInfoOutputDir, entitySizeMap: entitySizeMap) {
    this._size = size ?? 0;
    this._packageData = new SplayTreeMap<String, PackageData>.from(packageData ?? <String, PackageData>{});

    if (this.packageData.isEmpty) {
      this.contains.nodes.forEach((YamlNode node) {
        final packageLibData = new PackageLibData.fromNode(this, node,
            dart2JsInfoOutputDir: dart2JsInfoOutputDir,
            entitySizeMap: this.entitySizeMap,
        );

        if (this._packageData.containsKey(packageLibData.packageName)) {
          this._packageData[packageLibData.packageName].add(packageLibData);
        } else {
          this._packageData[packageLibData.packageName] =
              new PackageData(packageLibData.packageName,
                  dart2JsInfoOutputDir: dart2JsInfoOutputDir,
                  entitySizeMap: this.entitySizeMap,
                  packageLibData: [packageLibData],
                  deferredPartName: this.name
              );
        }
      });
    }

    if (this.packageData.isNotEmpty) {
      this.packageData.forEach((packageName, packageData) {
        this._size += packageData.size;
      });
    }
  }

  factory DeferredPartData.fromJSON(String serializedData) {
    Map<String, dynamic> deSerializedData = json.decode(serializedData);
    return new DeferredPartData(deSerializedData['name'],
        dart2JsInfoOutputDir: deSerializedData['dart2JsInfoOutputDir'],
        loadedBy: deSerializedData['loadedBy'],
        contains: deSerializedData['contains'],
        packageData: generatePackageDataFromDeSerializedData(deSerializedData['packageData']),
        size: deSerializedData['size'],
    );
  }

  SplayTreeMap<String, PackageData> get packageData => _packageData;
  SplayTreeMap<String, PackageData> _packageData;

  Map<String, dynamic> getSerializablePackageData({bool serialize: true, bool showLibraryMembers: false}) {
    var serializableData = <String, dynamic>{};
    this.packageData.forEach((packageName, packageData) {
      serializableData[packageName] = serialize
          ? packageData.toJSON(showLibraryMembers: showLibraryMembers)
          : packageData.toMap(showLibraryMembers: showLibraryMembers);
    });

    return serializableData;
  }

  static Map<String, PackageData> generatePackageDataFromDeSerializedData(Map<String, dynamic> deSerializedData) {
    var packageData = <String, PackageData>{};
    deSerializedData.forEach((packageName, deSerializedPackageData) {
      packageData[packageName] = new PackageData.fromJSON(deSerializedPackageData);
    });

    return packageData;
  }

  /// Use [DeferredPartDataMapView] for typed access.
  @override
  Map<String, dynamic> toMap({bool showLibraryMembers: false}) => {
    'name': name,
    'dart2JsInfoOutputDir': dart2JsInfoOutputDir,
    'loadedBy': loadedBy,
    'size': size,
//    'contains': contains,
    'packageData': getSerializablePackageData(serialize: false, showLibraryMembers: showLibraryMembers),
  };

  @override
  String toJSON({bool showLibraryMembers: false}) => json.encode({
    'name': name,
    'dart2JsInfoOutputDir': dart2JsInfoOutputDir,
    'loadedBy': loadedBy,
    'size': size,
//    'contains': contains,
    'packageData': getSerializablePackageData(showLibraryMembers: showLibraryMembers),
  });
}

class DeferredPartDataMapView extends DataEntityMapView<PackageDataMapView> {
  DeferredPartDataMapView(Map map) : super(map);

  @override
  String get name => this['name'];
  List<String> get loadedBy => this['loadedBy'];
  @override
  int get size => this['size'];

  Map<String, PackageDataMapView> get packages {
    Map<String, Map<String, dynamic>> rawPackageData = this['packageData'];
    Map<String, PackageDataMapView> tPackageData = {};

    rawPackageData.forEach((packageName, packageDataMap) {
      tPackageData[packageName] = new PackageDataMapView(packageDataMap);
    });

    return tPackageData;
  }

  @override
  Map<String, PackageDataMapView> sortedBySize({bool ascending: false}) {
    var sortedList = new List<PackageDataMapView>.from(this.packages.values);

    if (ascending) {
      sortedList.sort((a, b) => a.size.compareTo(b.size));
    } else {
      sortedList.sort((a, b) => b.size.compareTo(a.size));
    }

    Map<String, PackageDataMapView> tPackageData = {};

    sortedList.forEach((packageDataMap) {
      tPackageData[packageDataMap.name] = packageDataMap;
    });

    return tPackageData;
  }
}
