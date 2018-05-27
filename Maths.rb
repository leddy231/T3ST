def texture(string)
	return Gosu::Image.new("textures/#{string}.png", {retro: true})
end


def rotmouse(mx, my, x, y)
	return (180/Math::PI) * Math::atan2(my - y, mx - x)
end

#returns x but rotated by angle, use this + offset from 0
def rotx2 (x, y, angle)
	angle = angle * (Math::PI/180)
	return Math::cos(angle) * x - Math::sin(angle) * y
end

#returns y but rotated by angle, use this + offset from 0
def roty2 (x, y, angle)
	angle = angle * (Math::PI/180)
	return Math::sin(angle) * x + Math::cos(angle) * y
end

def isinside(x)
	return false if x < 0 || x > $size - 1
	return true
end

def isInt(string)
	/\A\d+\z/ === string
end

def cap(value, min, max)
	if value < min
		value = min
	end
	if value > max
		value = max
	end
	return value
end

=begin
	__1__
	0___2
	__3__
=end
def neis (x, y, board)
	ret = [false, false, false, false]
	if isinside(x - 1) && board[x - 1][y].sright
		ret[0] = true
	end
	if isinside(y - 1) && board[x][y -1].sdown
		ret[1] = true
	end
	if isinside(x + 1) && board[x + 1][y].sleft
		ret[2] = true
	end
	if isinside(y + 1) && board[x][y + 1].sup
		ret[3] = true
	end
	return ret
end

def nei2 (x,y,board,string)
	ret = [false,false,false,false]
	if isinside(x -1) && board[x - 1][y].class.name == string
		ret[0] = true
	end
	if isinside(y -1) && board[x][y - 1].class.name == string
		ret[1] = true
	end
	if isinside(x +1) && board[x + 1][y].class.name == string
		ret[2] = true
	end
	if isinside(y +1) && board[x][y + 1].class.name == string
		ret[3] = true
	end
	return ret
end

def neiw (x ,y ,board)
	ret = [false, false, false, false]
	t1 = board[x - 1][y]
	t2 = board[x][y - 1]
	t3 = board[x + 1][y]
	t4 = board[x][y + 1]
	if isinside(x -1) && t1.w && t1.wright
		ret[0] = true
	end
	if isinside(y -1) && t2.w && t2.wdown
		ret[1] = true
	end
	if isinside(x +1) && t3.w && t3.wleft
		ret[2] = true
	end
	if isinside(y +1) && t4.w && t4.wup
		ret[3] = true
	end
	return ret
end
