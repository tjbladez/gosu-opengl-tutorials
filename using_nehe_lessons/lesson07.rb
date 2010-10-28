require 'gosu'
require 'gl'
require 'glu'
require 'glut'

include Gl
include Glu

class Texture
  attr_accessor :info
  def initialize(window)
    @image = Gosu::Image.new(window, "resources/nehe/lesson07/crate.png", true)
    @info = @image.gl_tex_info
  end
end

class Window < Gosu::Window
  attr_accessor :current_filter

  def initialize
    super(800, 600, false)
    self.caption = "Lesson #7 - Texture Filters, Lighting and Keyboard Control"
    initialize_light
    initialize_textures
    @x_angle  = @y_angle = 0
    @x_change  = @y_change = 0.2
    @z_depth  = -5
    @light_on = false
  end

  def initialize_light
    @ambient_light = [0.5, 0.5, 0.5, 1] # ambient light - lights all objects on the scene equally, format is RGBA
    @diffuse_light = [1, 1, 1, 1] # diffuse light is created by the light source and reflects off the surface of an object, format is also RGBA
    @light_postion = [0, 0, 2, 1] # position of the light source from the current point
  end

  def initialize_textures
    gl do
      nearest = Texture.new(self)
    	glBindTexture(GL_TEXTURE_2D, nearest.info.tex_name); # see lesson 1
  		glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_NEAREST) # Nearest filter is the worst on quality
  		glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_NEAREST) # but fastest and lowest need for processing power

  		linear = Texture.new(self)
  		glBindTexture(GL_TEXTURE_2D, linear.info.tex_name);
  		glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR) # Linear filter, good quality - high demands see nehe06
  		glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR)

  		minimap = Texture.new(self)
  		glBindTexture(GL_TEXTURE_2D, minimap.info.tex_name);
  		texture = glGetTexImage(GL_TEXTURE_2D, 0, GL_RGB, GL_FLOAT) #use texture data to get data for buildimg a mipmap
  		glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR)
  		# Mipmapping. OpenGL tried to build different sized high quality texture. When you draw it OpenGL will select the best
  		# looking texture from ones it built and draw that instead of resizing the original image which can cause detail loss
  		glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR_MIPMAP_NEAREST)
  		gluBuild2DMipmaps(GL_TEXTURE_2D, 3, 128, 128, GL_RGB, GL_FLOAT, texture) # building mipmaps
  		@filters = [nearest.info.tex_name, linear.info.tex_name, minimap.info.tex_name]
	  end
  end

  def update
    @light_on = !@light_on if button_down? Gosu::Button::KbL # switch light on or off is L is pressed
    change_filter! if button_down? Gosu::Button::KbF # change filter if F is pressed
    @z_depth -= 0.2 if button_down? Gosu::Button::KbPageUp
    @z_depth += 0.2 if button_down? Gosu::Button::KbPageDown
    @x_change -= 0.01 if button_down? Gosu::Button::KbUp
    @x_change += 0.01 if button_down? Gosu::Button::KbDown
    @y_change -= 0.01 if button_down? Gosu::Button::KbLeft
    @y_change += 0.01 if button_down? Gosu::Button::KbRight
    @x_angle += @x_change
    @y_angle += @y_change
  end

  def change_filter!
    index = @filters.index(current_filter)
    index > 1 ? index = 0 : index += 1
    @current_filter = @filters[index]
  end

  def current_filter
    @current_filter ||= @filters.first
  end

  def draw
    gl do
      glClearColor(0,0,0,0.5) #see lesson 01
      glClearDepth(1) #see lesson 01
      glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT) #see lesson 01
      glEnable(GL_DEPTH_TEST) # see nehe06
      glDepthFunc(GL_LEQUAL) # see nehe06

      glMatrixMode(GL_PROJECTION) #see lesson01
      glLoadIdentity # see lesson01
      gluPerspective(45.0, width / height, 0.1, 100.0) #see lesson 01
      glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST) #Perspective correction calculation for most correct/highest quality value
      glMatrixMode(GL_MODELVIEW)  #see lesson 01
      glLoadIdentity #see lesson 01


      glEnable(GL_TEXTURE_2D) #see lesson01
      glShadeModel(GL_SMOOTH) # selects smooth shading
      glLightfv(GL_LIGHT1, GL_AMBIENT, @ambient_light) # sets ambient light for light source
      glLightfv(GL_LIGHT1, GL_DIFFUSE, @diffuse_light) # sets diffuse light for light source
      glLightfv(GL_LIGHT1, GL_POSITION, @light_postion) # sets position of light
      glEnable(GL_LIGHT1) # enables prepared light source
      @light_on ? glEnable(GL_LIGHTING) : glDisable(GL_LIGHTING) # enables / disables lighting of the scene based on light switch
      glTranslate(0, 0, @z_depth) #see lesson 01

      glBindTexture(GL_TEXTURE_2D, current_filter) #see lesson 01
      glRotatef(@x_angle, 1, 0, 0) # see nehe04
      glRotatef(@y_angle, 0, 1, 0) # see nehe04

      glBegin(GL_QUADS)
        # normal pointing to viewer. Normal is a line from the middle of the polygon at 90 degree angle. It is needed to tell opengl which
        # direction the polygon is facing.
        glNormal3f(0, 0, 1)
        glTexCoord2f(0, 0); glVertex3f(-1, -1,  1) # see lesson 01
        glTexCoord2f(1, 0); glVertex3f( 1, -1,  1)
        glTexCoord2f(1, 1); glVertex3f( 1,  1,  1)
        glTexCoord2f(0, 1); glVertex3f(-1,  1,  1)

        glNormal3f(0, 0, -1) # normal point away from viewer
        glTexCoord2f(1, 0); glVertex3f(-1, -1, -1)
        glTexCoord2f(1, 1); glVertex3f(-1,  1, -1)
        glTexCoord2f(0, 1); glVertex3f( 1,  1, -1)
        glTexCoord2f(0, 0); glVertex3f( 1, -1, -1)

        glNormal3f(0, 1, 0)
        glTexCoord2f(0, 1); glVertex3f(-1,  1, -1)
        glTexCoord2f(0, 0); glVertex3f(-1,  1,  1)
        glTexCoord2f(1, 0); glVertex3f( 1,  1,  1)
        glTexCoord2f(1, 1); glVertex3f( 1,  1, -1)

        glNormal3f(0, -1, 0)
        glTexCoord2f(1, 1); glVertex3f(-1, -1, -1)
        glTexCoord2f(0, 1); glVertex3f( 1, -1, -1)
        glTexCoord2f(0, 0); glVertex3f( 1, -1,  1)
        glTexCoord2f(1, 0); glVertex3f(-1, -1,  1)

        glNormal3f(1, 0, 0)
        glTexCoord2f(1, 0); glVertex3f( 1, -1, -1)
        glTexCoord2f(1, 1); glVertex3f( 1,  1, -1)
        glTexCoord2f(0, 1); glVertex3f( 1,  1,  1)
        glTexCoord2f(0, 0); glVertex3f( 1, -1,  1)

        glNormal3f(-1, 0, 0)
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