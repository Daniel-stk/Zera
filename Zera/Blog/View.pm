package Zera::Blog::View;

use JSON;
use Zera::Conf;
use base 'Zera::Base::View';

# Module Functions
sub display_home {
    my $self = shift;

    $self->set_title($conf->{App}->{Name});

    # Entries
    my $entries = $self->selectall_arrayref(
        "SELECT entry_id, url, title, description, display_options, DATE(e.date) AS date " .
        "FROM entries e WHERE module='Blog' AND active=1 ORDER BY e.date DESC",{Slice=>{}});
    foreach my $entry (@$entries){
        $entry->{display_options} = decode_json($entry->{display_options});
    }

    my $vars = {
        entries => $entries,
    };

    return $self->render_template($vars);
}

sub display_item {
    my $self = shift;

    # Entry
    my $entry = $self->selectrow_hashref(
        "SELECT entry_id, url, title, description, keywords, display_options, DATE(e.date) AS date, content " .
        "FROM entries e WHERE url=? AND module='Blog' AND active=1 ORDER BY e.date DESC",{Slice=>{}}, $self->param('SubView'));
    $entry->{display_options} = decode_json($entry->{display_options});

    $self->set_title($entry->{title});
    $self->set_keywords($entry->{keywords});
    $self->set_description($entry->{description});
    $self->set_page_attr('type','article');
    $self->set_page_attr('url','http://'.$conf->{App}->{URL} . '/' . $self->param('SubView'));
    if($entry->{display_options}->{image}){
        $self->set_page_attr('image','http://'.$conf->{App}->{URL} . $entry->{display_options}->{image});
    }

    my $vars = {
        entry => $entry,
    };

    return $self->render_template($vars);
}

1;
