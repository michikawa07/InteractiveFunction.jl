module InteractiveFunction

	include("includet_menu.jl")
	include("cd_menu.jl")

	#=
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
	=#	
end
