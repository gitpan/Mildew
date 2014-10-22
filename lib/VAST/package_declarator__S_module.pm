use v5.10;
use MooseX::Declare;
use utf8;
class VAST::package_declarator__S_module {
    use Mildew::AST::Helpers;
    method emit_m0ld {
        my $name  = $self->{package_def}{longname}[0]{name}{identifier}{TEXT};
        my $id_type_sub = Mildew::AST::unique_id;
    
        if ($self->{package_def}{statementlist}) {
            #HACK we ignore my module foo because it's need for defining the setting
            return Mildew::AST::Seq->new(stmts=>$self->{package_def}{statementlist}->emit_m0ld);
        }
        my $init = $self->{package_def}{blockoid}->emit_m0ld;
    
        my $mold = Mildew::AST::Block->new(regs => $init->regs,stmts => [
            let(call(new=>FETCH(lookup("Package"))),sub {
                my $package = shift;
    	    Mildew::AST::Seq->new(stmts => [
    		    call(STORE => call(name => $package),[string $name]),
                        call(STORE => call("postcircumfix:{ }" => reg '$scope',[string '$?PACKAGE']),[$package]),
                        call(STORE => call("postcircumfix:{ }" => FETCH(call outer => reg '$scope'),[string $name.'::']),[$package]),
                        let(call(new=>FETCH(lookup("Package"))), sub {
    			my $export = shift;
    			Mildew::AST::Seq->new(stmts => [
    					  call(STORE => call("postcircumfix:{ }"=>$package,[string 'EXPORT::']),
    					       [ $export ]),
    					  call(STORE => call("postcircumfix:{ }"=>$export,[string 'ALL::']),
    					       [ call(new=>FETCH(lookup('Package'))) ]),
    					  call(STORE => call("postcircumfix:{ }"=>$export,[string 'DEFAULT::']),
    					       [ call(new=>FETCH(lookup('Package'))) ]),
    				      ]);
    		    }),
                        call(STORE => call("postcircumfix:{ }" => FETCH(call lookup => FETCH(call outer => reg '$scope'),[string '$?PACKAGE']),[string $name.'::']),[$package])
                     ]);
            }),
            @{$init->stmts}
        ]);
        call("postcircumfix:( )" =>
    	 call(new => FETCH(lookup('Code')),[],[string 'outer'=>reg '$scope',string 'mold' => $mold,string 'signature'=>empty_sig()]),
    	 [capturize()]
            );
        }
}
