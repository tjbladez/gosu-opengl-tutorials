require File.expand_path('../../config/boot', __FILE__)

class Texture
  attr_accessor :info
  def initialize(window)
    @image = Gosu::Image.new(window, "resources/nehe/lesson08/Glass.bmp", true)
    @info = @image.gl_tex_info
  end
end

class Window < Gosu::Window
  attr_accessor :current_filter

  def initialize
    super(800, 600, false)
    self.caption = "Lesson #8 - Texture blending, transparency"
    initialize_light
    initialize_textures
    @x_angle  = @y_angle = 0
    @x_change  = @y_change = 0.2
    @z_depth  = -5
    @light_on = false
    @blending
  end

  def initialize_light
    @ambient_light = [0.5, 0.5, 0.5, 1] # see nehe07
    @diffuse_light = [1, 1, 1, 1] # see nehe07
    @light_postion = [0, 0, 2, 1] # see nehe07
  end

  def initialize_textures
    @nearest = Texture.new(self)
    glBindTexture(GL_TEXTURE_2D, @nearest.info.tex_name) # see lesson 1
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_NEAREST) # see nehe07
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_NEAREST) # see nehe07

    @linear = Texture.new(self)
    glBindTexture(GL_TEXTURE_2D, @linear.info.tex_name)
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR) # see nehe06
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR)

    @minimap = Texture.new(self)
    glBindTexture(GL_TEXTURE_2D, @minimap.info.tex_name)
    texture = glGetTexImage(GL_TEXTURE_2D, 0, GL_RGB, GL_FLOAT) # see nehe07
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR)

    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR_MIPMAP_NEAREST) # see nehe07
    gluBuild2DMipmaps(GL_TEXTURE_2D, 3, 128, 128, GL_RGB, GL_FLOAT, texture) # see nehe07
    @filters = [@nearest.info.tex_name, @linear.info.tex_name, @minimap.info.tex_name]
  end

  def update
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
      glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST) #see nehe07
      glMatrixMode(GL_MODELVIEW)  #see lesson 01
      glLoadIdentity #see lesson 01

      glColor4f(1.0,1.0,1.0,0.5) # full brightness, 50% opacity
      glBlendFunc(GL_SRC_ALPHA,GL_ONE) # blending function for translucency based on alpha source

      glEnable(GL_TEXTURE_2D) #see lesson01
      glShadeModel(GL_SMOOTH) # see nehe07
      glLightfv(GL_LIGHT1, GL_AMBIENT, @ambient_light) # see nehe07
      glLightfv(GL_LIGHT1, GL_DIFFUSE, @diffuse_light) # see nehe07
      glLightfv(GL_LIGHT1, GL_POSITION, @light_postion) # see nehe07
      glEnable(GL_LIGHT1) # see nehe07
      @light_on ? glEnable(GL_LIGHTING) : glDisable(GL_LIGHTING) # see nehe07
      if @blending
        glEnable(GL_BLEND) # enable blending
        glDisable(GL_DEPTH_TEST) # disable depth
      else
        glDisable(GL_BLEND)
      	glEnable(GL_DEPTH_TEST)
      end
      glTranslate(0, 0, @z_depth) #see lesson 01

      glBindTexture(GL_TEXTURE_2D, current_filter) #see lesson 01
      glRotatef(@x_angle, 1, 0, 0) # see nehe04
      glRotatef(@y_angle, 0, 1, 0) # see nehe04

      glBegin(GL_QUADS)
        glNormal3f(0, 0, 1) # see nehe07
        glTexCoord2f(0, 0); glVertex3f(-1, -1,  1) # see lesson 01
        glTexCoord2f(1, 0); glVertex3f( 1, -1,  1)
        glTexCoord2f(1, 1); glVertex3f( 1,  1,  1)
        glTexCoord2f(0, 1); glVertex3f(-1,  1,  1)

        glNormal3f(0, 0, -1)
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
    case id
    when Gosu::Button::KbEscape then close
    when Gosu::Button::KbL then @light_on = !@light_on
    when Gosu::Button::KbF then change_filter!
    when Gosu::Button::KbB then @blending = !@blending
    end
  end
end

window = Window.new
window.show