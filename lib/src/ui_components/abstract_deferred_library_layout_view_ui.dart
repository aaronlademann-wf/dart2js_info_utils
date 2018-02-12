part of wdesk.benchmark.dart2js_info.ui_components;

typedef Map<String, int> AggregatePackageSizeDataCallback();

@AbstractProps()
abstract class AbstractDeferredLibraryLayoutViewUiProps extends UiProps {
  @requiredProp
  covariant DeferredLibraryLayoutMapView data;

  @requiredProp
  AggregatePackageSizeDataCallback aggregatePackageSizeDataCallback;

  DeferredLibraryLayoutViewSortOptions sort;
}

@AbstractState()
abstract class AbstractDeferredLibraryLayoutViewUiState extends UiState {}

@AbstractComponent()
abstract class AbstractDeferredLibraryLayoutViewUiComponent<T extends AbstractDeferredLibraryLayoutViewUiProps,
                                                            S extends AbstractDeferredLibraryLayoutViewUiState>
    extends UiStatefulComponent<T, S> {
  var _collapsibleTopLevelKeyCardRefs = <String, CollapsibleComponent>{};

  String getTopLevelKeyHeaderText(String topLevelKey);

  String getSecondLevelKeyHeaderText(String secondLevelKey);

  @override
  @mustCallSuper
  Map getDefaultProps() => (newProps()
    ..sort = DeferredLibraryLayoutViewSortOptions.name
  );

  @override
  render() {
    return (Dom.div()..className = 'row')(
      (Dom.div()..className = 'col')(
        topLevelEntityView[props.sort].values.map(_renderTopLevelKeyCard),
      ),
    );
  }

  ReactElement _renderTopLevelKeyCard(covariant DataEntityMapView entityDataView) {
    if (entityDataView.size == 0 || entityDataView.size == null) return null;

    final name = entityDataView.name;

    return (Dom.div()
      ..key = name
      ..className = 'card ${bsMarginBottom(BsSpacingSize.ONE)}'
    )(
      (Dom.div()
        ..className = 'card-header'
        ..id = 'card-${name}__header'
      )(
        _renderEntityColumns(
            (Button()
              ..skin = ButtonSkin.LINK
              ..size = ButtonSize.SMALL
              ..className = bsPaddingHorizontal(BsSpacingSize.NONE)
              ..aria.controls = 'card-${name}__collapse'
              ..onClick = (_) { _collapsibleTopLevelKeyCardRefs[name].toggle(); }
            )(
              getTopLevelKeyHeaderText(name),
            ),
            getSizeWithUnitLabel(entityDataView.size),
        ),
      ),
      (Collapsible()
        ..id = 'card-${name}__collapse'
        ..aria.labelledby = 'card-${name}__header'
        ..ref = (instance) { _collapsibleTopLevelKeyCardRefs[name] = instance; }
        ..renderChildrenFn = () => (Dom.div()..className = 'card-body')(_renderTopLevelKeyCardBodyContent(entityDataView))
      )(),
    );
  }

  dynamic _renderTopLevelKeyCardBodyContent(covariant DataEntityMapView entityDataView);

  ReactElement _renderPackageLibs(PackageDataMapView packageData) {
    return (ListGroup()..key = 'package_libs')(
      getPackageLibsView(packageData)[props.sort].values.map((libDataMapView) {
        return (ListGroupItem()
          ..key = libDataMapView.name
          ..className = '${bsPaddingVertical(BsSpacingSize.ONE)} ${bsPaddingLeft(BsSpacingSize.FIVE)} border-right-0 border-left-0 rounded-0 bg-light'
        )(
          _renderEntityColumns(
              Dom.small()(libDataMapView.name),
              getSizeWithUnitLabel(libDataMapView.size),
          )
        );
      }).toList(growable: false),
    );
  }

  ReactElement _renderEntityColumns(dynamic leftColContent, dynamic rightColContent, [dynamic rightColSubText]) {
    ReactElement _renderSubText() {
      if (rightColSubText == null) return null;

      return (Dom.div()..className = 'col-auto ${bsPaddingLeft(BsSpacingSize.NONE)}')(
        Dom.small()(
          (Dom.code()..className = 'text-muted')(rightColSubText),
        ),
      );
    }

    return (Dom.div()..className = 'row align-items-center')(
      (Dom.div()..className = 'col text-truncate')(
        leftColContent,
      ),
      (Dom.div()..className = 'col-auto')(
        (Dom.div()..className = 'row align-items-center')(
          (Dom.div()..className = 'col-auto')(
            Dom.small()(
              (Dom.code()..className = 'font-weight-bold')(rightColContent),
            ),
          ),
          _renderSubText(),
        ),
      ),
    );
  }

  Map<String, Map<String, PackageLibDataMapView>> _packageLibsViewSortedBySizeAscendingCache;
  Map<String, PackageLibDataMapView> _getPackageLibsViewSortedBySizeAscending(PackageDataMapView packageData) {
    _packageLibsViewSortedBySizeAscendingCache = null;
    final deferredPartName = packageData.libraries.values.first.deferredPartName;

    if (_packageLibsViewSortedBySizeAscendingCache == null) {
      _packageLibsViewSortedBySizeAscendingCache = {
        deferredPartName: packageData.sortedBySize(ascending: true)
      };
    } else {
      _packageLibsViewSortedBySizeAscendingCache[deferredPartName] ??= packageData.sortedBySize(ascending: true);
    }

    return _packageLibsViewSortedBySizeAscendingCache[deferredPartName];
  }

  Map<String, Map<String, PackageLibDataMapView>> _packageLibsViewSortedBySizeDescendingCache;
  Map<String, PackageLibDataMapView> _getPackageLibsViewSortedBySizeDescending(PackageDataMapView packageData) {
    _packageLibsViewSortedBySizeDescendingCache = null;
    final deferredPartName = packageData.libraries.values.first.deferredPartName;

    if (_packageLibsViewSortedBySizeDescendingCache == null) {
      _packageLibsViewSortedBySizeDescendingCache = {
        deferredPartName: packageData.sortedBySize(ascending: false)
      };
    } else {
      _packageLibsViewSortedBySizeDescendingCache[deferredPartName] ??= packageData.sortedBySize(ascending: false);
    }

    return _packageLibsViewSortedBySizeDescendingCache[deferredPartName];
  }

  Map<DeferredLibraryLayoutViewSortOptions, Map<String, PackageLibDataMapView>> getPackageLibsView(PackageDataMapView packageData) => {
    DeferredLibraryLayoutViewSortOptions.name: packageData.libraries,
    DeferredLibraryLayoutViewSortOptions.sizeAscending: _getPackageLibsViewSortedBySizeAscending(packageData),
    DeferredLibraryLayoutViewSortOptions.sizeDescending: _getPackageLibsViewSortedBySizeDescending(packageData),
  };

  covariant Map<String, DataEntityMapView> _topLevelEntityViewSortedBySizeAscendingCache;
  Map<String, DataEntityMapView> _getTopLevelEntityViewSortedBySizeAscending() {
    return props.data.sortedBySize(ascending: true);
//    _topLevelEntityViewSortedBySizeAscendingCache ??= props.data.sortedBySize(ascending: true);
//
//    return _topLevelEntityViewSortedBySizeAscendingCache;
  }

  covariant Map<String, DataEntityMapView> _topLevelEntityViewSortedBySizeDescendingCache;
  Map<String, DataEntityMapView> _getTopLevelEntityViewSortedBySizeDescending() {
    return props.data.sortedBySize(ascending: false);
//    _topLevelEntityViewSortedBySizeDescendingCache ??= props.data.sortedBySize(ascending: false);
//
//    return _topLevelEntityViewSortedBySizeDescendingCache;
  }

  Map<DeferredLibraryLayoutViewSortOptions, Map<String, DataEntityMapView>> get topLevelEntityView;
}

enum DeferredLibraryLayoutViewSortOptions {
  name,
  sizeAscending,
  sizeDescending,
}
