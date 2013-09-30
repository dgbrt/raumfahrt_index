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
    print ARTICLE "</noinclude>";
    print ARTICLE "__NOTOC__";

    print ARTICLE " '''Inhaltsverzeichnis'''\n";
    print ARTICLE "  1. Artikel: [[Portal:Raumfahrt/Index#Index_0-9|0-9]] ";
    print ARTICLE "[[Portal:Raumfahrt/Index#Index_A|A]] ";
    print ARTICLE "[[Portal:Raumfahrt/Index#Index_B|B]] ";
    print ARTICLE "[[Portal:Raumfahrt/Index#Index_C|C]] ";
    print ARTICLE "[[Portal:Raumfahrt/Index#Index_D|D]] ";
    print ARTICLE "[[Portal:Raumfahrt/Index#Index_E|E]] ";
    print ARTICLE "[[Portal:Raumfahrt/Index#Index_F|F]] ";
    print ARTICLE "[[Portal:Raumfahrt/Index#Index_G|G]] ";
    print ARTICLE "[[Portal:Raumfahrt/Index#Index_H|H]] ";
    print ARTICLE "[[Portal:Raumfahrt/Index#Index_I|I]] ";
    print ARTICLE "[[Portal:Raumfahrt/Index#Index_J|J]] ";
    print ARTICLE "[[Portal:Raumfahrt/Index#Index_K|K]] ";
    print ARTICLE "[[Portal:Raumfahrt/Index#Index_L|L]] ";
    print ARTICLE "[[Portal:Raumfahrt/Index#Index_M|M]] ";
    print ARTICLE "[[Portal:Raumfahrt/Index#Index_N|N]] ";
    print ARTICLE "[[Portal:Raumfahrt/Index#Index_O|O]] ";
    print ARTICLE "[[Portal:Raumfahrt/Index#Index_P|P]] ";
    print ARTICLE "[[Portal:Raumfahrt/Index#Index_Q|Q]] ";
    print ARTICLE "[[Portal:Raumfahrt/Index#Index_R|R]] ";
    print ARTICLE "[[Portal:Raumfahrt/Index#Index_S|S]] ";
    print ARTICLE "[[Portal:Raumfahrt/Index#Index_T|T]] ";
    print ARTICLE "[[Portal:Raumfahrt/Index#Index_U|U]] ";
    print ARTICLE "[[Portal:Raumfahrt/Index#Index_V|V]] ";
    print ARTICLE "[[Portal:Raumfahrt/Index#Index_W|W]] ";
    print ARTICLE "[[Portal:Raumfahrt/Index#Index_X|X]] ";
    print ARTICLE "[[Portal:Raumfahrt/Index#Index_Y|Y]] ";
    print ARTICLE "[[Portal:Raumfahrt/Index#Index_Z|Z]] ";
    print ARTICLE "[[Portal:Raumfahrt/Index#Index_weitere|weitere]]\n";

    print ARTICLE "  2. [[Portal:Raumfahrt/Index#Kategorien|Kategorien]]\n";
    print ARTICLE "  3. [[Portal:Raumfahrt/Index#Portal_Seiten|Portal Seiten]]\n";


    my $date = DateTime->now->ymd;
    print ARTICLE "* '''Stand''': $date\n\n";

    my $arrSize = @article_list;
    print ARTICLE "*Anzahl Artikel: $arrSize\n";
    $arrSize = @categorie_list;
    print ARTICLE "*Anzahl Kategorien: $arrSize\n";
    $arrSize = @portal_list;
    print ARTICLE "*Anzahl Portalseiten: $arrSize\n\n\n";

    print ARTICLE "== Artikel ==";

    my $first = 0;
    my $char;
    my $lastchar = "";
    my $special_index = "";
    my $link;
    my $text;
    my $index_file ="";

    foreach my $fileout (@article_list)
    {

        $char = substr($fileout, 0, 1);
        if( $char ne $lastchar )
        {
            if( grep(/[0-9]/, $char) )
            {
                print ARTICLE "\n\n=== [[Portal:Raumfahrt/Index/0-9|Index 0-9]] ===\n";
                close (INDEX_FILE);
                $index_file = "Index 0-9";
                open (INDEX_FILE, ">$index_file.txt");
                &write_index_header($index_file);
            }
            else
            {
                if( $special_index eq "weitere" )
                {
                    print ARTICLE "\n\n=== [[Portal:Raumfahrt/Index/weitere|Index weitere]] ===\n: ";
                    close (INDEX_FILE);
                    $index_file = "Index weitere";
                    open (INDEX_FILE, ">$index_file.txt");
                    &write_index_header($index_file);
                    $special_index = "done1";
                }
                elsif( $special_index eq "" )
                {
                    print ARTICLE "\n\n=== [[Portal:Raumfahrt/Index/$char|Index $char]] ===\n";
                    close (INDEX_FILE);
                    $index_file = "Index $char";
                    open (INDEX_FILE, ">$index_file.txt");
                    &write_index_header($index_file);
                    if( $char eq "Z" )
                    {
                        $special_index = "weitere";
                    }
                }
            }
            if( $special_index eq "" || $special_index eq "weitere" )
            {
                print ARTICLE ": ";
            }
            elsif( $special_index eq "done1" )
            {
                $special_index = "done2";
            }
            else
            {
                print ARTICLE ", ";
            }
            $lastchar = $char;
            $first = 0;
        }

        if( $first != 0 )
        {
            print ARTICLE ", ";
        }

        $fileout =~ s/Apollo 0/Apollo /;
        $fileout =~ s/Cape Canaveral AFS Launch Complex 0/Cape Canaveral AFS Launch Complex /;
        $fileout =~ s/Gemini 0/Gemini /;
        $fileout =~ s/ISS-Expedition 0/ISS-Expedition /;
        $fileout =~ s/Intelsat 00/Intelsat /;
        $fileout =~ s/Intelsat 0/Intelsat /;
        $fileout =~ s/Luna 00000/Luna /;
        $fileout =~ s/Mariner 0/Mariner /;
        $fileout =~ s/OSCAR 0/OSCAR /;
        $fileout =~ s/PanAmSat 0/PanAmSat /;
        $fileout =~ s/Pioneer 0/Pioneer /;
        $fileout =~ s/STS-00/STS-/;
        $fileout =~ s/STS-0/STS-/;
        $fileout =~ s/Shenzhou 0/Shenzhou /;
        $fileout =~ s/Sojus 0/Sojus /;
        $fileout =~ s/Sojus T-0/Sojus T-/;
        $fileout =~ s/Sojus TM-0/Sojus TM-/;
        $fileout =~ s/Sojus TMA-0000/Sojus TMA-/;
        $fileout =~ s/Sojus TMA-000/Sojus TMA-/;
        $fileout =~ s/Sputnik 0/Sputnik /;
        $fileout =~ s/Telstar 0/Telstar /;

        print ARTICLE "[[$fileout]]";

        binmode INDEX_FILE, ':utf8';
        print INDEX_FILE "*[[$fileout]]\n";

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
            print ARTICLE "\n\n: ";
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
        $fileout =~ s/Portal:Raumfahrt\/Artikel der Woche\/Kalenderwoche 0/Portal:Raumfahrt\/Artikel der Woche\/Kalenderwoche /;
        $link = $fileout;
        $text = $fileout;
        $text =~ s/^Portal:Raumfahrt\///;

        $char = substr($text, 0, 1);
        if( $char ne $lastchar )
        {
            print ARTICLE "\n\n: ";
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

close (INDEX_FILE);


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
     { max => 100, hook => \&get_entries
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
            $number_of_entries = push(@article_list, $article);
        }
        $add = 0;
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
    my $title;

    foreach (@$ref)
    {
        $title = $_->{title};

        ### Add zeros for sorting
        if( grep(/^Apollo/, $title) && length($title) == 8 )
        {
            substr($title, 7, 0) = '0';
        }
        if( grep(/^Cape Canaveral AFS Launch Complex/, $title) && length($title) == 35 )
        {
            substr($title, 34, 0) = '0';
        }
        if( grep(/^Gemini/, $title) && length($title) == 8 )
        {
            substr($title, 7, 0) = '0';
        }
        if( grep(/^ISS-Expedition/, $title) && length($title) == 16 )
        {
            substr($title, 15, 0) = '0';
        }
        if( grep(/^Intelsat/, $title) && length($title) == 10 )
        {
            substr($title, 9, 0) = '00';
        }
        if( grep(/^Intelsat/, $title) && length($title) == 11 )
        {
            substr($title, 9, 0) = '0';
        }
        if( grep(/^Luna/, $title) && length($title) == 6 )
        {
            substr($title, 5, 0) = '00000';
        }
        if( grep(/^Mariner/, $title) && length($title) == 9 )
        {
            substr($title, 8, 0) = '0';
        }
        if( grep(/^OSCAR/, $title) && length($title) == 7 )
        {
            substr($title, 6, 0) = '0';
        }
        if( grep(/^PanAmSat/, $title) && length($title) == 10 )
        {
            substr($title, 9, 0) = '0';
        }
        if( grep(/^Pioneer/, $title) && length($title) == 9 )
        {
            substr($title, 8, 0) = '0';
        }
        if( grep(/^STS-/, $title) && length($title) == 5 )
        {
            substr($title, 4, 0) = '00';
        }
        if( grep(/^STS-/, $title) && length($title) == 6 )
        {
            substr($title, 4, 0) = '0';
        }
        if( grep(/^Shenzhou/, $title) && length($title) == 10 )
        {
            substr($title, 9, 0) = '0';
        }
        if( grep(/^Sojus/, $title) && length($title) == 7 )
        {
            substr($title, 6, 0) = '0';
        }
        if( grep(/^Sojus T-/, $title) && length($title) == 9 )
        {
            substr($title, 8, 0) = '0';
        }
        if( grep(/^Sojus TM-/, $title) && length($title) == 10 )
        {
            substr($title, 9, 0) = '0';
        }
        if( grep(/^Sojus TMA-/, $title) && length($title) == 11 )
        {
            substr($title, 10, 0) = '0000';
        }
        if( grep(/^Sojus TMA-/, $title) && length($title) == 12 && grep(!/M$/, $title) )
        {
            substr($title, 10, 0) = '000';
        }
        if( grep(/^Sputnik/, $title) && length($title) == 9 )
        {
            substr($title, 8, 0) = '0';
        }
        if( grep(/^Telstar/, $title) && length($title) == 9 )
        {
            substr($title, 8, 0) = '0';
        }
        if( grep(/^Portal:Raumfahrt\/Artikel der Woche\/Kalenderwoche/, $title) && length($title) == 50 )
        {
            substr($title, 49, 0) = '0';
        }

        push(@result_list, $title);


    }
}

sub write_index_header
{
    print INDEX_FILE "[[Kategorie:Wikipedia:Themenliste|Raumfahrt]]\n";

    my $date = DateTime->now->ymd;
    print INDEX_FILE "* '''Stand''': $date\n\n";

    print INDEX_FILE " '''Index:''' ";
    print INDEX_FILE "[[Portal:Raumfahrt/Index/0-9|0-9]] ";
    print INDEX_FILE "[[Portal:Raumfahrt/Index/A|A]] ";
    print INDEX_FILE "[[Portal:Raumfahrt/Index/B|B]] ";
    print INDEX_FILE "[[Portal:Raumfahrt/Index/C|C]] ";
    print INDEX_FILE "[[Portal:Raumfahrt/Index/D|D]] ";
    print INDEX_FILE "[[Portal:Raumfahrt/Index/E|E]] ";
    print INDEX_FILE "[[Portal:Raumfahrt/Index/F|F]] ";
    print INDEX_FILE "[[Portal:Raumfahrt/Index/G|G]] ";
    print INDEX_FILE "[[Portal:Raumfahrt/Index/H|H]] ";
    print INDEX_FILE "[[Portal:Raumfahrt/Index/I|I]] ";
    print INDEX_FILE "[[Portal:Raumfahrt/Index/J|J]] ";
    print INDEX_FILE "[[Portal:Raumfahrt/Index/K|K]] ";
    print INDEX_FILE "[[Portal:Raumfahrt/Index/L|L]] ";
    print INDEX_FILE "[[Portal:Raumfahrt/Index/M|M]] ";
    print INDEX_FILE "[[Portal:Raumfahrt/Index/N|N]] ";
    print INDEX_FILE "[[Portal:Raumfahrt/Index/O|O]] ";
    print INDEX_FILE "[[Portal:Raumfahrt/Index/P|P]] ";
    print INDEX_FILE "[[Portal:Raumfahrt/Index/Q|Q]] ";
    print INDEX_FILE "[[Portal:Raumfahrt/Index/R|R]] ";
    print INDEX_FILE "[[Portal:Raumfahrt/Index/S|S]] ";
    print INDEX_FILE "[[Portal:Raumfahrt/Index/T|T]] ";
    print INDEX_FILE "[[Portal:Raumfahrt/Index/U|U]] ";
    print INDEX_FILE "[[Portal:Raumfahrt/Index/V|V]] ";
    print INDEX_FILE "[[Portal:Raumfahrt/Index/W|W]] ";
    print INDEX_FILE "[[Portal:Raumfahrt/Index/X|X]] ";
    print INDEX_FILE "[[Portal:Raumfahrt/Index/Y|Y]] ";
    print INDEX_FILE "[[Portal:Raumfahrt/Index/Z|Z]] ";
    print INDEX_FILE "[[Portal:Raumfahrt/Index/weitere|weitere]]\n";
}
