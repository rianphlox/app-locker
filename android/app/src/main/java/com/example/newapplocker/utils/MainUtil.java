package com.example.newapplocker.utils;

import android.annotation.SuppressLint;
import android.content.Context;
import android.content.SharedPreferences;
import android.preference.PreferenceManager;

import androidx.annotation.Nullable;

public class MainUtil {
    @SuppressLint("StaticFieldLeak")
    private volatile static MainUtil mInstance;

    private Context mContext;
    private SharedPreferences mPref;

    private MainUtil() {
    }

    public static MainUtil getInstance() {
        if (null == mInstance) {
            synchronized (MainUtil.class) {
                if (null == mInstance) {
                    mInstance = new MainUtil();
                }
            }
        }
        return mInstance;
    }

    public void init(Context context) {
        if (mContext == null) {
            mContext = context.getApplicationContext();
        }
        if (mPref == null) {
            mPref = PreferenceManager.getDefaultSharedPreferences(mContext);
        }
    }

    public void putString(String key, String value) {
        if (mPref != null) {
            SharedPreferences.Editor editor = mPref.edit();
            editor.putString(key, value);
            editor.apply();
        }
    }

    public void putLong(String key, long value) {
        if (mPref != null) {
            SharedPreferences.Editor editor = mPref.edit();
            editor.putLong(key, value);
            editor.apply();
        }
    }

    public void putInt(String key, int value) {
        if (mPref != null) {
            SharedPreferences.Editor editor = mPref.edit();
            editor.putInt(key, value);
            editor.apply();
        }
    }

    public void putBoolean(String key, boolean value) {
        if (mPref != null) {
            SharedPreferences.Editor editor = mPref.edit();
            editor.putBoolean(key, value);
            editor.apply();
        }
    }

    public boolean getBoolean(String key) {
        return getBoolean(key, false);
    }

    public boolean getBoolean(String key, boolean def) {
        return mPref != null ? mPref.getBoolean(key, def) : def;
    }

    @Nullable
    public String getString(String key, String def) {
        return mPref != null ? mPref.getString(key, def) : def;
    }

    @Nullable
    public String getString(String key) {
        return getString(key, null);
    }

    public long getLong(String key, long def) {
        return mPref != null ? mPref.getLong(key, def) : def;
    }

    public int getInt(String key, int def) {
        return mPref != null ? mPref.getInt(key, def) : def;
    }

    public void clear() {
        if (mPref != null) {
            SharedPreferences.Editor editor = mPref.edit();
            editor.clear();
            editor.apply();
        }
    }

    public void remove(String key) {
        if (mPref != null) {
            SharedPreferences.Editor editor = mPref.edit();
            editor.remove(key);
            editor.apply();
        }
    }
}