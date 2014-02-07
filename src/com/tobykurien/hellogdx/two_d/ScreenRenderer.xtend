package com.tobykurien.hellogdx.two_d

import com.badlogic.gdx.Gdx
import com.badlogic.gdx.graphics.GL10
import com.badlogic.gdx.graphics.OrthographicCamera
import com.badlogic.gdx.graphics.Texture
import com.badlogic.gdx.graphics.g2d.Animation
import com.badlogic.gdx.graphics.g2d.SpriteBatch
import com.badlogic.gdx.graphics.g2d.TextureRegion
import java.util.List

class ScreenRenderer {
   SpriteBatch spriteBatch
   OrthographicCamera camera
   
   Texture splosion
   float elapsedTime
   Animation explosion

   Texture turtle
   List<Texture> tiles = newArrayList
   int[] map = #[
      0,0,0,3,3,
      0,4,4,1,1,
      0,0,0,1,1,
      0,0,0,1,1,
      2,2,2,1,1
   ]

   def setup() {
      spriteBatch = new SpriteBatch();
      camera = new OrthographicCamera(1024, 768);
      
      splosion = new Texture(Gdx.files.internal("data/explode.png"))
      val List<TextureRegion> frames = newArrayList
      new TextureRegion(splosion).split(256/4, 256/4).forEach [row|
         row.forEach [f|
            frames.add(f)
         ]
      ]
      explosion = new Animation(0.05f, frames)
      elapsedTime = 0f
      
      tiles.add(new Texture(Gdx.files.internal("data/2d/dirt.png")))
      tiles.add(new Texture(Gdx.files.internal("data/2d/grass.png")))
      tiles.add(new Texture(Gdx.files.internal("data/2d/grass_main.png")))
      tiles.add(new Texture(Gdx.files.internal("data/2d/grass_dead.png")))
   }

   def render(float delta) {
      var gl = Gdx.gl;

      //clear the screen with Black  
      gl.glClearColor(0, 0, 0, 1);
      gl.glClear(GL10.GL_COLOR_BUFFER_BIT);

      camera.update();
      elapsedTime = elapsedTime + delta

      spriteBatch.setProjectionMatrix(camera.combined);
      spriteBatch.enableBlending();

      spriteBatch.begin(); //<--  

      (0..4).forEach[row|
         (0..4).forEach [col|
            var x = ((5 - row) * 128) - (Gdx.graphics.width/2)
            var y = (col * 128) - (Gdx.graphics.width/2)
            var tile = map.get((row * 5) + col)
            var spr = if (tile == 0) {
               null
            } else {
               tiles.get(tile - 1)   
            }
            if (spr != null) spriteBatch.draw(spr, y, x)
         ]
      ]

      spriteBatch.draw(explosion.getKeyFrame(elapsedTime, true), 0, 0);
      spriteBatch.end(); //<-- 
   }
   
   def dispose() {
      spriteBatch.dispose
      splosion.dispose
   }
}
