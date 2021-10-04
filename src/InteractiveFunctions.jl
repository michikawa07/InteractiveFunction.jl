module InteractiveFunctions
	using Lazy
	using Revise
	using REPL.TerminalMenus:RadioMenu,MultiSelectMenu,request,config

	export includet_menu, cd_menu

	function readdir_all(dir=".")
		filecontents = String[]
		for (root, dirs, files) in walkdir(dir), file in files
			path = @> joinpath(root, file) replace("\\"=>"/") replace("./"=>"")
			push!(filecontents,path) # path to files
		end
		filecontents
	end	

	function includet_menu()
		try	
			list = readdir_all() |> l->l[occursin.(r".jl$",l)]
			config(ctrl_c_interrupt = false)
			menu = MultiSelectMenu(list)
			choice = request("\n== choice revising file ==", menu)
			#=if=# length(choice) ≤ 0 && throw("cancel")
			println("==========================\n")
			for file in list[choice|>collect]
				println(" includet( \"$(file)\" )")
				stats = @timed includet(pwd()*"/".*file)
				println("  - success (time:$(stats.time))")
			end
		catch e ;println("\n - $e\n")
		end
	end

	function cd_menu()
		try	
			list = readdir() |> l->["..", l[isdir.(l)]...]
			config(ctrl_c_interrupt = false)
			menu = RadioMenu(list.*"/")
			choice = request("\n~~ choice changing directory ~~", menu)
			#=if=# choice == -1 && throw("cancel")
			println("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n")
			println(" cd( \"$(list[choice])\" )")
			cd(list[choice])
			println("  - success")
		catch e ;println("\n - $e\n")
		end
	end
#[(v.trackedfiles|>keys)  for v in Revise.watched_files |> values]
end
