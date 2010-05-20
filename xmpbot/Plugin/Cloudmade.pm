package xmpbot::Plugin::Cloudmade;
use Geo::Cloudmade;
use utf8;

sub init {
	return ['map', '',
		''];
}

sub msg_cb {
	my ($self, $msg) = @_;
	my ($parametr,$values) = split(/:/, $msg,2);	
	#TODO: CHANGE API KEY
	my $geo = Geo::Cloudmade->new('BC9A493B41014CAABB98F0471D759707');


	#TODO: Maybe can get more POIs? And option FORCE_FIND select first from @arr
	if($parametr eq 'POI'){
		my ($type,$where) = split(/:/, $values,2);	
		my @arr = $geo->find($where, {results=>5, skip=>0});
			print $geo->error(), "\n" unless @arr;
		#IF more then 1
		print scalar (@arr), "\n";
		if(scalar (@arr)>1){
			my $ret="Położenie jest niejednoznaczne\n";
			foreach (@arr) {
				$ret=$ret.$_->name.":".$_->centroid->lat."/".$_->centroid->long."\n"
			}
			return $ret;
		}else{if(scalar (@arr)==0){
			return "Nie znalazłem takiego adresu";
		}}
		my $ret="Położenie:".$arr[0]->centroid->lat." ".$arr[0]->centroid->long."\n"."Szukane:".$type."\n";
		my @POIs = $geo->find_closest($type, [$arr[0]->centroid->lat, $arr[0]->centroid->long]);
		print "Znaleziono POI:",scalar(@POIs), "\n";
		if (scalar(@POIs)!=0) {
			foreach (@POIs) {
				$ret=$ret.join (' ', $_->properties('name','addr:housenumber', 'addr:street', 'addr:postcode', 'addr:city')).":".$_->centroid->lat."/".$_->centroid->long."\n";
			}
			return $ret;
		} else { 
			$ret.="\nNie znaleziono";
			return $ret;
		}	
	}
	if($parametr eq 'ROUTE'){
		my ($from,$to,$by) = split(/&/, $values,3);	
		my @arr = $geo->find($from, {results=>5, skip=>0});
			print $geo->error(), "\n" unless @arr;
		#IF more then 1
		if(scalar (@arr)>1){
			my $ret="Położenie 'Z' jest niejednoznaczne\n";
			foreach (@arr) {
				$ret=$ret.$_->name.":".$_->centroid->lat."/".$_->centroid->long."\n"
			}
			return $ret;
		}else{if(scalar (@arr)==0){
			return "Nie znalazłem takiego adresu";
		}}


		my @arr2 = $geo->find($to, {results=>5, skip=>0});
			print $geo->error(), "\n" unless @arr;
		#IF more then 1
		if(scalar (@arr2)>1){
			my $ret="Położenie 'DO' jest niejednoznaczne\n";
			foreach (@arr2) {
				$ret=$ret.$_->name.":".$_->centroid->lat."/".$_->centroid->long."\n"
			}
			return $ret;
		}else{if(scalar (@arr2)==0){
			return "Nie znalazłem takiego adresu";
		}}
		#TODO: TYPE
		#if (defined $by){print "Zdefiniowany ".$by."\n";}
		#else{
		#	$by='car';}
		my $route = $geo->get_route([$arr[0]->centroid->lat, $arr[0]->centroid->long], [$arr2[0]->centroid->lat, $arr2[0]->centroid->long], 															{ type=>'foot', method=>'shortest' } );

		my $ret="Dystans: ".$route->total_distance."\n";
		$ret.="Start: ".$route->start."\n";
		$ret.="End: ".$route->end."\n";
		$ret.="Route segments:\n";
		$ret.=join (',', @$_). "\n" foreach (@{$route->segments});

		return $ret;	
	}
}

1;


  

