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
      glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT) # Clear The Screen And The Depth Buffer

      #glMatrixMode(matrix) indicates that following [matrix] is going to get used

      glMatrixMode(GL_PROJECTION) # The projection matrix is responsible for adding perspective to our scene. 
      glLoadIdentity  # Resets current modelview matrix

      # Calculates aspect ratio of the window. Gets perspective  view. 45 is degree viewing angle, (0.1, 100) are ranges how deep can we draw into the screen
      gluPerspective(45.0, width / height, 0.1, 100.0) 
      
  	  glMatrixMode(GL_MODELVIEW) # The modelview matrix is where object information is stored.
      glLoadIdentity
      
      # Think 3-d coordinate system (x,y,z). +- on each movies on that axis
      glTranslatef(-2, 0, -10) # Moving function from the current point by x,y,z change

      glBegin(GL_TRIANGLES) #Begin drawing a figure.
          glVertex3f( 0,  1, 0) #place a point at (x,y,z) location from the current point
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