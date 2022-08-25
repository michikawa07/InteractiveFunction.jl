using REPL.TerminalMenus

export cd_menu, CD

function cd_menu(;karg=false)
	header = "\n== choice changing directory =="
	footer =   "==============================="

	try
		list = filter( isdir, readdir() )
		pushfirst!(list, "..")
		menu =  RadioMenu(list.*"/")
		printfooter(footer, 2+min(length(list), menu.pagesize+menu.pageoffset))
		choice = request(header, menu)
		#=if=# choice == -1 && throw(pwd())
		cd( list[choice])
		clean( 1+min(length(list), menu.pagesize+menu.pageoffset) )
		cd_menu()
	catch e ;println("\n - $e\n")
	end
end

CD(;karg...) = cd_menu(karg...)