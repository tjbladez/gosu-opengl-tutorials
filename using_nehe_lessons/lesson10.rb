require 'gosu'
require 'json'
require 'gl'
require 'glu'
require 'glut'
require 'ruby-debug'
include Gl
include Glu

class Texture
  attr_accessor :info
  def initialize(window)
    @image = Gosu::Image.new(window, "resources/nehe/lesson10/Mud.bmp", true)
    @info = @image.gl_tex_info
  end
end

class Vertex
  attr_reader :x, :y, :z, :u, :v

  def initialize(coords)
    coords.each do |coordinate, value|
      instance_variable_set(:"@#{coordinate}", value)
    end
  end
end

class Triangle
  attr_accessor :vertexes
  def initialize
    @vertexes = []
  end
end

class Window < Gosu::Window
  attr_accessor :triangles, :current_filter

  def initialize
    super(800, 600, false)
    self.caption = "Lesson #10 - Loading and moving through 3D World"
    @texture = Texture.new(self)
    setup_world
    init_defaults
    init_lights
    init_textures
  end
  def setup_world
    triangle_data = JSON.parse(File.read('resources/nehe/lesson10/world.json'))
    @triangles = triangle_data.inject([]) do |acc, vertexes|
      acc << Triangle.new.tap do |triangle|
        vertexes.each do |vertex|
          triangle.vertexes << Vertex.new(vertex)
        end
      end
      acc
    end
  end

  def init_defaults
    @light_on = false
    @blending = false
    @bouncing = @bouncing_angle = 0
    @x_pos = @look_up_or_down_pos = @y_angle = @look_up_or_down = 0
    @degree_radian_conversion = 0.0174532925 # pi / 180
  end

  def init_lights
     # see nehe07 for details on how lighting work
    @ambient_light = [0.5, 0.5, 0.5, 1]
    @diffuse_light = [1, 1, 1, 1]
    @light_postion = [0, 0, 2, 1]
  end
  def init_textures
     # see nehe07 for details on how filters work
    @nearest = Texture.new(self)
    glBindTexture(GL_TEXTURE_2D, @nearest.info.tex_name)
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_NEAREST)
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_NEAREST)

    @linear = Texture.new(self)
    glBindTexture(GL_TEXTURE_2D, @linear.info.tex_name)
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR)
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR)

    @minimap = Texture.new(self)
    glBindTexture(GL_TEXTURE_2D, @minimap.info.tex_name)
    texture = glGetTexImage(GL_TEXTURE_2D, 0, GL_RGB, GL_FLOAT)
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR)

    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR_MIPMAP_NEAREST)
    gluBuild2DMipmaps(GL_TEXTURE_2D, 3, 256, 256, GL_RGB, GL_FLOAT, texture)
    @filters = [@nearest.info.tex_name, @linear.info.tex_name, @minimap.info.tex_name]
  end

  def init_scene
    #basics of creating a scene. see lesson 1 and others
    glEnable(GL_TEXTURE_2D)
    glBlendFunc(GL_SRC_ALPHA,GL_ONE)
    glShadeModel(GL_SMOOTH)
    glClearColor(0,0,0,0)
    glClearDepth(1)
    glEnable(GL_DEPTH_TEST)
    glDepthFunc(GL_LEQUAL)
    glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST)
  end


  def add_perspective_to_scene
    # see lesson 01
    glMatrixMode(GL_PROJECTION)
    glLoadIdentity
    gluPerspective(45.0, width / height, 0.1, 100.0)
    glMatrixMode(GL_MODELVIEW)
    glLoadIdentity
  end

  def update
    @y_angle -= 1.5 if button_down? Gosu::Button::KbRight
    @y_angle += 1.5 if button_down? Gosu::Button::KbLeft

    if button_down?(Gosu::Button::KbUp)
      @x_pos -= Math.sin(@y_angle * @degree_radian_conversion) * 0.05
      @look_up_or_down_pos -= Math.cos(@y_angle * @degree_radian_conversion) * 0.05
      @bouncing_angle > 359 ? @bouncing_angle = 0 : @bouncing_angle += 10 # bouncing and bouncing angle gives illusion of walking
      @bouncing = Math.sin(@bouncing_angle * @degree_radian_conversion) / 20 # use sinusoid for bouncing
    end
    if button_down?(Gosu::Button::KbDown)
      @x_pos += Math.sin(@y_angle * @degree_radian_conversion) * 0.05
      @look_up_or_down_pos += Math.cos(@y_angle * @degree_radian_conversion) * 0.05
      @bouncing_angle <= 1 ? @bouncing_angle = 359 : @bouncing_angle -= 10 # bouncing and bouncing angle gives illusion of walking
      @bouncing = Math.sin(@bouncing_angle * @degree_radian_conversion) / 20 # use sinusoid for bouncing
    end
    @look_up_or_down -= 0.2 if button_down? Gosu::Button::KbPageUp
    @look_up_or_down += 0.2 if button_down? Gosu::Button::KbPageDown
  end

  def draw
    gl do
      init_scene
      add_perspective_to_scene
      glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT) # see lesson01

      glLightfv(GL_LIGHT1, GL_AMBIENT, @ambient_light) # see lighting lesson nehe07
      glLightfv(GL_LIGHT1, GL_DIFFUSE, @diffuse_light)
      glLightfv(GL_LIGHT1, GL_POSITION, @light_postion)
      glEnable(GL_LIGHT1)

      @light_on ? glEnable(GL_LIGHTING) : glDisable(GL_LIGHTING) # see nehe07
      if @blending # for blending see nehe08
        glEnable(GL_BLEND)
        glDisable(GL_DEPTH_TEST)
      else
        glDisable(GL_BLEND)
        glEnable(GL_DEPTH_TEST)
      end

      # For user to be able to walk around normally we would move the camera around and draw the 3D environment relative to the camera position.
      # This is slow and hard to code. What we will do is this:
      # 1. Rotate and translate the camera position according to user commands
      # 2. Rotate the world around the origin in the opposite direction of the camera rotation (giving the illusion that the camera has been rotated)
      # 3. Translate the world in the opposite manner that the camera has been translated (again, giving the illusion that the camera has moved)
      x = -@x_pos
      y = -@bouncing - 0.25
      z = -@look_up_or_down_pos
      scene_angle = 360 - @y_angle

      glRotatef(@look_up_or_down,1,0,0) #rotate to be able to look up or down
      glRotatef(scene_angle,0,1,0); #rotate based on direction user is facing
      glTranslate(x, y, z) #translate the world in opposite of camera
      glBindTexture(GL_TEXTURE_2D, current_filter) #see lesson 01
      triangles.each do |triangle|
        draw_triangle(triangle)
      end
    end
  end

  def draw_triangle(triangle)
    glBegin(GL_TRIANGLES)
      glNormal3f(0, 0, 1)
      triangle.vertexes.each do |vertex|
        glTexCoord2f(vertex.u, vertex.v)
        glVertex3f(vertex.x, vertex.y, vertex.z)
      end
    glEnd
  end

  def change_filter!
    index = @filters.index(current_filter)
    index > 1 ? index = 0 : index += 1
    @current_filter = @filters[index]
  end

  def current_filter
    @current_filter ||= @filters.first
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