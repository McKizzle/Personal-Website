package PersonalWebsite::Example;
use Mojo::Base 'Mojolicious::Controller';

# This action will render a template
sub welcome {
  my $self = shift;

  # Render template "example/welcome.html.ep" with message
  $self->render(msg => 'Welcome to the Mojolicious real-time web framework!');
}

sub goodbye {
    my $self = shift;

    # Render template "example/goodby.html.ep" with message
    $self->render(msg => 'Thanks for visiting the Mojolicious real-time web framework!');
}

1;


