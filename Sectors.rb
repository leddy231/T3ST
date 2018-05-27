
def switchSector(name, assisted = false)
	return if ($energy < 100 || $plasma < 100 || $flux < 100) && !assisted
	x = $worlds.index {|w| w.name == name}
	if x != nil
		$world = $worlds[x]
		$player.warp(0,0)
		$world.onEnter
	end
end

class Sector
	attr_accessor :name
	def initialize (name)
		@name = name
		@objects = []
		$worlds << self
	end
	def update
		@objects.each {|o| o.update}
	end
	def draw
		@objects.each {|o| o.draw}
	end
	def add (obj)
		@objects << obj
	end
	def delete (obj)
		@objects.delete(obj)
	end
	def objs
		return @objects
	end
	def onEnter
		
	end
end
