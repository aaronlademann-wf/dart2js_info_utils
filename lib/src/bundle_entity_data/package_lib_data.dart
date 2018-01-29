part of wdesk.benchmark.dart2js_info.bundle_entity_data;

/// Represents a single `package:<package_name>` or `dart:<core_lib_name>` entry found
/// within an instance of [PackageData].
class PackageLibData extends BundleEntityData {
  final String deferredPartName;
  final String packageName;
  final List<String> members;

  PackageLibData(String name, {
      @required
      String dart2JsInfoOutputDir,
      @required
      this.packageName,
      @required
      this.deferredPartName,
      Map<String, int> entitySizeMap,
      this.members: const <String>[],
      YamlNode node,
      int size,
  }) : super(name, dart2JsInfoOutputDir: dart2JsInfoOutputDir, entitySizeMap: entitySizeMap) {
    _node = node;

    _size = size ?? this.entitySizeMap[this.name] ?? 0;
  }

  factory PackageLibData.fromNode(DeferredPartData deferredPartData, YamlNode node, {
      @required String dart2JsInfoOutputDir,
      Map<String, int> entitySizeMap,
  }) {
    return new PackageLibData(getPackageLibraryNameFromSrc(node.span.toString()),
        dart2JsInfoOutputDir: dart2JsInfoOutputDir,
        entitySizeMap: entitySizeMap,
        packageName: getAnyPackageNameFromSrc(node.span.text),
        deferredPartName: deferredPartData.name,
        members: getMemberNames(node),
        node: node,
    );
  }

  factory PackageLibData.fromJSON(Object serializedData) {
    Map<String, dynamic> deSerializedData;

    if (serializedData is String) {
      deSerializedData = JSON.decode(serializedData);
    } else {
      deSerializedData = serializedData;
    }

    return new PackageLibData(deSerializedData['name'],
        dart2JsInfoOutputDir: deSerializedData['dart2JsInfoOutputDir'],
        packageName: deSerializedData['packageName'],
        deferredPartName: deSerializedData['deferredPartName'],
        members: deSerializedData['members'],
        size: deSerializedData['size'],
    );
  }

  static YamlNode _node;

  static List<String> getMemberNames([YamlNode node]) {
    node ??= _node;

    var members = <String>[];

    void _addMember(String nodeValue) {
//      nodeValue = nodeValue.substring(1, nodeValue.length - 1);
      int dollarLocation = nodeValue.indexOf('\$');

      if (dollarLocation > -1) {
        members.add(nodeValue.substring(0, dollarLocation) + '_dollar_' + nodeValue.substring(dollarLocation + 1));
      } else {
        members.add(nodeValue);
      }
    }

    if (node is YamlMap) {
      node.nodes.values.forEach((node) {
        if (node.value is YamlList) {
          YamlList value = node.value;
          value.forEach(_addMember);
        } else {
          _addMember(node.value);
        }
      });
    }

    return members;
  }

  @override
  Map<String, dynamic> toMap({bool showLibraryMembers: false}) => {
    'name': name,
    'dart2JsInfoOutputDir': dart2JsInfoOutputDir,
    'packageName': packageName,
    'deferredPartName': deferredPartName,
    'size': size,
    'members': showLibraryMembers
        ? members : [],
  };
}

class PackageLibDataMapView extends DataEntityMapView {
  PackageLibDataMapView(Map map) : super(map);

  @override
  String get name => this['name'];
  String get packageName => this['packageName'];
  String get deferredPartName => this['deferredPartName'];
  @override
  int get size => this['size'];
  List<String> get members => this['members'];

  @override
  Map<String, DataEntityMapView> sortedBySize({bool ascending: false}) => throw new UnimplementedError();
}
