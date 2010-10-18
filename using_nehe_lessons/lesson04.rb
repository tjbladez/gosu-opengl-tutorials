require 'gosu'
require 'gl'
require 'glu'
require 'glut'

include Gl
include Glu

class Window < Gosu::Window
  attr_accessor :rotation_angle
  
  def initialize
    super(800, 600, false)
    self.caption = "Lesson #4 - Rotation animation"
    @rotation_angle = 0
  end
  
  def update
    @rotation_angle += 0.2
  end
  
  def draw
    gl do
      glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT) # see 02

      glMatrixMode(GL_PROJECTION) # see 02 
      glLoadIdentity  # see 02

      gluPerspective(45.0, width / height, 0.1, 100.0) # see 02
      
  	  glMatrixMode(GL_MODELVIEW) # see 02
      glLoadIdentity # see 02
      
      glTranslatef(-2, 0, -10) # see 02

      glRotatef(@rotation_angle, 0, 1, 0) # rotate object around vector set by traveling to x,y,z from current unit, angle is in degrees
      
      glBegin(GL_TRIANGLES) # see 02
          glColor3f(1, 0, 0) #  see 03
          glVertex3f( 0,1, 0)
          glColor3f(0, 1, 0)
          glVertex3f( 1, -1, 0)
          glColor3f(0, 0, 1)
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