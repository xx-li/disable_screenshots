package com.devlxx.disable_screenshots

import android.util.Log

class test {
    private fun bsgfdfsdsf() {
        val screenShotListenManager = ScreenShotListenManager.newInstance(null)
        screenShotListenManager.setListener { imagePath ->
            val index = imagePath[5].toInt()
            Log.w("TAG", "Get screen real size failed.")
        }
        screenShotListenManager.startListen()
    }
}