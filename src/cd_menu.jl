using REPL.TerminalMenus

export cd_menu, @cd, CD

""" cd() の簡単なラッパー """
function cd_menu(show_files=true)
	repl_h, repl_w = displaysize(stdout)
	max_w = repl_w - 12
	H_dir, H_file = 3, 0
	current_path = "~\\$(relpath( pwd(), homedir()))\\"
	if length(current_path) > max_w
		current_path = "..." * current_path[end-max_w:end]
	end
	separater = " - - - - - - - - - - - - - - - "
	footer =    "==============================="
	try
		dirs  = [ ".."; filter( isdir, readdir() )]
		files = filter( isfile, readdir() )
		menu =  RadioMenu(dirs.*"/")
		size = menu.pagesize+menu.pageoffset

		H_dir  += min(length(dirs), size)
		H_file += show_files ? length(files) : 0
		buf = IOBuffer()
		print(buf, "\n"^(H_dir+H_file))
		print(buf, footer)
		show_files && begin
			foreach(files|>reverse) do f
				print(buf, "\x1b[999D\x1b[1A")
				print(buf, "   $f")
			end
			print(buf, "\x1b[999D\x1b[1A")
			print(buf, separater)
		end
		print(buf, "\x1b[999D\x1b[$(H_dir-2)A") # rollback
		print(buf |> take! |> String)

		@info "$current_path"
		choice = request(menu)
		choice == -1 && return throw(InterruptException())

		cd( dirs[choice] )

		buf = IOBuffer()
		print(buf, "\x1b[999D\x1b[$(H_file+1)B")
		for _ in 1:H_dir+H_file
			 print(buf, "\x1b[2K") # clear line
			 print(buf, "\x1b[999D\x1b[1A") # rollback
		end
		print(buf |> take! |> String)
		cd_menu(show_files)
	catch e 
		e == InterruptException() && return print("$("\n"^H_file)\n\n")
		#= other =# throw(e)
	end
end

const CD = cd_menu
macro cd(arg...)
	:(cd_menu($arg...))
end