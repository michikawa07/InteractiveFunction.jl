using Revise
using REPL.TerminalMenus

import Revise

export includet_menu

""" dir 以下のファイルをすべて参照し， dirとの相対Pathを返す． """
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

""" Revise で includet されているファイルのリストを取得する """
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