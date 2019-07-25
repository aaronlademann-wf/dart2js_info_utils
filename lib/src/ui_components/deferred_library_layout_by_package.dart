part of wdesk.benchmark.dart2js_info.ui_components;

@Factory()
UiFactory<DeferredLibraryLayoutByPackageUiProps> DeferredLibraryLayoutByPackageUi = _$DeferredLibraryLayoutByPackageUi;

@Props()
class _$DeferredLibraryLayoutByPackageUiProps extends AbstractDeferredLibraryLayoutViewUiProps {
  @requiredProp
  @override
  DeferredLibraryLayoutByPackageMapView data;
}

@State()
class _$DeferredLibraryLayoutByPackageUiState extends AbstractDeferredLibraryLayoutViewUiState {}

@Component()
class DeferredLibraryLayoutByPackageUiComponent
    extends AbstractDeferredLibraryLayoutViewUiComponent<DeferredLibraryLayoutByPackageUiProps,
                                                         DeferredLibraryLayoutByPackageUiState> {
  @override
  String getTopLevelKeyHeaderText(String topLevelKey) => 'package:$topLevelKey';

  @override
  String getSecondLevelKeyHeaderText(String secondLevelKey) => secondLevelKey.startsWith('00')
      ? '${secondLevelKey.replaceFirst('00_', '')}.dart.js (not deferred)'
      : 'deferred part $secondLevelKey';

  @override
  List<ReactElement> _renderTopLevelKeyCardBodyContent(PackagePartsMapView packageData) => [
    _renderPackageParts(packageData),
  ];

  ReactElement _renderPackageParts(PackagePartsMapView packageData) {
    var packageElems = <ReactElement>[];
    var _collapsiblePackageLibRefs = <String, CollapsibleComponent>{};

    getPackagePartsView(packageData)[props.sort].forEach((packagePartName, partPackageData) {
      if (partPackageData.size > 0) {
        packageElems.add(
            (ListGroupItem()
              ..key = packagePartName
              ..id = '${packagePartName}__item'
              ..className = bsPaddingVertical(BsSpacingSize.ONE)
            )(
              _renderEntityColumns(
                  (Button()
                    ..skin = ButtonSkin.LINK
                    ..size = ButtonSize.SMALL
                    ..className = bsPaddingHorizontal(BsSpacingSize.NONE)
                    ..aria.controls = '${packagePartName}__collapse'
                    ..onClick = (_) { _collapsiblePackageLibRefs[packagePartName].toggle(); }
                  )(
                    getSecondLevelKeyHeaderText(packagePartName),
                  ),
                  getSizeWithUnitLabel(partPackageData.size),
                  getPercentageOfTotalSizeWithLabel(partPackageData.size, packageData.size),
              ),
              (Collapsible()
                ..id = '${partPackageData.name}__collapse'
                ..aria.labelledby = '${partPackageData.name}__item'
                ..ref = (instance) { _collapsiblePackageLibRefs[packagePartName] = instance; }
                ..style = {'margin': '0 -1.25rem'}
                ..renderChildrenFn = () => _renderPackageLibs(partPackageData)
              )(),
            )
        );
      }
    });

    return (ListGroup()..key = 'packages')(packageElems);
  }

  Map<String, Map<String, PackageDataMapView>> _packagePartsViewSortedBySizeAscendingCache;
  Map<String, PackageDataMapView> _getPackagePartsViewSortedBySizeAscending(PackagePartsMapView packagePartsData) {
    _packagePartsViewSortedBySizeAscendingCache = {};

    packagePartsData.sortedBySize(ascending: true).forEach((deferredPartName, partPackageData) {
      if (_packagePartsViewSortedBySizeAscendingCache[packagePartsData.name] == null) {
        _packagePartsViewSortedBySizeAscendingCache[packagePartsData.name] = {
          deferredPartName: partPackageData,
        };
      } else {
        _packagePartsViewSortedBySizeAscendingCache[packagePartsData.name][deferredPartName] = partPackageData;
      }
    });

    return _packagePartsViewSortedBySizeAscendingCache[packagePartsData.name];
  }

  Map<String, Map<String, PackageDataMapView>> _packagePartsViewSortedBySizeDescendingCache;
  Map<String, PackageDataMapView> _getPackagePartsViewSortedBySizeDescending(PackagePartsMapView packagePartsData) {
    _packagePartsViewSortedBySizeDescendingCache = {};

    packagePartsData.sortedBySize(ascending: false).forEach((deferredPartName, partPackageData) {
      if (_packagePartsViewSortedBySizeDescendingCache[packagePartsData.name] == null) {
        _packagePartsViewSortedBySizeDescendingCache[packagePartsData.name] = {
          deferredPartName: partPackageData,
        };
      } else {
        _packagePartsViewSortedBySizeDescendingCache[packagePartsData.name][deferredPartName] = partPackageData;
      }
    });

    return _packagePartsViewSortedBySizeDescendingCache[packagePartsData.name];
  }

  Map<DeferredLibraryLayoutViewSortOptions, Map<String, PackageDataMapView>> getPackagePartsView(PackagePartsMapView packagePartsData) => {
    DeferredLibraryLayoutViewSortOptions.name: props.data.packages[packagePartsData.name].parts,
    DeferredLibraryLayoutViewSortOptions.sizeAscending: _getPackagePartsViewSortedBySizeAscending(packagePartsData),
    DeferredLibraryLayoutViewSortOptions.sizeDescending: _getPackagePartsViewSortedBySizeDescending(packagePartsData),
  };

  @override
  Map<String, PackagePartsMapView> _topLevelEntityViewSortedBySizeAscendingCache;
  @override
  Map<String, PackagePartsMapView> _getTopLevelEntityViewSortedBySizeAscending() {
    return props.data.sortedBySize(ascending: true);
//    _topLevelEntityViewSortedBySizeAscendingCache ??= props.data.sortedBySize(ascending: true);
//
//    return _topLevelEntityViewSortedBySizeAscendingCache;
  }

  @override
  Map<String, PackagePartsMapView> _topLevelEntityViewSortedBySizeDescendingCache;
  @override
  Map<String, PackagePartsMapView> _getTopLevelEntityViewSortedBySizeDescending() {
    return props.data.sortedBySize(ascending: false);
//    _topLevelEntityViewSortedBySizeDescendingCache ??= props.data.sortedBySize(ascending: false);
//
//    return _topLevelEntityViewSortedBySizeDescendingCache;
  }

  @override
  Map<DeferredLibraryLayoutViewSortOptions, Map<String, PackagePartsMapView>> get topLevelEntityView => {
    DeferredLibraryLayoutViewSortOptions.name: props.data.packages,
    DeferredLibraryLayoutViewSortOptions.sizeAscending: _getTopLevelEntityViewSortedBySizeAscending(),
    DeferredLibraryLayoutViewSortOptions.sizeDescending: _getTopLevelEntityViewSortedBySizeDescending(),
  };
}
