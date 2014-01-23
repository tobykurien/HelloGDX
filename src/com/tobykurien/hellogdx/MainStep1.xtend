package com.tobykurien.hellogdx

import com.badlogic.gdx.Application
import com.badlogic.gdx.ApplicationListener
import com.badlogic.gdx.Gdx
import com.badlogic.gdx.Graphics
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
import java.util.ArrayList
import com.badlogic.gdx.files.FileHandle

class MainStep1 implements ApplicationListener {
   var PerspectiveCamera cam
   var ModelBatch modelBatch;
   var Model model;
   var ArrayList<ModelInstance> instances;
   
   var Environment environment;
   var CameraInputController camController;
   var DirectionalLight light;
   
   override create() {
      Gdx.app => [
         setLogLevel(Application.LOG_DEBUG)
         debug("MyTag", "create called")
      ]

      //var menuMusic = Gdx.audio.newMusic(new FileHandle("data/menu.mp3"))
      //menuMusic.play

      modelBatch = new ModelBatch();

      cam = new PerspectiveCamera(67, Gdx.graphics.width, Gdx.graphics.height) => [
         position.set(2f, 2f, 2f);
         lookAt(0, 0, 0);
         near = 0.1f;
         far = 300f;
         update();
      ]
      
      camController = new CameraInputController(cam);
      Gdx.input.setInputProcessor(camController);
        
      instances = new ArrayList<ModelInstance>
      var modelBuilder = new ModelBuilder();

      var boxmodel = modelBuilder.createBox(1f, 1f, 1f,
            new Material(ColorAttribute.createDiffuse(Color.BLUE)),
            Usage.Position.bitwiseOr(Usage.Normal));
      var boxinst = new ModelInstance(boxmodel)
      boxinst.transform.setToTranslation(0, -1, 0)
      instances.add(boxinst)
      
      model = new ObjLoader().loadModel(Gdx.files.internal("data/EvilShip.obj"))            
      instances.add(new ModelInstance(model))

      var backdrop = new ObjLoader().loadModel(Gdx.files.internal("data/spacesphere.obj"))            
      instances.add(new ModelInstance(backdrop))
      
      light = new DirectionalLight().set(1f, 1f, 1f, -1f, -1f, -1f)
      environment = new Environment() => [
         set(new ColorAttribute(ColorAttribute.AmbientLight, 0.4f, 0.4f, 0.4f, 1f));
         add(light);  
      ]
   }

   override render() {
      camController.update();
      light.set(light.color, cam.direction)
      
      Gdx.gl => [
         glViewport(0, 0, Gdx.graphics.getWidth(), Gdx.graphics.getHeight())
         glClear(GL10.GL_COLOR_BUFFER_BIT.bitwiseOr(GL10.GL_DEPTH_BUFFER_BIT))  
      ]
 
      modelBatch.begin(cam);
      modelBatch.render(instances, environment);
      modelBatch.end();      
   }

   override resize(int width, int height) {
   }

   override resume() {
   }


   override dispose() {
      modelBatch.dispose();
      model.dispose();
   }

   override pause() {
   }
}
