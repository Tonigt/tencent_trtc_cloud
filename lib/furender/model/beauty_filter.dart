/*
 *  Copyright (C), 2015-2021
 *  FileName: beauty_filter
 *  Author: Tonight丶相拥
 *  Date: 2021/8/24
 *  Description: 
 **/

part of furender;


class _BeautyFilterModel extends FuRenderModelAbstract with _SettingType1Mixin {
  _BeautyFilterModel(VoidCallback updateState): super(_FuType.beautyFilter, updateState);

  @override
  // TODO: implement recover
  bool get recover => super.recover;
  final String _valueName = "filterLevel";

  @override
  // TODO: implement datas
  final List<ItemModel> datas = [
    ItemModel(title: "origin", image: "origin", value: 0.4, maxValue: 1.0, hasStatus: false),
    ItemModel(title: "ziran1", image: "ziran1", value: 0.4, maxValue: 1.0, hasStatus: false),
    ItemModel(title: "zhiganhui1", image: "zhiganhui1", value: 0.4, maxValue: 1.0, hasStatus: false),
    ItemModel(title: "bailiang1", image: "bailiang1", value: 0.4, maxValue: 1.0, hasStatus: false),
    ItemModel(title: "fennen1", image: "fennen1", value: 0.4, maxValue: 1.0, hasStatus: false),
    ItemModel(title: "lengsediao1", image: "lengsediao1", value: 0.4, maxValue: 1.0, hasStatus: false)
  ];

  @override
  void onSelectIndex(int index) {
    // TODO: implement onSelectIndex
    super.onSelectIndex(index);
    if(currentItem != null)
      TRTCCloud.sharedInstance().then((value) {
        value!._filterChange(imageName: currentItem!.image,
            value: currentItem!.value);
      });
  }

  @override
  Map<String, dynamic> toJson() {
    // TODO: implement toJson
    if (currentItem == null)
      return {};
    return {
      _valueName: currentItem!.value,
      _imageName: currentItem!.image
    };
  }

  @override
  void onChangeValue(double value) {
    // TODO: implement onChangeValue
    super.onChangeValue(value);
  }

  @override
  void settingParameter(Map<String, dynamic>? map) {
    // TODO: implement settingParameter
    if (map == null)
      return;
    int index;
    index = datas.indexWhere((element) => element.image == map[_imageName]);
    this.index = index;
    currentItem?.value = map[_valueName] ?? currentItem?.value;
  }
}