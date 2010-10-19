require 'gosu'
require 'gl'
require 'glu'
require 'glut'

include Gl
include Glu

class Window < Gosu::Window
  def initialize
    super(800, 600, false)
    self.caption = "Lesson #2"
  end
  
  def update
  end
  
  def draw
    gl do
      glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT) # see lesson01
      glMatrixMode(GL_PROJECTION) # see lesson01 
      glLoadIdentity  # see lesson01
      gluPerspective(45.0, width / height, 0.1, 100.0) # see lesson01
  	  glMatrixMode(GL_MODELVIEW) # see lesson01
      glLoadIdentity # see lesson01
      
      glTranslatef(-2, 0, -10) # see lesson01

      glBegin(GL_TRIANGLES) # see lesson01
          glVertex3f( 0,  1, 0) # see lesson01
          glVertex3f( 1, -1, 0)
          glVertex3f(-1, -1, 0)
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