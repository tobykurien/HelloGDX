package com.tobykurien.hellogdx.step3

import com.badlogic.gdx.Gdx
import com.badlogic.gdx.graphics.GL10
import com.badlogic.gdx.graphics.g3d.attributes.ColorAttribute
import com.badlogic.gdx.graphics.g3d.environment.DirectionalLight
import com.tobykurien.libgdx.ThreeD.Renderer
import com.tobykurien.libgdx.ThreeD.Simulation

class GameRenderer extends Renderer {

   override setup() {
      camera => [
         near = 0.1f;
         far = 300f;
         update();
      ]
      
      lights.add(new DirectionalLight().set(10f, 10f, 10f, 0f, -10f, 10f))
      environment.set(new ColorAttribute(
         ColorAttribute.AmbientLight, 0.8f, 0.8f, 0.8f, 1f
      ))
   }

   override setProjectionAndCamera(Simulation simulation) {
      // camera and light to follow the ship
      val sim = simulation as GameSimulation
      val tr = sim.shipTranslation
      val rotX = sim.rotationX

      camera.position.set(tr.cpy.add(0,1,-3))
      camera.lookAt(tr.add(rotX,0,100))
      camera.update

      var light = lights.get(0)
      light.set(light.color, camera.direction)
   }
   
}
