package com.tobykurien.hellogdx

import com.badlogic.gdx.Gdx
import com.badlogic.gdx.Input
import com.badlogic.gdx.audio.Music
import com.badlogic.gdx.audio.Sound
import com.badlogic.gdx.files.FileHandle
import com.badlogic.gdx.graphics.Color
import com.badlogic.gdx.graphics.VertexAttributes.Usage
import com.badlogic.gdx.graphics.g3d.Material
import com.badlogic.gdx.graphics.g3d.Model
import com.badlogic.gdx.graphics.g3d.ModelInstance
import com.badlogic.gdx.graphics.g3d.attributes.ColorAttribute
import com.badlogic.gdx.graphics.g3d.loader.ObjLoader
import com.badlogic.gdx.math.Quaternion
import com.badlogic.gdx.math.Vector3
import com.tobykurien.libgdx.ThreeD.Simulation
import java.util.ArrayList
import java.util.List

class GameSimulation extends Simulation {
   var bullets = new ArrayList<ModelInstance>
   var Sound pew
   var Model bullet
   long lastBulletTime
   Music menuMusic
   boolean paused = false
   
   int middleX   
   int middleY
   
   override populate() {
      middleX = Gdx.graphics.width / 2
      middleY = Gdx.graphics.height / 2

      menuMusic = Gdx.audio.newMusic(new FileHandle("data/plane.ogg"))
      disposables.add(menuMusic)
      menuMusic.setLooping(true)      
      //menuMusic.play
      
      pew = Gdx.audio.newSound(new FileHandle("data/laser_shooting_sfx.wav"))
      
      // programmatic models
      var boxmodel = modelBuilder.createSphere(1f, 1f, 1f, 20, 20,
            new Material(ColorAttribute.createDiffuse(Color.BLUE)),
            Usage.Position.bitwiseOr(Usage.Normal));      
      var boxinst = new ModelInstance(boxmodel)
      boxinst.transform.setToTranslation(0, -1, 0)
      instances.add(boxinst)
      things.put("earth", boxinst)
      disposables.add(boxmodel)

      // bullet
      bullet = modelBuilder.createCapsule(0.1f, 0.5f, 3,
            new Material(ColorAttribute.createDiffuse(Color.RED)),
            Usage.Position.bitwiseOr(Usage.Normal));      
      disposables.add(bullet)

      loadAllModels("data")
      
      // catch cursor
      Gdx.input.setCursorCatched(true);
      Gdx.input.setCursorPosition(middleX, middleY);
   }
   
   override update(float delta) {
      if (paused) return;
      if (Gdx.input.isKeyPressed(Input.Keys.ESCAPE)) {
         Gdx.app.exit
      }
      
      val ship = things.get("ship")
      val space = things.get("spacesphere")
      
      // move ship
      val speed = 0.2f
      var translate = new Vector3(0,0,0)
      if (Gdx.input.isKeyPressed(Input.Keys.S)) {
          translate = new Vector3(0, 0, -1*speed)
      } 
      if (Gdx.input.isKeyPressed(Input.Keys.W)) {
          translate = new Vector3(0, 0, speed)
      } 
      if (Gdx.input.isKeyPressed(Input.Keys.A)) {
          translate = new Vector3(speed, 0, 0)
      } 
      if (Gdx.input.isKeyPressed(Input.Keys.D)) {
          translate = new Vector3(-1*speed, 0, 0)
      }
      if (Gdx.input.isKeyPressed(Input.Keys.SPACE)) {
          translate = new Vector3(0, speed, 0)
      } 
      if (Gdx.input.isKeyPressed(Input.Keys.SHIFT_LEFT)) {
          translate = new Vector3(0, -1*speed, 0)
      }

      ship.transform.translate(translate)

      val rotX = (middleX - Gdx.input.x) / 16
      val rotY = (middleY - Gdx.input.y) / 16
      rotateX(ship, rotX)
      rotateY(ship, rotY)
      
      // camera, cursor and space follows the ship
      val tr = shipTranslate
      space.transform.setToTranslation(tr)
      
      if (Gdx.input.isButtonPressed(Input.Buttons.LEFT) && 
            (System.currentTimeMillis - lastBulletTime) > 100) {
         // fire a bullet   
         pew.play       
         var b = new ModelInstance(bullet)
         b.transform.set(ship.transform).translate(0, 0, 0.5f)
         bullets.add(b)
         instances.add(b)
         lastBulletTime = System.currentTimeMillis
      }

      // make bullets clone so we can modify bullets
      var bulletsClone = bullets.clone as List<ModelInstance> 
      // move bullets
      bulletsClone.forEach [b|
         if (b.transform.values.get(14) > 20) {
            bullets.remove(b)
            instances.remove(b)
         } else {
            b.transform.translate(0f, 0f, 0.5f)
         }
      ]
      //Gdx.app.debug("bullets", bullets.length.toString)
   }

   override pause() {
      menuMusic.pause
      paused = true
   }
   
   override resume() {
      paused = false
      menuMusic.play
   }
   
   public def getShipTranslate() {
      things.get("ship").transform.getTranslation(new Vector3(0,0,0))
   }
   
   def rotateX(ModelInstance ship, int rotX) {
      val rotXAxis = new Vector3(0,1,0)
      var curRotX = (ship.transform.getRotation(new Quaternion)
                     .getAxisAngle(rotXAxis) * rotXAxis.nor().y) as int
      curRotX = if (curRotX < 0) curRotX + 360 else curRotX
      var nRotX = if (rotX < 0) rotX + 360 else rotX
      var newRotX = nRotX - curRotX
      if (newRotX != 0) ship.transform.rotate(new Vector3(0,1,0), newRotX)
   }

   def rotateY(ModelInstance ship, int rotX) {
      val rotXAxis = new Vector3(1,0,0)
      var curRotX = (ship.transform.getRotation(new Quaternion)
                     .getAxisAngle(rotXAxis) * rotXAxis.nor().x) as int
      curRotX = if (curRotX < 0) curRotX + 360 else curRotX
      var nRotX = if (rotX < 0) rotX + 360 else rotX
      var newRotX = nRotX - curRotX
      if (newRotX != 0) ship.transform.rotate(new Vector3(1,0,0), newRotX)
   }   
}