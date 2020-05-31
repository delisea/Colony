--Turtle base
os.loadAPI("ocs/apis/sensor")

ss = sensor.wrap("front")
tt = turtle
SBlock_Slot = 2

x = 0
y = 0
z = -1

face = 0


xm = 999999
xM = -99999
ym = 99999
yM = -99999
zm = 99999
zM = -99999


Map = {}

function isFreeCell(a,b,c) 
	--print(a,b,c," : ",Map[tostring(a)..","..tostring(b)..","..tostring(c)])
	return Map[tostring(a)..","..tostring(b)..","..tostring(c)] == nil or Map[tostring(a)..","..tostring(b)..","..tostring(c)] ~= "SOLID"
end
function setFreeCell(a,b,c,statut) 
	Map[tostring(a)..","..tostring(b)..","..tostring(c)] = statut
end

function Ssetrange()
	for key, value in pairs(ss.getTargets()) do
		--print(key,"|",value)
		if (xm > value["Position"]["X"]) then xm = value["Position"]["X"]; end
		if (xM < value["Position"]["X"]) then xM = value["Position"]["X"]; end
		
		if (ym > value["Position"]["Y"]) then ym = value["Position"]["Y"]; end
		if (yM < value["Position"]["Y"]) then yM = value["Position"]["Y"]; end
		
		if (zm > value["Position"]["Z"]) then zm = value["Position"]["Z"]; end
		if (zM < value["Position"]["Z"]) then zM = value["Position"]["Z"]; end
		
		setFreeCell(value["Position"]["X"],value["Position"]["Y"],value["Position"]["Z"],value["Type"])
	end
	print("x: ", xm, ":", xM)
	print("y: ", ym, ":", yM)
	print("z: ", zm, ":", zM)
end

--todo gerer orientation
function find_tree()
	tt.select(SBlock_Slot)
	tt.drop()
	Ssetrange();
	tres = ss.getTargets()
	function res(a,b,c)
		return tres[tostring(a)..","..tostring(b)..","..tostring(c)]
	end
	function solid(a,b,c)
		return res(a,b,c)~= nil and res(a,b,c)["Type"] == "SOLID"
	end
	--print(solid(2,1,0))
	--print(solid(1,1,0))
	--print(solid(3,1,0))
	--print(solid(2,1,1))
	--print(solid(2,1,-1))
	dist = 99999
	candidate = nil
	for ty=ym,yM do
		for tx=xm,xM do
			for tz=zm,zM do
			if(res(tx,ty,tz) ~= nil) then
			--print(tz," ",res(tx,ty,tz)["Position"]["Z"])
				if(solid(tx,ty,tz) and not solid(tx-1,ty,tz) and not solid(tx+1,ty,tz) and not solid(tx,ty,tz-1) and not solid(tx,ty,tz+1) and
				solid(tx,ty+1,tz) and not solid(tx-1,ty+1,tz) and not solid(tx+1,ty+1,tz) and not solid(tx,ty+1,tz-1) and not solid(tx,ty+1,tz+1)) then
					--print(tx,ty,tz)
					if((tx-x)*(tx-x)+(ty-y)*(ty-y)+(tz-z)*(tz-z)<dist) then
						dist = (tx-x)*(tx-x)+(ty-y)*(ty-y)+(tz-z)*(tz-z)
						candidate = {tx,ty,tz}
					end
				end
			end
			end
		end
	end
	if(candidate == nil) then
		print("No tree found")
	else
		print("Tree in (",candidate[1],",",candidate[2],",",candidate[3],") dist: ",dist)
	end
	return candidate
end

function find_block(blockType)
	tt.select(SBlock_Slot)
	tt.drop()
	for key, value in pairs(ss.getTargets()) do
		--print(key,"|",value)
		if (xm > value["Position"]["X"]) then xm = value["Position"]["X"]; end
		if (xM < value["Position"]["X"]) then xM = value["Position"]["X"]; end
		for key2, value2 in pairs(value) do
			--print(key2,"|",value2)
			--if (type(value2) == "table") then
			--	for pk,pv in pairs(value2) do
					--print(pk,"-",pv)
			--	end
			--end
		end
	end
	print("x: ", xm, ":", xM)
end

function cdist(tx,ty,tz)
	return (tx-x)*(tx-x)+(ty-y)*(ty-y)+(tz-z)*(tz-z)
end
function dist(tx,ty,tz,x,y,z)
	return (tx-x)*(tx-x)+(ty-y)*(ty-y)+(tz-z)*(tz-z)
end

function moveCloseToBQP(dx,dy,dz)
	while(cdist(dx,dy,dz)>1) do
		if(dz<z) then
			t = {
			  [1] = function() z=z-1; tt.back() end,
			  [2] = function() face=2; tt.turnRight() end,
			  [3] = function() z=z-1; tt.forward() end,
			  [4] = function() face=2; tt.turnLeft() end,
			}; t[face+1]()
		elseif(dz>z) then
			t = {
			  [1] = function() z=z+1; tt.forward() end,
			  [2] = function() face=0; tt.turnLeft() end,
			  [3] = function() z=z+1; tt.back() end,
			  [4] = function() face=0; tt.turnRight() end,
			}; t[face+1]()
		elseif(dx<x) then
			t = {
			  [4] = function() x=x-1; tt.back() end,
			  [1] = function() face=1; tt.turnRight() end,
			  [2] = function() x=x-1; tt.forward() end,
			  [3] = function() face=1; tt.turnLeft() end,
			}; t[face+1]()
		elseif(dx>x) then
			t = {
			  [2] = function() x=x+1; tt.forward() end,
			  [3] = function() face=3; tt.turnLeft() end,
			  [4] = function() x=x+1; tt.back() end,
			  [1] = function() face=3; tt.turnRight() end,
			}; t[face+1]()
		end
	end
end


function front()
	r = tt.forward()
	if(not r) then return false; end
	t = {
	  [1] = function() z=z+1; end,
	  [2] = function() x=x-1 end,
	  [3] = function() z=z-1;end,
	  [4] = function() x=x+1 end,
	}; t[face+1]()
	return true
end
function back()
	r = tt.back()
	if(not r) then return false; end
	t = {
	  [1] = function() z=z-1; end,
	  [2] = function() x=x+1 end,
	  [3] = function() z=z+1;end,
	  [4] = function() x=x-1 end,
	}; t[face+1]()
	return true
end
function turnLeft()
	r = tt.turnLeft()
	face = ((face-1)%4 + 4)%4;
	return true
end
function turnRight()
	r = tt.turnRight()
	face = (face+1)%4;
	return true
end
function up()
	if(tt.up()) then
		y=y+1
		return true
	end
	return false
end
function down()
	if(tt.down()) then
		y=y-1
		return true
	end
	return false
end

function gdist(x1,y1,z1,x2,y2,z2)
	local l
	if(x1<x2) then
		l = x1
		x1=x2
		x2=l
	end
	if(y1<y2) then
		l = y1
		y1=y2
		y2=l
	end
	if(z1<z2) then
		l = z1
		z1=z2
		z2=l
	end
	return x1-x2+z1-z2+y1-y2
end

--add double cost when turn
function astar(dc,cc)

	local closedList = {}
	local openList = nil--{pos=cc,cout=0,next=nil,parent=nil}
	local u
	local v
	local p
	
	function addtol(openList, cel)
	    if(openList == nil) then
	        return cel
	    end
		if(openList.dist>cel.dist) then
			cel.next = openList
			return cel
		end
		local cc = openList
		while(cc.next ~= nil and cc.next.dist < cel.dist) do --dist+cout?
			cc = cc.next
		end
		cel.next = cc.next
		cc.next = cel
		return openList
	end
	
	function reversePath(u)
		local ret = u
		local temp
		u = u.parent
		ret.next = nil
		while(u~=nil) do
			temp = u.parent
			u.next = ret
			ret = u
			u=temp
		end
		return ret
	end
	-- Force first do due to current position occupied
	u = {pos=cc,cout=0,next=nil,parent=nil}
	openList={pos={u.pos[1]+1,u.pos[2],u.pos[3]}, cout=u.cout+1, dist=gdist(u.pos[1]+1,u.pos[2],u.pos[3],dc[1],dc[2],dc[3]), next=nil, parent=u}
	openList=addtol(openList,{pos={u.pos[1]-1,u.pos[2],u.pos[3]}, cout=u.cout+1, dist=gdist(u.pos[1]-1,u.pos[2],u.pos[3],dc[1],dc[2],dc[3]), next=nil, parent=u})
	openList=addtol(openList,{pos={u.pos[1],u.pos[2]+1,u.pos[3]}, cout=u.cout+1, dist=gdist(u.pos[1],u.pos[2]+1,u.pos[3],dc[1],dc[2],dc[3]), next=nil, parent=u})
	openList=addtol(openList,{pos={u.pos[1],u.pos[2]-1,u.pos[3]}, cout=u.cout+1, dist=gdist(u.pos[1],u.pos[2]-1,u.pos[3],dc[1],dc[2],dc[3]), next=nil, parent=u})
	openList=addtol(openList,{pos={u.pos[1],u.pos[2],u.pos[3]+1}, cout=u.cout+1, dist=gdist(u.pos[1],u.pos[2],u.pos[3]+1,dc[1],dc[2],dc[3]), next=nil, parent=u})
	openList=addtol(openList,{pos={u.pos[1],u.pos[2],u.pos[3]-1}, cout=u.cout+1, dist=gdist(u.pos[1],u.pos[2],u.pos[3]-1,dc[1],dc[2],dc[3]), next=nil, parent=u})
	closedList[tostring(u.pos[1])..","..tostring(u.pos[2])..","..tostring(u.pos[3])] = u.cout
	urg = 0
	while(openList ~= nil) do
		u = openList
		openList = u.next
		if(u.pos[1] == dc[1] and u.pos[2] == dc[2] and u.pos[3] == dc[3]) then
			return reversePath(u).next
		end
		--print(u.pos[1],u.pos[2],u.pos[3],u.cout,u.dist)
		urg = urg + 1
		if urg > 1000 then return nil end
		
		if(isFreeCell(u.pos[1],u.pos[2],u.pos[3])) then		
			if(closedList[tostring(u.pos[1]+1)..","..tostring(u.pos[2])..","..tostring(u.pos[3])] == nil or closedList[tostring(u.pos[1]+1)..","..tostring(u.pos[2])..","..tostring(u.pos[3])]>u.cout+1) then
				openList=addtol(openList,{pos={u.pos[1]+1,u.pos[2],u.pos[3]}, cout=u.cout+1, dist=gdist(u.pos[1]+1,u.pos[2],u.pos[3],dc[1],dc[2],dc[3]), next=nil, parent=u})
			end
			if(closedList[tostring(u.pos[1]-1)..","..tostring(u.pos[2])..","..tostring(u.pos[3])] == nil or closedList[tostring(u.pos[1]-1)..","..tostring(u.pos[2])..","..tostring(u.pos[3])]>u.cout+1) then
				openList=addtol(openList,{pos={u.pos[1]-1,u.pos[2],u.pos[3]}, cout=u.cout+1, dist=gdist(u.pos[1]-1,u.pos[2],u.pos[3],dc[1],dc[2],dc[3]), next=nil, parent=u})
			end
			if(closedList[tostring(u.pos[1])..","..tostring(u.pos[2]+1)..","..tostring(u.pos[3])] == nil or closedList[tostring(u.pos[1])..","..tostring(u.pos[2]+1)..","..tostring(u.pos[3])]>u.cout+1) then
				openList=addtol(openList,{pos={u.pos[1],u.pos[2]+1,u.pos[3]}, cout=u.cout+1, dist=gdist(u.pos[1],u.pos[2]+1,u.pos[3],dc[1],dc[2],dc[3]), next=nil, parent=u})
			end
			if(closedList[tostring(u.pos[1])..","..tostring(u.pos[2]-1)..","..tostring(u.pos[3])] == nil or closedList[tostring(u.pos[1])..","..tostring(u.pos[2]-1)..","..tostring(u.pos[3])]>u.cout+1) then
				openList=addtol(openList,{pos={u.pos[1],u.pos[2]-1,u.pos[3]}, cout=u.cout+1, dist=gdist(u.pos[1],u.pos[2]-1,u.pos[3],dc[1],dc[2],dc[3]), next=nil, parent=u})
			end
			if(closedList[tostring(u.pos[1])..","..tostring(u.pos[2])..","..tostring(u.pos[3]+1)] == nil or closedList[tostring(u.pos[1])..","..tostring(u.pos[2])..","..tostring(u.pos[3]+1)]>u.cout+1) then
				openList=addtol(openList,{pos={u.pos[1],u.pos[2],u.pos[3]+1}, cout=u.cout+1, dist=gdist(u.pos[1],u.pos[2],u.pos[3]+1,dc[1],dc[2],dc[3]), next=nil, parent=u})
			end
			if(closedList[tostring(u.pos[1])..","..tostring(u.pos[2])..","..tostring(u.pos[3]-1)] == nil or closedList[tostring(u.pos[1])..","..tostring(u.pos[2])..","..tostring(u.pos[3]-1)]>u.cout+1) then
				openList=addtol(openList,{pos={u.pos[1],u.pos[2],u.pos[3]-1}, cout=u.cout+1, dist=gdist(u.pos[1],u.pos[2],u.pos[3]-1,dc[1],dc[2],dc[3]), next=nil, parent=u})
			end
			closedList[tostring(u.pos[1])..","..tostring(u.pos[2])..","..tostring(u.pos[3])] = u.cout
		else
			closedList[tostring(u.pos[1])..","..tostring(u.pos[2])..","..tostring(u.pos[3])] = -1
		end
    end
	return nil	
end


function stepTo(dx,dy,dz)
	if(dz<z) then
		t = {
		  [1] = function() return back() end,
		  [2] = function() turnRight(); return front() end,
		  [3] = function() return front() end,
		  [4] = function() turnLeft(); return front() end,
		}; return t[face+1]()
	elseif(dz>z) then
		t = {
		  [1] = function() return front() end,
		  [2] = function() turnLeft(); return front() end,
		  [3] = function() return back() end,
		  [4] = function() turnRight(); return front() end,
		}; return t[face+1]()
	elseif(dx<x) then
		t = {
		  [4] = function() return back() end,
		  [1] = function() turnRight(); return front() end,
		  [2] = function() return front() end,
		  [3] = function() turnLeft(); return front() end,
		}; return t[face+1]()
	elseif(dx>x) then
		t = {
		  [4] = function() return front() end,
		  [1] = function() turnLeft(); return front() end,
		  [2] = function() return back() end,
		  [3] = function() turnRight(); return front() end,
		}; return t[face+1]()
	elseif(dy>y) then
		return up()
	elseif(dy<y) then
		return down()
	end
end

function moveCloseTo(dx,dy,dz)
	ret = astar({dx,dy,dz},{x,y,z})

	while(ret~=nil and cdist(dx,dy,dz)>1) do
		print(ret.pos[1],ret.pos[2],ret.pos[3],ret.cout,ret.dist)
		if(not stepTo(ret.pos[1],ret.pos[2],ret.pos[3])) then
			setFreeCell(ret.pos[1],ret.pos[2],ret.pos[3],"SOLID")--TODO should check via inspect
			ret = astar({dx,dy,dz},{x,y,z})
		else
		--stepTo(ret.pos[1],ret.pos[2],ret.pos[3])
			ret = ret.next
		end
	end
end

function moveTo(dx,dy,dz)
	moveCloseTo(dx,dy,dz)
	stepTo(dx,dy,dz)
end

--TODO check de secu
function turnTo(d)
	while(d ~= face) do
		turnRight()
	end
end

function faceTo(a,b,c)
	if(a>x) then turnTo(3)
	elseif(a<x) then turnTo(1)
	elseif(c>z) then turnTo(0)
	elseif(c<z) then turnTo(2)
	end
end

function goToRadar()
	moveTo(0,0,-1)
	turnTo(0)
end

--dest = find_tree()
--moveCloseTo(dest[1],dest[2],dest[3])
--moveCloseTo(0,0,0)

dest = find_tree()

moveCloseTo(dest[1],dest[2],dest[3])
faceTo(dest[1],dest[2],dest[3])
tt.dig()
print("done")
goToRadar()



--stepTo(0,0,-2)
--moveTo(0,0,-2)
--turnTo(3)

exit()

local t = sensor.wrap("right")
local targets = t.getTargets()
for key, value in pairs(targets) do
for key2, value2 in pairs(value) do
print(key2,"|",value2)
if (type(value2) == "table") then
	for pk,pv in pairs(value2) do
		print(pk,"-",pv)
	end
end
end
end













os.loadAPI("ocs/apis/sensor")
local sensor = sensor.wrap("right")
local targets = sensor.getTargets()
for key, value in pairs(targets) do
print(key.." "..value)
end