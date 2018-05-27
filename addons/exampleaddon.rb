=begin
puts "I am an addon!"

class TileTest < Tile
	@name = "Addon"
	def initialize (x, y, angle)
		super
		@image = Gosu::Image.new("textures/debug.png", {retro: true})
		@w = @wleft = @wup = @wright = @wdown = @sleft = @sup = @sright = @sdown = true
	end
end

newTile(TileTest, Gosu::Image.new("textures/debug.png", {retro: true}))
=end
