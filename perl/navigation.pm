
use Data::Dumper;

local $_;

# _flatten_sections(%page, $prefix)
sub _flatten_sections {
    my %page = %{$_[0]};
    my $prefix = $_[1];
    my $new_prefix = $page{'name'};
    $new_prefix = $prefix . "\0" . $new_prefix unless $prefix eq '';
    my %sections;
    $sections{$new_prefix} = $page{'content'};
    for my $section (@{$page{'section'}}) {
        my %curr = %{_flatten_sections($section, $new_prefix)};
        @sections{keys %curr} = values %curr;
    }
    return \%sections;
}

=head2 flatten_sections(%page)

Given a Wikipedia page with section headers, flatten the hierarchy into a single
hash consisting of all sections on the page, listed hierarchically. For example,
given the following section hierarchy:

=over

=item * History

=item * Uses

=over

=item * Recent Uses

=item * Historical Uses

=back

=item * Pop Culture

=back

The following result will be produced

=over

=item * History

=item * Uses

=item * Uses\0Recent Uses

=item * Uses\0Historical Uses

=item * Pop Culture

=back

=cut

sub flatten_sections {
    return _flatten_sections($_[0], '');
}

=head2 nonhierarchical(%sections)

Given the output of flatten_sections(), remove the hierarchical information and keep only the
deepest-level section name of each entry.

=cut

sub nonhierarchical {
    local $1;
    my %sections = %{$_[0]};
    my %new_sections;
    @new_sections{map { /\x00([^\x00]+)$/ ? $1 : $_ } (keys %sections)} = values %sections;
    return \%new_sections;
}

1;
