Dir.chdir(File.dirname(__FILE__))
$fullscreen ||= false
require 'gosu'
for file in [
	"Maths", 
	"Tiles", 
	"Ship", 
	"Particles", 
	"Resources", 
	"Projectiles", 
	"Quests",
	"UI", 
	"Sectors", 
	"Enemies", 
	"Buildmanager"] do
	require_relative file
end


class GameWindow < Gosu::Window
	def initialize(width=1500, height=1000, fullscreen=false)
		super
		self.caption = '[T3ST] Tile Space Ship Simulator Thing'

		#initialize vars
		$debug = false
		$flightmode = false
		$pause = false
		$zoom = 2
		$tscale = 32.0
		$offsetx = width / 2.0
		$offsety = height / 2.0
		$size = 19
		$middle = $size / 2.0
		$font = Gosu::Font.new(32)

		$particles = []
		$popups = []
		$worlds = []
		$quests = []

		$buildmode = false
		$inv = []

		$blankImage = Gosu::Image.new("textures/blank.png")
		$emptyText = Gosu::Image.from_text("<i>empty</i>", 32, options = {retro: true})
		@timer = 0
		@speed = 0

		#create managers
		$res = Resources.new
		$ui = Ui.new
		$build = Buildmanager.new
		$player = Player.new($size)

		#create world
		$world = Sector.new("Sector Alpha")
		$world.add Station.new
		Sector.new("Sector Beta")
		Quest.new
		QuestStation.new
		#Popup.new(Gosu::Image.new("textures/debug.png"), "Test")

		#load addons
		Dir[File.dirname(__FILE__) + '/addons/*.rb'].each {|file| require file }
	end

	def update
		$posx = cap(((mouse_x - $offsetx) / ($zoom * $tscale) + $size / 2.0).floor, 0, $size - 1)
		$posy = cap(((mouse_y - $offsety) / ($zoom * $tscale) + $size / 2.0).floor, 0, $size - 1)
		return if $pause
		if @timer > 6
			@timer = 0
			$res.update
			if Gosu::button_down? Gosu::KbW
				@speed = 0
				for e in $player.engines do
					@speed += e.drive
				end
				@speed *= 0.2
			end
		end
		@timer += 1
		$player.update
		$world.update
		if Gosu::button_down? Gosu::KbA
		  $player.turn_left
		end
		if Gosu::button_down? Gosu::KbD
		  $player.turn_right
		end
		if Gosu::button_down? Gosu::KbW
			$player.accelerate(@speed)
		end
		$player.move(rotmouse(mouse_x, mouse_y, $offsetx, $offsety))
		$quests.each {|q| q.update}
		$particles.each {|p| p.update}
		while $particles.length > 1000
			$particles.delete($particles.sample)
		end
		$ui.update
	end

	def button_down(id)
		case id
		when Gosu::MsLeft
			if $buildmode
				$build.build
			else
				$player.shoot
			end
		when Gosu::MsRight
			$build.remove
		when Gosu::KbUp
			$build.invUp
		when Gosu::KbDown
			$build.invDown
		when Gosu::KbRight
			$build.invRotR
		when Gosu::KbLeft
			$build.invRotL
		when Gosu::KbSpace
			$player.shoot
		when Gosu::KbT
			$world.add EnemyAI.new(0, 0)
		when Gosu::KbX
			if $zoom == 2
				$zoom = 1
			elsif $zoom == 1
				$zoom = 0.5
			else
				$zoom = 2
			end
		end
		$ui.button_down(id)
	end

	def draw
		Gosu::translate($offsetx, $offsety) do
			Gosu::scale($zoom) do
				Gosu::translate(-$player.worldx, -$player.worldy) do
					$particles.each {|p| p.draw}
					$world.draw
					$player.draw
				end
			end
		end
		$build.draw
		$res.draw
		$ui.drawUI
	end

	def needs_cursor?
		return true
	end
end


if $fullscreen
	$window = GameWindow.new(Gosu::screen_width,Gosu::screen_height,true)
else
	$window = GameWindow.new
end
$window.show
