use v5.10;
use MooseX::Declare;
class Mildew::AST::IntegerConstant extends Mildew::AST::Base {
    has 'value' => (is=>'ro');
    has 'type_info' => (is=>'ro',lazy=>1,default=>sub {Mildew::TypeInfo::IntegerConstant->new()});
    method m0ld($ret) {
        "my $ret = ".$self->value.";\n";
    }
    method pretty {
        $self->value
    }
    method simplified {
        $self;
    }
    method m0ld_literal {
        $self->value;
    }
 }
