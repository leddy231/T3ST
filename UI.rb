
class Popup
	def initialize (image, text)
		@image = image
		@text = text
		$popups << self
		@times = 80
		@w = @image.width * 2 + ($font.text_width(@text) *2) + 10
	end

	def draw (y)
		if @img == nil
			@img = $window.record(@w.ceil, 74){
				Gosu.draw_rect(0, 0, @w, 74, Gosu::Color.argb(0xff_888888), 100)
				@image.draw(5, 5, 100, 2, 2)
				$font.draw(@text, 74, 5, 100, 2, 2)
			}
		else
			@img.draw(20, 200 + 74 * y, 100)
		end
		if y <= 0
			@times -= 1
		end
		if @times < 0
			$popups.delete(self)
		end
	end
end

class Fader
	attr_accessor :speed, :time, :value
	def initialize(s)
		@speed = s
		@time = 0
		@value = false
	end
end

class Menu
	def initialize
	end

	def open
	end

	def draw
	end
end

class PauseMenu < Menu
	def initialize
		@pauseList = []
		@pauseList << Gosu::Image.from_text("Resume - Esc", 32, options = {retro: true})
		@pauseList << Gosu::Image.from_text("Quests - Q", 32, options = {retro: true})
		@pauseList << Gosu::Image.from_text("Build - B", 32, options = {retro: true})
		@pauseList << Gosu::Image.from_text("Toggle Debug - D", 32, options = {retro: true})
		@pauseList << Gosu::Image.from_text("Toggle Flightmode - F", 32, options = {retro: true})
		@pauseList << Gosu::Image.from_text("Exit - E", 32, options = {retro: true})
		@w = 20 + @pauseList.max_by(&:width).width
		@h = 20 + @pauseList.size * 32
		@x = $offsetx - @w / 2
		@y = $offsety - @h / 2
	end

	def draw
		Gosu.draw_rect(@x, @y, @w, @h, Gosu::Color.argb(0xff_888888), 101)
		for p in @pauseList
			p.draw(@x + 10, @y + 10 + 32 * @pauseList.index(p), 102)
		end
	end
end

class QuestMenu < Menu

	def open
		@w2 = $quests.max_by{|x| x.imgText.width}.imgText.width
		@w = 50 + $quests.max_by{|x| x.imgReward.width}.imgReward.width + @w2
		@h = 20 + $quests.size * 32
		@x = $offsetx - @w / 2
		@y = $offsety - @h / 2
	end

	def draw
		Gosu.draw_rect(@x, @y, @w, @h, Gosu::Color.argb(0xff_888888), 101)
		for q in $quests
			q.imgText.draw(@x + 10, @y + 10 + 32 * $quests.index(q), 102)
			q.imgReward.draw(@x + @w2 + 40, @y + 10 + 32 * $quests.index(q), 102)
		end
	end
end

class Ui
	def initialize
		@fadeobj
		@menu = ""
		@pauseMenu = PauseMenu.new
		@questMenu = QuestMenu.new
		@posText = ""
	end

	def update
		@posText = "#{$world.name}: X#{$player.worldx.floor}, Y#{$player.worldy.floor}"
	end

	def drawUI
		$font.draw(@posText, $offsetx - $font.text_width(@posText) / 2, 20, 100)
		if @menu != "" && @menu != "build" && @menu != "fade"
			Gosu.draw_rect(0, 0, 10000, 10000, Gosu::Color.argb(0xdd_000000), 100)
		end
		if @menu != "build"
			$popups.each {|p| p.draw($popups.index(p))}
		end
		if @menu == "pause"
			@pauseMenu.draw
		end
		if @menu == "quests"
			@questMenu.draw
		end
		if @menu == "fade"
			gcol = Gosu::Color.new(@fadeobj.time,0,0,0)
			Gosu.draw_rect(0, 0, 10000, 10000, gcol, 100)
			@fadeobj.time += @fadeobj.speed
			$zoom += @fadeobj.speed * 0.1
			if @fadeobj.time > 255
				@menu = ""
				@fadeobj.value = true
				@fadeobj.time = 0
				$zoom = 1
				$pause = false
			end
		end
	end

	def fade (obj)
		$pause = true
		@fadeobj = obj
		@menu = "fade"
	end

	def button_down (id)
		case id
		when Gosu::KbE
			if @menu == "pause"
				$window.close
			end

		when Gosu::KbD
			if @menu == "pause"
				$debug = !$debug
			end

		when Gosu::KbF
			if @menu == "pause"
				$flightmode = !$flightmode
			end

		when Gosu::KbB
			if @menu == "" || @menu == "pause"
				$player.switchMode
				@menu = "build"
			elsif @menu == "build"
				$player.switchMode
				@menu = ""
			end

		when Gosu::KbQ
			if @menu == "pause"
				@menu = "quests"
				@questMenu.open
			end

		when Gosu::KbEscape
			if @menu == "pause"
				@menu = ""
				$pause = false
			elsif @menu == "build"
				@menu = ""
				$player.switchMode()
			else
				@menu = "pause"
				@pauseMenu.open
				$pause = true
			end
		end
	end
end
