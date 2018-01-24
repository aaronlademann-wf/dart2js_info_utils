part of wdesk.benchmark.dart2js_info.bundle_entity_data;

/// Represents a single `package:<package_name>` or `dart:<core_lib_name>` entry found
/// within an instance of [PackageData].
class PackageLibData extends BundleEntityData {
  @override
  final String name;
  final String deferredPartName;
  final String packageName;
  final List<String> members;

  PackageLibData(this.name, {
      @required
      this.packageName,
      @required
      this.deferredPartName,
      this.members: const <String>[],
      YamlNode node,
      int size,
  }) {
    _node = node;

    if (packageLibrarySizeInfo.isEmpty && size == null) {
      setPackageLibrarySizeInfo();
    }
    _size = size ?? packageLibrarySizeInfo[this.name] ?? 0;
  }

  factory PackageLibData.fromNode(DeferredPartData deferredPartData, YamlNode node) {
    return new PackageLibData(getPackageLibraryNameFromSrc(node.span.toString()),
        packageName: getPackageNameFromSrc(node.span),
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
