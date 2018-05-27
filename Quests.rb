
class Quest
	attr_reader :imgText, :imgReward, :codename, :stage
	def initialize
		$quests << self
		@stage = 0
		@codename = "default"
		@imgText = Gosu::Image.from_text("<i>Quest </i>", 32, options = {retro: true})
		@imgReward = Gosu::Image.from_text("<i>Reward </i>", 32, options = {retro: true})
	end
	def update
	end
end

class Questteleport < Quest
	def initialize
		super
		@codename = "teleport"
		@imgText = Gosu::Image.from_text("Teleport to Sector Beta", 32, options = {retro: true})
		@imgReward = Gosu::Image.from_text("4 Tiles", 32, options = {retro: true})
	end

	def update
		if $world.name == "Sector Beta"
			$res.add("Tile", 4)
			$quests.delete(self)
		end
	end
end

class QuestStation < Quest
	def initialize
		super
		@codename = "station"
		@imgText = Gosu::Image.from_text("Find Space Station at 5K, -3K", 32, options = {retro: true})
		@imgReward = Gosu::Image.from_text("4 Slants", 32, options = {retro: true})
	end

	def update
		if $world.name == "Sector Alpha" && (4700..5300) === $player.worldx && (-3300..-2700) === $player.worldy
			$res.add("Slant", 4)
			$quests.delete(self)
			Questteleport.new
		end
	end
end

class Station
	def initialize
		@x = 5000
		@y = -3000
		@angle = 0
		@img = Gosu::Image.new("textures/station.png", :retro => true)
		@fader = Fader.new(4)
		@active = 0
	end

	def update
		@active -= 1
		@angle += 0.05
		if @fader.value
			switchSector("Sector Beta", true)
			@fader.value = false
		end
		if @active < 0 && Gosu::distance($player.worldx, $player.worldy, @x, @y) < 100
			@active = 10
			$ui.fade(@fader)
		end
	end

	def draw
		parx = ($player.worldx - @x) / 9
		pary = ($player.worldy - @y) / 9
		@img.draw_rot(@x + parx, @y + pary, 0.8, @angle)
	end
end
