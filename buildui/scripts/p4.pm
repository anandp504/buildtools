package p4;
use Cwd qw(chdir);
use utils;

sub setup {
    $ENV{"P4HOST"}="build01.dev.tumri.net";
    $ENV{"P4CLIENT"}="ondemand-build";
    $ENV{'P4USER'}="build";
    $ENV{'P4PORT'}="perforce.corp.tumri.net:1666";
    #$ENV{'P4CONFIG'}=".p4config" unless (defined $ENV{'P4CONFIG'} && $ENV{"P4CONFIG"} ne "");
    die "Can not find p4 command utility" if (`which p4` =~ /^no/);
}

# Updates the version file given by name $relPath in base $depotPath
sub updateVersionFile {
  my($version,$depotPath, $relPath,$component) = @_;
  my($workspacePath) = getPath($depotPath);
  my($dir) = Cwd::cwd();
  chdir($workspacePath);

  my($result) = `p4 edit $relPath`;
  die $result unless ($result =~ /opened for edit[\s]*$/);

  editVersionFile($relPath,$version,$component);
  buildChangeList($relPath,$version);
  

  my($result) = `p4 submit -i < /tmp/changelist`;
  die $result unless (($result =~ /submitted/) || ($result =~ /created/));
  
  chdir($dir);
}

# labels a given depot path recursively with given label
sub labelBuild {
  my($depotPath, $dirs, $label) = @_;
  my($workspacePath) = getPath("//depot/Tumri");
  $workspacePath = utils::file($workspacePath,"..") . "/...";
  makeP4Label($depotPath, $dirs, $label) || die "Failed to create p4 label: $label";
  my($result) = `p4 labelsync -l $label $workspacePath`;
  print STDERR "$result\n";
  lockP4Label($label) || print STDERR "Warning: Could not lock label: $label\n";
  die $result unless ($result =~ /added[\s]*$/);
}


sub sync {
  my($root,$depotPath,$base,$tickets) = @_;
  my($dir) = Cwd::cwd();
  chdir($root);
  if (defined $base) {
    my($result) = `p4 sync $depotPath/...\@$base`;
    die $result if ($result =~ /invalid/i);
    my($ticket);
    foreach $ticket (@$tickets) {
      my($result) = `p4 sync $depotPath/...\@$ticket,\@$ticket`;
      print STDERR $result if ($result =~ /invalid/i);
    }
  } else {
    my($result) = `p4 sync $depotPath/...#head`;
  }
  chdir($dir);
}

#remove all files that were checkedout
sub removeWorkspace {
  my($root,$depotPath) = @_;
  my($dir) = Cwd::cwd();
  chdir("$root/depot");
  my ($result);
  if ( ! defined $depotPath ) {
    $result = `p4 sync ./...#0`;
  }
  else {
    $result = `p4 sync $depotPath/...#0`;
  }
  chdir($dir);
}

#revert all files opened by this client
sub revertOpenFiles {
  `p4 revert //depot/...`;
}

sub editVersionFile {
  my($relPath,$version,$component)  = @_;
  my($c) = $component . "_" . $version;
  my($major_number,$minor_number,$maintenance_number,$build_number) = split(/\./,$version);
  die $! unless open (FILE,$relPath);
  die $! unless open (FILEOUT,">$relPath.new");
  my($line);
  while($line = <FILE>) {
    chomp();
    $line =~ s/^[\s]*major_number=\d*[\s]*$/major_number=$major_number\n/;
    $line =~ s/^[\s]*minor_number=\d*[\s]*$/minor_number=$minor_number\n/;
    $line =~ s/^[\s]*maintenance_number=\d*[\s]*$/maintenance_number=$maintenance_number\n/;
    $line =~ s/^[\s]*build_number=\d*[\s]*$/build_number=$build_number\n/;
    $line =~ s/^[\s]*code_label=.*[\s]*$/code_label=$c\n/;
    $line =~ s/^[\s]*version=.*[\s]*$/version=$version\n/;
    $line =~ s/^[\s]*package.version=.*[\s]*$/package.version=$version\n/; # pattern for widgets
    print FILEOUT "$line";
  }
  close (FILE);
  close (FILEOUT);
  rename("$relPath.new",$relPath);
}

sub buildChangeList {
    my($relPath,$version) = @_;
    my($depotPath) = getDepotPath($relPath);
    die $! unless open(TMP,">/tmp/changelist");
    print TMP "Change: new\n\n";
    print TMP "Description: Build checkin for version $version\n\n";
    print TMP "Files: $depotPath\n\n";
    close TMP;
}

sub getChangesByLabel {
    my($result);
    my($label) = @_;
    $result = `p4 changes -l //depot/Tumri/...\@$label`;
    return $result;
}

# Given a depot path, return file system path
sub getPath {
  my($depotPath) = @_;
  my($ret) = `p4 where $depotPath`;
  my($a,$b,$c) = split(/\s+/,$ret);
  return $c if ($a eq $depotPath);
  die "Can not resolve the depot path $depotPath";
}

# Given a relative depot path, get complete depot path
sub getDepotPath {
  my($relPath) = @_;
  my($ret) = `p4 where $relPath`;
  my($a,$b,$c) = split(/\s+/,$ret);
  return $a if ($a =~ /$relPath/);
  die "Can not resolve the depot path $relPath";
}

sub getRoot {
  my($dir) = Cwd::cwd();
  my($tumri) = getPath("//depot/Tumri");
  chdir(utils::file($tumri,"../.."));
  my($root) = Cwd::cwd();
  chdir($dir);
  return $root;
}

sub makeP4Label {
    my ($depotPath, $dirs, $label) = @_;
    ## first delete an existing label with that name.
    my $result = `p4 label -d $label`;
    open(TMP, '>/tmp/p4label') || die $!;
    print TMP "Label: $label\n\n";
    print TMP "View: \n";
    print TMP "\t $depotPath/...\n";
    foreach $dir (@$dirs) {
       my $path = utils::file($depotPath, $dir);
       print TMP "\t $path/...\n";
    }
    close(TMP);
    $result = `p4 label -i < '/tmp/p4label'`;
    return ( $result =~ /saved/ );
}

sub lockP4Label {
    my ($label) = @_;
    my $p4label = `p4 label -o $label`;
    $p4label =~ s/^Options:.*$/Options: locked\n/m;
    my $result = `echo "$p4label" | p4 label -i`;
    return ( $result =~ /saved/ );
}

sub checkInNewFile {
    my ($file) = @_;
    my $p4cmd = `p4 add -f $file `;
    if ($p4cmd =~ /opened for add/) {
        $p4cmd = `p4 changelist -o`;
        $p4cmd  =~ s/<enter description here>/New version of library file/g;
        my $result = `echo "$p4cmd" | p4 submit -i`;
        die $result unless (($result =~ /submitted/) || ($result =~ /created/));
    }
    else {
        die "Failed to add file: $p4cmd\n";
    }
}
1;
