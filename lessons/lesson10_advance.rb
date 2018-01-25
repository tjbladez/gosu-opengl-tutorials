# This lesson wants to make sure that nehe/lesson10 is fully understood,
# certain decisions in nehe/lesson 10 could be argueable: use of the meshes,
# less than optimal data point map, interesting choice of lighting source
# coordinates, only 1 type of textures. Here we will create 2 connecting
# rooms (diagram below) each with its own set of textures. We will only use
# knowledge learned up and including to lesson10.
#
# We will also provide the following movement control:
#  Up    - move forward
#  Down  - move back
#  Left  - turn left
#  Right - turn right
#  W     - go up
#  S     - go down
#  D     - strafe right
#  A     - strafe left
#  Esc   - quit
#  B     - toggle blending
#  L     - toggle lights
#  F     - toggle filters
#
#  3D Map
#  /-------------------\
#  |                   |
#  |    stone room     |
#  |__________   ______|
#  __________|  |_______
# |                    |
# | wood rooom         |
# \-------------------/
#
# Take Home exerises:
#  * reduce size of textures/increase quality
#  * modify lighting to go from the center of the ceiling of each floor
#  * add another room
require 'gosu'
require 'json'
require 'gl'
require 'glu'
require 'glut'
include Gl
include Glu

class TjTexture
  attr_accessor :info, :image
  def initialize(window, name)
    @image = Gosu::Image.new("resources/tj/lesson10_advance/#{name}.jpg", {tileable: true})
    @info = @image.gl_tex_info
  end
end

class TjVertex
  attr_reader :x, :y, :z, :u, :v

  def initialize(coords)
    coords.each do |coordinate, value|
      instance_variable_set(:"@#{coordinate}", value)
    end
  end
end

class TjMesh
  attr_accessor :vertexes
  def initialize
    @vertexes = []
  end
end

class Window < Gosu::Window
  attr_accessor :meshes, :current_filter

  def initialize
    super(800, 600, false)
    self.caption = "Lesson #10 - Loading and moving through 3D World"
    setup_world
    init_defaults
    init_lights
    init_textures
  end

  def setup_world
    world = JSON.parse(File.read('resources/tj/lesson10_advance/world.json'))
    @all_meshes = world.inject({}) do |acc, mesh_array|
      acc[mesh_array.first] = mesh_array.last.map do |vertexes|
        TjMesh.new.tap do |mesh|
          vertexes.each do |vertex|
            mesh.vertexes << TjVertex.new(vertex)
          end
        end
      end
      acc
    end
  end

  def init_defaults
    @light_on = false
    @blending = false
    @bouncing = @bouncing_angle = 0
    @x_pos = @look_up_or_down_pos = @y_angle = @look_up_or_down = @y_pos = @z_pos = 0
    @degree_radian_conversion = 0.0174532925 # pi / 180
  end

  def init_lights
    @ambient_light = [0.5, 0.5, 0.5, 1]
    @diffuse_light = [1, 1, 1, 1]
    @light_postion = [0, 0, 2, 1]
  end

  def init_textures
    @filter_index = 0
    @filters = {}
    glGetError
    @all_meshes.keys.each do |name|
      nearest = TjTexture.new(self, name)
      glBindTexture(GL_TEXTURE_2D, nearest.info.tex_name)
      glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_NEAREST)
      glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_NEAREST)

      linear = TjTexture.new(self, name)
      glBindTexture(GL_TEXTURE_2D, linear.info.tex_name)
      glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR)
      glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR)

      minimap = TjTexture.new(self, name)
      glBindTexture(GL_TEXTURE_2D, minimap.info.tex_name)
      texture = glGetTexImage(GL_TEXTURE_2D, 0, GL_RGB, GL_FLOAT)
      glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR)
      glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR_MIPMAP_NEAREST)
      gluBuild2DMipmaps(GL_TEXTURE_2D, 3, minimap.image.width, minimap.image.height, GL_RGB, GL_FLOAT, texture)
      @filters[name] = [nearest, linear, minimap]
    end
  end

  def init_scene
    glBlendFunc(GL_SRC_ALPHA,GL_ONE)
    glShadeModel(GL_SMOOTH)
    glClearColor(0,0,0,0)
    glClearDepth(1)
    glEnable(GL_DEPTH_TEST)
    glDepthFunc(GL_LEQUAL)
    glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST)
  end


  def add_perspective_to_scene
    glEnable(GL_TEXTURE_2D)
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
      @bouncing_angle > 359 ? @bouncing_angle = 0 : @bouncing_angle += 10
      @bouncing = Math.sin(@bouncing_angle * @degree_radian_conversion) / 20
    end
    if button_down?(Gosu::Button::KbDown)
      @x_pos += Math.sin(@y_angle * @degree_radian_conversion) * 0.05
      @look_up_or_down_pos += Math.cos(@y_angle * @degree_radian_conversion) * 0.05
      @bouncing_angle <= 1 ? @bouncing_angle = 359 : @bouncing_angle -= 10
      @bouncing = Math.sin(@bouncing_angle * @degree_radian_conversion) / 20
    end
    @look_up_or_down -= 0.3 if button_down? Gosu::Button::KbPageUp
    @look_up_or_down += 0.3 if button_down? Gosu::Button::KbPageDown
    @y_pos -= 0.05 if button_down? Gosu::Button::KbW
    @y_pos += 0.05 if button_down? Gosu::Button::KbS
    @x_pos += 0.05 if button_down? Gosu::Button::KbD
    @x_pos -= 0.05 if button_down? Gosu::Button::KbA
  end

  def draw
    gl do
      init_scene
      add_perspective_to_scene
      glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
      glLightfv(GL_LIGHT1, GL_AMBIENT, @ambient_light)
      glLightfv(GL_LIGHT1, GL_DIFFUSE, @diffuse_light)
      glLightfv(GL_LIGHT1, GL_POSITION, @light_postion)
      glEnable(GL_LIGHT1)

      @light_on ? glEnable(GL_LIGHTING) : glDisable(GL_LIGHTING)
      if @blending
        glEnable(GL_BLEND)
        glDisable(GL_DEPTH_TEST)
      else
        glDisable(GL_BLEND)
        glEnable(GL_DEPTH_TEST)
      end

      x = -@x_pos
      y = -@bouncing - 0.25 + @y_pos
      z = -@look_up_or_down_pos
      scene_angle = 360 - @y_angle

      glRotatef(@look_up_or_down,1,0,0)
      glRotatef(scene_angle,0,1,0);
      glTranslate(x, y, z)

      @all_meshes.each do |name, meshes|
        glBindTexture(GL_TEXTURE_2D, @filters[name][@filter_index].info.tex_name)
        meshes.each do |mesh|
          draw_mesh(mesh)
        end
      end
    end
  end

  def draw_mesh(mesh)
    glBegin(GL_QUADS)
      glNormal3f(0, 0, 1)
      mesh.vertexes.each do |vertex|
        glTexCoord2f(vertex.u, vertex.v)
        glVertex3f(vertex.x, vertex.y, vertex.z)
      end
    glEnd
  end

  def change_filter!
    @filter_index == 2 ? @filter_index = 0 : @filter_index += 1
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