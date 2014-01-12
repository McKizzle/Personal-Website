package PersonalWebsite;
use Mojo::Base 'Mojolicious';
use Data::Dumper;
use Mojo::Home;
use Cwd;

# This method will run once at server start
sub startup {
    my $self = shift;

    # Change the directory to the home directory. 
    # Allows the proper functioning of all of the
    # other modules that read files. 
    my $home = Mojo::Home->new;
    $home->detect;
    $self->log->info("MOJO_HOME: ". $home);
    $self->log->debug("LIB_DIR: ". $home->lib_dir); 

    # Router
    my $r = $self->routes;

    # Routes to index.
    $r->get('/')->to('index#build_index');
    $r->get('/index')->to('index#build_index');

    # The `to` method can also take in a hash as in Mojo::Lite
    #$r->get('/golden.css')->to({
    #  template => '/golden', format => 'css' 
    #});

    # Handle all markdown requests
    $r->get('/*.md')->to('markdown#parse');
    
    # Handle all texttile requests
    #$r->get('/*.texttile')->to('markdown#parse');
}

1;
