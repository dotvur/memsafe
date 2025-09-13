local memsafe = {}

function memsafe:Create(Size: number?)
	local safe = {}
	local methods = {}
	local connections = {}
	local safeSize = 0
	
	function methods:append(k: any, v: any): boolean
		local exists = safe[k]
			
		if exists then
			self:remove(k)
		end

		if (Size and safeSize < Size) or not Size then
			safe[k] = v

			if typeof(v) == "Instance" then
				local conn: RBXScriptConnection

				conn = v.AncestryChanged:Connect(function()
					if not v.Parent then
						conn:Disconnect()

						if safe[k] == v then
							safe[k] = nil

							safeSize -= 1
						end

						connections[v] = nil
					end
				end)

				connections[v] = conn
			end

			safeSize += 1
			return true
		else
			warn('MemsafeTable is full!')

			return false
		end
	end
	
	function methods:remove(k: any): boolean
		local v = safe[k]
		
		if v then
			if v:IsA('Instance') then
				connections[v]:Disconnect()
				
				connections[v] = nil
			end
			
			safe[k] = nil
			safeSize -= 1
			
			return true
		end
		
		return false
	end
	
	function methods:find(v): Key
		for key, val in pairs(safe) do
			if val == v then
				return key
			end
		end
	end
	
	function methods:gcollect(get: boolean)
		local collected = {}
		
		for k, v in pairs(safe) do
			if typeof(v) == "Instance" then
				if not v.Parent then
					safe[k] = nil
					
					local conn = connections[v]
					
					if conn and conn.Connected then
						connections[v]:Disconnect()
						
						connections[v] = nil
					end
					
					safeSize -= 1
					
					if get then
						table.insert(collected, {k, v})
					end
				end
			end
		end
		
		return collected
	end
	
	function methods:getsize()
		return safeSize
	end	
	
	function methods:reset()
		for k, v in pairs(safe) do
			safe[k] = nil
			
			local conn = connections[v]
			
			if conn then
				conn:Disconnect()
				
				connections[v] = nil
			end
		end
		
		safeSize = 0
	end
	
	return safe, methods, connections
end

return memsafe
