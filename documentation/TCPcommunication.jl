module TCPcommunication
    using Sockets
    ForN   = Union{Function,Nothing}
    Base.@kwdef mutable struct tcp_port
        # basic port object connects ip address and port in one structure
        ip::IPAddr=getaddrinfo("localhost", IPv4)
        port::Int=-1
    end
    # external constructor for the port 
    tcp_port(;port::Int=-1,ip::AbstractString="localhost") = tcp_port(getaddrinfo(ip, IPv4),port) 

    # Thing common for both server and client
    Base.@kwdef mutable struct tcp_connection
        port::tcp_port # port properties
        on_connection::ForN # on connection callback 
        commands::Dict{AbstractString,Function} # this dictionary stores special keywords to manipulate the server
        on_reading::ForN # every reading callback
    end

    mutable struct tcp_server
        connection::tcp_connection
        server::Sockets.TCPServer
        stream::IO # stream object is created on calling listen
        task::Task # @async task created right after port connection
        tcp_server(connection::tcp_connection)=begin 
            server = listen(connection.port.ip,connection.port.port)
            
            new_tcp_server = new(connection,server,stdout,Task([]))
            new_tcp_server.task = errormonitor(@async begin
                new_tcp_server.stream = accept(server)
                sleep(1E-10)
                new_tcp_server.task = @async while isopen(new_tcp_server.stream )
                    line = readline(new_tcp_server.stream ,keep=true)
                    write(new_tcp_server.stream ,"server_writes"*line)
                end
            end)
            return new_tcp_server
        end
    end
    function start_server(;
        ip::String="localhost",
        port::Int, 
        on_connection::ForN=nothing,
        on_reading::ForN=nothing,
        commands::Dict{AbstractString,Function}=Dict{AbstractString,Function}())
        port_obj = tcp_port(port=port,ip = ip)
        port_con=tcp_connection(port=port_obj,
                    on_connection=on_connection,
                    on_reading=on_reading,
                    commands=commands)    
        return tcp_server(port_con)
    end
#=    SERVER FROM THE EXAMPLE:
        t1 = errormonitor(@async begin
        server=listen(2001) # next port 
        stop_server = false
        while !stop_server
            sock=accept(server)
            @async while isopen(sock)&& !stop_server
                line = readline(sock,keep=true)
                write(sock,"server_writes"*line)
                if contains(line,"stop_server")
                    error("stop server")
                end
            end
        end
    end) 
    # CLIENT FROM THE EXAMPLE
        client_side = connect(2001)
        t2 = errormonitor(
            @async while isopen(client_side)
                write(stdout,readline(client_side,keep=true))
            end
        )   
    =#
end

mutable struct A
    a::Float64
end
using BenchmarkTools
a = [A(a) for a in zeros(10)]
@benchmark for i in 1:10
    @async begin
        a[i].a=a[i].a+ i
    end
end
a
@benchmark for i in 1:10
    begin
        a[i].a=a[i].a+ i
    end
end
@benchmark Threads.@spawn for i in 1:10
    begin
        a[i].a=a[i].a+ i
    end
end