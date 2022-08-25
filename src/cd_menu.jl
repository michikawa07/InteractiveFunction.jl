using REPL.TerminalMenus

export cd_menu, CD

function cd_menu(;karg=false)
	header = "\n== choice changing directory =="
	footer =   "==============================="
	try
		list = filter( isdir, readdir() )
		pushfirst!(list, "..")
		menu =  RadioMenu(list.*"/")
		size = menu.pagesize+menu.pageoffset

		printfooter(footer, 2+min(length(list), size))
		choice = request(header, menu)
		
		choice == -1 && throw( relpath( pwd(), homedir()) )
		cd( list[choice] )

		clean( 1+min(length(list), size) )
		
		cd_menu()
	catch e 
		println("\n - $e\n")
	end
end

CD(;karg...) = cd_menu(karg...)