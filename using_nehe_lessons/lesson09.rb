require 'gosu'
require 'gl'
require 'glu'
require 'glut'

include Gl
include Glu

class Texture
  attr_accessor :index
  def initialize(window)
    @image = Gosu::Image.new(window, "resources/nehe/lesson09/Star.bmp", true)
    @index = @image.gl_tex_info.tex_name
  end
end

class Star
  attr_accessor :colors, :distance, :angle

  def color_randomly
    self.colors = [rand(256), rand(256), rand(256)]
  end
end

class Window < Gosu::Window
  STAR_NUMBER = 50

  def initialize
    super(800, 600, false)
    self.caption = "Lesson #9 - Moving bitmaps in 3D space"
		@texture = Texture.new(self)
    initialize_defaults
    initialize_stars
  end

  def initialize_defaults
    @twinkle_on = false
    @tilt       = 90
    @zoom       = -15
    @spin       = 0
  end

  def initialize_stars
    @stars = []
    STAR_NUMBER.times do |i|
      @stars << Star.new.tap do |star|
        star.angle = 0
        star.distance = 7 * i.to_f / STAR_NUMBER
        star.color_randomly
      end
    end
  end

  def update
    @zoom -= 0.2 if button_down? Gosu::Button::KbPageUp
    @zoom += 0.2 if button_down? Gosu::Button::KbPageDown
    @tilt -= 0.5 if button_down? Gosu::Button::KbUp
    @tilt += 0.5 if button_down? Gosu::Button::KbDown
    @spin += 0.01
  end

  def draw_star(star)
    red, green, blue = * star.colors
		glColor4ub(red, green, blue, 255)
		glBegin(GL_QUADS)
			glTexCoord2f(0, 0); glVertex3f(-1,-1, 0)
			glTexCoord2f(1, 0); glVertex3f( 1,-1, 0)
			glTexCoord2f(1, 1); glVertex3f( 1, 1, 0)
			glTexCoord2f(0, 1); glVertex3f(-1, 1, 0)
		glEnd
  end

  # see lesson 01 and nehe02
  def init_scene
    glEnable(GL_TEXTURE_2D)
  	glShadeModel(GL_SMOOTH)
    glClearColor(0,0,0,0.5)
    glClearDepth(1)
  	glBlendFunc(GL_SRC_ALPHA,GL_ONE) #see nehe08
  	glEnable(GL_BLEND)
	end

	# see lesson 01
	def add_perspective_to_scene
	  glMatrixMode(GL_PROJECTION)
    glLoadIdentity
    gluPerspective(45.0, width / height, 0.1, 100.0)
    glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST) #see nehe07
  end

  def draw
    gl do
      init_scene
      glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
    	glBindTexture(GL_TEXTURE_2D, @texture.index)

    	@stars.each_with_index do |star, i|
        add_perspective_to_scene

        glMatrixMode(GL_MODELVIEW)  #see lesson 01
        glLoadIdentity #see lesson 01
        glTranslatef(0, 0, @zoom)
    		glRotatef(@tilt, 1, 0, 0)

        glRotatef(star.angle, 0, 1, 0)
    		glTranslatef(star.distance, 0, 0)

        glRotatef(-star.angle, 0, 1, 0)
    		glRotatef(-@tilt, 1, 0, 0)

    		if (@twinkle_on)
          draw_star(@stars[(@stars.size-i-1)])
    		end

    		glRotatef(@spin,0,0,1)
        draw_star(star)

        star.angle += i.to_f / STAR_NUMBER
        star.distance -= 0.01

        if (star.distance < 0)
    			star.distance += 5
          star.color_randomly
    		end
  	  end
    end
  end

  def button_down(id)
    case id
    when Gosu::Button::KbEscape then close
    when Gosu::Button::KbT then @twinkle_on = !@twinkle_on
    end
  end
end

window = Window.new
window.show