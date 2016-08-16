
# TODO The filters currently operate in a first-fit fashion; see if we can get some semblance of best-fit.

package Filters {

    sub trailing_comma_phrase {
        for (@_) { s/,.*$//; }
    }

    sub slash_phrase {
        for (@_) { s|/[^ /]/||g; }
    }

    sub paren_expr {
        my $matches;
        for (@_) {
            do { $matches = s/\([^()]*\)//g; } while $matches > 0;
        }
    }

    sub consecutive_spaces {
        for (@_) {
            s/ {2,}/ /g;
            s/^ +//;
            s/ +$//;
            s/ +,/,/g;
        }
    }

    sub appositive_phrase {
        for (@_) {
            s/,[A-Za-z0-9:\-' _]*,//g;
        }
    }

}

sub apply_filter {
    my $func = shift;
    my @arr;
    for (@_) {
        my $arg = $_;
        $func->($arg);
        push @arr, ($_, $arg);
    }
    return @arr;
}

sub apply_filters {
    my $funcs = shift;
    my @arr = @_;
    for my $func (@$funcs) {
        @arr = apply_filter($func, @arr);
    }
    return @arr;
}

1;