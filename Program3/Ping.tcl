#!/usr/bin/tclsh
# Program: Ping.tcl
# This script simulates a network with Ping agents using the NS2 Simulator.

# Create a new Simulator object
set ns [new Simulator]

# Open a NAM trace file
set nf [open lab2.nam w]
$ns namtrace-all $nf

# Open a Trace file
set tf [open lab2.tr w]
$ns trace-all $tf

# Create nodes
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]

# Create duplex links with specified bandwidth, delay, and queue type
$ns duplex-link $n0 $n4 1005Mb 1ms DropTail
$ns duplex-link $n1 $n4 50Mb 1ms DropTail
$ns duplex-link $n2 $n4 2000Mb 1ms DropTail
$ns duplex-link $n3 $n4 200Mb 1ms DropTail
$ns duplex-link $n4 $n5 1Mb 1ms DropTail

# --- Attach Ping Agents ---

# Create Ping Agent p1 and attach to n0
set p1 [new Agent/Ping]; # letters A and P should be capital
$ns attach-agent $n0 $p1
$p1 set packetSize_ 50000
$p1 set interval_ 0.0001

# Create Ping Agent p2 and attach to n1
set p2 [new Agent/Ping]; # letters A and P should be capital
$ns attach-agent $n1 $p2

# Create Ping Agent p3 and attach to n2
set p3 [new Agent/Ping]; # letters A and P should be capital
$ns attach-agent $n2 $p3
$p3 set packetSize_ 30000
$p3 set interval_ 0.00001

# Create Ping Agent p4 and attach to n3
set p4 [new Agent/Ping]; # letters A and P should be capital
$ns attach-agent $n3 $p4

# Create Ping Agent p5 and attach to n5
set p5 [new Agent/Ping]; # letters A and P should be capital
$ns attach-agent $n5 $p5

# Set Queue Limits
$ns queue-limit $n0 $n4 5
$ns queue-limit $n2 $n4 3
$ns queue-limit $n4 $n5 2

# Define the 'recv' instance procedure for Agent/Ping
# This method is called when a ping response is received
Agent/Ping instproc recv { from rtt } {
    $self instvar node_
    puts "node [$node_ id] received answer from $from with round trip time $rtt msec"
}

# Connect the agents
$ns connect $p1 $p5
$ns connect $p3 $p4

# Define finish procedure
proc finish { } {
    global ns nf tf
    $ns flush-trace
    close $nf
    close $tf
    exec nam lab2.nam &
    exit 0
}

# Schedule Ping events
$ns at 0.1 "$p1 send"
$ns at 0.2 "$p1 send"
$ns at 0.3 "$p1 send"
$ns at 0.4 "$p1 send"
$ns at 0.5 "$p1 send"
$ns at 0.6 "$p1 send"
$ns at 0.7 "$p1 send"
$ns at 0.8 "$p1 send"
$ns at 0.9 "$p1 send"
$ns at 1.0 "$p1 send"

$ns at 0.1 "$p3 send"
$ns at 0.2 "$p3 send"
$ns at 0.3 "$p3 send"
$ns at 0.4 "$p3 send"
$ns at 0.5 "$p3 send"
$ns at 0.6 "$p3 send"
$ns at 0.7 "$p3 send"
$ns at 0.8 "$p3 send"
$ns at 0.9 "$p3 send"
$ns at 1.0 "$p3 send"

# Schedule finish
$ns at 2.0 "finish"

# Run simulation
$ns run
