require 'gosu'
require 'gl'
require 'glu'
require 'glut'

include Gl
include Glu

class Window < Gosu::Window
  def initialize
    super(800, 600, false)
    self.caption = "Lesson #3 - Adding colors"
  end
  
  def update
  end
  
  def draw
    gl do
      glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT) #explained in lesson02 [see 02]

      glMatrixMode(GL_PROJECTION) # see 02 
      glLoadIdentity  # see 02

      gluPerspective(45.0, width / height, 0.1, 100.0) # see 02
      
  	  glMatrixMode(GL_MODELVIEW) # see 02
      glLoadIdentity # see 02
      
      glTranslatef(-2, 0.0, -10.0) # see 02

      glBegin(GL_TRIANGLES) # see 02
          glColor3f(1.0, 0.0, 0.0) # sets color to be used using RBG
          glVertex3f( 0.0,1.0, 0.0)
          glColor3f(0.0, 1.0, 0.0)
          glVertex3f( 1.0, -1.0, 0.0)
          glColor3f(0.0, 0.0, 1.0)
          glVertex3f(-1.0, -1.0, 0.0)
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