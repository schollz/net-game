local $_;

my(%occu, @mwords, @fwords, %placenames, %weapons, %animals, @foodprefixes, @foodblacklist, @foodsuffixes,
   %foodtrees, @foodnegatives, @foodnutrition, @foodpoison, @foodsections);
my $fh;

open $fh, '<', './data/occupations.txt' or die("$!");
while (<$fh>) {
    chomp;
    /^((?:\w+ )+) +([\w ]+)$/ or die("Illegal line in occupations.txt at line $.");
    my $key = $1;
    chop $key;
    $occu{$key} = $2;
}
close $fh;

open $fh, '<', './data/gender.txt' or die("$!");
while (<$fh>) {
    chomp;
    /^((?:\w+ )+) +([\w ]+)$/ or die("Illegal line in gender.txt at line $.");
    my $key = $1;
    my $gen = $2;
    push @mwords, $key if ($gen =~ /^male$/);
    push @fwords, $key if ($gen =~ /^female$/);
}
chop @mwords;
chop @fwords;
close $fh;

open $fh, '<', './data/placenames.txt' or die("$!");
while (<$fh>) {
    chomp;
    /^((?:[\w\-]+ )+) +([\w ]+)$/ or die("Illegal line in placenames.txt at line $.");
    my $key = $1;
    chop $key;
    $placenames{$key} = $2;
}
close $fh;

open $fh, '<', './data/weapons.txt' or die("$!");
while (<$fh>) {
    chomp;
    /^((?:[\w\-]+ )+) +([\w ]+)$/ or die("Illegal line in weapons.txt at line $.");
    my $key = $1;
    chop $key;
    $weapons{$key} = $2;
}
close $fh;

open $fh, '<', './data/animals.txt' or die("$!");
while (<$fh>) {
    chomp;
    /^([\w\- ]+)+: (.*)$/ or die("Illegal line in animals.txt at line $.");
    my $key = $1;
    my @rest = split(/,/, $2);
    my %stats;
    foreach my $token (@rest) {
        $token =~ /\b(\w+) *([-+]\d+)/ or die("Illegal line in animals.txt at line $.");
        $stats{$1} = 0+ $2;
    }
    $animals{$key} = \%stats;
}

open $fh, '<', './data/foodnames.txt' or die("$!");
my $foodmode = 'prefix';
# TODO Look into CPAN Set modules for this, rather than using a hash
my %foodmodes = ( 'prefix' => 1,
                  'suffix' => 1,
                  'blacklist' => 1,
                  'negative' => 1,
                  'plant' => 1,
                  'nutrition' => 1,
                  'poison' => 1,
                  'sections' => 1 );
while (<$fh>) {
    chomp;
    if (s/^://) {
        $foodmode = $_;
        die("Illegal line in foodnames.txt at line $.") unless defined $foodmodes{$foodmode};
    } elsif ($foodmode eq 'blacklist') {
        push @foodblacklist, $_;
    } elsif ($foodmode eq 'suffix') {
        push @foodsuffixes, $_;
    } elsif ($foodmode eq 'prefix') {
        push @foodprefixes, $_;
    } elsif ($foodmode eq 'negative') {
        push @foodnegatives, $_;
    } elsif ($foodmode eq 'plant') {
        /^(\w+)/ or die("Illegal line in foodnames.txt at line $.");
        $foodtrees{$1} = [split / /];
    } elsif ($foodmode eq 'nutrition') {
        push @foodnutrition, split / /;
    } elsif ($foodmode eq 'poison') {
        push @foodpoison, split / /;
    } elsif ($foodmode eq 'sections') {
        push @foodsections, $_;
    } else {
        die("Illegal line in foodnames.txt at line $.");
    }
}
close $fh;

(
 'occu' => \%occu,
 'mwords' => \@mwords,
 'fwords' => \@fwords,
 'placenames' => \%placenames,
 'weapons' => \%weapons,
 'animals' => \%animals,
 'foodprefixes' => \@foodprefixes,
 'foodnegatives' => \@foodnegatives,
 'foodblacklist' => \@foodblacklist,
 'foodsuffixes' => \@foodsuffixes,
 'foodtrees' => \%foodtrees,
 'foodnutrition' => \@foodnutrition,
 'foodpoison' => \@foodpoison,
 'foodsections' => \@foodsections
);
