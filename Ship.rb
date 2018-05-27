
class Ship
	attr_accessor :angle, :worldx, :worldy, :speed, :board, :size, :guns, :engines
	def initialize (size)
		@angle = @worldx = @worldy = @speed = 0.0
		@size = size
		@guns = []
		@engines = []
	end

	def buildBoard
		@board = []
		for i in 0...@size do
			a = []
			for j in 0...@size do
				a << Tile.new(i, j, 0, self, true)
			end
			@board << a
		end
		m = (@size / 2.0).floor
		@board[m][m - 1] = TileCannon.new(m,m - 1,0, self)
		@board[m][m + 1] = TileEngine.new(m,m + 1,0, self)
		@board[m][m] = TileCore.new(m,m,0, self)
	end

	def update
		@board.each {|i| i.each {|j| j.update}}
	end

	def draw
		@board.each {|i| i.each {|j| j.draw}}
		Gosu.flush
	end
end

class Player < Ship
	def initialize (size)
		super(size)
		buildBoard
		@vel_x = @vel_y = 0.0
	end

	def warp(x, y)
		@worldx, @worldy = x, y
		@vel_x = @vel_y = 0
		ParticlePoof.new(0xff_ffffff,3,100,300).draw(0,0)
		update
	end
		def turn_left
		if !$pause && !$buildmode && !$flightmode
			@angle -= 4
		end
	end

	def turn_right
		if !$pause && !$buildmode && !$flightmode
			@angle += 4
		end
	end

	def accelerate(s)
		@vel_x += Gosu::offset_x(@angle, s)
		@vel_y += Gosu::offset_y(@angle, s)
	end

	def switchMode
		@vel_y = @vel_x = @angle = 0
		update
		$buildmode = !$buildmode
		$pause = false
		$build.updateInventory
	end

	def move(a)
		if !$pause && !$buildmode
			@worldx += @vel_x
			@worldy += @vel_y
			if $flightmode
				@angle = a + 90
			end
		end
		@speed = @vel_x.abs + @vel_y.abs
		@vel_x *= 0.95
		@vel_y *= 0.95
		update
	end

	def shoot
		if !$pause && !$buildmode
			@guns.shuffle.each {|g| g.shoot}
		end
	end
end
