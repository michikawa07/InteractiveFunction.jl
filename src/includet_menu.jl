using Revise
using REPL.TerminalMenus
using	Base.Threads
using InteractiveUtils
using ProgressMeter
using Suppressor

import Revise

export includet_menu, @includet

""" dir 以下のファイルをすべて参照し， dirとの相対Pathを返す． """
function readdirs(dir=pwd(); join=false, sort=true, by=_->true)
	file_contents = String[] #todo 再帰の深さかlistの長さで切らないとまずいかも．
	for (root, dirs, filenames) in walkdir(dir, topdown=true)
		startswith(relpath(root, dir), ".") && continue
		filter!( by, filenames )
		isempty( filenames ) && continue
		paths_full = joinpath.( root, filenames )
		paths_rel  = relpath.( paths_full , dir )
		push!(file_contents, paths_rel...)
	end
	sort && sort!( file_contents )
	file_contents
end

""" dir 以下のファイルをすべて参照し， dirとの相対Pathを返す． """
function readfiles(pdir=pwd(), max=4; join=false, sort=true, by=isfile, _depth=1)
	paths = readdir(pdir; join=true)
	file_contents = filter!(by, filter(isfile, paths))
	_depth < max && for dir in filter(isdir, paths)
		dirname = relpath(dir, pdir)
		startswith(dirname, ".") && continue
		jifiles = readfiles(dir, max; join, sort, by, _depth=_depth+1)
		push!(file_contents, jifiles...)
	end
	sort && sort!( file_contents )
	relpath.(file_contents)
end

""" Revise で includet されているファイルのリストを取得する """
function getrevisedfiles(dir=pwd(); by=_->true)
	file_revised = String[]
	for (root,files) in Revise.watched_files
		filenames = keys(files.trackedfiles)
		paths_full = joinpath.(root, filenames )
		paths_rel = relpath.(paths_full , dir )
		filter!(by, paths_rel)
		push!(file_revised, paths_rel...)
	end
	file_revised
end

"""
Current directory 以下にある `.jl` ファイルを `MultiSelectMenu` で列挙する．\n
選択された `.jl` ファイルを `Revise.includemt` でincludeする．
"""
function includet_menu(;dir=pwd(), dep=4, 
	show_verbose=true, 
	show_result=show_verbose, 
	show_error=false, 
	show_varinfo=false
	)
	header = "\n==== choice files to revise ===="
	footer =   "================================"

	isdir(dir) || return @warn "`$dir` directory cannot be found"

	try	
		list = readfiles(dir, dep; by=endswith(".jl"))
		isempty(list) && return @warn "Cannot find `.jl` files (search depth is $dep)"
		
		list_selected = getrevisedfiles(;by=l->!occursin("..",l))
		selected = [i for (i,l) in enumerate(list) if l ∈ list_selected]

		menu = MultiSelectMenu( list; selected )
		size = menu.pagesize + menu.pageoffset

		H = 3+min(length(list), size)
		buf = IOBuffer()
		print(buf, "\n"^(H) * footer)		 # footer
		print(buf, "\x1b[999D\x1b[$(H)A") # rollback
		print(buf |> take! |> String)		 # 表示

		choice = request(header, menu) |> collect
		setdiff!( sort!(choice), selected )
		print("\n\n")
		length(choice)==0 && return
		length(choice)==1 && begin 
			show_error = true
			show_result = false	
		end

		for file in list[choice]
			file ∈ list_selected && continue
			prog = ProgressUnknown(0.01, "includet( $file )"; spinner=true, color=:blue)
			show_error || begin task = @async @suppress (sleep(0.1); includet( joinpath(dir, file) )) end
			show_error && begin task = @async           (sleep(0.1); includet( joinpath(dir, file) )) end
			while !istaskdone(task)
				show_verbose && ProgressMeter.next!(prog)
				sleep(0.1)
			end
			if file ∈ getrevisedfiles() #includetが成功したかを判定
				ProgressMeter.finish!(prog)
			else
				show_result || continue
				println()
				@error "`includet( \"$(file)\" )` failed" _file=nothing
			end
		end
	
	catch e 
		e isa InterruptException && return println("\n\n - cancel")
		#= other =# throw(e)
	finally
		show_varinfo && println("\n=== Variables and Functions ===\n$(varinfo())")
	end

	nothing
end

Revise.includet(;karg...) = includet_menu(;karg...)
macro includet()
	:($includet_menu( ))
end