#coloring a line onto a render target
# by Gawain Doell (DarkGriffin) 2024

def setup_coloring(args, rt_name=:rt)
  args.state.coloring_click_positions ||= []
  args.state.coloring_thickness ||= 10
  args.state.coloring_rt_name ||= rt_name
  #create the rt if it doesn't exist
  #putz("Creating render target")
  args.outputs[args.state.coloring_rt_name].transient!
  args.outputs[args.state.coloring_rt_name].clear_before_render = false
  args.outputs[args.state.coloring_rt_name].w = 1280
  args.outputs[args.state.coloring_rt_name].h = 720
end


def coloring_track_mouse_position(args)
    #add current mouse position to the array
    args.state.coloring_click_positions << {x: args.inputs.mouse.x, y: args.inputs.mouse.y}
    #also render the line in progress being drawn so far.
    coloring_render_in_progress_line(args)
end

def coloring_render_in_progress_line(args)
    args.state.coloring_click_positions.each_with_index do |pos, i|
        if i < args.state.coloring_click_positions.length - 1
          fill_with_rotated_rect(args, pos, args.state.coloring_click_positions[i+1], args.state.coloring_thickness)
          draw_brush_at_joint_point(args, args.state.coloring_click_positions[i+1], args.state.coloring_thickness)
        end
    end
end

def coloring_finish_line(args)
    cache_sprites_to_render_target(args)
    args.state.coloring_click_positions.clear
end

def cache_sprites_to_render_target(args)
    args.state.coloring_click_positions.each_with_index do |pos, i|
        if i < args.state.coloring_click_positions.length - 1
            args.outputs[args.state.coloring_rt_name].clear_before_render = false
            fill_with_rotated_rect(args, pos, args.state.coloring_click_positions[i+1], args.state.coloring_thickness, true)
            draw_brush_at_joint_point(args, args.state.coloring_click_positions[i+1], args.state.coloring_thickness, true)
        end
    end
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
    args.outputs[args.state.coloring_rt_name].sprites << {
      x: midpoint[0],
      y: midpoint[1],
      w: distance,
      h: thickness,
      path: 'sprites/square/green.png',
      angle: angle * (180.0 / Math::PI),
      anchor_x: 0.5,
      anchor_y: 0.5
    }
    else
    args.outputs.sprites << {
      x: midpoint[0],
      y: midpoint[1],
      w: distance,
      h: thickness,
      path: 'sprites/square/black.png', 
      angle: angle * (180.0 / Math::PI),
      anchor_x: 0.5,
      anchor_y: 0.5
    }
    end
end

def draw_brush_at_joint_point(args, pos, thickness, to_render_target=false)
    if to_render_target
        args.outputs[args.state.coloring_rt_name].sprites << {
            x: pos.x,
            y: pos.y,
            w: thickness,
            h: thickness,
            path: 'sprites/circle/green.png',
            angle: 0,
            anchor_x: 0.5,
            anchor_y: 0.5
        }
    else
        args.outputs.sprites << {
            x: pos.x,
            y: pos.y,
            w: thickness,
            h: thickness,
            path: 'sprites/circle/black.png',
            angle: 0,
            anchor_x: 0.5,
            anchor_y: 0.5
        }
    end
end

def coloring_clear_drawing(args)
    args.outputs[args.state.coloring_rt_name].clear_before_render = true
    args.outputs[args.state.coloring_rt_name].sprites.clear
end