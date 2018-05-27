
class Resources
	def initialize

		$energy = 0
		$energyMax = 100
		$energyGenerators = []
		$energyStorage = []
		$energyText = ""

		$plasma = 0
		$plasmaMax = 100
		$plasmaGenerators = []
		$plasmaStorage = []
		$plasmaText = ""

		$flux = 0
		$fluxMax = 100
		$fluxGenerators = []
		$fluxStorage = []
		$fluxText = ""
	end

	def update
		$energyMax = ($energyStorage.size + 1) * 100
		$energy = cap(($energy + $energyGenerators.size + 1 ) * 1, 0, $energyMax)
		$energyText = "Energy: #{$energy}/#{$energyMax}"
		$energyText = "Energy: #{$energy}/#{$energyMax}"

		$plasmaMax = ($plasmaStorage.size + 1) * 100
		$plasma = cap(($plasma + $plasmaGenerators.size + 1 ) * 1, 0, $plasmaMax)
		$plasmaText =  "Plasma: #{$plasma}/#{$plasmaMax}"

		$fluxMax = ($fluxStorage.size + 1) * 100
		$flux = cap(($flux + $fluxGenerators.size + 1 ) * 1, 0, $fluxMax)
		$fluxText = "Flux: #{$flux}/#{$fluxMax}"

		Crate.new if $world.objs.size < 10
		if $debug
			$energy = $energyMax
			$plasma = $plasmaMax
			$flux = $fluxMax
		end
	end

	def draw
		$font.draw($energyText, 0, 100, 1)
		$font.draw($plasmaText, 0, 130, 1)
		$font.draw($fluxText, 0, 160, 1)
	end

	def add(name, amount = 1, pop = true)
		if name == "BUG"
			return
		end
		cInv = $inv.find {|s| s.name == name }
		cInv.amount += amount
		if pop
			Popup.new(cInv.image,"+#{amount}")
		end
	end
end

class Crate
	attr_reader :x, :y
	def initialize (x = rand * ($offsetx * 2) - $offsetx + $player.worldx, y = rand * 1000 - 500 + $player.worldy, angle = rand(0..360))
		@image = Gosu::Image.new("textures/crate.png", {retro: true})
		@x = x
		@y = y
		@angle = angle
		@dir = rand(0..360)
		@content = $inv[rand(0...$inv.size)].name
		@hp = 50
		$world.add self
		ParticlePoof.new(0xff_ffffff,3,10,20).draw(@x, @y)
	end

	def update
		if @hp <= 0
			$world.delete(self)
			$res.add(@content)
		end
		if Gosu::distance($player.worldx, $player.worldy, @x, @y) > 2000
			$world.delete self
		end
	end

	def draw
		@image.draw_rot(@x, @y, 0.9, @angle)
	end

	def hit(x)
		@hp -= x
	end
end
