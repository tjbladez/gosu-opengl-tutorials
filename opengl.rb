require 'gosu'
require 'gl'
require 'glu'
require 'glut'

include Gl
include Glu

class Window < Gosu::Window
  def initialize
    super(800, 600, false)
    self.caption = "Bla"
  end
  def update
  end
  def draw
    gl do
      glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT) # Clear The Screen And The Depth Buffer
      # glViewport(0, 0, width, height) #resets current viewport (for resizing etc)

      #glMatrixMode(GL_PROJECTION) indicates that the next 2 lines of code will affect the projection matrix. The projection matrix is responsible for adding perspective to our scene. 
      glMatrixMode(GL_PROJECTION) 
      glLoadIdentity # Reset The Current Modelview Matrix

      gluPerspective(45.0, width / height, 0.1, 100.0) #Calculate The Aspect Ratio Of The Window. gets perspective  view. 45 is degree viewing angle, (0.1, 100) are ranges how deep
      #can we draw into the screen
    	
    	# glMatrixMode(GL_MODELVIEW) indicates that any new transformations will affect the modelview matrix. The modelview matrix is where our object information is stored.
    	glMatrixMode(GL_MODELVIEW) 
      glLoadIdentity # Reset The Current Modelview Matrix
      
      # Move left 1.5 units and into the screen 6.0 units
      glTranslatef(-2, 0.0, -10.0) #moving function from the current point by direction
      # Draw a triangle
      glBegin(GL_TRIANGLES) #begin drawing a figure
          glVertex3f( 0.0,  1.0, 0.0)
          glVertex3f( 1.0, -1.0, 0.0)
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