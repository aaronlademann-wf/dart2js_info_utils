part of wdesk.benchmark.dart2js_info.bundle_entity_data;

/// A base class to be shared by the three pieces of the "bundle" data hierarchy:
///
///     DeferredPartData
///       PackageData
///         PackageLibData
abstract class BundleEntityData/*<T> implements Comparable<T>*/ {
  final String name;
  final String dart2JsInfoOutputDir;

  BundleEntityData(this.name, {
      @required
      this.dart2JsInfoOutputDir,
      Map<String, int> entitySizeMap,
  }) {
    this._entitySizeMap = entitySizeMap ?? getEntitySizeMap(getEntitySizeListSrc(this.dart2JsInfoOutputDir));
  }

  Map<String/*entity name*/, int/*entity size (in bytes)*/> get entitySizeMap => _entitySizeMap;
  Map<String, int> _entitySizeMap;

  /// The size of the entity when compiled into the bundle (in bytes).
  int get size => _size;
  /// The size of the entity when compiled into the bundle (in bytes).
  int _size;

  Map<String, dynamic> toMap({bool showLibraryMembers: false});

  String toJSON({bool showLibraryMembers: false}) => JSON.encode(toMap(showLibraryMembers: showLibraryMembers));

  @override
  String toString({bool showLibraryMembers: false}) => toJSON(showLibraryMembers: showLibraryMembers);
}
