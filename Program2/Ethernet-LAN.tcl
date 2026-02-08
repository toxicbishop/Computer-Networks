# Create a new Simulator object
set ns [new Simulator]

# Open a Trace file in write mode
set tf [open lab3.tr w]
$ns trace-all $tf

# Open a NAM trace file in write mode
set nf [open lab3.nam w]
$ns namtrace-all $nf

# Create nodes
set n0 [$ns node]
$n0 color "magenta"
$n0 label "src1"

set n1 [$ns node]

set n2 [$ns node]
$n2 color "magenta"
$n2 label "src2"

set n3 [$ns node]
$n3 color "blue"
$n3 label "dest2"

set n4 [$ns node]

set n5 [$ns node]
$n5 color "blue"
$n5 label "dest1"

# Create the LAN (Local Area Network)
# Syntax: $ns make-lan <nodelist> <bw> <delay> <LL> <ifq> <mac> <channel> <phy>
# Fixed: "Queue/ DropTail" -> "Queue/DropTail" (removed space)
$ns make-lan "$n0 $n1 $n2 $n3 $n4" 100Mb 100ms LL Queue/DropTail Mac/802_3

# Create a link from the LAN gateway (n4) to the destination (n5)
$ns duplex-link $n4 $n5 1Mb 1ms DropTail

# --- TCP Connection 1 (n0 -> n5) ---
# Create TCP Agent and attach to n0
set tcp0 [new Agent/TCP]
$ns attach-agent $n0 $tcp0

# Create FTP Application and attach to TCP agent
set ftp0 [new Application/FTP]
$ftp0 attach-agent $tcp0
$ftp0 set packetSize_ 500
$ftp0 set interval_ 0.0001

# Create TCP Sink and attach to n5
set sink5 [new Agent/TCPSink]
$ns attach-agent $n5 $sink5

# Connect TCP agent to Sink
$ns connect $tcp0 $sink5

# --- TCP Connection 2 (n2 -> n3) ---
# Create TCP Agent and attach to n2
set tcp2 [new Agent/TCP]
$ns attach-agent $n2 $tcp2

# Create FTP Application and attach to TCP agent
set ftp2 [new Application/FTP]
$ftp2 attach-agent $tcp2
$ftp2 set packetSize_ 600
$ftp2 set interval_ 0.001

# Create TCP Sink and attach to n3
set sink3 [new Agent/TCPSink]
$ns attach-agent $n3 $sink3

# Connect TCP agent to Sink
$ns connect $tcp2 $sink3

# --- Congestion Window Tracing ---
# Open files to record congestion window data
set file1 [open file1.tr w]
$tcp0 attach $file1

set file2 [open file2.tr w]
$tcp2 attach $file2

# Enable tracing of the congestion window variable 'cwnd_'
# Fixed: Added semicolon before inline comment
$tcp0 trace cwnd_; # must put underscore ( _ ) after cwnd and no space between them
$tcp2 trace cwnd_

# Define 'finish' procedure
proc finish { } {
    global ns nf tf
    $ns flush-trace
    close $tf
    close $nf
    exec nam lab3.nam &
    exit 0
}

# --- Schedule Events ---
$ns at 0.1 "$ftp0 start"
$ns at 5 "$ftp0 stop"
$ns at 7 "$ftp0 start"
$ns at 0.2 "$ftp2 start"
$ns at 8 "$ftp2 stop"
$ns at 14 "$ftp0 stop"
$ns at 10 "$ftp2 start"
$ns at 15 "$ftp2 stop"
$ns at 16 "finish"

# Run the simulation
$ns run

# Removed: "AWK file:" text at end of file to prevent syntax errors