use v5.10;
use MooseX::Declare;
use utf8;
class VAST::statement_control__S_loop {
    use Mildew::AST::Helpers;
    method emit_m0ld {
        Mildew::AST::Loop->new(code => call('postcircumfix:( )',code($self->{block}),[capturize([])]));
    }
}
