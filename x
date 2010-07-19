diff --git a/v6/Mildew/lib/Mildew/Backend/C.pm b/v6/Mildew/lib/Mildew/Backend/C.pm
index 20b5143..0513d2a 100644
--- a/v6/Mildew/lib/Mildew/Backend/C.pm
+++ b/v6/Mildew/lib/Mildew/Backend/C.pm
@@ -10,6 +10,7 @@ role Mildew::Backend::C {
     has load_setting=>(default=>1,is=>'rw');
     has valgrind=>(default=>0,is=>'rw');
     has gdb=>(default=>0,is=>'rw');
+    has wrap_in_block=>(default=>1,is=>'rw');
 
     method _build_cflags {
         require SMOP;
@@ -27,7 +28,8 @@ role Mildew::Backend::C {
         die "-o is required when compiling to an executable\n" unless $output;
         my ($c_fh,$c_file) = tempfile();
         binmode($c_fh,":utf8");
-        print $c_fh $self->c_source(wrap_in_block($ast,$self->enclosing_scope));
+        my $wrapped_ast = $self->wrap_in_block ? wrap_in_block($ast,$self->enclosing_scope) : $ast;
+        print $c_fh $self->c_source($wrapped_ast);
 
 
         # compile the c source to the executable
diff --git a/v6/Mildew/lib/Mildew/Backend/OptC.pm b/v6/Mildew/lib/Mildew/Backend/OptC.pm
index 6c5867a..26823c6 100644
--- a/v6/Mildew/lib/Mildew/Backend/OptC.pm
+++ b/v6/Mildew/lib/Mildew/Backend/OptC.pm
@@ -12,7 +12,7 @@ class Mildew::Backend::OptC with Mildew::Backend::C {
     has trace=>(is=>'rw');
     has dump=>(is=>'rw');
     method BUILD {
-        my ($trace,$dump,$cflags,$ld_library_path,$no_setting,$valgrind,$gdb);
+        my ($trace,$dump,$cflags,$ld_library_path,$no_setting,$valgrind,$gdb,$no_wrap_in_block);
         GetOptionsFromArray(
             ($self->options->{BACKEND} // []),
             'trace' => \$trace,
@@ -22,6 +22,7 @@ class Mildew::Backend::OptC with Mildew::Backend::C {
             'ld-library-path=s' => \$ld_library_path,
             'valgrind' => \$valgrind,
             'gdb' => \$gdb,
+            'no-wrap-in-block' => \$no_wrap_in_block,
         ) || die 'incorrent options passed to Mildew::Backend::OptC';
         use YAML::XS;
         $self->trace($trace);
@@ -31,6 +32,7 @@ class Mildew::Backend::OptC with Mildew::Backend::C {
         $self->ld_library_path([split(',',$ld_library_path)]) if $ld_library_path;
         $self->valgrind($valgrind);
         $self->gdb($gdb);
+        $self->no_wrap_in_block(!$no_wrap_in_block);
     }
     method c_source($ast) {
         my $ssa_ast = Mildew::SSA::to_ssa($ast->simplified,{
diff --git a/v6/smop/inc/MyBuilder.pm b/v6/smop/inc/MyBuilder.pm
index fa7adf1..7d01bf9 100644
--- a/v6/smop/inc/MyBuilder.pm
+++ b/v6/smop/inc/MyBuilder.pm
@@ -241,7 +241,7 @@ sub ACTION_test {
     my $harness = TAP::Harness->new({ exec=>sub {
         my ($harness,$file) = @_;
         if ($file =~ /\.m0ld$/) {
-            ["mildew","-F","m0ld",'++BACKEND','--no-setting','--cflags',$cflags,'--ld-library-path','build/lib','++/BACKEND',$file];
+            ["mildew","-F","m0ld",'++BACKEND','--no-wrap-in-block','--no-setting','--cflags',$cflags,'--ld-library-path','build/lib','++/BACKEND',$file];
         } else {
             [$file];
         }
