def tick args
  args.outputs.labels << [640, 500, "Click and color tracking logic tests."]
  args.outputs.labels  << { x: 640, y: 460, text: "Click and drag to draw lines", size_enum: 2, alignment_enum: 1 }

  #create a rendertarget to draw finished line sprites to
  if args.state.tick_count == 0
    putz("Creating render target")
    args.outputs[:rt].transient!
    args.outputs[:rt].clear_before_render = false
    args.outputs[:rt].w = 1280
    args.outputs[:rt].h = 720
  end

  #show frame rate
  args.outputs.debug << "Frame rate: #{args.gtk.current_framerate}"

  #initialize click positions array if it doesn't exist
  args.state.click_positions ||= []
  #respond to inputs
  #if args.inputs.mouse.click
  if args.inputs.mouse.button_left
    #create coordinates for this frame of mouse position
    xpos = args.inputs.mouse.x
    ypos = args.inputs.mouse.y
    args.state.click_positions << {x: xpos, y: ypos}
  end

  #for each click position, draw a line to the next position
  args.state.click_positions.each_with_index do |pos, i|
    if i < args.state.click_positions.length - 1
      #args.outputs.lines << {x:pos.x, y:pos.y, x2:args.state.click_positions[i+1].x, y2:args.state.click_positions[i+1].y}
      #draw_circle_at(args, pos.x, pos.y, 10)
      #draw_thick_line_between_two_points(args, pos, args.state.click_positions[i+1], 10)
      #calculate_and_fill_an_area_between_4_points_based_on_click_points(args, pos, args.state.click_positions[i+1])
      fill_with_rotated_rect(args, pos, args.state.click_positions[i+1], 10)
      #args.outputs.debug << pos.to_s
    end
  end
  
  #clear the line if button is let go of this frame
  #if args.inputs.mouse.button_right
  if !args.inputs.mouse.button_left
    cache_sprites_to_render_target(args)
    args.state.click_positions.clear
  end

  #draw the render target to the screen
  args.outputs.sprites << {x: 0, y: 0, w: 1280, h: 720, path: :rt}
  
  #output to debug messages
  #args.outputs.debug << "Click positions: #{args.state.click_positions}"



end

def fill_with_rotated_rect(args, pos1,pos2, thickness, to_render_target=false)
  # Calculate the distance and angle between the two points
  dx = pos2.x - pos1.x
  dy = pos2.y - pos1.y
  distance = Math.sqrt(dx**2 + dy**2)
  angle = Math.atan2(dy, dx)

  # Calculate the midpoint between the two points
  midpoint = [(pos1.x + pos2.x) / 2, (pos1.y + pos2.y) / 2]

  # Draw a sprite at the midpoint, with the width equal to the distance between the points, and the height equal to the thickness
  if to_render_target
  args.outputs[:rt].sprites << {
    x: midpoint[0],
    y: midpoint[1],
    #x: pos1.x + (dx / 2),
    #y: pos1.y + (dy / 2),
    w: distance,
    h: thickness,
    path: 'sprites/square/green.png', # replace with the path to your square sprite
    angle: angle * (180.0 / Math::PI),
    anchor_x: 0.5,
    anchor_y: 0.5
  }
  else
  args.outputs.sprites << {
    x: midpoint[0],
    y: midpoint[1],
    #x: pos1.x + (dx / 2),
    #y: pos1.y + (dy / 2),
    w: distance,
    h: thickness,
    path: 'sprites/square/black.png', # replace with the path to your square sprite
    angle: angle * (180.0 / Math::PI),
    anchor_x: 0.5,
    anchor_y: 0.5
  }
  end
end


def cache_sprites_to_render_target(args)
  args.state.click_positions.each_with_index do |pos, i|
    if i < args.state.click_positions.length - 1
      args.outputs[:rt].clear_before_render = false
      #args.outputs.lines << {x:pos.x, y:pos.y, x2:args.state.click_positions[i+1].x, y2:args.state.click_positions[i+1].y}
      #draw_circle_at(args, pos.x, pos.y, 10)
      #draw_thick_line_between_two_points(args, pos, args.state.click_positions[i+1], 10)
      #calculate_and_fill_an_area_between_4_points_based_on_click_points(args, pos, args.state.click_positions[i+1])
      fill_with_rotated_rect(args, pos, args.state.click_positions[i+1], 10, true)
      #args.outputs.debug << pos.to_s
    end
  end
end



# the below is unused code we tried to experiment with, to be moved to unused code section later.


def draw_circle_at(args, xpos, ypos, radius)
  for i in 0..360
    x = xpos + radius * Math.cos(i)
    y = ypos + radius * Math.sin(i)
    args.outputs.lines << {x: xpos, y: ypos, x2: x, y2: y}
  end
end

def calculate_and_fill_an_area_between_4_points_based_on_click_points(args, point1,point2, thickness=10)

  angle = Math.atan2(point2.y - point1.y, point2.x - point1.x)
  perp_angle = angle + Math::PI / 2
  #draw the angle found with red lines
  args.outputs.lines << {x: point1.x, y: point1.y, x2: point1.x + 100 * Math.cos(angle), y2: point1.y + 100 * Math.sin(angle), r: 255, g: 0, b: 0}
  args.outputs.lines << {x: point1.x, y: point1.y, x2: point1.x + 100 * Math.cos(perp_angle), y2: point1.y + 100 * Math.sin(perp_angle), r: 255, g: 0, b: 0}
  #draw the base line between two points
  args.outputs.lines << {x: point1.x, y: point1.y, x2: point2.x, y2: point2.y}
  #calculate the offset along the perpendicular angle to do half of thickness
  offset = {x: Math.cos(perp_angle) * (thickness/2), y: Math.sin(perp_angle) * (thickness/2)}
  #draw the first line of the offset to mark it with blue
  args.outputs.lines << {x: point1.x + offset.x, y: point1.y + offset.y, x2: point2.x + offset.x, y2: point2.y + offset.y, r: 0, g: 0, b: 255}
  #now we loop over both positive and negative offsets to the center in order to draw a full line
  #for i in 0..thickness
    #args.outputs.lines << {x: point1.x + offset.x, y: point1.y + offset.y + i, x2: point2.x + offset.x, y2: point2.y + offset.y + i}
    #args.outputs.lines << {x: point1.x - offset.x, y: point1.y - offset.y + i, x2: point2.x - offset.x, y2: point2.y - offset.y + i}
  #end
  #now we loop over both positive and negative offsets to the center in order to draw a full line
for i in 0..thickness
  x_increment = i * Math.cos(angle)
  y_increment = i * Math.sin(angle)
  args.outputs.lines << {x: point1.x + offset.x + x_increment, y: point1.y + offset.y + y_increment, x2: point2.x + offset.x + x_increment, y2: point2.y + offset.y + y_increment}
  args.outputs.lines << {x: point1.x - offset.x + x_increment, y: point1.y - offset.y + y_increment, x2: point2.x - offset.x + x_increment, y2: point2.y - offset.y + y_increment}
end

end

def draw_thick_line_between_two_points(args, pos1, pos2, thickness)
  #calculate the angle between the two points
  angle = Math.atan2(pos2.y - pos1.y, pos2.x - pos1.x)
  #calculate the perpendicular angle
  perp_angle = angle + Math::PI / 2
  #calculate the offset for the thickness
  offset = {x: Math.cos(perp_angle) * (thickness/2), y: Math.sin(perp_angle) * (thickness/2)}
  #draw the line
  args.outputs.lines << {x: pos1.x + offset.x, y: pos1.y + offset.y, x2: pos2.x + offset.x, y2: pos2.y + offset.y}
  #args.outputs.lines << {x: pos1.x - offset.x, y: pos1.y - offset.y, x2: pos2.x - offset.x, y2: pos2.y - offset.y}

  #draw lines between the first line and the second line to fill in the area between the two lines
  for i in 0..thickness
    args.outputs.lines << {x: pos1.x + offset.x, y: pos1.y + offset.y + i, x2: pos2.x + offset.x, y2: pos2.y + offset.y + i}
  end

  #fill between the two lines
  #for i in 0..thickness
    #args.outputs.lines << {x: pos1.x + offset.x, y: pos1.y + offset.y + i, x2: pos2.x + offset.x, y2: pos2.y + offset.y + i}
    #args.outputs.lines << {x: pos1.x - offset.x, y: pos1.y - offset.y + i, x2: pos2.x - offset.x, y2: pos2.y - offset.y + i}
  #end
  #fill the entire area of the circle lines between the two spots on the screen with a for loop
  #for i in 0..360
  #  x1 = pos1.x + thickness * Math.cos(i)
  #  y1 = pos1.y + thickness * Math.sin(i)
  #  x2 = pos2.x + thickness * Math.cos(i)
  #  y2 = pos2.y + thickness * Math.sin(i)
  #  args.outputs.lines << {x: x1, y: y1, x2: x2, y2: y2}
  #end
  
end