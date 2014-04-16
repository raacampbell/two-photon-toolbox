        
#!/usr/bin/perl

my $this_file_name=$ARGV[0];

print "Opening " . $this_file_name . "\n";

open(FILE,$this_file_name) or die "$! error opening file.";



my $temp_file='TEMPORARY' ;
open(TEMP,">",$temp_file) ;


#print $this_file;
foreach my $line (<FILE>) {

  $line =~ s/(.*src=\")(\/.*\/)(.*\" .*)/\1\3/;
  print TEMP $line or die "can't write to $temp_file: $!" ;
}





close FILE or die "$! error closing $this_file.";
close TEMP or die "$! error closing $temp_file.";

#swap original file for temporary file
rename($temp_file,$this_file_name)
