part of wdesk.benchmark.dart2js_info.bundle_entity_data;

/// Aggregates all [PackageLibData] instances that share a [PackageLibData.packageName] value into a
/// single entity that represents a standalone top-level dart package found within an instance of [DeferredPartData].
class PackageData extends BundleEntityData {
  PackageData(String name, {
      @required
      String dart2JsInfoOutputDir,
      Map<String, int> entitySizeMap,
      List<PackageLibData> packageLibData = const [],
      int size,
      String deferredPartName,
  }) : super(name, dart2JsInfoOutputDir: dart2JsInfoOutputDir, entitySizeMap: entitySizeMap) {
    this._size = size ?? 0;
    this._deferredPartName = deferredPartName ?? '';

    this._packageLibData = new SplayTreeMap<String, PackageLibData>();

    if (packageLibData.isNotEmpty) {
      packageLibData.forEach((data) {
        this._packageLibData[data.name] = data;
      });
    }

    if (this.packageLibData.isNotEmpty) {
      this.packageLibData.forEach((libraryName, libraryData) {
        this._size += libraryData.size;
      });
    }
  }

  factory PackageData.fromJSON(Object serializedData) {
    Map<String, dynamic> deSerializedData;

    if (serializedData is String) {
      deSerializedData = JSON.decode(serializedData);
    } else {
      deSerializedData = serializedData;
    }

    return new PackageData(deSerializedData['name'],
        dart2JsInfoOutputDir: deSerializedData['dart2JsInfoOutputDir'],
        packageLibData: generatePackageLibDataFromDeSerializedData(deSerializedData['packageLibData']),
        size: deSerializedData['size'],
        deferredPartName: deSerializedData['deferredPartName'],
    );
  }

  String get deferredPartName => _deferredPartName;
  String _deferredPartName;

  SplayTreeMap<String, PackageLibData> get packageLibData => _packageLibData;
  SplayTreeMap<String, PackageLibData> _packageLibData;

  void add(PackageLibData packageLibData) {
    if (packageLibData.packageName != this.name) {
      throw new ArgumentError('''
          ${packageLibData.name} cannot be added to the `PackageData` for `package:${this.name}` 
          because it is not part of that package.
      ''');
    }

    if (this._packageLibData[packageLibData.name] != null) {
      throw new ArgumentError('''
          ${packageLibData.name} has already been added to ${this.name}.
      ''');
    }

    _size += packageLibData.size;
    this._packageLibData[packageLibData.name] = packageLibData;
  }

  void addAll(List<PackageLibData> packageLibs) => packageLibs.forEach(add);

  Map<String, dynamic> getSerializablePackageLibData({bool serialize: true, bool showLibraryMembers: false}) {
    var serializableData = <String, String>{};
    this.packageLibData.forEach((libraryName, packageLibData) {
      if (libraryName.isNotEmpty) {
        serializableData[libraryName] = serialize
            ? packageLibData.toJSON(showLibraryMembers: showLibraryMembers)
            : packageLibData.toMap(showLibraryMembers: showLibraryMembers);
      }
    });

    return serializableData;
  }

  static List<PackageLibData> generatePackageLibDataFromDeSerializedData(Map<String, dynamic> deSerializedData) {
    var packageLibData = <PackageLibData>[];
    deSerializedData.forEach((libraryName, deSerializedLibraryData) {
      packageLibData.add(new PackageLibData.fromJSON(deSerializedLibraryData));
    });

    return packageLibData;
  }

  @override
  Map<String, dynamic> toMap({bool showLibraryMembers: false}) => {
    'name': name,
    'dart2JsInfoOutputDir': dart2JsInfoOutputDir,
    'size': size,
    'deferredPartName': deferredPartName,
    'packageLibData': getSerializablePackageLibData(serialize: false, showLibraryMembers: showLibraryMembers),
  };

  @override
  String toJSON({bool showLibraryMembers: false}) => JSON.encode({
    'name': name,
    'dart2JsInfoOutputDir': dart2JsInfoOutputDir,
    'size': size,
    'deferredPartName': deferredPartName,
    'packageLibData': getSerializablePackageLibData(showLibraryMembers: showLibraryMembers),
  });
}

class PackageDataMapView extends DataEntityMapView {
  PackageDataMapView(Map map) : super(map);

  @override
  String get name => this['name'];
  @override
  int get size => this['size'];

  String get deferredPartName => this['deferredPartName'];

  Map<String, PackageLibDataMapView> get libraries {
    Map<String, Map<String, dynamic>> rawPackageLibData = this['packageLibData'];
    Map<String, PackageLibDataMapView> tPackageLibData = {};

    rawPackageLibData.forEach((packageLibName, packageLibDataMap) {
      tPackageLibData[packageLibName] = new PackageLibDataMapView(packageLibDataMap);
    });

    return tPackageLibData;
  }

  @override
  Map<String, PackageLibDataMapView> sortedBySize({bool ascending: false}) {
    var sortedList = new List<PackageLibDataMapView>.from(this.libraries.values);

    if (ascending) {
      sortedList.sort((a, b) => a.size.compareTo(b.size));
    } else {
      sortedList.sort((a, b) => b.size.compareTo(a.size));
    }

    Map<String, PackageLibDataMapView> tPackageLibData = {};

    sortedList.forEach((packageLibDataMap) {
      tPackageLibData[packageLibDataMap.name] = packageLibDataMap;
    });

    return tPackageLibData;
  }
}
