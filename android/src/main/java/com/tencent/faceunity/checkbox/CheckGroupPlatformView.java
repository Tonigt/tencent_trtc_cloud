package com.tencent.faceunity.checkbox;

import android.content.Context;
import android.view.View;
import android.widget.Toolbar;

import io.flutter.plugin.platform.PlatformView;

import com.tencent.faceunity.data.FaceUnityDataFactory;
import com.tencent.faceunity.ui.FaceUnityView;


public class CheckGroupPlatformView implements PlatformView {

    private final FaceUnityView _view;
    public CheckGroupPlatformView(Context context, Object args) {
        _view = new FaceUnityView(context.getApplicationContext());
        _view.setVisibility(View.VISIBLE);
        FaceUnityDataFactory f = new FaceUnityDataFactory(0);
        _view.bindDataFactory(f);
    }
    
    @Override
    public View getView() {
        return _view;
    }


    @Override
    public void dispose() {

    }
}
