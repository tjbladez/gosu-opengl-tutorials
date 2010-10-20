require 'gosu'
require 'gl'
require 'glu'
require 'glut'

include Gl
include Glu

class Texture
  attr_accessor :info
  def initialize(window)
    @image = Gosu::Image.new(window, "resources/nehe/lesson06/ruby.png", true)
    @info = @image.gl_tex_info
  end
end
class Window < Gosu::Window
  attr_accessor :rotation_angle
  
  def initialize
    super(800, 600, false)
    self.caption = "Lesson #6 - Texture Mapping"
    texture = Texture.new(self)
    @texture_info = texture.info
    @x_angle = @y_angle = @z_angle = 0
  end
  
  def update
    @x_angle += 0.3
    @y_angle += 0.2
    @z_angle += 0.4
  end
  
  def draw
    gl do  
      glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT) #see lesson 01
          
      glEnable(GL_DEPTH_TEST) # enables depth testing
      
      # Our depth function. Everything that is less or equal the actual value gets drawn. Depth buffet value is 1/z
      glDepthFunc(GL_LEQUAL)
          
      glMatrixMode(GL_PROJECTION) #see lesson01
      glLoadIdentity # see lesson01
            
      gluPerspective(45.0, width / height, 0.1, 100.0) #see lesson 01
      glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST) #Perspective correction calculation for most correct/highest quality value
      glMatrixMode(GL_MODELVIEW)  #see lesson 01
      glLoadIdentity #see lesson 01
          
      glTranslate(0, 0, -10) #see lesson 01
      
      glEnable(GL_TEXTURE_2D) #see lesson 01
      glBindTexture(GL_TEXTURE_2D, @texture_info.tex_name) #see lesson 01
      
      glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR) #linear filter when image is larger than actual texture
      glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR) #linear filter when image is smaller than actual texture
      glRotatef(@x_angle, 1, 0, 0) # see nehe04
      glRotatef(@y_angle, 0, 1, 0) # see nehe04
      glRotatef(@z_angle, 0, 0, 1) # see nehe04      
        
      glBegin(GL_QUADS)
        glTexCoord2f(0, 0); glVertex3f(-1, -1,  1) # see lesson 01
        glTexCoord2f(1, 0); glVertex3f( 1, -1,  1)
        glTexCoord2f(1, 1); glVertex3f( 1,  1,  1)
        glTexCoord2f(0, 1); glVertex3f(-1,  1,  1)
        glTexCoord2f(1, 0); glVertex3f(-1, -1, -1)
        glTexCoord2f(1, 1); glVertex3f(-1,  1, -1)
        glTexCoord2f(0, 1); glVertex3f( 1,  1, -1)
        glTexCoord2f(0, 0); glVertex3f( 1, -1, -1)
                                              
        glTexCoord2f(0, 1); glVertex3f(-1,  1, -1)
        glTexCoord2f(0, 0); glVertex3f(-1,  1,  1)
        glTexCoord2f(1, 0); glVertex3f( 1,  1,  1)
        glTexCoord2f(1, 1); glVertex3f( 1,  1, -1)
                                                
        glTexCoord2f(1, 1); glVertex3f(-1, -1, -1)
        glTexCoord2f(0, 1); glVertex3f( 1, -1, -1)
        glTexCoord2f(0, 0); glVertex3f( 1, -1,  1)
        glTexCoord2f(1, 0); glVertex3f(-1, -1,  1)
                                              
        glTexCoord2f(1, 0); glVertex3f( 1, -1, -1)
        glTexCoord2f(1, 1); glVertex3f( 1,  1, -1)
        glTexCoord2f(0, 1); glVertex3f( 1,  1,  1)
        glTexCoord2f(0, 0); glVertex3f( 1, -1,  1)
                                         
        glTexCoord2f(0, 0); glVertex3f(-1, -1, -1)
        glTexCoord2f(1, 0); glVertex3f(-1, -1,  1)
        glTexCoord2f(1, 1); glVertex3f(-1,  1,  1)
        glTexCoord2f(0, 1); glVertex3f(-1,  1, -1)
      glEnd
    end
  end
  
  def button_down(id)
    if id == Gosu::KbEscape
      close
    end
  end
end

window = Window.new
window.show