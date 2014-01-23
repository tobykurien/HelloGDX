package com.tobykurien.hellogdx

import com.badlogic.gdx.Application
import com.badlogic.gdx.ApplicationListener
import com.badlogic.gdx.Gdx
import com.tobykurien.hellogdx.step3.GameRenderer
import com.tobykurien.hellogdx.step3.GameSimulation
import com.tobykurien.libgdx.ThreeD.GameLoop

class MainStep3 implements ApplicationListener {
   GameLoop loop
   
   override create() {
      Gdx.app => [
         setLogLevel(Application.LOG_DEBUG)
         debug("main", "create called")
      ]
      
      loop = new GameLoop(new GameRenderer, new GameSimulation)
   }

   override render() {
      loop.render(Gdx.graphics.deltaTime)
   }

   override resize(int width, int height) {
      loop.resize(width, height)
   }

   override pause() {
      loop.pause
   }

   override resume() {
      loop.resume
   }

   override dispose() {
      loop.dispose
   }
}
