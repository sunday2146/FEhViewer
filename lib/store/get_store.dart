import 'dart:convert';

import 'package:fehviewer/common/global.dart';
import 'package:fehviewer/models/index.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:get_storage/get_storage.dart';

class GStore {
  static GetStorage _getStore([String container = 'GetStorage']) {
    return GetStorage('GalleryCache', Global.appSupportPath);
  }

  static final _cacheStore = () => _getStore('GalleryCache');
  static final _hisStore = () => _getStore('GalleryHistory');
  static final _profileStore = () => _getStore('Profile');
  static final _downloadStore = () => _getStore('Download');

  static Future<void> init() async {
    await _getStore('GalleryCache').initStorage;
    await _getStore('GalleryHistory').initStorage;
    await _getStore('Profile').initStorage;
    await _getStore('Download').initStorage;
  }

  GalleryCache? getCache(String gid) {
    final val = ReadWriteValue(gid, '', _cacheStore).val;
    return val.isNotEmpty ? GalleryCache.fromJson(jsonDecode(val)) : null;
  }

  void saveCache(GalleryCache cache) {
    if (cache.gid != null) {
      ReadWriteValue(cache.gid!, '', _cacheStore).val = jsonEncode(cache);
    }
  }

  set tabConfig(TabConfig? tabConfig) {
    logger.d('set tabConfig ${tabConfig?.toJson()}');
    ReadWriteValue('tabConfig', '', _profileStore).val = jsonEncode(tabConfig);
  }

  TabConfig? get tabConfig {
    final String val =
        ReadWriteValue('tabConfig', '{"tab_item_list": []}', _profileStore).val;
    final _config = jsonDecode(val);
    if (_config['tab_item_list'] == null) {
      _config['tab_item_list'] = _config['tabItemList'];
    }
    return val.isNotEmpty ? TabConfig.fromJson(_config) : null;
  }

  set archiverTaskMap(Map<String, DownloadTaskInfo>? taskInfoMap) {
    logger.d('set archiverDlMap \n'
        '${taskInfoMap?.entries.map((e) => '${e.key} = ${e.value.toJson().toString().split(', ').join('\n')}').join('\n')} ');

    if (taskInfoMap == null) {
      return;
    }

    ReadWriteValue('archiverTaskMap', '', _downloadStore).val =
        jsonEncode(taskInfoMap.entries.map((e) => e.value).toList());
  }

  Map<String, DownloadTaskInfo>? get archiverTaskMap {
    final val = ReadWriteValue('archiverTaskMap', '', _downloadStore).val;

    if (val.isEmpty) {
      return null;
    }

    logger.d('get archiverDlMap ${jsonDecode(val)}');
    final Map<String, DownloadTaskInfo> _map = <String, DownloadTaskInfo>{};
    for (final dynamic dlItemJson in jsonDecode(val) as List<dynamic>) {
      final DownloadTaskInfo _takInfo = DownloadTaskInfo.fromJson(dlItemJson);
      if (_takInfo.tag != null) {
        _map[_takInfo.tag!] = _takInfo;
      }
    }

    return _map;
  }

  set searchHistory(List<String> val) {
    // logger.d('set searchHistory ${val.join(',')}');
    ReadWriteValue('searchHistory', '', _hisStore).val = jsonEncode(val);
  }

  List<String> get searchHistory {
    final String val = ReadWriteValue('searchHistory', '', _hisStore).val;

    // logger.d('get searchHistory $val');

    List<String> rult = <String>[];
    if (val == null || val.trim().isEmpty) {
      return rult;
    }
    for (final dynamic his in jsonDecode(val) as List<dynamic>) {
      final String _his = his;
      rult.add(_his);
    }

    return rult;
  }

  Profile get profile {
    final String val = ReadWriteValue('profile', '{}', _profileStore).val;
    final Profile _profileObj = Profile.fromJson(jsonDecode(val));
    // logger.v('_initProfile \n${_profileObj.toJson()}');
    final Profile _profile = kDefProfile.copyWith(
        user: _profileObj.user,
        ehConfig: _profileObj.ehConfig,
        lastLogin: _profileObj.lastLogin,
        locale: _profileObj.locale,
        theme: _profileObj.theme,
        searchText: _profileObj.searchText,
        localFav: _profileObj.localFav,
        enableAdvanceSearch: _profileObj.enableAdvanceSearch,
        advanceSearch: _profileObj.advanceSearch,
        dnsConfig: _profileObj.dnsConfig,
        downloadConfig: _profileObj.downloadConfig,
        autoLock: _profileObj.autoLock);
    return _profile;
  }

  set profile(Profile val) {
    ReadWriteValue('profile', '{}', _profileStore).val = jsonEncode(val);
  }

  List<GalleryItem> get historys {
    final String val = ReadWriteValue('galleryHistory', '[]', _hisStore).val;
    final List<GalleryItem> _his = (jsonDecode(val) as List)
        .map((e) => GalleryItem.fromJson(e as Map<String, dynamic>))
        .toList();
    return _his;
  }

  set historys(List<GalleryItem> val) {
    // logger.d('set his ${jsonEncode(val)}');
    ReadWriteValue('galleryHistory', '{}', _hisStore).val = jsonEncode(val);
  }
}