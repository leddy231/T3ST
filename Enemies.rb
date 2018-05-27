#o shit waddup

class EnemyAI < Ship
	def initialize (x, y)
		super(5)
		@vel_x = @vel_y = 0
		buildBoard()
		@board.each {|i| i.each {|j| j.updateVars}}
		@wait = 0
		@speed = 0.1
		@worldx = rand * 2000 -1000 + $player.worldx
		@worldy = rand * 2000 - 1000 + $player.worldy
		@angle = rand(0..360)
	end
	
	def update
		super
		dis = Gosu::distance($player.worldx, $player.worldy, @worldx, @worldy)
		if dis < 1000
			lookAt($player)
			if dis > 300
				@vel_x += Gosu::offset_x(@angle, @speed)
				@vel_y += Gosu::offset_y(@angle, @speed)
			end
		end
		if dis < 600
			shoot
		end
		@worldx += @vel_x
		@worldy += @vel_y
		@vel_x *= 0.95
		@vel_y *= 0.9
		@wait -= 1
	end
	
	def shoot
		if @wait < 0
			@guns.shuffle.each {|g| EnergyBullet.new(g.wx, g.wy, @angle, 50)}
			@wait = 60
		end
	end
	
	def lookAt (target)
		@angle = rotmouse(target.worldx, target.worldy, @worldx, @worldy) + 90
	end
end
