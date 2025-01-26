module TCPcommunication
    export start_server,tcp_server 
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
    """
    Structure to store the server object
    fields:
                connection - tcp connection settings
                server - TCPserver object
                clients_streams - clients io Streams

    """
    Base.@kwdef mutable struct tcp_server
        connection::tcp_connection
        server::Sockets.TCPServer
        task::Task=Task([]) # @async task created right after port connection
        shut_down_server::Bool =false# flag to shut down the server
        clients_list::Dict{Int,TCPSocket}=Dict{Int,TCPSocket}()
        room_lock=ReentrantLock()
    end
    function tcp_server(connection::tcp_connection)
        @info "Server started listening" connection.port.ip connection.port.port
        serv = tcp_server(connection=connection,
                            server=listen(connection.port.ip,connection.port.port)
        )
        serv.task=errormonitor(@async accept_client_loop(serv))
        return serv
    end
    function accept_client_loop(serv::tcp_server)
        # new client connection
        while !serv.shut_down_server
            client = accept(serv.server)# accept function waits for  connection of  client
            peername = Sockets.getpeername(client) # returns clients ip and port address
            client_ip_address = peername[1]
            client_port_number = Int(peername[2])
            @info "Socket accepted" client_ip_address client_port_number
            #lock(serv.room_lock) do
            serv.clients_list[client_port_number]=client
            errormonitor(@async client_message_handler(serv,client))
        end
        close(serv.server)
    end
    function start_server(;port::Int,
        ip::String="localhost",
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
    function client_message_handler(serv::tcp_server,socket)
        # function to handle client message
        # tcp_server - object
        # socket - client connection 
        while isopen(socket)
            line = readline(socket ,keep=true)
            try_write(socket ,"server_writes"*line)
        end
        @info "Client closed" Sockets.getpeername(socket)
    end
    function try_write(socket, message)
        try
            println(socket, message)
        catch error
            @error error
            close(socket)
        end
    
        return nothing
    end
end
using .TCPcommunication

s = start_server(port=2020)
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

 ⬚(a::Int...) = begin
    sum(length(string(i)) - 2*count("0",string(i)) for i in a) 
 end