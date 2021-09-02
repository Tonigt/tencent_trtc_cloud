/*
 *  Copyright (C), 2015-2021
 *  FileName: value_change_listener
 *  Author: Tonight丶相拥
 *  Date: 2021/9/1
 *  Description: 
 **/

part of furender;

mixin ValueChangeListener {
  void valueChange(Map<String, dynamic> map);

  Future<Map<String, dynamic>> getOriginalValue();
}