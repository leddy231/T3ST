class ParticleFlames
	def initialize(col, fadespeed, vel, angle, spread, amount, instant = false)
		@am = amount
		@vel = vel
		@col = col
		@angle = angle
		@spread = spread
		@nspread = spread * -1
		@fadespeed = fadespeed
		@instant = instant
	end

	def draw (x, y, angle, vel)
		return if $pause
		for i in 1..@am do
			Particle.new(x, y, @col, @fadespeed, @vel + vel, @angle + angle + rand(@nspread..@spread)).draw
		end
	end
end

class ParticleFlameSpike
	def initialize (col, fadespeed, vel, angle, spread, amount)
		@am = amount
		@vel = vel
		@col = col
		@fadespeed = fadespeed
		@spread = spread
		@nspread = spread * -1
		@angle = angle
	end
	def draw (x, y, angle, vel)
		return if $pause
		for i in 0..@am do
			s = rand(@nspread..@spread)
			Particle.new(x + s, y, @col, @fadespeed, @vel + vel, @angle + angle + s * 0.3).draw
		end
	end
end

class ParticlePoof
	def initialize (col, fadespeed, vel, amount)
		@am = amount
		@vel = vel
		@col = col
		@fadespeed = fadespeed
	end

	def draw (x, y)
		return if $pause
		for i in 0..@am do
			Particle.new(x, y, @col, @fadespeed, @vel, rand(0..360), 0.8)
		end
	end
end

class ParticlePulse < ParticlePoof
	def initialize (col, fadespeed, vel, amount, time)
		super(col, fadespeed, vel, amount)
		@t = @ot = time
	end

	def draw (x, y, vel)
		@t -= vel / 2 + 2
		if @t < 0
			super(x, y)
			@t = @ot
		end
	end
end


class Particle
	def initialize (x, y, col, fadespeed, vel, angle, decreasespeed = 0.95)
		@x = x
		@y = y
		$particles << self
		@fadeSpeed = fadespeed
		@gcol = Gosu::Color.argb(col)
		@a = @gcol.alpha
		@r = @gcol.red
		@g = @gcol.green
		@b = @gcol.blue
		@vel_x = Gosu::offset_x(angle, vel)
		@vel_y = Gosu::offset_y(angle, vel)
		@despeed = decreasespeed
		@angle = angle
	end

	def draw
		$window.rotate(@angle, @x, @y) { Gosu.draw_rect(@x, @y, 10, 10, @gcol, 0.9) }
	end

	def update
		if Gosu::distance($player.worldx, $player.worldy, @x, @y) > 2000
			destroy
		end
		if !$pause
			fade
			@x += @vel_x
			@y += @vel_y
			@vel_x *= @despeed
			@vel_y *= @despeed
			@angle = rand(0..360)
		end
	end

	def destroy
		$particles.delete(self)
	end

	def fade
		@r -= @fadeSpeed
		@g -= @fadeSpeed
		@b -= @fadeSpeed
		@a -= @fadeSpeed
		@gcol = Gosu::Color.new(@a,@r,@g,@b)
		if @a < 0
			destroy
		end
	end
end
