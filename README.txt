Scribbling Render Target for DragonRuby!

Code to allow drawing lines with the mouse like in a drawing software.  The magic is done inside lib/rtcoloring.rb file.

Instructions:

To run the demonstration, run the dragonruby.exe file.

To use in your own game/app, copy the lib/rtcoloring.rb file to your own lib folder in your dragonruby project (create it if needed).  Then add 

require 'app/lib/rtcoloring.rb'

above your tick function.

Now you can call the following commands in your tick function.

setup_coloring(args)
Sets up the Render Texture we will be coloring to.  Recommended to call only the first tick as a setup process.

coloring_track_mouse_position(args)
Tracks the current mouse position and adds it to the current internal stroke array.  Call this every tick you want the current mouse position to be part of a line.  Example: calling this when mouse is held down will ensure to capture every mouse position each tick.

coloring_finish_line(args)
Finalize the line array for the current internal stroke array.  This will write the stroke to the RT, locking it into the drawing.  This command should be run only once, such as the first tick the mouse is released.

Last, do not forget to render the coloring rt to the regular sprite output.  If you do not do this the whole coloring thing will be invisible anyway, not very useful.  Use a command like this somewhere in your tick function.  I recommend calling this BEFORE calling the coloring_track_mouse_position.  Doing so will allow the tracked line in progress to render on top of the RT so the user can see what they are doing.

args.outputs.sprites << {x: 0, y: 0, w: 1280, h: 720, path: :rt}
Renders the drawing rt named :rt to the normal sprite output.

There are also some additional commands:

coloring_clear_drawing(args)
This will clear the RT back to an empty image.

args.state.coloring_thickness += 5
Change the thickness of the rendered line we will draw with the internal stroke array.  You can set this value to any valid integer, the stroke can even handle 0 (though no output will happen in that case.)

Additional Setup:
I highly recommend replacing the brush texture paths with something more sensible for clean output, like a plain circle and a plain square sprite.  I used the DragonRuby defaults so you can see how the sprites are put together in the demo.
