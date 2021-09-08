//
//  DeviceManager.swift
//  tencent_trtc_cloud
//
//  Created by 林智 on 2020/12/24.
//

import Foundation
//import TXLiteAVSDK_TRTC

class DeviceManager {
	private var txDeviceManager: TXDeviceManager = TRTCCloud.sharedInstance().getDeviceManager();
	
	/**
	* 切换摄像头
	*/
	public func switchCamera(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let isFrontCamera = CommonUtils.getParamByKey(call: call, result: result, param: "isFrontCamera") as? Bool {
			txDeviceManager.switchCamera(isFrontCamera);
			result(nil);
		}
	}
	
	/**
	* 查询是前置摄像头
	*/
	public func isFrontCamera(call: FlutterMethodCall, result: @escaping FlutterResult) {
		result(txDeviceManager.isFrontCamera());
	}
	
	/**
	* 查询摄像头最大缩放率
	*/
	public func getCameraZoomMaxRatio(call: FlutterMethodCall, result: @escaping FlutterResult) {
		result(Int(txDeviceManager.getCameraZoomMaxRatio()));
	}
	
	/**
	* 设置摄像头缩放率
	*/
	public func setCameraZoomRatio(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let value = CommonUtils.getParamByKey(call: call, result: result, param: "value") as? String {
			let ret = txDeviceManager.setCameraZoomRatio(CGFloat(Int(Float(value)!)));
			result(ret);
		}
	}
	
	/**
	* 设置摄像头缩放率
	*/
	public func enableCameraAutoFocus(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let enable = CommonUtils.getParamByKey(call: call, result: result, param: "enable") as? Bool {
			result(txDeviceManager.enableCameraAutoFocus(enable));
		}
	}
	
	/**
	* 设置摄像头闪光灯，开启后置摄像头才有效果
	*/
	public func enableCameraTorch(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let enable = CommonUtils.getParamByKey(call: call, result: result, param: "enable") as? Bool {
			txDeviceManager.enableCameraTorch(enable);
			result(nil);
		}
	}
	
	/**
	* 设置对焦位置
	*/
	public func setCameraFocusPosition(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let x = CommonUtils.getParamByKey(call: call, result: result, param: "x") as? Int,
		   let y = CommonUtils.getParamByKey(call: call, result: result, param: "y") as? Int {
			txDeviceManager.setCameraFocusPosition(CGPoint(x: CGFloat(x), y: CGFloat(y)));
			result(nil);
		}
	}
	
	/**
	* 查询摄像头是否自动对焦
	*/
	public func isAutoFocusEnabled(call: FlutterMethodCall, result: @escaping FlutterResult) {
		result(txDeviceManager.isAutoFocusEnabled());
	}
	
	/**
	* 设置通话时使用的系统音量类型
	*/
	public func setSystemVolumeType(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let type = CommonUtils.getParamByKey(call: call, result: result, param: "type") as? Int {
			txDeviceManager.setSystemVolumeType(TXSystemVolumeType(rawValue: type)!);
			result(nil);
		}
	}
	
	/**
	* 设置音频路由
	*/
	public func setAudioRoute(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let route = CommonUtils.getParamByKey(call: call, result: result, param: "route") as? Int {
			txDeviceManager.setAudioRoute(TXAudioRoute(rawValue: route)!);
			result(nil);
		}
	}
}
