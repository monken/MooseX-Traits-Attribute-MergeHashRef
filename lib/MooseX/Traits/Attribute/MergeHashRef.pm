package MooseX::Traits::Attribute::MergeHashRef;

use base 'Moose::Meta::Method::Accessor';

use warnings;
use strict;

use Hash::Merge qw(merge);

sub _inline_pre_body {
    my $self = shift;
    my $isa  = $self->associated_attribute->{isa};
    unless ($isa eq 'HashRef') {
        warn 'MergeHashRef work on HashRef attributes only';
        return '';
    }
    my $inv         = '$_[0]';

    my $attr = $self->associated_attribute;

    my $mi = $attr->associated_class->get_meta_instance;
    my $pred = $mi->inline_is_slot_initialized($inv, $attr->name);
    my $old = 'my ($old) = '
            . $pred . q{ ? }
            . $self->_inline_get($inv) . q{ : ()} . ";\n";
    return $old . q{
use Hash::Merge qw(merge);
$_[1] = merge ($_[1], $old) if(defined $old && defined $_[1]);

};
}

1;

__END__

=head1 NAME

MooseX::Traits::Attribute::MergeHashRef - Merging HashRef attribute

=head1 SYNOPSIS

    package MyClass;
    use Moose;
    has stash => ( is => 'rw', isa => 'HashRef', traits => [qw(MergeHashRef)] );

    my $class = MyClass->new;
    $class->stash({ animals => { dogs => 1 } });
    # $class->stash: { animals => { dogs => 1 } }
    $class->stash({ animals => { cats => 2 } });
    # $class->stash: { animals => { dogs => 1, cats => 2 } }
    $class->set_stash({ foo => bar });
    # $class->stash: { foo => bar });
    $class->clear_stash;
    # $class->stash: undef

=head1 DESCRIPTION

This trait will merge values added to a HashRef attribute. It uses L<Hash::Merge> to combine them.
The method  C<set_$attr> which resets the attribute with a given hashref is also created.
Call C<clear_$attr> to clear the attribute.
    
    