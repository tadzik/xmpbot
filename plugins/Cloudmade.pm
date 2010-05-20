package Cloudmade;
use Geo::Cloudmade;
use utf8;

sub init {
	return ['map', 'komenda do wyszukiwania trasy oraz miejsc','Ta komenda korzysta z wyznaczania tras przez http://www.cloudmade.com na podstawie map http://www.openstreetmap.org. \nPrzykładowe zapytania:\n map ROUTE:Rynek,Wrocław&Damrota,Wrocław   -wyznacz trasę z Rynku na ulicę Damrota\n map POI:restaurant:Rynek,Warszawa    -znajdź najbliższe restauracje od Rynek,Wrocław'];
}

sub msg_cb {
	my ($self, $msg) = @_;
	my ($parametr,$values) = split(/:/, $msg,2);	
	#Api key
	my $geo = Geo::Cloudmade->new('6b3cde25e6c24f72af16946717c9c6bb');


	#TODO: Maybe can get more POIs? And option FORCE_FIND select first from @arr
	if($parametr eq 'POI'){
		my ($type,$where) = split(/:/, $values,2);	
		my @arr = $geo->find($where, {results=>5, skip=>0});
			print $geo->error(), "\n" unless @arr;
		#IF more then 1
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
		print "Cloudmade.pm: Znaleziono POI -",scalar(@POIs), "\n";
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
		print "Cloudmade.pm: Wyznaczam trase\n";
		my $route = $geo->get_route([$arr[0]->centroid->lat, $arr[0]->centroid->long], [$arr2[0]->centroid->lat, $arr2[0]->centroid->long],	{ type=>'car', method=>'shortest' } );
		#if(not defined $route){
		#	return "Przepraszam, nie mogę wyznaczyć trasy";
		#}
		my $ret="Dystans: ".$route->total_distance."\n";
		$ret.="Start: ".$route->start."\n";
		$ret.="End: ".$route->end."\n";
		$ret.="\nTrasa:\n";
		#TODO: REGEXP
		$ret.=join (',', @$_). "\n" foreach (@{$route->segments});

		return $ret;	
	}
}

1;


  

