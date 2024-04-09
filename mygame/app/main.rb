# coloring example
# by Gawain Doell (DarkGriffin) 2024
# A simple example of coloring using a sprite on a render target,
# and tracking a mouse position array to draw a "line" on the screen.
# the main code is in the rtcoloring.rb file, and can be imported into your own projects to get an rt that can be colored.

require 'app/lib/rtcoloring.rb'

def tick args
  args.outputs.labels << [640, 500, "Click and color tracking logic tests."]
  args.outputs.labels  << { x: 640, y: 460, text: "Click and drag to draw lines", size_enum: 2, alignment_enum: 1 }
  args.outputs.labels << [640, 420, "Press C to clear the rt and start a new drawing."]
  args.outputs.labels << [640, 380, "Press up or down to change the thickness of the line."]

  #create a rendertarget to draw finished line sprites to
  if args.state.tick_count == 0
    setup_coloring(args, :rt)
  end

  #draw the render target to the screen so we can see our coloring
  # we do this BEFORE any response because we want the coloring of the current line to be on top of this sprite.
  args.outputs.sprites << {x: 0, y: 0, w: 1280, h: 720, path: :rt}

  #respond to inputs
  if args.inputs.mouse.button_left
    coloring_track_mouse_position(args)
  end
  
  #if letting go, finish the line, this turns the sprites into just pixel data inside the render target.  They will no longer cost any additional memory.
  if args.inputs.mouse.up
    coloring_finish_line(args)
  end
  
  #clear the render target and start a new drawing if C is pressed
  if args.inputs.keyboard.key_down.c
    coloring_clear_drawing(args)
  end

  #show frame rate to check performance
  args.outputs.debug << "Frame rate: #{args.gtk.current_framerate}"

  #change the thickness of the line with up and down keys
  if args.inputs.keyboard.key_down.up
    args.state.coloring_thickness += 5
  end
  if args.inputs.keyboard.key_down.down
    args.state.coloring_thickness -= 5
  end

  #show thickness of the line
  args.outputs.debug << "Thickness: #{args.state.coloring_thickness}"
end