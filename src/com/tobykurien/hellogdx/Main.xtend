package com.tobykurien.hellogdx

import com.badlogic.gdx.Application
import com.badlogic.gdx.ApplicationListener
import com.badlogic.gdx.Gdx
import com.badlogic.gdx.Input
import com.badlogic.gdx.audio.Music
import com.badlogic.gdx.audio.Sound
import com.badlogic.gdx.files.FileHandle
import com.badlogic.gdx.graphics.Color
import com.badlogic.gdx.graphics.GL10
import com.badlogic.gdx.graphics.PerspectiveCamera
import com.badlogic.gdx.graphics.VertexAttributes.Usage
import com.badlogic.gdx.graphics.g3d.Environment
import com.badlogic.gdx.graphics.g3d.Material
import com.badlogic.gdx.graphics.g3d.Model
import com.badlogic.gdx.graphics.g3d.ModelBatch
import com.badlogic.gdx.graphics.g3d.ModelInstance
import com.badlogic.gdx.graphics.g3d.attributes.ColorAttribute
import com.badlogic.gdx.graphics.g3d.environment.DirectionalLight
import com.badlogic.gdx.graphics.g3d.loader.ObjLoader
import com.badlogic.gdx.graphics.g3d.utils.CameraInputController
import com.badlogic.gdx.graphics.g3d.utils.ModelBuilder
import com.badlogic.gdx.math.Vector3
import com.badlogic.gdx.utils.Disposable
import java.util.ArrayList
import java.util.List
import java.util.WeakHashMap
import com.badlogic.gdx.math.Quaternion

class Main implements ApplicationListener {
   var PerspectiveCamera cam
   var ModelBatch modelBatch;
   var instances = new ArrayList<ModelInstance>
   var things = new WeakHashMap<String, ModelInstance>
   var disposable = new ArrayList<Disposable>
   
   var bullets = new ArrayList<ModelInstance>
   var Sound pew
   var Model bullet
   long lastBulletTime
   
   var Environment environment;
   var CameraInputController camController;
   var DirectionalLight light;
   
   Music menuMusic
   boolean paused = false
   
   int middleX   
   int middleY
   
   override create() {
      Gdx.app => [
         setLogLevel(Application.LOG_DEBUG)
         debug("main", "create called")
      ]

      middleX = Gdx.graphics.width / 2
      middleY = Gdx.graphics.height / 2

      menuMusic = Gdx.audio.newMusic(new FileHandle("data/plane.ogg"))
      disposable.add(menuMusic)
      menuMusic.setLooping(true)      
      //menuMusic.play
      
      pew = Gdx.audio.newSound(new FileHandle("data/laser_shooting_sfx.wav"))

      modelBatch = new ModelBatch();

      cam = new PerspectiveCamera(67, Gdx.graphics.width, Gdx.graphics.height)
      cam => [
         //position.set(2f, 2f, 2f);
         //lookAt(0, 0, 0);
         near = 0.1f;
         far = 300f;
         update();
      ]

      //camController = new CameraInputController(cam);
      //Gdx.input.setInputProcessor(camController);
        
      var modelBuilder = new ModelBuilder();

      // programmatic models
      var boxmodel = modelBuilder.createSphere(1f, 1f, 1f, 20, 20,
            new Material(ColorAttribute.createDiffuse(Color.BLUE)),
            Usage.Position.bitwiseOr(Usage.Normal));      
      var boxinst = new ModelInstance(boxmodel)
      boxinst.transform.setToTranslation(0, -1, 0)
      instances.add(boxinst)
      things.put("earth", boxinst)
      disposable.add(boxmodel)

      // bullet
      bullet = modelBuilder.createCapsule(0.1f, 0.5f, 3,
            new Material(ColorAttribute.createDiffuse(Color.RED)),
            Usage.Position.bitwiseOr(Usage.Normal));      
      disposable.add(bullet)
      
      // load all models from assets      
      var fd = Gdx.files.internal("data")
      val loader = new ObjLoader()
      fd.list(".obj").forEach [m|
         var model = loader.loadModel(m)
         var inst = new ModelInstance(model)
         instances.add(inst)
         things.put(m.nameWithoutExtension, inst)
         disposable.add(model)
      ]

      light = new DirectionalLight().set(10f, 10f, 10f, 0f, -10f, 10f)
      environment = new Environment() => [
         set(new ColorAttribute(ColorAttribute.AmbientLight, 0.8f, 0.8f, 0.8f, 1f));
         add(light);  
      ]

      // catch cursor
      Gdx.input.setCursorCatched(true);
      Gdx.input.setCursorPosition(middleX, middleY);
   }

   override render() {
      if (paused) return;
      if (Gdx.input.isKeyPressed(Input.Keys.ESCAPE)) {
         Gdx.app.exit
      }
      
      Gdx.gl => [
         glViewport(0, 0, Gdx.graphics.getWidth(), Gdx.graphics.getHeight())
         glClear(GL10.GL_COLOR_BUFFER_BIT.bitwiseOr(GL10.GL_DEPTH_BUFFER_BIT))  
      ]

      light.set(light.color, cam.direction)
      
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
      val tr = ship.transform.getTranslation(new Vector3(0,0,0))
      space.transform.setToTranslation(tr)
      cam.position.set(tr.cpy.add(0,1,-3))
      cam.lookAt(tr.add(rotX,0,100))
      cam.update
      
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

      modelBatch.begin(cam);
      modelBatch.render(instances, environment);
      modelBatch.end();      
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

   override resize(int width, int height) {
      //Gdx.gl.glViewport(0, 0, width, height)
   }


   override pause() {
      menuMusic.pause
      paused = true
   }

   override resume() {
      menuMusic.play
      paused = false;
   }


   override dispose() {
      modelBatch.dispose
      disposable.forEach[ it.dispose ]
   }
}
