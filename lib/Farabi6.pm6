use v6;
use HTTP::Easy::PSGI;

class Farabi6;

method find-mime-type(Str $filename) {
	my $mime-type;
	if ($filename ~~ /\.html$/) {
			$mime-type = 'text/html';
		} elsif ($filename ~~ /\.css$/) {
			$mime-type = 'text/css';
		} elsif ($filename ~~ /\.js$/) {
			$mime-type = 'text/javascript';
		} elsif ($filename ~~ /\.png$/) {
			$mime-type = 'image/png';		
		} else {
			$mime-type = 'text/plain';
			warn "Cannot handle $filename";
		}
	$mime-type;

}

method run($port) {
	my $http = HTTP::Easy::PSGI.new(:port($port));
	my $app = sub (%env)
	{
		my Str $filename;
   		my Str $uri = %env<REQUEST_URI>;
		if ($uri eq '/') {
			$filename = 'index.html';
		} else {
			$filename = $uri.substr(1);
		}
		$filename = "lib/Farabi6/files/$filename";

		
		my Str $mime-type = self.find-mime-type($filename);
	
		my Int $status;
		my @contents;
		if ($filename.IO ~~ :e) {
			if (my $fh = open $filename, :bin ) {
				$status = 200;
				@contents = $fh.slurp;
				$fh.close;
			}
		} 

		if (!@contents) {
			$status = 404;
			$mime-type = 'text/plain';
			@contents = "Not found $uri";	
		}
		return [ 
			$status, 
			[ 'Content-Type' => $mime-type ], 
			[ @contents ] 
		];
	}
 	$http.handle($app);

}
