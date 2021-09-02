/*
 *  Copyright (C), 2015-2021
 *  FileName: make_up_model
 *  Author: Tonight丶相拥
 *  Date: 2021/8/24
 *  Description: 
 **/

part of furender;

class _MakeUpModel extends FuRenderModelAbstract with _SettingType1Mixin {
  _MakeUpModel(VoidCallback updateState): super(_FuType.makeUp, updateState);

  @override
  // TODO: implement recover
  bool get recover => super.recover;

  
  @override
  // TODO: implement datas
  final List<ItemModel> datas = [
    ItemModel(title: "makeup_noitem", image: "origin", value: 0.7, maxValue: 1, hasStatus: false),
    ItemModel(title: "chaoA", image: "chaoA", value: 0.7, maxValue: 1, hasStatus: false),
    ItemModel(title: "dousha", image: "dousha", value: 0.7, maxValue: 1, hasStatus: false),
    ItemModel(title: "naicha", image: "naicha", value: 0.7, maxValue: 1, hasStatus: false)
  ];
  
  @override
  void onChangeValue(double value) {
    // TODO: implement onChangeValue
    super.onChangeValue(value);
  }
  
  @override
  void onSelectIndex(int index) {
    // TODO: implement onSelectIndex
    super.onSelectIndex(index);
    if(currentItem != null)
      TRTCCloud.sharedInstance().then((value) {
        value!._makeUpChange(imageName: index == 0 ? null
            : currentItem!.image,
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
      _imageName: index == 0 ? null
          : currentItem!.image
    };
  }

  @override
  void settingParameter(Map<String, dynamic>? map) {
    // TODO: implement settingParameter
    if (map == null)
      return;
    int index = -1;
    if (map.containsKey(_imageName)) {
      index = map[_imageName] == null ? 0 : datas.indexWhere((element) => element.image == map[_imageName]);
    }
    this.index = index;
    currentItem?.value = map[_valueName] ?? currentItem?.value;
  }
}