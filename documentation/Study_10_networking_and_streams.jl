# Networking and Streams

#=
    * Basic Stream I/O
    * Text I/O 
    * IO Output contextual  Properties
    * Working with files
    * A simple TCP example
    * Resolving IP Addresses
    * Asynchronous I/O 
    * Multicast 
=#

#-------------* Basic Stream I/O-------------------
write(stdout,"Hello world")
# returns  number of bytes
write(stdout,"H")

read(stdin, Char)

x = Vector{UInt8}(undef,5)
read!(stdin,x) # reads to the array (the type of data is specified)
x = Vector{Any}(undef,5)
# this gives error
# because IO stream does not support reading to this type
# of data

read!(stdin,x) 

x = read(stdin,4)

#-----------------------* Text I/O-------------- 
readline(stdin) # read the whole line
println(stdout,"sdsd")
while !eof(stdin) # eof 
    x= read(stdin,Char)
    println("Found: $x")
end
# i dont understand the behaviour of REPL and how to send the eof from the REPL

#----------* IO Output contextual Properties------
# there is an object IOContext wrapper for the IO object
# with additional key-value arguments
io = IOBuffer()

function f1(io::IO)
    if get(io,:short,false)
        print(io,"short")
    else
        print(io,"long")
    end
end
f1(stdout)
# returns "short"
f1(IOContext(stdout,:short=>true))

#--------------*Working with files*---------------
write("hello.txt","Hello,world") # returns number of bytes written
out = read("hello.txt")
[Char(o) for o in out]
String(out)

#--------------*Advanced: streaming files*-------------
f_stream = open("hello.txt")
readlines(f_stream)
close(f_stream)
open("hello.txt","w") do io
    for i in 1:10
        write(io,"$i")
    end
end
# redirect stdout
out_file = open("output.txt","w")
using Pkg
redirect_stdout(out_file) do
    Pkg.status() # prints packages status to file
end
close(out_file)
#----------------*A simple TCP example*---------------
using Sockets

errormonitor(@async begin
    server=listen(2000)
    while true
        sock=accept(server)
        println("Hello world\n")
    end
end) # creates server 
connect(2000) 
#connecting to the server

# creating echo server:
t1 = errormonitor(@async begin
    server=listen(2001) # next port 
    stop_server = false
    while !stop_server
        sock=accept(server)
        @async while isopen(sock)&& !stop_server
            line = readline(sock,keep=true)
            write(sock,line)
            if contains(line,"stop_server")
                error("stop server")
            end
        end
    end
end) # creates server
# id dont understand how to kill server....
client_side = connect(2001)
t2 = errormonitor(
    @async while isopen(client_side)
        write(stdout,readline(client_side,keep=true))
    end
)
println(client_side,"ss2s")
println(client_side,"stop_server")
