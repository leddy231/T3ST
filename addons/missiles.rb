class Misile
	attr_reader :x ,:y
	def initialize(x, y, angle, target)
		@x = x
		@y = y
		@angle = angle
		@target = target
	end
end
