import 'dart:developer';
import 'dart:html';

import 'package:dart2js_info_utils/data.dart';
import 'package:dart2js_info_utils/ui.dart';
import 'package:over_react/over_react.dart';
import 'package:react/react_dom.dart' as react_dom;

import './data/mapped/deferred_library_layout__by_package.dart' as data_by_package; // ignore: uri_does_not_exist
import './data/mapped/deferred_library_layout__by_part.dart' as data_by_part; // ignore: uri_does_not_exist

main() {
  setClientConfiguration();

  react_dom.render((DeferredLibraryLayoutDataListUi()
    ..byPackageMapView = new DeferredLibraryLayoutByPackageMapView(data_by_package.deferredLibraryLayoutByPackage)
    ..byPartMapView = new DeferredLibraryLayoutByPartMapView(data_by_part.deferredLibraryLayoutByPart)
  )(), querySelector("#benchmarks"));

//  var dataByPackageMapView = new DeferredLibraryLayoutByPackageMapView(data_by_package.deferredLibraryLayoutByPackage);
//  var dataByPartMapView = new DeferredLibraryLayoutByPartMapView(data_by_part.deferredLibraryLayoutByPart);

//  debugger();
}
