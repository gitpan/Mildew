package VAST::statementlist;
BEGIN {
  $VAST::statementlist::VERSION = '0.04';
}
use utf8;
use strict;
use warnings;
use Mildew::AST::Helpers;

sub emit_m0ld {
    my $m = shift;
    if (@{$m->{statement}}) {
        [map {$_->emit_m0ld} move_CONTROL($m->{statement})]
    } else {
        [lookup("False")]
    }
}

1;
