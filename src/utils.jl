function printfooter(footer, H)
	buf = IOBuffer()
	print(buf, "\n"^H)
	println(buf, footer)
	print(buf, "\x1b[999D\x1b[$(H+1)A") # rollback
	print(buf |> take! |> String)
end

function clean(H)
	buf = IOBuffer()
	for _ in 1:H+1
		 print(buf, "\x1b[2K") # clear line
		 print(buf, "\x1b[999D\x1b[$(1)A") # rollback
	end
	print(buf |> take! |> String)
end
