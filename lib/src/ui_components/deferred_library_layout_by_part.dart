part of wdesk.benchmark.dart2js_info.ui_components;

@Factory()
UiFactory<DeferredLibraryLayoutByPartUiProps> DeferredLibraryLayoutByPartUi;

@Props()
class DeferredLibraryLayoutByPartUiProps extends AbstractDeferredLibraryLayoutViewUiProps {
  @requiredProp
  @override
  DeferredLibraryLayoutByPartMapView data;
}

@State()
class DeferredLibraryLayoutByPartUiState extends AbstractDeferredLibraryLayoutViewUiState {}

@Component()
class DeferredLibraryLayoutByPartUiComponent
    extends AbstractDeferredLibraryLayoutViewUiComponent<DeferredLibraryLayoutByPartUiProps,
                                                         DeferredLibraryLayoutByPartUiState> {
  @override
  String getTopLevelKeyHeaderText(String topLevelKey) => topLevelKey == '00_main'
      ? 'main.dart.js (not deferred)'
      : 'deferred part $topLevelKey';

  @override
  String getSecondLevelKeyHeaderText(String secondLevelKey) => 'package:$secondLevelKey';

  @override
  List<ReactElement> _renderTopLevelKeyCardBodyContent(DeferredPartDataMapView partData) => [
    _renderLoadedByPartData(partData),
    _renderPartPackages(partData),
  ];

  ReactElement _renderLoadedByPartData(DeferredPartDataMapView partData) {
    if (partData.loadedBy == null) return null;

    return (Dom.div()
      ..key = 'loaded_by'
      ..className = bsPaddingVertical(BsSpacingSize.ONE)
    )(
      (Dom.div()..className = 'row')(
        (Dom.div()..className = 'col-auto')(
          Dom.small()('Loaded By:'),
        ),
        (Dom.div()..className = 'col')(
          Dom.small()(
            (Dom.ol()..className = bsMarginBottom(BsSpacingSize.NONE))(
              partData.loadedBy.map((module) => (Dom.li()..key = module)(module)),
            ),
          ),
        ),
      ),
    );
  }

  ReactElement _renderPartPackages(DeferredPartDataMapView partData) {
    var packageElems = <ReactElement>[];
    var _collapsiblePackageLibRefs = <String, CollapsibleComponent>{};

    getPartPackagesView(partData)[props.sort].forEach((partPackageName, partPackageData) {
      if (partPackageData.size > 0) {
        packageElems.add(
            (ListGroupItem()
              ..key = partPackageName
              ..id = '${partPackageName}__item'
              ..className = bsPaddingVertical(BsSpacingSize.ONE)
            )(
              _renderEntityColumns(
                  (Button()
                    ..skin = ButtonSkin.LINK
                    ..size = ButtonSize.SMALL
                    ..className = bsPaddingHorizontal(BsSpacingSize.NONE)
                    ..aria.controls = '${partPackageName}__collapse'
                    ..onClick = (_) { _collapsiblePackageLibRefs[partPackageName].toggle(); }
                  )(
                    getSecondLevelKeyHeaderText(partPackageName),
                  ),
                  getSizeWithUnitLabel(partPackageData.size),
                  getPercentageOfTotalSizeWithLabel(partPackageData.size, props.aggregatePackageSizeDataCallback()[partPackageName]),
              ),
              (Collapsible()
                ..id = '${partPackageData.name}__collapse'
                ..aria.labelledby = '${partPackageData.name}__item'
                ..ref = (instance) { _collapsiblePackageLibRefs[partPackageName] = instance; }
                ..style = {'margin': '0 -1.25rem'}
                ..renderChildrenFn = () => _renderPackageLibs(partPackageData)
              )(),
            )
        );
      }
    });

    return (ListGroup()..key = 'packages')(packageElems);
  }

  Map<String, Map<String, PackageDataMapView>> _partPackagesViewSortedBySizeAscendingCache;
  Map<String, PackageDataMapView> _getPartPackagesViewSortedBySizeAscending(DeferredPartDataMapView partData) {
    _partPackagesViewSortedBySizeAscendingCache = null;

    if (_partPackagesViewSortedBySizeAscendingCache == null) {
      _partPackagesViewSortedBySizeAscendingCache = {
        partData.name: props.data.parts[partData.name].sortedBySize(ascending: true)
      };
    } else {
      _partPackagesViewSortedBySizeAscendingCache[partData.name]
          ??= props.data.parts[partData.name].sortedBySize(ascending: true);
    }

    return _partPackagesViewSortedBySizeAscendingCache[partData.name];
  }

  Map<String, Map<String, PackageDataMapView>> _partPackagesViewSortedBySizeDescendingCache;
  Map<String, PackageDataMapView> _getPartPackagesViewSortedBySizeDescending(DeferredPartDataMapView partData) {
    _partPackagesViewSortedBySizeDescendingCache == null;

    if (_partPackagesViewSortedBySizeDescendingCache == null) {
      _partPackagesViewSortedBySizeDescendingCache = {
        partData.name: props.data.parts[partData.name].sortedBySize(ascending: false)
      };
    } else {
      _partPackagesViewSortedBySizeDescendingCache[partData.name]
          ??= props.data.parts[partData.name].sortedBySize(ascending: false);
    }

    return _partPackagesViewSortedBySizeDescendingCache[partData.name];
  }

  Map<DeferredLibraryLayoutViewSortOptions, Map<String, PackageDataMapView>> getPartPackagesView(DeferredPartDataMapView partData) => {
    DeferredLibraryLayoutViewSortOptions.name: props.data.parts[partData.name].packages,
    DeferredLibraryLayoutViewSortOptions.sizeAscending: _getPartPackagesViewSortedBySizeAscending(partData),
    DeferredLibraryLayoutViewSortOptions.sizeDescending: _getPartPackagesViewSortedBySizeDescending(partData),
  };

  @override
  Map<String, DeferredPartDataMapView> _topLevelEntityViewSortedBySizeAscendingCache;
  @override
  Map<String, DeferredPartDataMapView> _getTopLevelEntityViewSortedBySizeAscending() {
    return props.data.sortedBySize(ascending: true);
//    _topLevelEntityViewSortedBySizeAscendingCache ??= props.data.sortedBySize(ascending: true);
//
//    return _topLevelEntityViewSortedBySizeAscendingCache;
  }

  @override
  Map<String, DeferredPartDataMapView> _topLevelEntityViewSortedBySizeDescendingCache;
  @override
  Map<String, DeferredPartDataMapView> _getTopLevelEntityViewSortedBySizeDescending() {
    return props.data.sortedBySize(ascending: false);;
//    _topLevelEntityViewSortedBySizeDescendingCache ??= props.data.sortedBySize(ascending: false);
//
//    return _topLevelEntityViewSortedBySizeDescendingCache;
  }

  @override
  Map<DeferredLibraryLayoutViewSortOptions, Map<String, DeferredPartDataMapView>> get topLevelEntityView => {
    DeferredLibraryLayoutViewSortOptions.name: props.data.parts,
    DeferredLibraryLayoutViewSortOptions.sizeAscending: _getTopLevelEntityViewSortedBySizeAscending(),
    DeferredLibraryLayoutViewSortOptions.sizeDescending: _getTopLevelEntityViewSortedBySizeDescending(),
  };
}
