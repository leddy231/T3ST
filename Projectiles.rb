
class FluxBullet
	attr_reader :x, :y
	def initialize (x, y, angle, dmg, speed = 15, life = 60, tag = "player")
		@image = Gosu::Image.new("textures/fluxball.png", {retro: true})
		@angle = angle
		@x = x
		@y = y
		@dmg = dmg
		@speed = speed
		$world.add self
		@color = 0xff_ff00ff
		@life = life
		@tag = tag
	end

	def update
		@x += Gosu::offset_x(@angle, @speed)
		@y += Gosu::offset_y(@angle, @speed)
		@life -= 1
		if @life < 0
			destroy
		end
		$world.objs.each do |c|
			if @tag == "player" && c.class == Crate && Gosu::distance(c.x, c.y, @x, @y) < 32
				c.hit(@dmg)
				destroy
			end
		end
	end

	def draw
		@image.draw_rot(@x, @y, 7, @angle)
		return if $pause
		Particle.new(@x, @y, @color, 5, 0, @angle, 0.8)
	end

	def destroy
		ParticlePoof.new(@color,5,7,10).draw(@x, @y)
		$world.delete self
	end
end

class PlasmaBullet < FluxBullet
	def initialize (x, y, angle, dmg)
		super(x, y, angle, dmg, 30)
		@image = Gosu::Image.new("textures/plasmaball.png", {retro: true})
		@color = 0xff_00ffff
	end
end

class EnergyBullet < FluxBullet
	def initialize (x, y, angle, dmg)
		super(x, y, angle, dmg, 10)
		@image = Gosu::Image.new("textures/energyball.png", {retro: true})
		@color = 0xff_ffff44
	end
end
