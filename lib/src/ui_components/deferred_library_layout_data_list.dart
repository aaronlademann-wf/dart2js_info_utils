part of wdesk.benchmark.dart2js_info.ui_components;

@Factory()
UiFactory<DeferredLibraryLayoutDataListUiProps> DeferredLibraryLayoutDataListUi;

@Props()
class DeferredLibraryLayoutDataListUiProps extends UiProps {
  @requiredProp
  DeferredLibraryLayoutByPackageMapView byPackageMapView;

  @requiredProp
  DeferredLibraryLayoutByPartMapView byPartMapView;

  DeferredLibraryLayoutDataListUiMode initialViewMode;
  DeferredLibraryLayoutViewSortOptions initialSort;
}

@State()
class DeferredLibraryLayoutDataListUiState extends UiState {
  DeferredLibraryLayoutDataListUiMode viewMode;
  DeferredLibraryLayoutViewSortOptions sort;
}

@Component()
class DeferredLibraryLayoutDataListUiComponent extends UiStatefulComponent<DeferredLibraryLayoutDataListUiProps,
                                                                           DeferredLibraryLayoutDataListUiState> {
  @override
  Map getDefaultProps() => (newProps()
    ..initialViewMode = DeferredLibraryLayoutDataListUiMode.byPart
    ..initialSort = DeferredLibraryLayoutViewSortOptions.name
  );

  @override
  Map getInitialState() => (newState()
    ..viewMode = props.initialViewMode
    ..sort = props.initialSort
  );

  @override
  render() {
    return (Dom.div()..className = 'container ${bsPaddingVertical(BsSpacingSize.DEFAULT)}')(
      (Dom.div()..className = 'row justify-content-md-between ${bsPaddingBottom(BsSpacingSize.DEFAULT)}')(
        (Dom.div()..className = 'col-md-auto')(
          (Dom.div()..className = 'row')(
            (Dom.div()..className = 'col-sm-2 col-md-auto ${bsPaddingRight(BsSpacingSize.NONE)}')(
              (Dom.div()..className = 'btn btn-sm text-sm-right text-md-center')(
                'Sort:',
              ),
            ),
            (Dom.div()..className = 'col')(
              (ToggleButtonGroup()
                ..skin = ButtonSkin.LINK
                ..size = ButtonGroupSize.SMALL
                ..onChange = (SyntheticFormEvent event) {
                  RadioButtonInputElement target = event.target;

                  Map<String, DeferredLibraryLayoutViewSortOptions> valueToSortOption = {
                    'name': DeferredLibraryLayoutViewSortOptions.name,
                    'sizeAsc': DeferredLibraryLayoutViewSortOptions.sizeAscending,
                    'sizeDesc': DeferredLibraryLayoutViewSortOptions.sizeDescending,
                  };

                  if (target.checked) {
                    final newSortOption = valueToSortOption[target.value];

                    if (newSortOption != state.sort) {
                      setState(newState()..sort = newSortOption);
                    }
                  }
                }
              )(
                (ToggleButton()
                  ..toggleType = ToggleBehaviorType.RADIO
                  ..checked = state.sort == DeferredLibraryLayoutViewSortOptions.name
                  ..value = 'name'
                )('By Name'),
                (ToggleButton()
                  ..toggleType = ToggleBehaviorType.RADIO
                  ..checked = state.sort == DeferredLibraryLayoutViewSortOptions.sizeDescending
                  ..value = 'sizeDesc'
                )('Size (Desc)'),
                (ToggleButton()
                  ..toggleType = ToggleBehaviorType.RADIO
                  ..checked = state.sort == DeferredLibraryLayoutViewSortOptions.sizeAscending
                  ..value = 'sizeAsc'
                )('Size (Asc)'),
              ),
            ),
          ),
        ),
        (Dom.div()..className = 'col-md-auto')(
          (Dom.div()..className = 'row')(
            (Dom.div()..className = 'col-sm-2 col-md-auto ${bsPaddingRight(BsSpacingSize.NONE)}')(
              (Dom.div()..className = 'btn btn-sm text-sm-right text-md-center')(
                'Group:',
              ),
            ),
            (Dom.div()..className = 'col')(
              (ToggleButtonGroup()
                ..skin = ButtonSkin.LINK
                ..size = ButtonGroupSize.SMALL
                ..onChange = (SyntheticFormEvent event) {
                  RadioButtonInputElement target = event.target;

                  Map<String, DeferredLibraryLayoutDataListUiMode> valueToMode = {
                    'byPackage': DeferredLibraryLayoutDataListUiMode.byPackage,
                    'byPart': DeferredLibraryLayoutDataListUiMode.byPart,
                  };

                  if (target.checked) {
                    final newViewMode = valueToMode[target.value];

                    if (newViewMode != state.viewMode) {
                      setState(newState()..viewMode = newViewMode);
                    }
                  }
                }
              )(
                (ToggleButton()
                  ..toggleType = ToggleBehaviorType.RADIO
                  ..checked = state.viewMode == DeferredLibraryLayoutDataListUiMode.byPackage
                  ..value = 'byPackage'
                )('By Package'),
                (ToggleButton()
                  ..toggleType = ToggleBehaviorType.RADIO
                  ..checked = state.viewMode == DeferredLibraryLayoutDataListUiMode.byPart
                  ..value = 'byPart'
                )('By Part'),
              ),
            ),
          ),
        ),
      ),
      (viewModeComponent[state.viewMode]()
        ..data = viewModeData[state.viewMode]
        ..sort = state.sort
        ..aggregatePackageSizeDataCallback = _getAggregatePackageSizeData
      )()
    );
  }

  Map<String, int> _aggregatePackageSizeDataCache;
  Map<String, int> _getAggregatePackageSizeData() {
    if (_aggregatePackageSizeDataCache != null) return _aggregatePackageSizeDataCache;

    Map<String, int> data = {};

    props.byPackageMapView.packages.forEach((packageName, aggregatePackagePartsData) {
      data[packageName] = aggregatePackagePartsData.size;
    });

    _aggregatePackageSizeDataCache = data;

    return _aggregatePackageSizeDataCache;
  }

  Map<DeferredLibraryLayoutDataListUiMode, DeferredLibraryLayoutMapView> get viewModeData => {
    DeferredLibraryLayoutDataListUiMode.byPackage: props.byPackageMapView,
    DeferredLibraryLayoutDataListUiMode.byPart: props.byPartMapView,
  };

  Map<DeferredLibraryLayoutDataListUiMode, UiFactory<AbstractDeferredLibraryLayoutViewUiProps>> get viewModeComponent => {
    DeferredLibraryLayoutDataListUiMode.byPackage: DeferredLibraryLayoutByPackageUi,
    DeferredLibraryLayoutDataListUiMode.byPart: DeferredLibraryLayoutByPartUi,
  };
}

enum DeferredLibraryLayoutDataListUiMode {
  byPackage,
  byPart,
}
