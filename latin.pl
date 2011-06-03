#!/usr/bin/perl

use warnings;
use strict;
use CGI;
use CGI::Pretty ":standard";
use CGI::Carp qw(carpout fatalsToBrowser);

my $cgi = new CGI;

my $maximal_paragraphs = $cgi->param('maximal_paragraphs') || 5;
if ($maximal_paragraphs !~ m/^\d\d?$/) {$maximal_paragraphs = 5;}

my $maximal_sentences_per_paragraph = $cgi->param('maximal_sentences_per_paragraph') || 5;
if ($maximal_sentences_per_paragraph !~ m/^\d\d?$/) {$maximal_sentences_per_paragraph = 5;}

my $maximal_words_per_sentence = $cgi->param('maximal_words_per_sentence') || 20;
if ($maximal_words_per_sentence !~ m/^\d\d?$/) {$maximal_words_per_sentence = 20;}

my $maximal_letters_per_word = $cgi->param('maximal_letters_per_word') || 8;
if ($maximal_letters_per_word !~ m/^\d\d?$/) {$maximal_letters_per_word = 8;}

my $vowels_base = 'a e i o u';
my $consonants_base = 'b c d f g h k l m n p r s t v x y z qu';
my @vowels;
my @consonants;
my @end_interpunctions = qw(. . . . . . . . . . . ? ! ... :);
my @inner_interpunctions = qw(, , , , , , , ;);

open(INIT_BIGRAMS, "bigrams/init_bigrams.txt");
my @init_bigrams = <INIT_BIGRAMS>;
close(INIT_BIGRAMS);

open(ENDINGS, "bigrams/endings.txt");
my @endings = <ENDINGS>;
close(ENDINGS);

my $current_number_of_paragraphs;
my $current_number_of_sentences;
my $current_number_of_words;
my $current_number_of_letters;
my $total_number_of_lines;

my $text = q[];

$current_number_of_paragraphs = $maximal_paragraphs;
foreach my $paragraph (1..$current_number_of_paragraphs) {
  $text .= "<p>";
  $current_number_of_sentences = int(rand(
                                 $maximal_sentences_per_paragraph))+1;
  foreach my $sentence_position (1..$current_number_of_sentences) {
    $current_number_of_words =
                             int(rand($maximal_words_per_sentence))+1;
      foreach my $word_position (1..$current_number_of_words) {
      
        # $counter is the switch variable for alterating vowels and consonants
        my $counter = 1;
    	my $ending = $endings[int(rand($#endings))];
    	chomp($ending);
    	
    	my $beginning = $init_bigrams[int(rand($#init_bigrams))];
    	chomp($beginning);
    	if ($text =~ m/[\.\?\!\:\>] ?$/) {$beginning = ucfirst($beginning);}
    	$text .= $beginning;
    	if ($beginning =~ m/[aeiou]$/) {$counter = 2;}
    	
        foreach my $letter_position (1..int(rand(abs($maximal_letters_per_word - length($ending) - length($beginning)))
                                      )) {
            # consonants
            if ($counter % 2 == 0) {
              $text .= &append_consonant($word_position, $letter_position);
            }
            
            # vowels
            else {
              $text .= &append_vowel($word_position, $letter_position);
            }
            
            $counter++;
        }
    	if ($text =~ m/[aeiou]$/i and $ending =~ m/^[aeiou]/) {$text .= &append_consonant(2,2);}
    	if ($text =~ m/[bcdfghklmnprstvxyzq]$/i and $ending =~ m/^[bcdfghklmnprstvxyzq]/) {$text .= &append_vowel(2,2);}
    	if ($text =~ m/[\.\?\!\:\>] ?$/) {$ending = ucfirst($ending);}
    	$text .= $ending;
        if ($word_position == $current_number_of_words) {
          # Interpunctions at the end of the sentence.
          $text .= $end_interpunctions[int(rand($#end_interpunctions+1))];
        }
        else {
          if (int(rand(10)) == 0) {
            # Interpunctions in the middle of the sentence.
            $text .= $inner_interpunctions[int(rand($#inner_interpunctions))];
          }
        }
        $text .= ' ';
      }
  }
  $text .= "</p>\n";
}

my $cgi = new CGI;
print $cgi->header();
print "<html><head><title>arturs wortgenerator</title></head><body>";
print '<form name="confs" action="latin" method="post">
<select name="maximal_paragraphs">
<option value="1">1 Absatz</option>
<option value="2">2 Abs&auml;tze</option>
<option value="3">3 Abs&auml;tze</option>
<option value="4">4 Abs&auml;tze</option>
<option value="5" selected>5 Abs&auml;tze</option>
<option value="6">6 Abs&auml;tze</option>
<option value="7">7 Abs&auml;tze</option>
<option value="8">8 Abs&auml;tze</option>
<option value="9">9 Abs&auml;tze</option>
<option value="10">10 Abs&auml;tze</option>
<option value="15">15 Abs&auml;tze</option>
<option value="20">20 Abs&auml;tze</option>
<option value="30">30 Abs&auml;tze</option>
<option value="40">40 Abs&auml;tze</option>
<option value="50">50 Abs&auml;tze</option>
</select>
<select name="maximal_sentences_per_paragraph">
<option value="1">1 Satz pro Absatz</option>
<option value="2">Bis zu 2 S&auml;tze pro Absatz</option>
<option value="3">Bis zu 3 S&auml;tze pro Absatz</option>
<option value="4">Bis zu 4 S&auml;tze pro Absatz</option>
<option value="5" selected>Bis zu 5 S&auml;tze pro Absatz</option>
<option value="6">Bis zu 6 S&auml;tze pro Absatz</option>
<option value="7">Bis zu 7 S&auml;tze pro Absatz</option>
<option value="8">Bis zu 8 S&auml;tze pro Absatz</option>
<option value="9">Bis zu 9 S&auml;tze pro Absatz</option>
<option value="10">Bis zu 10 S&auml;tze pro Absatz</option>
<option value="15">Bis zu 15 S&auml;tze pro Absatz</option>
<option value="20">Bis zu 20 S&auml;tze pro Absatz</option>
<option value="30">Bis zu 30 S&auml;tze pro Absatz</option>
<option value="40">Bis zu 40 S&auml;tze pro Absatz</option>
<option value="50">Bis zu 50 S&auml;tze pro Absatz</option>
</select>
<select name="maximal_words_per_sentence">
<option value="1">1 Wort pro Satz</option>
<option value="2">Bis zu 2 W&ouml;rter pro Satz</option>
<option value="3">Bis zu 3 W&ouml;rter pro Satz</option>
<option value="4">Bis zu 4 W&ouml;rter pro Satz</option>
<option value="5">Bis zu 5 W&ouml;rter pro Satz</option>
<option value="6">Bis zu 6 W&ouml;rter pro Satz</option>
<option value="7">Bis zu 7 W&ouml;rter pro Satz</option>
<option value="8">Bis zu 8 W&ouml;rter pro Satz</option>
<option value="9">Bis zu 9 W&ouml;rter pro Satz</option>
<option value="10">Bis zu 10 W&ouml;rter pro Satz</option>
<option value="15">Bis zu 15 W&ouml;rter pro Satz</option>
<option value="20" selected>Bis zu 20 W&ouml;rter pro Satz</option>
<option value="30">Bis zu 30 W&ouml;rter pro Satz</option>
<option value="40">Bis zu 40 W&ouml;rter pro Satz</option>
<option value="50">Bis zu 50 W&ouml;rter pro Satz</option>
</select>
<select name="maximal_letters_per_word">Bis zu 
<option value="6" selected>Bis zu 6 Buchstaben pro Wort</option>
<option value="7">Bis zu 7 Buchstaben pro Wort</option>
<option value="8">Bis zu 8 Buchstaben pro Wort</option>
<option value="9">Bis zu 9 Buchstaben pro Wort</option>
<option value="10">Bis zu 10 Buchstaben pro Wort</option>
<option value="15">Bis zu 15 Buchstaben pro Wort</option>
<option value="20">Bis zu 20 Buchstaben pro Wort</option>
<option value="30">Bis zu 30 Buchstaben pro Wort</option>
<option value="40">Bis zu 40 Buchstaben pro Wort</option>
<option value="50">Bis zu 50 Buchstaben pro Wort</option>
</select>
<input type="submit" value="Generieren!"/>
</form>';

print '<div style="position:absolute; width:56ex; border:1px solid #232323; padding:5ex;">';

print $text;
print "</div>";
print "</body></html>";

sub append_consonant {
    my $word_position = shift;
    my $letter_position = shift;
    my $consonant;
    my $ran_num;
    if ($letter_position == 1) {
        $ran_num = int(rand(4701));
    }
    else {
        $ran_num = int(rand(7337));
    }
    
    if ($ran_num <= 489) {$consonant = 'n';}
    if ($ran_num > 489)  {$consonant = 'r';}
    if ($ran_num > 1661) {$consonant = 'x';}
    if ($ran_num > 1692) {$consonant = 'v';}
    if ($ran_num > 1820) {$consonant = 'd';}
    if ($ran_num > 2028) {$consonant = 'm';}
    if ($ran_num > 2256) {$consonant = 's';}
    if ($ran_num > 2409) {$consonant = 'l';}
    if ($ran_num > 2685) {$consonant = 'c';}
    if ($ran_num > 2947) {$consonant = 'p';}
    if ($ran_num > 3048) {$consonant = 'h';}
    if ($ran_num > 3058) {$consonant = 'g';}
    if ($ran_num > 3135) {$consonant = 'q';}
    if ($ran_num > 3293) {$consonant = 'b';}
    if ($ran_num > 3657) {$consonant = 'f';}
    if ($ran_num > 3667) {$consonant = 't';}
    if ($ran_num > 4434) {$consonant = 'sp';}
    if ($ran_num > 4451) {$consonant = 'sc';}
    if ($ran_num > 4475) {$consonant = 'tr';}
    if ($ran_num > 4513) {$consonant = 'cr';}
    if ($ran_num > 4524) {$consonant = 'br';}
    if ($ran_num > 4539) {$consonant = 'ts';}
    if ($ran_num > 4541) {$consonant = 'pr';}
    if ($ran_num > 4544) {$consonant = 'ps';}
    if ($ran_num > 4593) {$consonant = 'gr';}
    if ($ran_num > 4613) {$consonant = 'pl';}
    if ($ran_num > 4617) {$consonant = 'gn';}
    if ($ran_num > 4698) {$consonant = 'cl';}
    if ($ran_num > 4700) {$consonant = 'sl';}
    if ($ran_num > 4701) {$consonant = 'bl';}
    if ($ran_num > 4712) {$consonant = 'bd';}
    if ($ran_num > 4717) {$consonant = 'rs';}
    if ($ran_num > 4737) {$consonant = 'mm';}
    if ($ran_num > 4780) {$consonant = 'cn';}
    if ($ran_num > 4781) {$consonant = 'rr';}
    if ($ran_num > 4827) {$consonant = 'df';}
    if ($ran_num > 4828) {$consonant = 'rq';}
    if ($ran_num > 4831) {$consonant = 'bm';}
    if ($ran_num > 4833) {$consonant = 'rt';}
    if ($ran_num > 4965) {$consonant = 'nc';}
    if ($ran_num > 5023) {$consonant = 'nr';}
    if ($ran_num > 5024) {$consonant = 'll';}
    if ($ran_num > 5219) {$consonant = 'st';}
    if ($ran_num > 5374) {$consonant = 'bv';}
    if ($ran_num > 5375) {$consonant = 'rv';}
    if ($ran_num > 5392) {$consonant = 'rp';}
    if ($ran_num > 5400) {$consonant = 'nf';}
    if ($ran_num > 5407) {$consonant = 'nt';}
    if ($ran_num > 5694) {$consonant = 'mv';}
    if ($ran_num > 5696) {$consonant = 'dh';}
    if ($ran_num > 5698) {$consonant = 'ls';}
    if ($ran_num > 5709) {$consonant = 'mp';}
    if ($ran_num > 5768) {$consonant = 'bs';}
    if ($ran_num > 5788) {$consonant = 'ct';}
    if ($ran_num > 5923) {$consonant = 'gm';}
    if ($ran_num > 5928) {$consonant = 'xc';}
    if ($ran_num > 5929) {$consonant = 'bt';}
    if ($ran_num > 5935) {$consonant = 'gc';}
    if ($ran_num > 5936) {$consonant = 'rc';}
    if ($ran_num > 5990) {$consonant = 'nx';}
    if ($ran_num > 5991) {$consonant = 'mq';}
    if ($ran_num > 6033) {$consonant = 'sq';}
    if ($ran_num > 6090) {$consonant = 'pp';}
    if ($ran_num > 6108) {$consonant = 'ng';}
    if ($ran_num > 6143) {$consonant = 'xp';}
    if ($ran_num > 6147) {$consonant = 'ld';}
    if ($ran_num > 6148) {$consonant = 'rd';}
    if ($ran_num > 6155) {$consonant = 'pt';}
    if ($ran_num > 6212) {$consonant = 'xq';}
    if ($ran_num > 6213) {$consonant = 'lv';}
    if ($ran_num > 6279) {$consonant = 'rb';}
    if ($ran_num > 6291) {$consonant = 'tt';}
    if ($ran_num > 6322) {$consonant = 'lp';}
    if ($ran_num > 6323) {$consonant = 'ln';}
    if ($ran_num > 6329) {$consonant = 'rf';}
    if ($ran_num > 6340) {$consonant = 'ss';}
    if ($ran_num > 6738) {$consonant = 'cc';}
    if ($ran_num > 6763) {$consonant = 'nq';}
    if ($ran_num > 6770) {$consonant = 'ff';}
    if ($ran_num > 6778) {$consonant = 'nd';}
    if ($ran_num > 6921) {$consonant = 'dd';}
    if ($ran_num > 6928) {$consonant = 'lt';}
    if ($ran_num > 6990) {$consonant = 'dq';}
    if ($ran_num > 6994) {$consonant = 'sd';}
    if ($ran_num > 6997) {$consonant = 'md';}
    if ($ran_num > 6999) {$consonant = 'dp';}
    if ($ran_num > 7000) {$consonant = 'lg';}
    if ($ran_num > 7008) {$consonant = 'rg';}
    if ($ran_num > 7021) {$consonant = 'nn';}
    if ($ran_num > 7034) {$consonant = 'rm';}
    if ($ran_num > 7082) {$consonant = 'cq';}
    if ($ran_num > 7084) {$consonant = 'tq';}
    if ($ran_num > 7131) {$consonant = 'mb';}
    if ($ran_num > 7133) {$consonant = 'rn';}
    if ($ran_num > 7151) {$consonant = 'nl';}
    if ($ran_num > 7173) {$consonant = 'ns';}
    if ($ran_num > 7239) {$consonant = 'mn';}
    if ($ran_num > 7327) {$consonant = 'nv';}
    
    return $consonant;
}

sub append_vowel {
    my $word_position = shift;
    my $letter_position = shift;
    my $vowel;
    my $ran_num;

    # check whether last letter in word is a 'u'; in that case don't append another one, but a different vowel
    if    ($text =~ m/u$/)        {$ran_num = int(rand(7247-673))+673;}
    if    ($text =~ m/q$/)        {$ran_num = int(rand(673));}
    elsif ($letter_position == 1) {$ran_num = int(rand(5097-673))+673;}
    else                          {$ran_num = int(rand(7247));}
    
    if ($ran_num <= 178) {$vowel = 'ua';}
    if ($ran_num > 178) {$vowel = 'ue';}
    if ($ran_num > 255) {$vowel = 'uu';}
    if ($ran_num > 289) {$vowel = 'ui';}
    if ($ran_num > 484) {$vowel = 'uo';}
    if ($ran_num > 673) {$vowel = 'u';}
    if ($ran_num > 2113) {$vowel = 'e';}
    if ($ran_num > 3649) {$vowel = 'a';}
    if ($ran_num > 4566) {$vowel = 'o';}
    if ($ran_num > 5097) {$vowel = 'i';}
    if ($ran_num > 6278) {$vowel = 'ia';}
    if ($ran_num > 6450) {$vowel = 'ae';}
    if ($ran_num > 6604) {$vowel = 'au';}
    if ($ran_num > 6646) {$vowel = 'ei';}
    if ($ran_num > 6651) {$vowel = 'ii';}
    if ($ran_num > 6692) {$vowel = 'oa';}
    if ($ran_num > 6696) {$vowel = 'ea';}
    if ($ran_num > 6718) {$vowel = 'iu';}
    if ($ran_num > 6904) {$vowel = 'oe';}
    if ($ran_num > 6937) {$vowel = 'eu';}
    if ($ran_num > 6944) {$vowel = 'io';}
    if ($ran_num > 7147) {$vowel = 'ee';}
    if ($ran_num > 7148) {$vowel = 'ie';}
    if ($ran_num > 7242) {$vowel = 'ou';}
    if ($ran_num > 7243) {$vowel = 'eo';}
    if ($ran_num > 7246) {$vowel = 'oi';}
    

    return $vowel;
}
