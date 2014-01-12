package PersonalWebsite::Markdown;
use Mojo::Base 'Mojolicious::Controller';
use Tools::Functions qw(fh4yaml fh4md);
#use Text::Markdown;
use Text::MultiMarkdown;
use Data::Dumper;
use Cwd qw(abs_path getcwd);

my $markdown_dir = $ENV{POSTS_DIR}; # "markdown/";

sub parse {
    my $self = shift;
    my $url = $self->req->url; 

    my $md_path = "$markdown_dir$url";
    my $md_parser = Text::MultiMarkdown->new;
    
    $self->app->log->debug("File: ". $md_path);
    $self->app->log->debug("ABS CWD: ". abs_path($md_path));
    $self->app->log->debug("CWD: ". getcwd);
    $self->app->log->debug("APP HOME: ". $self->app->home);
    
    if(-e $md_path) {
        open my $MD, "<$md_path"  or print "Unable to open $md_path for markdown.\n $!\n";
        my $markdown = fh4md $MD;
        close $MD;

        open my $YAML, "<$md_path" or print "Unable to open $md_path for YAML.\n $!\n";
        my $yaml = fh4yaml $YAML;
        close $YAML;

        $self->render(
            md_title => $yaml->{'title'},
            parsed_markdown => $md_parser->markdown($markdown)
        );
    } else {
        $self->render_not_found;
    }
     
}

1;

