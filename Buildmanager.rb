
class InvTile
	attr_accessor :name, :image, :rot, :clas, :amount, :text
	def initialize(clas, texturestring, rotate = false, name = clas.name)
		@name = name
		@image = Gosu::Image.new(texturestring, {retro: true})
		@rot = rotate
		@clas = clas
		@amount = 0
		$inv << self
	end
end

class Buildmanager
	def initialize

		InvTile.new(TileEmpty, "textures/Display/Empty.png")
		InvTile.new(TileSlant, "textures/emptySlant.png", true)
		InvTile.new(TileSlantCurved, "textures/curvedSlant.png", true)
		InvTile.new(TilePipe, "textures/Display/Pipe.png", true)
		InvTile.new(TileWire, "textures/wcore.png")
		InvTile.new(TileEngine, "textures/Display/Engine.png")
		InvTile.new(TileEngine2, "textures/Display/Engine2.png")
		InvTile.new(TileEngine3, "textures/engine3.png")
		InvTile.new(TileCannon, "textures/cannon.png")
		InvTile.new(TileCannon2, "textures/cannon2.png")
		InvTile.new(TileCannon3, "textures/cannon3.png")
		InvTile.new(TileGenerator, "textures/generator.png")
		InvTile.new(TileGenerator2, "textures/generator2.png")
		InvTile.new(TileGenerator3, "textures/generator3.png")
		InvTile.new(TileStorage, "textures/storage.png")
		InvTile.new(TileStorage2, "textures/storage2.png")
		InvTile.new(TileStorage3, "textures/storage3.png")

		@font = Gosu::Font.new(32)
		@invselect = -1
		@invrot = 0
		@x = 10
		@y = 200
		@listHeight = 40
		longest = $inv.max_by{|x| @font.text_width(x.name)}
		@w2 = @font.text_width(longest.name) + 30
		updateInventory
	end

	def build (x = $posx, y = $posy, rot = @invrot)
		return if $player.board[$posx][$posy].class.name == "Core"
		cInv = @inv[@invselect]
		if cInv.amount > 0 || $debug
			cInv.clas.new(x, y, rot, $player)
			cInv.amount -= 1
			updateInventory
			updateBuildlist
		end
	end

	def remove
		if $buildmode && $player.board[$posx][$posy].class.name != "Core"
			Tile.new($posx, $posy, 0, $player)
		end
		updateInventory
		updateBuildlist
	end

	def updateBuildlist
		if @invselect == -1
			return
		end
		@invselect = cap(@invselect, 0, @inv.size - 1)
		@invrot = 0 if !@inv[@invselect].rot
	end

	def invDown
		return if @inv.size == 0
		@invselect = cap(@invselect + 1, 0, @inv.size - 1)
		updateBuildlist
	end

	def invUp
		return if @inv.size == 0
		@invselect = cap(@invselect - 1, 0, @inv.size - 1)
		updateBuildlist
	end

	def invRotR
		@invrot += 90
		@invrot = 0 if @invrot > 270
	end

	def invRotL
		@invrot -= 90
		@invrot = 270 if @invrot < 0
	end

	def draw
		return if !$buildmode
		Gosu.draw_rect(@x, @y, @w, @h, Gosu::Color.argb(0xff_888888), 101)
		for q in 0...@inv.size
			@inv[q].image.draw(@x + 10, @y + 4 + @listHeight * q, 102)
			@font.draw(@inv[q].name, @x + 52, @y + 4 + @listHeight * q, 102)
			@font.draw(@am[q].to_s, @x + @w2 + 40, @y + 4 + @listHeight * q, 102)
		end
		@x2 = ($posx - $middle) * 32 + $offsetx / $zoom
		@y2 = ($posy - $middle) * 32 + $offsety / $zoom
		Gosu::scale($zoom) do
			Gosu.draw_rect(@x2, @y2, 32, 32, Gosu::Color.argb(0x55_ff0000), 11)
			return if @invselect == -1
			@inv[@invselect].image.draw_rot(@x2 + 16, @y2 + 16, 10, @invrot)
		end
		Gosu.draw_rect(@x, @y + @invselect * @listHeight, @w, @listHeight, Gosu::Color.argb(0x44_ff0000), 103)
	end

	#SUPER SLOW, HALP, LAGS WHEN BUILDING
	#i fix is ok now but keep eye yes
	def updateInventory
		@inv = []
		@am = []
		for cInv in $inv do
			if cInv.amount > 0 || $debug
				@am << cInv.amount
				@inv << cInv
			end
		end
		if @inv[0] == nil
			@w = @h = 0
			@invselect = -1
			return
		end
		invDown if @invselect == -1
		longest = @am.max_by{|x| @font.text_width(x.to_s)}
		@w = 50 + @font.text_width(longest.to_s)+ @w2
		@h = @inv.size * @listHeight
	end
end
