module InteractiveFunction
	using Revise
	using REPL.TerminalMenus

	import Revise
	import Base.Filesystem

	export includet_menu, cd_menu, CD

	"""
		dir 以下のファイルをすべて参照し， dirとの相対Pathを返す．
	"""
	function readdirs(dir=pwd(); join=false, sort=true)
		filecontents = String[]
		for (root, dirs, filenames) in walkdir(dir)
			paths_full = joinpath.(root, filenames )
			paths_rel = relpath.(paths_full , dir )
			push!(filecontents, paths_rel...) # path to files
		end
		sort && sort!( filecontents )
		filecontents
	end	

	function getrevisedfile(dir=pwd())
		revisedfile = String[]
		for (root,files) in Revise.watched_files
			filenames = keys(files.trackedfiles)
			paths_full = joinpath.(root, filenames )
			paths_rel = relpath.(paths_full , dir )
			push!(revisedfile,paths_rel...)
		end
		revisedfile
	end

	"""
		Current directory 以下にある `.jl` ファイルを `MultiSelectMenu` で列挙する．\n
		選択された `.jl` ファイルを `Revise.includemt` でincludeする．
	"""
	function includet_menu(; verbose=true, result=false)  #todo リファクタする．
		header = "\n==== choice file to revise ===="
		footer =   "==============================="
		try	
			list = filter( endswith(".jl"), readdirs() ) 
			list_selected = filter( l->!occursin("..",l), getrevisedfile() )
			selected = [i for (i,l) in enumerate(list) if l ∈ list_selected]

			menu = MultiSelectMenu( list; selected )
			choice = request(header, menu) |> collect
			println(footer)
			
			#=if=# length(choice) ≤ 0 && throw("cancel")
			for file in list[choice]
				file ∈ list_selected && continue
				verbose && @info "\n includet( \"$(file)\" )"
				stats = @timed includet(joinpath(pwd(), file))
				println(" - finish (time:$(stats.time))\n")
			end
			result || return
			println("== Variables and Functions ==\n")
			varinfo() |> display
		catch e 
			println("\n - $e")
		end
		println("\n")
	end

	Revise.includet(;karg...) = includet_menu(;karg...)

	function clean(H)
		buf = IOBuffer()
		for i in 1:H+1
			 print(buf, "\x1b[2K") # clear line
			 print(buf, "\x1b[999D\x1b[$(1)A") # rollback
		end
		print(buf |> take! |> String)
  	end

	TerminalMenus.config( scroll = :nowrap)

	function cd_menu(;karg=false)
		header="\n== choice changing directory =="
		try
			list = filter( isdir, readdir() )
			pushfirst!(list, "..")
			menu =  RadioMenu(list.*"/")
			choice = request(header, menu)
			#=if=# choice == -1 && throw(pwd())
			cd( list[choice])
			clean( 1+min(length(list), menu.pagesize+menu.pageoffset) )
			cd_menu()
		catch e ;println("\n - $e\n")
		end
	end

	CD(;karg...) = cd_menu(karg...)

	macro multiSelectMenud(f, title)
		#f_d = Symbol(f,"_menued")
		#@eval function $f_d(x...; y...) $f($x, x...;y...) end
		try	
			list = readdirs() |> l->l[occursin.(r".jl$",l)]
			config(ctrl_c_interrupt = false)
			menu = MultiSelectMenu(list)
			choice = request("\n== choice multi files ==", menu)
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
