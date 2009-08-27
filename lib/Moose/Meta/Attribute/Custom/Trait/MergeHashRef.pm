package Moose::Meta::Attribute::Custom::Trait::MergeHashRef; 
use Moose::Role;
use MooseX::Traits::Attribute::MergeHashRef;

has '+clearer' => (default => sub { 'clear_' . $_[0]->name } );

sub accessor_metaclass { 'MooseX::Traits::Attribute::MergeHashRef' }


after 'install_accessors' => sub { 
    my $attr  = shift;
    my $class = $attr->associated_class;
    my $method = sub { $_[0]->${\('clear_'.$attr->name)}; shift->${\($attr->name)}(@_); };
    $class->add_method( 'set_' . $attr->name, $method );
};

1;