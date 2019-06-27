package com.gamenative.xiaomi;

import android.app.Activity;
import android.content.Context;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.util.Log;

import com.xiaomi.gamecenter.sdk.MiCommplatform;
import com.xiaomi.gamecenter.sdk.OnExitListner;
import com.xiaomi.gamecenter.sdk.OnInitProcessListener;
import com.xiaomi.gamecenter.sdk.OnLoginProcessListener;
import com.xiaomi.gamecenter.sdk.OnPayProcessListener;
import com.xiaomi.gamecenter.sdk.entry.MiAppInfo;
import com.xiaomi.gamecenter.sdk.entry.MiBuyInfo;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.Iterator;
import java.util.List;
import java.util.UUID;

/**
 * Created by lyzz0612 on 2019/6/27
 */

public class XiaomiAgent {
    final static String TAG = "xiaomi";

    private static String getMetaData(Context context, String key) {
        try {
            ApplicationInfo ai = context.getPackageManager().getApplicationInfo(context.getPackageName(), PackageManager.GET_META_DATA);
            Bundle bundle = ai.metaData;
            String value = bundle.getString(key, "");
            return value;
        } catch (PackageManager.NameNotFoundException e) {
            e.printStackTrace();
        } catch (NullPointerException e) {
            e.printStackTrace();
        }
        return "";
    }

    public void init(Context context) {
        MiAppInfo appInfo = new MiAppInfo();
        appInfo.setAppId(XiaomiAgent.getMetaData(context, "MI_APP_ID"));
        appInfo.setAppKey(XiaomiAgent.getMetaData(context, "MI_APP_KEY"));

        MiCommplatform.Init(context, appInfo, new OnInitProcessListener() {
            @Override
            public void finishInitProcess(List<String> list, int code) {
                Log.i(XiaomiAgent.TAG, "finishInitProcess" + code);
            }
        });
    }
    public void login(Activity activity, OnLoginProcessListener listener) {
        MiCommplatform.getInstance().miLogin(activity, listener);
    }
    /*
    * jsonStr: {
    *  order_id: 商家唯一订单ID
    *  cpUserInfo: 商家信息，会透传给支付回调
    *  amount: 金额，单位元
    *  productCode: 后台申请的产品代码，有amount会忽略此参数
    *  count: 用产品代码购买时，可消耗商品的购买数量，非消耗产品只能为1，不传默认为1
    *  extralInfo: 额外信息，网游必传
    *    roleId: 玩家ID
    *    roleName: 玩家昵称
    *    lv: 玩家等级
    *    serverName: 所在服务器名
    *    balance: 用户余额
    *    vip: vip等级
    *    partyName: 工会
    * }
    **/
    public void pay(Activity activity, String jsonStr, OnPayProcessListener listener) {
        MiBuyInfo buyInfo = new MiBuyInfo();
        try {
            JSONObject jsonObj = new JSONObject(jsonStr);
            if (jsonObj.has("order_id")) {
                buyInfo.setCpOrderId(jsonObj.getString("order_id"));
            } else {
                buyInfo.setCpOrderId(UUID.randomUUID().toString());
            }
            if (jsonObj.has("cpUserInfo")) {
                buyInfo.setCpUserInfo(jsonObj.getString("cpUserInfo"));
            } else {
                buyInfo.setCpUserInfo("cpUserInfoDefault");
            }
            if (jsonObj.has("amount")) {
                buyInfo.setAmount(jsonObj.getInt("amount"));
            } else if (jsonObj.has("productCode")) {
                buyInfo.setProductCode(jsonObj.getString("productCode"));
                if (jsonObj.has("count")) {
                    buyInfo.setCount(jsonObj.getInt("count"));
                } else {
                    buyInfo.setCount(1);
                }
            }
            if (jsonObj.has("extralInfo")) {
                Bundle extralInfo = new Bundle();
                JSONObject extralObj = jsonObj.getJSONObject("extralInfo");

                String key;
                Iterator<String> keys = extralObj.keys();
                while(keys.hasNext()) {
                    key = keys.next();
                    extralInfo.putString(key, extralObj.getString(key));
                }
                buyInfo.setExtraInfo(extralInfo);
            }
        } catch (JSONException e) {
            e.printStackTrace();
        }
        MiCommplatform.getInstance().miUniPay(activity, buyInfo, listener);
    }

    public void exitGame(Activity activity, OnExitListner listener) {
        MiCommplatform.getInstance().miAppExit(activity, listener);
    }
}
