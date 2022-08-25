function clean(H)
	buf = IOBuffer()
	for i in 1:H+1
			print(buf, "\x1b[2K") # clear line
			print(buf, "\x1b[999D\x1b[$(1)A") # rollback
	end
	print(buf |> take! |> String)
end
