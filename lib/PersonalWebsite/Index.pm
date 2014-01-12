package PersonalWebsite::Index;
use Mojo::Base 'Mojolicious::Controller';
use Tools::Functions qw(mddir2yaml fh4yaml fh4md);
use Data::Dumper;
use Cwd;

my $DIRPATH_KEY = 'dir-path';
my $DIR_KEY = 'dir';
my $FILENAME_KEY = 'file-name';

my $markdown_dir = $ENV{POSTS_DIR};

# Takes in a hash and returns an index based on the yaml key provided.
sub index_by_yaml {
    my $yaml_ar = shift;
    my $index_key = shift;

    my %index = ();    
    foreach(@$yaml_ar) {
        my %hr = %$_;
        
        #print "+++++++++++++++++++++++++++++++++++++++++++++++++++\n";
        #print Dumper \%hr;
        #print Dumper ref $hr{$index_key};
        
        if( ref($hr{$index_key}) eq 'ARRAY' ) {
            foreach(@{$hr{$index_key}}) {
                if(defined($index{$_})) {
                    push @{$index{$_}}, \%hr;
                } else {
                    $index{$_} = [\%hr];
                }
            }
        } elsif (ref($hr{$index_key}) eq '') {
            my $key = $hr{$index_key};
            $key = (!defined($key)) ? "No ".ucfirst($index_key) : $key;
            #print Dumper $key;
            if(defined($index{$key})) {
                push @{$index{$key}}, \%hr;
            } else {
                $index{$key} = [\%hr];
            }
        } else {
            print "Not a SCALAR nor ARRAY\n";
            print Dumper $hr{$index_key};
            print "ref: ". ref $hr{$index_key} ."\n";
        }
    }

    return \%index;
}

# takes in a list of markdown documents and indexes them in alphabeticle order based on the
# specified tag.
sub index_by_alpha {
    my $yaml_ar = shift;
    my $index_key = shift;

    my %index = ();
    map {$index{$_} = []} ("A"..."Z");
    foreach(@$yaml_ar) {
        my %hr = %$_;
        my $key = $hr{$index_key};
        my $fchar = uc substr($key, 0, 1);
        if($index{$fchar}) {
            push @{$index{$fchar}}, \%hr;
        } else {
            $index{$key} = [\%hr];
        }
    }

    return \%index;
}

# Selects indexing function.
sub index_by {
    my $yaml_ar = shift;
    my $index_key = shift;
    
    if($index_key eq 'alpha') {
        return index_by_alpha($yaml_ar, 'title'); # default to alphabetical by title. 
    } else {
        return index_by_yaml($yaml_ar, $index_key);
    }
}

# Group by document tags
sub build_index { 
    my $self = shift;

    # get the param 'by' so that we know what to index by.
    my $index_by = (defined($self->param('by'))) ? $self->param('by') : 'tags' ;
    my $index_dir = (defined($self->param('dir'))) ? $self->param('dir') : '';

    #print "INDEX DIR: $markdown_dir/$index_dir\n";
    #print "INDEX BY: $index_by\n";
    #print "URL:".$self->req->url. "\n";

    # Extract yaml, index files, and build a url list.
    my $yaml = mddir2yaml("$markdown_dir/$index_dir");
    my $indexed = index_by($yaml, $index_by); 

    #print Dumper $yaml;
     
    $self->render(
        indexed => $indexed,
        website_title => "Clinton McKay's Website",
        dir => $index_dir
    );
}

1;
