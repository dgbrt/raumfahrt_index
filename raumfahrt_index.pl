#!/usr/bin/perl
#Copyright (C) 2013 by dgbrt.
#
#This library is free software; you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation; either version 3 of the License, or
#(at your option) any later version.
#
#This library is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.
#
#You should have received a copy of the GNU General Public License
#along with this program.  If not, see <http://www.gnu.org/licenses/>.


use strict;
use warnings;
use DateTime;
use MediaWiki::API;

binmode STDOUT, ':utf8';

if ($#ARGV != 1)
{
    print "usage: raumfahrt_index username password\n";
    exit;
}

my $user = $ARGV[0];
my $pass = $ARGV[1];


my @result_list;

my @article_list;
my @categorie_list;
my @portal_list;

my $level = 0;
my $number_of_entries = 0;


### Wiki URL
my $mw = MediaWiki::API->new();
$mw->{config}->{api_url} = 'http://de.wikipedia.org/w/api.php';

### Log in to the wiki
$mw->login( { lgname => $user, lgpassword => $pass } )
    || die $mw->{error}->{code} . ': ' . $mw->{error}->{details};


### Getting all entries
&get_categorie('Kategorie:Raumfahrt');


### Sorting
@article_list = sort @article_list;

### Extract the portal list
@portal_list = grep(/^Portal:/, @article_list);
#@portal_list = grep(!/^Portal:Raumfahrt\//, @portal_list);

### Extract the categorie list
@categorie_list = grep(/^Kategorie:/, @article_list);
@categorie_list = grep(!/^Kategorie:Raumfahrt/, @categorie_list);

### Removing some content from the article list
@article_list = grep(!/^Kategorie:/, @article_list);
@article_list = grep(!/^Portal:/, @article_list);


### Output
open (ARTICLE, '>articles.txt');
binmode ARTICLE, ':utf8';

    print ARTICLE "<noinclude>{{nobots|deny=verschieberest}}\n";
    print ARTICLE "</noinclude>\n";

    my $date = DateTime->now->ymd;
    print ARTICLE "* '''Stand''': $date\n\n";


    print ARTICLE "== Artikel ==\n";

    my $first = 0;
    my $char;
    my $lastchar = "";
    my $link;
    my $text;

    foreach my $fileout (@article_list)
    {

        $char = substr($fileout, 0, 1);
        if( $char ne $lastchar )
        {
            print ARTICLE "\n\n=== [[Portal:Raumfahrt/Index/$char|$char]] ===\n";
            print ARTICLE ": ";
            $lastchar = $char;
            $first = 0;
        }

        if( $first != 0 )
        {
            print ARTICLE ", ";
        }
        print ARTICLE "[[$fileout]]";
        $first = 1;
    }

    print ARTICLE "\n\n== Kategorien ==\n";

    $first = 0;
    $lastchar = "";
    foreach my $fileout (@categorie_list)
    {
        $link = $fileout;
        $text = $fileout;
        $text =~ s/^Kategorie://;

        $char = substr($text, 0, 1);
        if( $char ne $lastchar )
        {
            print ARTICLE "\n: ";
            $lastchar = $char;
            $first = 0;
        }

        if( $first != 0 )
        {
            print ARTICLE ", ";
        }

        print ARTICLE "[[:$link|$text]]";
        $first = 1;
    }

    print ARTICLE "\n\n== Portal Seiten ==\n";

    $first = 0;
    $lastchar = "";
    foreach my $fileout (@portal_list)
    {
        $link = $fileout;
        $text = $fileout;
        $text =~ s/^Portal:Raumfahrt\///;

        $char = substr($text, 0, 1);
        if( $char ne $lastchar )
        {
            print ARTICLE "\n: ";
            $lastchar = $char;
            $first = 0;
        }

        if( $first != 0 )
        {
            print ARTICLE ", ";
        }

        print ARTICLE "[[$link|$text]]";
        $first = 1;
    }

    print ARTICLE "[[Kategorie:Portal:Raumfahrt/Index]]\n\n";

close (ARTICLE);


print "Number of all scanned entries: $number_of_entries\n";



### Get a list of articles in category
sub get_categorie
{

    ### Stop here if it is too much
    if ($level > 10)
    {
        print "Abort at level: $level\n";
        print "Entries: $number_of_entries\n";
        exit 0;
    }


    ### Get the content
    my $categorie = $_[0];

    my $articles = $mw->list
    ({
        action => 'query',
        list => 'categorymembers',
        cmtitle => $categorie,
        cmlimit => 'max'
     },
     { max => 10, hook => \&get_entries
    })
    || die $mw->{error}->{code} . ': ' . $mw->{error}->{details};


    ### Add new items to the article list
    my $article;
    my $item;
    my $add = 0;

    foreach $article (@result_list)
    {
        foreach $item (@article_list)
        {
            if( $article eq $item )
            {
                $add = 1;
            }
        }
        if( $add == 0 )
        {
            $number_of_entries += push(@article_list, $article);
        }
    }


    ### Recursiv search for all categories
    my @categories = grep(/^Kategorie:/, @result_list);

    @result_list = ();

    foreach (@categories)
    {
        print "$_\n";
    }

    foreach (@categories)
    {
        $level += 1;
        print "Level: $level ($_)\n\n";
        &get_categorie("$_");
        $level -= 1;
    }

}

### Get the names of each entry
sub get_entries
{
    my ($ref) = @_;
    foreach (@$ref)
    {
        #print "$_->{title}\n";
        push(@result_list, $_->{title})
    }
}
