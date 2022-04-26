module SW
  module Frames

    BUTTON = Struct.new(:type, :label, :location, :width, :height,
      :perimeter, :screen_scale, :box_color, :outline_color,
      :text_location, :text_options, :highlight, :action, :parent)

    class BUTTON
      def initialize(&block)
        #p 'init button'
        self.type = :Button
        self.label = nil
        self.location = [0,0]
        self.width = 80
        self.height = 22
        self.perimeter = []
        self.screen_scale = 1.0
        self.box_color = Sketchup::Color.new(256, 256, 256)
        self.outline_color = Sketchup::Color.new(180, 180, 180)
        self.text_location = [5, 0]
        self.text_options =  {size: 13, color: [80, 80, 80]}
        self.highlight = false
        self.action = block
        self.parent = nil
      end
      
      # place keeper for a future algorithm
      def size()
        [self.width, self.height]
      end
      
      def onMouseMove(flags, x, y, view)
        mouse_over_entity?(view, x, y)
      end
      
      def onLButtonDown(flags, x, y, view)
        if mouse_over_entity?(view, x, y)
          UI.start_timer(0, false) { action.call } if action
          return self
        else
          return false
        end
      end
      
      def onLButtonUp(flags, x, y, view)
        if mouse_over_entity?(view, x, y)
          return self
        else
          return false
        end
      end
       
      # # is the mouse over this entity => true/false
      def mouse_over_entity?(view, x, y)
        a, b = self.location
        if  x > a && x < a + self.width && y > b && y < b + self.height
          view.invalidate if self.highlight != true
          self.highlight = true
          self
        else
          view.invalidate if self.highlight != false
          self.highlight = false
          false
        end
      end
        
      def draw_entity(view, scale, invalidated)
        get_perimeter() if invalidated 

        # Background
        view.drawing_color = self.box_color
        view.draw2d(GL_POLYGON, self.perimeter)

        # Outline
        view.line_stipple = '' # Solid line
        view.line_width = 1
        view.drawing_color = self.outline_color
        view.drawing_color = Sketchup::Color.new "Blue" if self.highlight
        view.draw2d(GL_LINE_LOOP, self.perimeter)
        
        # Bar Background
        x = self.location[0] * scale
        y = self.location[1] * scale
        
        # Label
        if self.label
            point = Geom::Point3d.new(x + self.text_location[0] * scale,  y + self.text_location[1] * scale, 0)
            view.draw_text(point, self.label, self.text_options)
        end
      end
   
      # 
      def get_perimeter()
        # a 1x1 rounded edge box
        roundedgebox = [[0.125, 0.0, 0.0], [0.875, 0.0, 0.0], [0.922835, 0.009515, 0.0],\
          [0.963388, 0.036612, 0.0], [0.990485, 0.077165, 0.0], [1.0, 0.125, 0.0],\
          [0.990485, 0.922835, 0.0], [0.963388, 0.963388, 0.0], [0.922835, 0.990485, 0.0],\
          [0.875, 1.0, 0.0], [0.875, 1.0, 0.0], [0.077165, 0.990485, 0.0], [0.036612, 0.963388, 0.0],\
          [0.009515, 0.922835, 0.0], [0.0, 0.875, 0.0], [0.0, 0.875, 0.0], [0.009515, 0.077165, 0.0],\
          [0.036612, 0.036612, 0.0], [0.077165, 0.009515, 0.0], [0.125, 0.0, 0.0]]

        self.perimeter = scale_and_translate(roundedgebox, width, self.height, self.screen_scale, self.location)
      end
      
      # scale uniformly by the height value and scootch the right side 
      # points over to the correct width. Move to location on screen  
      def scale_and_translate(outline, width, height, scale, location)
        tr = Geom::Transformation.scaling(height * scale, height * scale,0)
        outline.collect!{|pt|
          pt.transform!(tr)
          pt[0] = pt[0] + width * scale - height * scale if pt[0] > height * scale/2
          pt
        }
        tr = Geom::Transformation.translation([location[0] * scale, location[1] * scale])
        outline.collect{|pt| pt.transform(tr)}
      end
    end # button
  end # frame
end



nil




