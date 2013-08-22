package utils;

# Merge $base and $rel to return absolute path
# $base must be an absolute path
sub file {
  my($base,$rel) = @_;
  my(@comps) = split(/\//,$base);
  my(@relcomps) = split(/\//,$rel);
  my($relcompi);
  while($relcomp = shift(@relcomps)) {
     if ($relcomp =~ /\.\./) {
       pop(@comps);
     } else {
       push(@comps,$relcomp);
     } 
  }
  my($i,$path);
  for($i=1;$i<@comps;$i++) {
     $path .= "/";
     $path .= $comps[$i];
  }
  return $path;
}
# return 1 if build successful or else return 0
sub checkBuildSuccess {
  my($file) = @_;
  die $! unless open(FILE,$file);
  my($line);
  my($ret) = 0;
  while($line = <FILE>) {
    if ($line =~ /BUILD SUCCESSFUL/) {
      $ret = 1;
      break;
    }
  }
  close(FILE);
  return $ret;
}
# dump a datafile to STDOUT
sub dumpFile {
   my($file) = @_;
   my($line,$b);
   open (FILE,$file);
   while($line = <FILE>) {
     $line =~ s/</\&lt;/g;
     $line =~ s/>/\&gt;/g;
     $b .= $line;
   }
   close(FILE);
   return $b;
}

sub getRelVersion {
  my($file) = @_;
  my ($properties) = loadProperties($file);
  my($relversion) = $$properties{'version'};
  return $relversion if ($relversion ne "");
  my($w,$x,$y,$z) = ($$properties{'major_number'},
                     $$properties{'minor_number'},
                     $$properties{'maintenance_number'},
                     $$properties{'build_number'});

  if ($w ne "" && $x ne "" && $y ne "" && $z ne "") {
    return "$w.$x.$y.$z";
  }
  $relversion =  $$properties{"release_version"};
  return $relversion if ($relversion ne "");
  $relversion =  $$properties{"package.version"};
  return $relversion if ($relversion ne "");
}

sub loadProperties {
  my($file) = @_;
  die "Can not open file $file" unless open(FILE,$file);
  my($line,%properties);
  while($line = <FILE>) {
    chomp($line);
    $line =~ s/#.*$//;
    next if ($line =~ /^\s*$/);
    if ($line =~ /^\s*([^=\s]+)\s*=\s*(.*)$/) {
       $properties{$1} = $2;
    } elsif ($line =~ /^\s*([^:\s]+)\s*:\s*(.*)$/) {
       $properties{$1} = $2;
    }
  }
  close(FILE);
  return \%properties;
}

1;
