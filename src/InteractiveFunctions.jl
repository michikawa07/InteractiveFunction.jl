module InteractiveFunctions
	using Revise:includet
	using REPL.TerminalMenus:RadioMenu,MultiSelectMenu,request,config

	export includet_menu, cd_menu

	function readdir_all!(filecontents, dir="")
		isdir(dir) && dir[end]!='/' && (dir*='/')
		list = readdir(dir=="" ? pwd() : dir)
		for name in list
			(isdir(dir*name) 
				?	readdir_all!(filecontents, dir*name*'/') 
				:	push!(filecontents, dir*name)	)
	 	end 
		filecontents
	end
	readdir_all(dir="",filecontents=String[]) = readdir_all!(filecontents,dir)
	

	function includet_menu()
		try	
			list = readdir_all() |> l->l[occursin.(".jl",l)]
			config(ctrl_c_interrupt = false)
			menu = MultiSelectMenu(list)
			choice = request("\\n== choice revising file ==", menu)
			#=if=# length(choice) ≤ 0 && throw(ErrorException(""))
			println("==========================\n")
			for file in list[choice|>collect]
				println(" includet( \"$(file)\" )")
				stats = @timed includet(pwd()*"/".*file)
				println("  - success (time:$(stats.time))\n")
			end
		catch e ;println("\n - cancel or failed\n $e\n")
		end
	end

	function cd_menu()
		try	
			list = readdir() |> l->["..", l[isdir.(l)]...]
			config(ctrl_c_interrupt = false)
			menu = RadioMenu(list.*"/")
			choice = request("\n== choice changing directory ==\n~~~~", menu)
			#=if=# choice == -1 && throw(ErrorException(""))
			print("~~~~\n - cd( \"$(list[choice])\" )")
			cd(list[choice])
			println("  - success\n")
		catch e ;println("\n - cancel or failed\n $e\n")
		end
	end

end