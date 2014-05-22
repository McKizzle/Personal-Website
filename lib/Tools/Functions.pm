package Tools::Functions;
use strict;
use warnings;
use YAML;
use Cwd;

use Exporter qw(import);
our @EXPORT_OK = qw(mddir2yaml fh4yaml fh4md);

my $DIRPATH_KEY = 'dir-path';
my $DIR_KEY = 'dir';
my $FILENAME_KEY = 'file-name';

sub mddir2yaml;
sub fh4yaml;
sub fh4md;

# Takes in a markdown directory and converts it into 
# an array of hashes that stores all of the yaml data associated with each 
# file and adds additional informaiton such as the dir and the file name
#
#   @PARAM pass in the root directory of the markdown files. 
#
#   @RETURN an array of hashes that stores document information 
#       and yaml information
sub mddir2yaml {
    my $dir = shift;
    my $root_dir = shift; 

    $dir = "$dir/";
    $root_dir = "$root_dir/";
    
    # Remove the extra '/' characters.  
    $dir =~ tr/\/+/\//s;
    $root_dir =~ tr/\/+/\//s;

    # if a markdown file is located then only use the path RELATIVE to the 
    # 'posts' directory (or whatever directory is being used)
    my $dir_to_use = $dir;
    $dir_to_use =~ s/$root_dir//;

    my %tags = ();

    #print "mddir2yaml directory: " . $dir . "\n";
    #print "mddir2yaml root directory: " . $root_dir . "\n";
    #print "mddir2yaml cwd: " . getcwd() . "\n";
     
    # First get a listing all all the folders in markdown folder.
    opendir(my $opendir, $dir); 

    my @documents = ();
    while(my $file = readdir($opendir)) {
        #print "mddir2yaml File: $file\n";
        if(-f "$dir$file" && ($file =~ /[.]md$/)) {
            # print "mddir2yaml found a markdown file\n";
            # If a file then read the yaml at the beginning of the document.
            open my $fh, "<$dir$file", or print "Failed to open the document\n $!";
            my $meta = fh4yaml $fh;
            close $fh;
 
            # Store relavent information in the hash so that other modules can reopen the file.
            $meta->{$DIRPATH_KEY} = $dir;
            $meta->{$DIR_KEY} = $dir_to_use;
            $meta->{$FILENAME_KEY} = $file;

            push @documents, $meta;
        } elsif(-d "$dir$file" &&
           ($file !~ /^[.]{1,2}$/) #Ignore special directories
        ) {
            # If a folder is found then recurse.
            # print "mddir2yaml found folder,... Recurse\n";
            my $dir_documents = mddir2yaml "$dir$file/", "$root_dir";
            push @documents, @$dir_documents;
        } else {
            # print "mddir2yaml $dir$file is a special file\n";
        }
    }
    return \@documents; # Return the parsed yaml data. 
}

# Takes in a markdown file filehandler and extracts the yaml data from the head. 
sub fh4yaml {
    my $fh = shift;

    my $yaml_data = "";
    my $isYaml = 0;
    while(my $line = <$fh>) {
        if($line =~ /``/ && !$isYaml) {
            $isYaml = 1;
        } elsif( $line =~ /``/ && $isYaml) {
            last;
        } else {
            $yaml_data .= $line;
        }
    } 
    $yaml_data = Load($yaml_data);

    return $yaml_data;
}

# Take a file and extract the markdown from the body.
sub fh4md {
    my $fh = shift;
    
    my $md_data = "";
    my $isYaml = 0;
    my $isMd = 0;
    while(my $line = <$fh>) {
        if($line =~ /``/ && !$isYaml && !$isMd) {
            $isYaml = 1;
        } elsif($line =~ /``/ && $isYaml && !$isMd) {
            $isYaml = 0;
            $isMd = 1;
        } elsif($isMd) {
            $md_data .= $line;
        }
    }

    return $md_data;
}

1;

