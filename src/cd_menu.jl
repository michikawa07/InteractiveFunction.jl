using REPL.TerminalMenus

export cd_menu, CD

function clean(H)
	buf = IOBuffer()
	for _ in 1:H+1
		 print(buf, "\x1b[2K") # clear line
		 print(buf, "\x1b[999D\x1b[$(1)A") # rollback
	end
	print(buf |> take! |> String)
end

function cd_menu(;karg=false)
	header = "\n== choice changing directory =="
	footer =   "==============================="
	try
		list = filter( isdir, readdir() )
		pushfirst!(list, "..")
		menu =  RadioMenu(list.*"/")
		size = menu.pagesize+menu.pageoffset

		H = 3+min(length(list), size)
		buf = IOBuffer()
		print(buf, "\n"^(H))
		print(buf, footer)
		print(buf, "\x1b[999D\x1b[$(H-1)A") # rollback
		print(buf |> take! |> String)
		
		@info " ~\\$(relpath( pwd(), homedir())) \x1b[999D\x1b[$(1)A"
		
		choice = request(header, menu)
		choice == -1 && return print("\n")

		cd( list[choice] )

		clean( H-1 )
		cd_menu()
	catch e 
		e == InterruptException() && return print("\n")
		e
	end
end

CD(;karg...) = cd_menu(karg...)