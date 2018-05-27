
=begin
Z ordering
1 Main image
2 Boarders
3 Wire
=end

$borderImg = texture("boarder")
$wcore = texture("wcore")
$wire = texture("wire")

class Tile
	class << self; attr_reader :name end
	@name = "BUG"
	attr_accessor :w
	attr_reader :wleft, :wup, :wright, :wdown, :wable, :sleft, :sup, :sright, :sdown, :visible, :wx, :wy
	def initialize (x, y, angle, parent, startup = false)
		@x = x
		@y = y
		@image = texture("debug")
		@boarder = $borderImg
		@wcore = $wcore
		@wire = $wire
		@w = @wleft = @wup = @wright = @wdown = @wable = @sleft = @sup = @sright = @sdown = false
		@dwire = @dboarders = true
		@angle = @wx = @wy = 0
		@parent = parent
		@board = parent.board
		if !startup
			@board[@x][@y].destroy
			@board[@x][@y] = self
		end
		@visible = self.class.name != "BUG"
	end

	def update
		updateVars
	end

	def draw
		if @visible
			@image.draw_rot(@wx, @wy, 1, @angle + @parent.angle)
			drawBoarders if @dboarders
			drawWire if @dwire && @w
		end
	end

	def drawBoarders
		boarders = neis(@x, @y, @board)
		solids = [@sleft, @sup, @sright, @sdown]
		4.times do |index|
			if !boarders[index] && solids[index]
				@boarder.draw_rot(@wx, @wy, 2, 90 * index + @parent.angle)
			end
		end
	end

	def drawWire
		@wcore.draw_rot(@wx, @wy, 2, 0 + @parent.angle)
		wires = neiw(@x, @y, @board)
		sides = [@wleft, @wup, @wright, @wdown]
		4.times do |index|
			if sides[index] && wires[index]
				@wire.draw_rot(@wx, @wy, 3, 90 * index + @parent.angle)
			end
		end
	end

	def destroy
		c = self.class.name
		$res.add(c, 1, false)
		if @wable && @w
			$res.add("Wire", 1, false)
		end
	end

	def updateVars
		m = (@parent.size / 2.0).floor
		relx = (@x - m) * $tscale
		rely = (@y - m) * $tscale
		@wx = rotx2(relx, rely, @parent.angle()) + @parent.worldx
		@wy = roty2(relx, rely, @parent.angle()) + @parent.worldy
	end
end

class TileEmpty < Tile
	@name = "Tile"
	def initialize (x, y, angle, parent)
		super
		@image = texture("empty")
		@wleft = @wup = @wright = @wdown = @wable = @sleft = @sup = @sright = @sdown = true
	end
end

class TileSlant < Tile
	@name = "Slant"
	def initialize (x, y, angle, parent)
		super
		@image = texture("emptySlant")
		@wslant = texture("wireSlant")
		@wslantedge = texture("wireSlantShort")
		@angle = angle
		@wable = true
		case @angle
		when 0
			@wleft = @wdown = @sleft = @sdown = true
		when 90
			@wleft = @wup = @sleft = @sup = true
		when 180
			@wright = @wup = @sright = @sup = true
		when 270
			@wright = @wdown = @sright = @sdown = true
		end
	end

	def drawWire
		wires = neiw(@x,@y, @board)
		@wslant.draw_rot(@wx, @wy, 3, @angle + @parent.angle)
		angles = [@angle == 0 || @angle == 90,
							@angle == 90 || @angle == 180,
							@angle == 180 || @angle == 270,
							@angle == 270 || @angle == 0]
		4.times do |index|
			if wires[index] && angles[index]
				@wslantedge.draw_rot(@wx, @wy, 3, 90 * index + @parent.angle)
			end
		end
	end
end

class TileSlantCurved < TileSlant
	@name = "Curved Slant"
	def initialize (x, y, angle, parent)
		super
		@image = texture("curvedSlant")
	end
end

class TileCore < TileEmpty
	@name = "Core"
	def initialize (x, y, angle, parent)
		super
		@core = texture("core")
		@w = true
	end
	def draw
		super
		@core.draw_rot(@wx, @wy, 4, @parent.angle)
	end
end

class TileCannon < Tile
	@name = "Energy Cannon"
	def initialize (x, y, angle, parent)
		super
		@image = texture("cannon")
		@w = @wdown = @sdown = @sright = @sleft = true
		@parent.guns << self
		@dwire = false
	end
	def shoot
		updateVars
		if $energy >= 25
			EnergyBullet.new(@wx, @wy, @parent.angle, 50)
			$energy -= 25
		end
	end

	def destroy
		@parent.guns.delete(self)
		super
	end
end

class TileCannon2 < Tile
	@name = "Plasma Cannon"
	def initialize (x, y, angle, parent)
		super
		@image = texture("cannon2")
		@topimage = texture("cannon2Top")
		@botimage = texture("cannon2Base")
		@w = @wdown = @sleft = @sright = true
		@parent.guns << self
		@dwire = false
	end
	def shoot
		updateVars
		if @sdown && $plasma >= 50
			PlasmaBullet.new(@wx, @wy, @parent.angle, 50)
			$plasma -= 50
		end
	end

	def draw
		edges = nei2(@x, @y, @board, self.class.name)
		@sdown = !edges[3]
		super
		if edges[1]
			@topimage.draw_rot(@wx, @wy, 1.1, 0 + @parent.angle)
		end
		if !edges[3]
			@botimage.draw_rot(@wx, @wy, 1.1, 0 + @parent.angle)
		end
	end

	def destroy
		@parent.guns.delete(self)
		super
	end
end

class TileCannon3 < Tile
	@name = "Flux Cannon"
	def initialize (x, y, angle, parent)
		super
		@image = texture("cannon3")
		@w = @wdown = @sdown = true
		@parent.guns << self
		@dwire = false
		@p = ParticlePoof.new(0xff_ff00ff,5,10,30)
	end

	def shoot
		updateVars
		if $flux >= 50
			@p.draw(@wx, @wy)
			FluxBullet.new(@wx, @wy, @parent.angle, 50)
			$flux -= 50
		end
	end

	def destroy
		@parent.guns.delete(self)
		super
	end
end

class TilePipe < Tile
	@name = "Pipe"
	def initialize (x, y, angle, parent)
		super
		@image = texture("pipe")
		@base = texture("pipeBase")
		@cap = texture("pipeCap")
		@side = (angle == 90 || angle == 270)
		@angle = angle
		@dboarders = false
		@wable = true
		if @side
			@wleft = @wright = @sleft = @sright = true
		else
			@wup = @wdown = @sup = @sdown = true
		end
	end

	def draw
		super
		pipes = nei2(@x,@y, @board,self.class.name)
		solids = neis(@x,@y,@board)
		sides = [@side, !@side, @side, !@side]
		4.times do |index|
			if sides[index]
				if solids[index]
					if !pipes[index]
						@base.draw_rot(@wx, @wy, 2, 90 + 90 * index + @parent.angle)
					end
				else
					@cap.draw_rot(@wx, @wy, 2, 90 + 90 * index + @parent.angle)
				end
			end
		end
	end
end

class TileEngine < Tile
	@name = "Energy Engine"
	def initialize (x, y, angle, parent)
		super
		@image = texture("engine00")
		@leftImage = texture("engine10")
		@rightImage = texture("engine01")
		@w = @wup = @sleft = @sup = @sright = true
		@dwire = false
		@p = ParticleFlames.new(0xff_ff5500, 5, 3, 180, 40, 3)
		@parent.engines << self
		@edges = [true, true, true, true]
	end

	def update
		super
		@edges = nei2(@x, @y, @board, self.class.name)
	end

	def draw
		super
		@p.draw(@wx, @wy, @parent.angle, @parent.speed)
		if !@edges[0]
			@leftImage.draw_rot(@wx, @wy, 1.1, @parent.angle)
		end
		if !@edges[2]
			@rightImage.draw_rot(@wx, @wy, 1.1, @parent.angle)
		end
	end

	def drive
		if $energy >= 2
			$energy -= 2
			return 1
		elsif $energy >= 1
			$energy -= 1
			return 0.5
		end
		return 0
	end

	def destroy
		@parent.engines.delete(self)
		super
	end
end

class TileEngine2 < Tile
	@name = "Plasma Engine"
	def initialize (x, y, angle, parent)
		super
		@image = texture("engine2")
		@leftImage = texture("engine20")
		@rightImage = texture("engine21")
		@w = @wup = @sleft = @sup = @sright = true
		@dwire = @dboarders = false
		@p = ParticleFlameSpike.new(0xff_00ffff, 10, 5, 180, 10, 3)
		@parent.engines << self
		@edges = [true, true, true, true]
	end

	def update
		super
		@edges = neis(@x, @y, @board)
	end

	def draw
		super
		@p.draw(@wx, @wy,@parent.angle, @parent.speed)
		if !@edges[0]
			@leftImage.draw_rot(@wx, @wy, 2, @parent.angle)
		end
		if !@edges[2]
			@rightImage.draw_rot(@wx, @wy, 2, @parent.angle)
		end
		if !@edges[1]
			@boarder.draw_rot(@wx, @wy, 2, 90 + @parent.angle)
		end
	end

	def drive
		if $plasma >= 2
			$plasma -= 2
			return 1
		end
		return 0
	end

	def destroy
		@parent.engines.delete(self)
		super
	end
end

class TileEngine3 < Tile
	@name = "Flux Engine"
	def initialize (x, y, angle, parent)
		super
		@image = texture("engine3")
		@w = @wup = @sup = true
		@dwire = false
		@p = ParticlePulse.new(0xff_ff00ff,5,10,30,100)
		@parent.engines << self
	end
	def draw
		super
		@p.draw(@wx, @wy, @parent.speed)
	end

	def drive
		if $flux >= 2
			$flux -= 2
			return 1
		end
		return 0
	end

	def destroy
		@parent.engines.delete(self)
		super
	end
end

class TileGenerator < Tile
	@name = "Energy Generator"
	def initialize (x, y, angle, parent)
		super
		$energyGenerators << self
		@image = texture("generator")
		@wire = texture("wireSlantShort")
		@wcore = texture("blank")
		@w = @wleft = @wup = @wright = @wdown = @sleft = @sup = @sright = @sdown = true
	end

	def destroy
		$energyGenerators.delete(self)
		super
	end
end

class TileGenerator2 < Tile
	@name = "Plasma Generator"
	def initialize (x, y, angle, parent)
		super
		$plasmaGenerators << self
		@image = texture("generator2")
		@wire = texture("wireSlantShort")
		@wcore = texture("blank")
		@w = @wleft = @wup = @wright = @wdown = @sleft = @sup = @sright = @sdown = true
	end

	def destroy
		$plasmaGenerators.delete(self)
		super
	end
end

class TileGenerator3 < Tile
	@name = "Flux Generator"
	def initialize (x, y, angle, parent)
		super
		$fluxGenerators << self
		@image = texture("generator3")
		@wire = texture("wireSlantShort")
		@wcore = texture("blank")
		@w = @wleft = @wup = @wright = @wdown = @sleft = @sup = @sright = @sdown = true
	end

	def destroy
		$fluxGenerators.delete(self)
		super
	end
end

class TileStorage < Tile
	@name = "Energy Cell"
	def initialize(x, y, angle, parent)
		super
		$energyStorage << self
		@image = texture("storage")
		@wire = texture("wireSlantShort")
		@wcore = texture("blank")
		@w = @wleft = @wright = @wdown = @sleft = @sup = @sright = @sdown = true
	end

	def destroy
		$energyStorage.delete(self)
		super
	end
end

class TileStorage2 < Tile
	@name = "Plasma Cell"
	def initialize(x, y, angle, parent)
		super
		$plasmaStorage << self
		@image = texture("storage2")
		@wire = texture("wireSlantShort")
		@wcore = texture("blank")
		@w = @wleft = @wright = @wdown = @sleft = @sup = @sright = @sdown = true
	end

	def destroy
		$plasmaStorage.delete(self)
		super
	end
end

class TileStorage3 < Tile
	@name = "Flux Cell"
	def initialize(x, y, angle, parent)
		super
		$fluxStorage << self
		@image = texture("storage3")
		@wire = texture("wireSlantShort")
		@wcore = texture("blank")
		@w = @wleft = @wright = @wdown = @sleft = @sup = @sright = @sdown = true
	end

	def destroy
		$fluxStorage.delete(self)
		super
	end
end

class TileWire < Tile
	@name = "Wire"
	def initialize(x, y, angle, parent)
		@board = parent.board
		if @board[x][y].wable && !@board[x][y].w
			@board[x][y].w = true
		elsif @board[x][y].wable && @board[x][y].w
			@board[x][y].w = false
			$res.add("Wire", 1, false)
		else
			$res.add("Wire", 1, false)
		end
	end
end
