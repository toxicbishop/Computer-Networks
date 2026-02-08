# Create a new Simulator object
set ns [new Simulator]

# Open a NAM trace file in write mode
# This file (lab1.nam) will contain the animation information for the network
set nf [open lab1.nam w]
$ns namtrace-all $nf

# Open a Trace file in write mode
# This file (lab1.tr) will contain detailed simulation data (packet drops, easy to parse)
set tf [open lab1.tr w]
$ns trace-all $tf

# Define a 'finish' procedure to run at the end of simulation
proc finish { } {
    global ns nf tf
    $ns flush-trace;       # Flush all trace buffers to file
    close $nf;             # Close the NAM file
    close $tf;             # Close the Trace file
    exec nam lab1.nam &;   # Execute NAM to visualize the simulation
    exit 0;                # Exit the application
}

# Create three network nodes
set n0 [$ns node]; # Source node
set n1 [$ns node]; # Intermediate router
set n2 [$ns node]; # Destination node

# Create duplex (two-way) links between the nodes
# Syntax: duplex-link <node1> <node2> <bandwidth> <delay> <algorithm>
# Link between n0 and n1: 200Mbps bandwidth, 10ms delay, DropTail queue
$ns duplex-link $n0 $n1 200Mb 10ms DropTail

# Link between n1 and n2: 1Mbps bandwidth, 1000ms (1s) delay, DropTail queue
$ns duplex-link $n1 $n2 1Mb 1000ms DropTail

# Set the queue size limit between n0 and n1 to 10 packets
$ns queue-limit $n0 $n1 10

# --- Transport Layer ---
# Create a UDP agent (User Datagram Protocol - unreliable, connectionless)
set udp0 [new Agent/UDP]
# Attach the UDP agent to node n0 (the source)
$ns attach-agent $n0 $udp0

# --- Application Layer ---
# Create a CBR (Constant Bit Rate) traffic generator
set cbr0 [new Application/Traffic/CBR]
$cbr0 set packetSize_ 500;  # Set packet size to 500 bytes
$cbr0 set interval_ 0.005;  # Set time interval between packets to 0.005 seconds
$cbr0 attach-agent $udp0;   # Attach the CBR application to the UDP agent

# --- Destination ---
# Create a Null agent to act as a traffic sink (it just accepts and discards packets)
set null0 [new Agent/Null]
# Attach the Null agent to node n2 (the destination)
$ns attach-agent $n2 $null0

# Connect the source (UDP) to the destination (Null)
$ns connect $udp0 $null0

# --- Simulation Events ---
# Start the CBR traffic generation at 0.1 seconds
$ns at 0.1 "$cbr0 start"

# Call the 'finish' procedure at 1.0 seconds to end the simulation
$ns at 1.0 "finish"

# Start the simulation
$ns run