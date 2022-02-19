module InteractiveFunctions
	using Revise
	using REPL.TerminalMenus
	using InteractiveUtils

	export includemt, cdm

	"""
		dir 以下のファイルをすべて参照し，dirとの相対Pathを返す．
	"""
	function readdirs(dir=pwd(); join=false)
		filecontents = String[]
		for (root, dirs, filenames) in walkdir(dir)
			#///folder = relpath( root, dir )
			#///paths = joinpath.(folder, filenames )
			paths_full = joinpath.(root, filenames )
			paths_rel = relpath.(paths_full , dir )
			push!(filecontents,paths_rel...) # path to files
		end
		filecontents
	end	

	function getRevisedFileName(dir=pwd())
		revisedfile = String[]
		for (root,files) in Revise.watched_files
			filenames = keys(files.trackedfiles)
			#///folder = relpath( root, dir )
			#///paths = joinpath.(folder, filenames)
			paths_full = joinpath.(root, filenames )
			paths_rel = relpath.(paths_full , dir )
			push!(revisedfile,paths_rel...)
		end
		revisedfile
	end

	function includemt(;showFunc=true,showVar=false)
		try	
			list = readdirs() |> l->l[occursin.(r".jl$",l)]
			selectedlist = getRevisedFileName() |> l->l[.!occursin.("..",l)]
			selected = [i for (i,l) in enumerate(list) if l ∈ selectedlist]

			TerminalMenus.config(ctrl_c_interrupt = false)
			menu = MultiSelectMenu(list;selected)
			choice = request("\n== choice revising file ==", menu)
			println("==========================")
			
			#=if=# length(choice) ≤ 0 && throw("cancel")
			for file in list[choice|>collect]
				file ∈ selectedlist && continue
				showFunc && println("\n includet( \"$(file)\" )")
				stats = @timed a=includet(joinpath(pwd(), file))
				println("  - success (time:$(stats.time))\n")
			end
			showVar || return
			println("== Variables and Functions ==\n")
			varinfo() |> display
			println("\n")
		catch e 
			println("\n - $e\n")
			return
		end
	end

	function cdm()
		try	
			list = readdir() |> l->["..", l[isdir.(l)]...]
			TerminalMenus.config(ctrl_c_interrupt = false)
			menu = RadioMenu(list.*"/")
			choice = request("\n== choice changing directory ==", menu)

			#=if=# choice == -1 && throw("cancel")
			println("==============================\n")
			println(" cd( \"$(list[choice])\" )")
			cd(list[choice])
			println("  - success")
		catch e ;println("\n - $e\n")
		end
	end

	macro multiSelectMenud(f, title)
		#f_d = Symbol(f,"_menued")
		#@eval function $f_d(x...; y...) $f($x, x...;y...) end
		try	
			list = readdirs() |> l->l[occursin.(r".jl$",l)]
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
end
