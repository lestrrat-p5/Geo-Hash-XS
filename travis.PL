use strict;

sub mysystem(@) {
    system(@_) == 0 or die "Failed to execute @_: $!";
}

sub cpanm (@) {
    @_ = ("cpanm", "--notest", @_);
    goto &mysystem;
}

sub run_tests {
    cpanm("--installdeps", ".");
    mysystem("perl", "Makefile.PL");
    mysystem("make", "test");
}

cpanm(qw(
    inc::Module::Install
    Module::Install::AuthorTests
    Module::Install::Repository
    Module::Install::XSUtil
));
run_tests();
