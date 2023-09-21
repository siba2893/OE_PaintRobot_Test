require "rspec/autorun"

class PaintRobot
  # Directions Hash => [X, Y]
  DIRECTIONS = {
    "up" => [0, -1],
    "down" => [0, 1],
    "left" => [-1, 0],
    "right" => [1, 0]
  }

  def initialize
    @initial_x = 0
    @initial_y = 0
    @painted_spaces = 1 # Count starting position as a painted one.
  end

  def paint(file_path = nil, instructions: [], rows: 10, columns: 10)
    raise "No file or instructions where given." if file_path.nil? && instructions.empty?

    # Grid representation starts with 0,0 at the top left corner meaning any UP will be negative and any DOWN will be positive
    grid = Array.new(rows) { Array.new(columns, 0) }

    begin
      if !file_path.nil?
        File.foreach(File.join(__dir__, file_path)) do |line|
          process_instructions(grid, line, rows, columns)
        end
      elsif instructions.any?
        instructions.each do |line|
          process_instructions(grid, line, rows, columns)
        end
      end

      {
        final_location: [@initial_x, @initial_y],
        painted_spaces: @painted_spaces
      }
    rescue StandardError => e
      puts "An error occurred: #{e.message}"
      return nil
    end
  end

  private

  def process_instructions(grid, line, rows, columns)
    direction = line.chomp.strip.downcase
    dir_x, dir_y = DIRECTIONS[direction]
    new_dir_x, new_dir_y = @initial_x + dir_x, @initial_y + dir_y
    in_bounds = (0...rows).include?(new_dir_y) && (0...columns).include?(new_dir_x)
    not_painted = grid[new_dir_x][new_dir_y] == 0 || grid[new_dir_x][new_dir_y] == nil

    return unless in_bounds

    if in_bounds && not_painted
      grid[new_dir_x][new_dir_y] = 1
      @painted_spaces += 1
    end

    @initial_x, @initial_y = new_dir_x, new_dir_y
  end
end

describe PaintRobot, "paint_bot" do
  it "Should show the appropriate output for instructions" do
    paint_robot = PaintRobot.new.paint(nil, instructions: ["up", "right", "down", "left"])
    expect(paint_robot).to eq({
                                final_location: [0, 1],
                                painted_spaces: 4
                              })
  end

  it "Should show the appropriate output for an input file" do
    paint_robot = PaintRobot.new.paint('instructions_file.txt')
    expect(paint_robot).to eq({
                                final_location: [0, 3],
                                painted_spaces: 8
                              })
  end

  it "Should show the appropriate output even on different configurations" do
    paint_robot = PaintRobot.new.paint(nil, instructions: ["down", "down", "left", "right", "right", "down", "left"], rows: 5, columns: 3)
    expect(paint_robot).to eq({
                                final_location: [1, 3],
                                painted_spaces: 7
                              })
  end

  it "Should show the appropriate output for instructions" do
    expect { PaintRobot.new.paint }.to raise_error(RuntimeError, "No file or instructions where given.")
  end
end

puts ""
puts "EXECUTION RESULTS"
puts "#------------------------------"
puts PaintRobot.new.paint('instructions_file.txt')
puts "#------------------------------"
puts ""
puts "SPEC RESULTS"
puts "#------------------------------"
