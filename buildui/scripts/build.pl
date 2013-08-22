#!/usr/bin/perl
use builddata;
use p4;
use utils;
use Fcntl ':flock';
use Cwd qw(chdir);
use File::Path;
use File::Copy;
use File::Basename;
use Storable;
use MIME::Lite::TT;
use IO::CaptureOutput qw(capture);
use LWP::Simple;
use XML::DOM;

%main = (
'request'       => "request.build",
'locked'        => 0,
'status'        => "Another build in process, please try again later",
'contentRoot'   => "",
'widget'        =>0, # is it a widget build
'devbuild'      =>1  # is it a dev build
);

$compdata;       # component builddata from builddata::component


sub usage {
    my($error) = @_;
    print STDERR "Error: Illegal arguments to Perl script\n";
    print STDERR "Error: $error\n";
    print STDERR "Usage: build.pl build -component component -depotPath path [-version version] [-base base [-tickets ticket[,ticket]*]]\n";
    print STDERR "\tCreates a new build based on the arguments provided\n";
    print STDERR "\tcomponent: component to be built\n";
    print STDERR "\tversion: string of the format w.x.y.z\n";
    print STDERR "\tpath: perforce path in format //depot/...";
    print STDERR "\tbase: base label to be used, optional\n";
    print STDERR "\tticket: additional checkin tickets to be added to the baseline\n";
    print STDERR "   build.pl remove -component component -version version -depotPath path\n";
    print STDERR "\tRemoves the build from staging dir\n";
    print STDERR "   build.pl release -component component -version version -depotPath path\n";
    print STDERR "\tMoves the build from staging dir to release dir\n";
    print STDERR "   build.pl clean\n";
    print STDERR "\t clean any build artifacts from prior build\n";
    print STDERR "\t all the source code is also removed\n";
    print STDERR "   build.pl displaylog\n";
    print STDERR "\t dumps the build log file from immediately prior build request\n";
    exit(-1);
}

# find previous release version
sub findPrevRelease {
  my($versionfile) = utils::file($main{'depotPath'},$$compdata{'versionFile'});
  $versionfile = p4::getPath($versionfile);
  my($preVersion) = utils::getRelVersion($versionfile);
  die "Can not find prior release version from $versionfile" unless ($preVersion ne "");
  $main{'prevVersion'} = $preVersion;
}

sub results {
  my($key,$buf);
  $buf = "<results>\n";
  my($s) = $main{"status"};
  if ($s =~ /success/) {
    $buf .= "<success>success</success>\n";
  } else {
    $buf .= "<error>$s</error>\n";
  }
  foreach $key (keys(%main)) {
     $buf = $buf . "<$key>$main{$key}</$key>\n" if (($key ne "status") && ($key ne "notes") && ($key ne "p4changes"));
  }
  $buf .= "</results>\n";
  return $buf;
}

sub END {
   unlock();
   print STDOUT results();
   local ($/);
   if (defined $main{'debugfile'}) {
      open(my $fh, $main{'debugfile'});
      my $text = <$fh>;
      print STDERR "$text";
   }
}

sub lock {
    open SELF, "< $0" or die $!;
    flock SELF, LOCK_EX | LOCK_NB or die $!;
    $main{'locked'} = 1;
    $main{'status'} = "";
}

sub unlock {
    if ($main{'locked'} == 1) {
      close(SELF);
      $main{'locked'} = 0;
    }
}

sub isClean {
   my($file) = utils::file($main{'contentRoot'}, $main{'request'});
   if (open(FILE,$file)) {  # if prior request file missing then we are clean
     my($oldmain) = Storable::fd_retrieve(\*FILE); # read the old file & compare objects
     close(FILE);
     return 0 if (
       $$oldmain{'component'} ne $main{'component'} ||
       $$oldmain{'depotPath'} ne $main{'depotPath'} ||
       $$oldmain{'widget'}    ne $main{'widget'}    ||
       $$oldmain{'devbuild'}  ne $main{'devbuild'}  ||
       $$oldmain{'base'}      ne $main{'base'}      ||
       $$oldmain{'tickets'}   ne $main{'tickets'});
     return 0 if ($$oldmain{'version'}   ne $main{'version'} &&
                $main{'devbuild'} == 0);
   }
   open(FILE,">$file");
   Storable::nstore_fd(\%main,\*FILE);
   close(FILE);
   return 1;
}

sub antbuild {
  my($depotPath,$component) = @_;

  my($buildDir) = utils::file($depotPath,$$compdata{'buildDir'}); # repo path
  my($buildPath) = p4::getPath($buildDir); # file path
  my($dir) = Cwd::cwd();
  system("echo $buildPath"); 
  chdir("$buildPath/.."); 
  `cp build/default.buildconf.properties ./buildconf.properties`;
  if ($main{'widget'} == 0) {
    if (! -e "buildconf.properties") { # build config already available.
        system("ant -f build/build.xml configure > $builddata::buildlog 2>&1 ");
        #die "Could not run build config" if (utils::checkBuildSuccess($builddata::buildlog) == 0);
    }
  }
  # system("ant -f build/build.xml clean > $builddata::buildlog 2>&1 ");
  if ($$compdata{'componentType'} eq 'application') { # it is an application build
    system("echo building..."); 
    system("ant -f build/build.xml clean package-$component > $builddata::buildlog 2>&1 ");
    system("echo completed building..."); 
  }
  else { # it is a library build 
    system("ant -f build/build.xml clean build-lib-$component > $builddata::buildlog 2>&1 ");
    print STDERR "PWD is ".`pwd`;
    `cp -f ./tas/int/lib/$component/*  ~/TumriLibs`;
  }
  die "Could not complete build" if (utils::checkBuildSuccess($builddata::buildlog) == 0);
  chdir($dir);
}

sub labelBuild {
  my($depotPath,$version) = @_;
  if ($main{'devbuild'} == 0) {
     my($label) = $main{'component'}."_".$version;
     my($dirs) = $$compdata{'dirs'};
     p4::labelBuild($depotPath, $dirs, $label);
     ## get the changes to write to release notes file later
     $main{'p4changes'} = p4::getChangesByLabel($label);
  }
}

sub checkout {
  my($depotPath,$component,$base,$tickets,$version) = @_;

  #die "You must clean prior build before doing a new build" unless isClean();

  my($label);
  $label = $main{'component'}."_".$base if (defined $base);
  p4::sync($main{'contentRoot'},$depotPath,$label,$tickets);
  p4::sync($main{'contentRoot'},utils::file($depotPath,$$compdata{'buildDir'}));
  p4::sync($main{'contentRoot'},utils::file($depotPath,$$compdata{'installDir'})) if (defined $$compdata{'installDir'});
  p4::sync($main{'contentRoot'},utils::file($depotPath,$$compdata{'buildToolsDir'})) if (defined $$compdata{'buildToolsDir'});
  p4::sync($main{'contentRoot'},utils::file($depotPath,$$compdata{'extDir'})) if (defined $$compdata{'extDir'});
  my($dirs) = $$compdata{'dirs'};
  my($dir);
  foreach $dir (@$dirs) {
    p4::sync($main{'contentRoot'},utils::file($depotPath,$dir),$label,$tickets);
  }
  findPrevRelease();
  p4::updateVersionFile($version,$depotPath, $$compdata{'versionFile'},$component) if ($main{'devbuild'} == 0 && $main{'prevVersion'} ne $version);
}

sub copyFiles {
  my($depotPath,$component,$version) = @_;

  ## to select staging dir:
  ## default is $$compdata{'stagingDir'};
  ## is overridden by $$compdata{'stagingDir'.$main{'branchname'}};

  my($stagingDir) =  ($main{'devbuild'} == 1 ? $$compdata{'devbuildDir'} : $$compdata{'stagingDir'});

  if (defined $main{'branchname'}) {
      if (defined $$compdata{'stagingDir'.'.'.$main{'branchname'}}){
          $stagingDir = $$compdata{'stagingDir'.'.'.$main{'branchname'}};
      }
  }

  $stagingDir =~ s/component/$component/;
  $stagingDir =~ s/version/$version/;
  $main{'stagingUrl'} = utils::file($builddata::releaseUrl, $stagingDir);
  $stagingDir = utils::file($builddata::releaseDir, $stagingDir);
  $main{'stagingDir'} = $stagingDir;
  my($buildDir) = utils::file($depotPath,$$compdata{'buildDir'});
  my($buildPath) = p4::getPath($buildDir);
  my($srcFiles);
  my($target);
  if ($main{'widget'} == 1) {
    # $srcFiles = "$buildPath/../dist/packages/zipfiles/$component/$component*.tgz";
      $srcFiles = "$buildPath/../dist/packages/zipfiles/$component/*";
    $target = "";
  } else {
    $srcFiles = "$buildPath/../package/$component.tar.gz";
    if ($main{'devbuild'} == 1) {
        $target = "";
    }
    else {
        $target = "$component-$version.tar.gz";
    }
  }
  eval { mkpath($stagingDir); };
  if ($@) {
	die "Cannot create directory $stagingDir";
  }
  my $srcDir = dirname($srcFiles);
  opendir(DIR, $srcDir);
  my @files = grep { /.*\.tgz/ || /.*\.tar\.gz/ || /.*\.zip/} readdir(DIR);
  closedir(DIR);
  for my $i (@files) {
	copy("$srcDir/$i", "$stagingDir/$target") or die "Copy $i to $stagingDir/$target failed: $!";
  	print STDERR "cp $i $stagingDir/$target\n";
  }

  if (defined ($main{'p4changes'})) { # if this is a labelled build
     if ($main{'widget'} == 0) { # this is not a widget build
        my($file) = utils::file($stagingDir, "../RN_".$component."_".$version.".txt");
        open(FILE, ">$file");
        print FILE $main{'p4changes'};
        close FILE;
     }
     delete $main{'p4changes'};
  }
}

sub parseArgs {
   my($i);
   if (@ARGV == 0 || @ARGV % 2 == 0) {
     usage();
   }
   $main{'command'} = $ARGV[0];
   for($i=1;$i<@ARGV;$i+=2) {
     my($arg) = $ARGV[$i];
     $arg =~ s/^\-//;
     $main{$arg} = $ARGV[$i+1];
   }
   initFromXML($main{'id'}) if (defined $main{'id'});
}

sub updateBuildMap {
    my($node, $cdata) = @_;
    if ($node->getNodeType() == ELEMENT_NODE) {
        foreach my $child ($node->getChildNodes()) {
            if ($child->getNodeType() == TEXT_NODE) {
                my $txt = $child->getData();
                $txt =~ s/[\n ]*//g;
                $$cdata{$node->getTagName()} = $child->getData() if $txt ne "";
                my $attrs = $node->getAttributes();
                if (defined $attrs) {
                    foreach my $val ($attrs->getValues()) {
                        $$cdata{$node->getTagName().".".$val->getName()} = $val->getValue();
                    }
                }
            }
            else { 
                updateBuildMap($child, $cdata);
            }
        }
    } 
}

sub initFromXML {
   my($id) = @_;
   my($configxml) = get("http://localhost:12080/buildui/build/getxml/$id");

   ((defined $configxml) && ($configxml ne '')) || die "Could not retrieve XML document from server";

   my $parser = new XML::DOM::Parser;
   my $doc = $parser->parse($configxml) || die "Failed to parse XML document from server";

   my $root = $doc->getDocumentElement();

   (($root->getTagName() eq "BuildComponent") && ($root->getAttribute("id") == $id)) || 
   die "Wrong XML document received from server";

   my %cdata = ();

   foreach my $child ($root->getChildNodes()) {
     if ($child->getNodeName() eq 'BuildData') {
        updateBuildMap($child, \%main);
     }
     elsif ($child->getNodeName() eq 'ConfigData') {
        updateBuildMap($child, \%cdata);
     }
   }

   $main{'component'} = $main{'componentname'} if (defined $main{'componentname'});

   if (defined $main{'depotPath'}) {
     if ($main{'depotPath'} =~ /Widgets/) {
       $main{'widget'} = 1;
       $builddata::components{'widget'} = \%cdata;
       $compdata = $builddata::components{'widget'};
     } else {
       $main{'widget'} = 0;
       $builddata::components{$main{'component'}} = \%cdata;
       $compdata = $builddata::components{$main{'component'}};
     }
   }
   if (!defined $$compdata{'componentType'}) {
       $$compdata{'componentType'} = 'application';
   }
   $$compdata{'componentType'} =~ tr/A-Z/a-z/ ;

   if ($main{'command'} eq "build" || $main{'command'} eq "remove" ) {
     usage("no component found") if (!defined $main{'component'});
     usage("no depotPath provided") if (!defined $main{'depotPath'});
     die "No component definition found in builddata file\n" if (!defined $compdata);
     if (!defined $main{'version'} || $main{'version'} =~ /^v/) {
       my($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(time);
       $main{'version'} = sprintf "v%4d%02d%02d%02d%02d%02d", $year+1900,$mon+1,$mday,$hour,$min,$sec;
       $main{'devbuild'} = 1;
     } else {
       $main{'devbuild'} = 0;
     }
     if (defined $main{'tickets'}) {
       my(@tickets) = split(/,/,$main{'tickets'});
       $main{'tickets'} = \@tickets;
     }
   }

   if (defined $$compdata{'dirs'}) {
      my(@projectdirs) = split(/,/,$$compdata{'dirs'});
      $$compdata{'dirs'} = \@projectdirs;
   }

   if (defined $$compdata{'mailto'}) {
      my(@maillist) = split(/,/,$$compdata{'mailto'});
      $$compdata{'mailto'} = \@maillist;
   }

   die("can not release a non release build") if ($main{'command'} eq "release" && !($main{'version'} =~ /^[\d\.]+$/));
   return 1;
}

sub remove {
  my($component,$version) = ($main{'component'},$main{'version'});
  my($stagingDir) =  ($main{'devbuild'} == 1 ? $$compdata{'devbuildDir'} : $$compdata{'stagingDir'});
  if (defined $main{'branchname'}) {
      if (defined $$compdata{'stagingDir'.'.'.$main{'branchname'}}){
          $stagingDir = $$compdata{'stagingDir'.'.'.$main{'branchname'}};
      }
  }
  $stagingDir = utils::file($builddata::releaseDir, $stagingDir);
  $stagingDir =~ s/component/$component/;
  $stagingDir =~ s/version/$version/;


  if (!-d $stagingDir) {
    $main{'status'} = "Could not find the staging build";
  } else {
    if ($main{'widget'} == 1) {
      print STDERR "rm -f $stagingDir/$component-$version.tgz\n";
      system("rm -f $stagingDir/$component-$version.tgz");
    } else {
      print STDERR "rm -rf $stagingDir/*\n";
      #system("rm -rf $stagingDir/*");
    }
    $main{'status'} = "success";
  }
}

sub releaseLibrary {
  my($component,$version) = @_;
  $version =~ s/v//;
  $homeDir = $ENV{"HOME"};
  my $file = $homeDir.'/TumriLibs/'.$component.'*'.$version.'*';
  my $srcFile = $file;
  $file = $srcFile;
  my($directory,$fileExt) = $file =~ m/(.*\.)(.*)$/;  # split to get the file extension
  $fileExt = 'tar.gz' if($fileExt eq 'gz');
  my $depotlibPath = $main{'depotPath'};
  my($depotDir, $file) = $depotlibPath =~ m/(.*\/)(.*)$/;  # split of the depot dir location as eg: str = //depot/Tumri/tas/utils ==> str1 =  //depot/Tumri/tas/ and str2 = utils
  my$libDepot = $depotDir.'int/lib';  # always int is expected to be under tas
  
  my $libFile = p4::getPath($libDepot).'/'.$component;
  my $checkInFile = p4::getPath($libDepot).'/'.$component.'/'.$component.'*'.$version.'*';
  
  `cp -f $srcFile $libFile`;
    
  if (-e $libFile) {
  	p4::checkInNewFile($checkInFile);
  }
    else {
      die "Cannot find library file: $libFile";
    }
    sendLibReleaseMail($libDepot.'/'.$component.'/'.$component.'_'.$version.'.'.$fileExt);
}

sub release {
  my($component,$version) = ($main{'component'},$main{'version'});
  if ($$compdata{'componentType'} eq 'library') {
      releaseLibrary($component, $version);
      $main{'status'} = "success";
      return;
  }

  my($stagingDir) = $$compdata{'stagingDir'};
  if (defined $main{'branchname'}) {
      if (defined $$compdata{'stagingDir'.'.'.$main{'branchname'}}){
          $stagingDir = $$compdata{'stagingDir'.'.'.$main{'branchname'}};
      }
  }
  $stagingDir = utils::file("$builddata::releaseDir" , $stagingDir);
  $stagingDir =~ s/component/$component/;
  $stagingDir =~ s/version/$version/;

  my($releaseDir) = $$compdata{'releaseDir'};
  if (defined $main{'branchname'}) {
      if (defined $$compdata{'releaseDir'.'.'.$main{'branchname'}}){
          $releaseDir = $$compdata{'releaseDir'.'.'.$main{'branchname'}};
      }
  }
  $releaseDir =~ s/component/$component/;
  $releaseDir =~ s/version/$version/;
  $main{'releaseUrl'} = utils::file("$builddata::releaseUrl" , $releaseDir);
  $releaseDir = utils::file("$builddata::releaseDir" , $releaseDir);
  $main{'releaseDir'} = $releaseDir;

  if (!-d $stagingDir) {
    $main{'status'} = "Could not find the staging build to be released";
  } else {
    mkpath($releaseDir);
    if ($main{'widget'} == 1) {
      if (-f "$stagingDir/$component-$version.tgz") {
        print STDERR "cp -R $stagingDir/$component-$version* $releaseDir\n";
        # system("cp $stagingDir/$component-$version.tgz $releaseDir");
        system("cp -R $stagingDir/$component-$version* $releaseDir");
        $main{'status'} = "success";
      } else {
        $main{'status'} = "Could not find the build package tobe released";
      }
    } else {
      print STDERR "cp -R $stagingDir/* $releaseDir\n";
      system("cp -R $stagingDir/* $releaseDir");
      $main{'status'} = "success";
    }
  }
  if ($main{'status'} eq 'success') {
      die "User is not authenticated by email." unless (defined $main{'user'});
      sendmail($main{'user'});
  }
}

sub cleanWorkspace {
  my($depotPath) = @_;
  p4::revertOpenFiles();
  p4::removeWorkspace($main{'contentRoot'}, $depotPath);
  my($success, $diskpath);
  $diskpath = "";
  $success = eval { $diskpath = p4::getPath($depotPath) } ;
  if ( $success  && ( $diskpath ne "" ) ) {
    `rm -rf $diskpath/*`;
  }
  my($dirs) = $$compdata{'dirs'};
  my($dir);
  foreach $dir (@$dirs) {
    my $tmpPath = utils::file($depotPath, $dir);
    p4::removeWorkspace($main{'contentRoot'}, $tmpPath);
    $diskpath = "";
    $success = eval { $diskpath = p4::getPath($tmpPath) } ;
    if ( $success  && ( $diskpath ne "" ) ) {
        `rm -rf $diskpath/*`;
    }
  }
}

sub clean {
   p4::revertOpenFiles();
   p4::removeWorkspace($main{'contentRoot'});
   `rm -rf $main{'contentRoot'}/*`;
   $main{'log'} = "rm -rf $main{'contentRoot'}/*";
   $main{'status'} = "success";
}

sub displaylog {
   $main{'log'} = utils::dumpFile($builddata::buildlog);
   $main{'status'} = "success";
}

sub sendLibReleaseMail {
   my ($location) = @_;
   my %params;
   $params{'componentname'} = $main{'component'};
   $params{'version'}       = $main{'version'};
   $params{'location'}      = $location;
   $params{'notes'}         = $main{'notes'};
   my %options;
   $options{'INCLUDE_PATH'} = $builddata::templateDir;
   my ($to);
   foreach $name (@builddata::lib_release_mailing_list) {
          $to = $to.$name."\@collective.com,";
   }
   if (defined $$compdata{'mailto'}) {
      my $names = $$compdata{'mailto'};
      foreach $name (@$names) {
         $to = $to.$name.",";
      }
   };
   $to =~ s/,$//; # remove trailing comma.
   my $msg = MIME::Lite::TT->new(
                'From'        => $main{'user'},
                'To'          => $to, 
                'Subject'     => "Release of new library version for $main{'component'}",
                'Template'    => "librelease_email.txt.tt",
                'TmplOptions' => \%options,
                'TmplParams'  => \%params);
   $msg->send;
}

sub sendmail {
   my ($user) = @_;
   if (! defined $user) {
      $user = "ajayv\@collective.com";
   }
   my %params;
   $params{'componentname'} = $main{'component'};
   $params{'version'}       = $main{'version'};
   $params{'stagingurl'}    = $main{'stagingUrl'}; 
   $params{'stagingdir'}    = $main{'stagingDir'}; 
   $params{'releasedir'}    = $main{'releaseDir'}; 
   $params{'releaseurl'}    = $main{'releaseUrl'}; 
   $params{'label'}         = $main{'devbuild'} == '1'? "Not Labelled" : $main{'component'}."_".$main{'version'};
   $params{'notes'}         = $main{'notes'};

   if ($main{'widget'} == 0) {
      eval {
        my @libfiles = getLibVersions();
        for (my $i=0; $i < scalar(@libfiles); $i++) { 
            my $j = $i + 1;
            $params{"library"."$j"}     = $libfiles[$i]; 
        }
      };
      if ($@) {
         print STDERR "Could not generate library versions for this build/release action.\n";
         $params{"library"."1"}     = "Could not determine library versions."; 
      }
   }

   my %options;
   $options{'INCLUDE_PATH'} = $builddata::templateDir;
   my ($subject);
   my ($name);
   my ($to);
   my ($maillist);
   my ($mailtemplate);
   if ($main{'command'} eq 'build') {
	if($params{'label'} eq 'Not Labelled') {
        $subject = "Official Dev build of $main{'component'} $main{'version'} is available for internal testing";
        $maillist = \@builddata::dev_qa_mailing_list;
        $mailtemplate = 'devbuild_qa_email.txt.tt';
        }
        else {
        $subject = "Official RC build of $main{'component'} $main{'version'} is available for QA testing";
        $maillist = \@builddata::qa_mailing_list;
        $mailtemplate = 'qa_email.txt.tt';
        }
   }
   else {
        $subject = "Official package of $main{'component'} $main{'version'} is available for production release";
        $maillist = $main{'widget'} == 1 ? \@builddata::business_mailing_list : \@builddata::release_mailing_list;
        $mailtemplate = $main{'widget'} == 1 ? 'biz_email.txt.tt' : 'release_email.txt.tt';
   } 
       
   foreach $name (@$maillist) {
          $to = $to.$name."\@collective.com,";
   }
   if (defined $$compdata{'mailto'}) {
      my $names = $$compdata{'mailto'};
      foreach $name (@$names) {
         $to = $to.$name.",";
      }
   };

   # add the user who requested the command to the mailing list
   # if he is not already on the list.
   if (!($to =~ /$user/)) {
      $to = $to.$user;
   }

   $to =~ s/,$//; # remove trailing comma.
   my $msg = MIME::Lite::TT->new(
                'From'        => $user,
                'To'          => $to, 
                'Subject'     => $subject,
                'Template'    => $mailtemplate,
                'TmplOptions' => \%options,
                'TmplParams'  => \%params);

   if (defined $main{'attach'}) {
        my($filename,$filetype) = split(/,/, $main{'attach'});
        my $filename = "/opt/Tumri/buildui/data/attachments/".$filename;
        if (-e $filename) {
            $msg->attach(Type => $filetype,
                         Path => $filename,
                         Filename => basename($filename),
                         Disposition => 'attachment'); 
        }
   }
   $msg->send('smtp','smtp.dc1.tumri.net');

}

sub debugonly {
     my $buf;
     print STDERR  "-------Writing contents of main---------\n";
     foreach my $key (keys(%main)) {
        $buf = $buf . "<$key>$main{$key}</$key>\n" if ($key ne "status");
     }
     print STDERR "$buf\n";
     print STDERR "--------Writing contents of \$\$compdata------------\n"; 
     $buf = "";
     foreach my $key (keys(%$compdata)) {
        $buf = $buf . "<$key>$$compdata{$key}</$key>\n" if ($key ne "status");
     }
     print STDERR "$buf\n";
}

sub build {
     my($depotPath,$component,$base,$tickets,$version) = ($main{'depotPath'},$main{'component'},$main{'base'},$main{'tickets'},$main{'version'});
     cleanWorkspace($depotPath);
     checkout($depotPath,$component,$base,$tickets,$version);

     antbuild($depotPath,$component);
     labelBuild($depotPath,$version);
     copyFiles($depotPath,$component,$version) if ($$compdata{'componentType'} eq 'application');
     $main{'status'} = "success";
     sendmail($main{'user'}) if ($$compdata{'componentType'} eq 'application');
}


sub main {
   p4::setup();
   $main{'contentRoot'} = p4::getRoot();
   parseArgs();
   if ($main{'command'} eq "clean") {
       clean(); 
   } elsif ($main{'command'} eq "displaylog") {
       displaylog();
   } elsif ($main{'command'} eq "release") {
       release();
   } elsif ($main{'command'} eq "remove") {
       remove();
   } elsif ($main{'command'} eq "build") {
       build();
   } else {
       usage("command not found");
   }
}

sub getLibVersions {
    my $path = p4::getPath($main{'depotPath'});
    $path = $path.'/build/build.properties';
    local ($/);
    open(my $fh, $path) || die "Cannot open $path";
    my $contents = <$fh> ;
    close($fh);
    @libfiles = $contents =~ m/[^\.]*?\.lib\.file=(.*)/g;
    return @libfiles;
}

# The following routine determines the debug file to use to write
# captured stdout and stderr. The filename consists of the value
# contained in the variable $DEBUGFILE with a number suffix. 
# The number cycles from 0 through 9 with the oldest file overwritten
# first.

sub setupdebug {
   my($DEBUGFILE) = '/tmp/buildui.debug.';
   my(@files) = `ls -t $DEBUGFILE* 2>&1`;
   my($id) = 0;
   if (!($files[0] =~ /No such file/)) {
       $_ = $files[0];
       s/$DEBUGFILE//g;
       $id = ($_ >= 9 ? 0 : $_+1);
   }
   $main{'debugfile'} = $DEBUGFILE.$id;
}

lock();
setupdebug();

if (defined $main{'debugfile'}) {
    capture \&main, undef, undef, $main{'debugfile'}, $main{'debugfile'};
}
else {
    main();
}

