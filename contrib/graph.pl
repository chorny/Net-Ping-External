use Chart::Gnuplot;
use Net::Ping::External qw(ping);

die("Please pass in a host.\n") unless $ARGV[0];

$Net::Ping::External::DEBUG_OUTPUT = 1;

ping(host => $ARGV[0], count => $ARGV[1] // 20);

my $count = 0;
my @x = ();
my @y = ();

open(my $fh, "<", \$Net::Ping::External::LAST_OUTPUT) or die;
while (<$fh>) {
    if (/time=(\d+\.\d+)\s+ms/) {
        push(@y, $1);
        push(@x, $count);

        ++$count;
    }
}
close($fh);

die("No data found") unless 0 != scalar(@x);
 
# Create chart object and specify the properties of the chart
my $chart = Chart::Gnuplot->new(
    output => sprintf("./ping_%s_%s.png", $ARGV[0], time),
    title  => "Ping $ARGV[0]",
    xlabel => "Ping count",
    ylabel => "Timings"
);
 
# Create dataset object and specify the properties of the dataset
my $dataSet = Chart::Gnuplot::DataSet->new(
    xdata => \@x,
    ydata => \@y,
    title => "Ping line plot",
    style => "linespoints",
);
 
# Plot the data set on the chart
$chart->plot2d($dataSet);
