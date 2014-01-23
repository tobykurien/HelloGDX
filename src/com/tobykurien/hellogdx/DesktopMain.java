package com.tobykurien.hellogdx;

import com.badlogic.gdx.backends.lwjgl.LwjglApplication;
import com.badlogic.gdx.backends.lwjgl.LwjglApplicationConfiguration;

public class DesktopMain {
   public static void main(String[] args) {
      LwjglApplicationConfiguration cfg = new LwjglApplicationConfiguration();
      cfg.width = 1024;
      cfg.height = 768;

      // fullscreen
      cfg.fullscreen = false;
      // vSync
      cfg.vSyncEnabled = true;
      
      new LwjglApplication(new Main(), cfg);
   }
}
