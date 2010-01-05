#!/usr/bin/perl
#
# wikedtags.pl (c) 2004 by Madd Sauer <madd_@web.de>
#                  2004 by Benjamin Schweizer <gopher at h07 dot org>
#                          http://www.ressheep.de/
#                  2003 by Tim Timewaster
#
#######################################################################

#
# This file generates the ./tag file that holds the association between
# WikiWords and filenames.
#
# This version introduces the [foobar] syntax.
#
#  Ver.	date		who	descr.
#  1	2004-06-17	madd	shutoff the "feature" to make a
#				new wikifile by using 'ThoseWords'.
#				(words with capital letters inside)
#				see also .vim/syntax/wiki.vim
########################################################################
use File::Basename;

$templatefile = "$ENV{'HOME'}/.vim/tools/unknown.wiki";

sub process_file {
	my $filename = $_[0];
	my $dir = dirname($filename);
	open (FILE, $filename) or die "cannot open $filename!";
	while (<>) {
		#while (m/\b(\w*[A-Z]\w*[a-z0-9]+\w*[A-Z]\w*)\b|\[(\w+)\]|\[.*\|(\w+)\]/g) {
		# if you not want to create by using 'ThoseWords' take 'while...' below
		# otherwise the upper one.
		while (m/\[(\w+)\]|\[.*\|(\w+)\]/g) {
			my $t = $1 . $2 . $3;
			my $targetfile = $t . ".wiki";
			if (-f "$dir/$targetfile") {
				# print "$t\t$targetfile\t1\n";
				$tags{$t} = "$t\t$targetfile\t1\n";
			} else {
				# TODO: bla.wiki -> unknown.wiki
				# print "$1\tbla.wiki\t1\n";
				$tags{$t} = "$t\t$templatefile\t1\n";
			}
		}
	}
}

%tags = ( );

#print STDERR "@ARGV\n";

foreach $f (@ARGV) {
#	print STDERR "$f\n";
}
foreach $f (@ARGV) {
	process_file($f);
}

foreach $k (sort (keys %tags)) {
	print $tags{$k};
}
