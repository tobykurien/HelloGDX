package com.tobykurien.hellogdx

import com.badlogic.gdx.ApplicationListener
import com.badlogic.gdx.Gdx

class Main implements ApplicationListener {
   ScreenRenderer renderer
      
   override create() {
      renderer = new ScreenRenderer()
      renderer.setup
   }
   
   override dispose() {
      renderer.dispose
   }
   
   override pause() {
   }
   
   override render() {
      renderer.render(Gdx.graphics.deltaTime)
   }
   
   override resize(int width, int height) {
   }
   
   override resume() {
   }
   
}