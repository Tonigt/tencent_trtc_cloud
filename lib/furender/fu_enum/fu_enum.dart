/*
 *  Copyright (C), 2015-2021
 *  FileName: fu_enum
 *  Author: Tonight丶相拥
 *  Date: 2021/8/24
 *  Description: 
 **/

part of furender;

enum _FuType {
  /// 美肤
  skin,
  /// 美型
  shape,
  /// 滤镜
  beautyFilter,
  /// 贴纸
  sticker,
  /// 美妆
  makeUp,
  /// 美体
  body,
  unknown
}


extension FuTypeExtension on _FuType {

  String get description {
    String description;
    switch(this) {
      case _FuType.skin:
        description = "美肤";
        break;
      case _FuType.shape:
        description = "美型";
        break;
      case _FuType.beautyFilter:
        description = "滤镜";
        break;
      case _FuType.sticker:
        description = "贴纸";
        break;
      case _FuType.makeUp:
        description = "美妆";
        break;
      case _FuType.body:
        description = "美体";
        break;
      default:
        description = "未知";
    }
    return description;
  }

  String get rawValue {
    String rawValue;
    switch(this) {
      case _FuType.skin:
        rawValue = "skin";
        break;
      case _FuType.shape:
        rawValue = "shape";
        break;
      case _FuType.beautyFilter:
        rawValue = "filter";
        break;
      case _FuType.sticker:
        rawValue = "sticker";
        break;
      case _FuType.makeUp:
        rawValue = "makeUp";
        break;
      case _FuType.body:
        rawValue = "bodyBeauty";
        break;
      default:
        rawValue = "unknown";
    }
    return rawValue;
  }
}