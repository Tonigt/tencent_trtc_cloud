/*
 *  Copyright (C), 2015-2021
 *  FileName: setting_mixin
 *  Author: Tonight丶相拥
 *  Date: 2021/9/1
 *  Description: 
 **/

part of furender;

mixin _SettingMixin {
  /// 数据源
  List<ItemModel> datas = [];

  void settingParameter(Map<String, dynamic>? map) {
    // TODO: implement settingParameter
    if (map == null)
      return;
    datas.forEach((element) {
      var value = map[element.key];
      if (value != null)
        element.value = value;
    });
  }
}

mixin _SettingType1Mixin {
  final String _imageName = "imageName";
  final String _valueName = "intensity";
}