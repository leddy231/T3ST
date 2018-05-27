@image = $window.record($scale.floor * @size + 100,$scale.floor * @size +100){ 
	for i in 0...@size do
		for j in 0...@size do
			$board[i][j].draw
		end
	end
}

def rotx(px,py,x,y,angle)
	angle = angle * (Math::PI/180)
	return Math::cos(angle) * (x - px) - Math::sin(angle) * (y - py) + px
end

def roty(px,py,x,y,angle)
	angle = angle * (Math::PI/180)
	return Math::sin(angle) * (x - px) + Math::cos(angle) * (y - py) + py
end

class AnimatedPopup
	attr_accessor :open
	def initialize
		@open = true
		@x = 500
		@y = 0
		$world.add self
	end
	
	def update
		if @y <= 300 && @open
			@y += 10
		end
		if @y > 0 && !@open
			@y -= 10
		end
	end
	def draw
		Gosu.draw_rect(@x, @y, 100, 100, Gosu::Color.argb(0xff_888888), 101)
	end
end