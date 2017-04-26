#!/bin/env perl -w
# github: @cedriczirtacic
# to be used with keysniffer linux kernel module

use strict;
use warnings;
use Fcntl qw(SEEK_SET SEEK_CUR);
use Data::Dumper;

my $keys_f;
BEGIN{
    $keys_f="/sys/kernel/debug/kisni/keys";
    die "Error: $keys_f doesn't exists." if( !-e $keys_f || !-r $keys_f);
};

sub help($) {
    printf STDERR <<EOH, shift(@_);
Usage: %s <pattern>
EOH
    exit 1;
}

help($0) if($#ARGV < 0);
my @pattern = split //, $ARGV[0];
my $pattern_l = length($ARGV[0]);
my ($curr_line, $ocurr) = 0;

open(FD, "<$keys_f");
while(<FD>){
    $curr_line++;
    next if(/^_+/);
    
    if($_ =~ /^$pattern[0]$/x){
        my($l, $curr) = (0,tell(FD));

        my $found_line = $curr_line;
        while($l++ <= $pattern_l and !eof FD) {
            seek(FD, $curr + 1, SEEK_SET);
            $curr_line++;
            if(eof(FD)) {
                warn "eof()";
                last;
            }
            $curr = tell(FD);
            $_ = readline(FD);
            chomp $_;

            last if($pattern[$l] ne $_ || $l >= $pattern_l);
            if($pattern[$pattern_l-1] eq $_ && $l == ($pattern_l-1) ){
                print "Pattern found on line $found_line\n";
                $ocurr++;
                last
            }
        }
    }
}

print "Lines: $curr_line; Found: $ocurr\n";
close(FD);

exit 0;

__END__
