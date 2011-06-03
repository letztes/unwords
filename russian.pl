#!/usr/bin/perl

use warnings;
use strict;
use CGI;
use CGI::Pretty ":standard";
use CGI::Carp qw(carpout fatalsToBrowser);

my $cgi = new CGI;

my $maximal_paragraphs = $cgi->param('maximal_paragraphs') || 1;
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

open(PREFIXES, "bigrams/russian_prefixes_for_eval.txt") or die $!;
my $prefixes_for_eval = do { local $/; <PREFIXES>};
close(PREFIXES);

open(ENDINGS, "bigrams/russian_endings_for_eval.txt") or die $!;
my $endings_for_eval = do { local $/; <ENDINGS>};
close(ENDINGS);

open(VOWELS, "bigrams/russian_vowels_for_eval.txt") or die $!;
my $vowels_for_eval = do { local $/; <VOWELS>};
close(VOWELS);

open(CONSONANTS, "bigrams/russian_consonants_for_eval.txt") or die $!;
my $consonants_for_eval = do { local $/; <CONSONANTS>};
close(CONSONANTS);

my $current_number_of_paragraphs;
my $current_number_of_sentences;
my $current_number_of_words;
my $current_number_of_letters;
my $total_number_of_lines;

my $text = q[];

$current_number_of_paragraphs = $maximal_paragraphs;
foreach my $paragraph (1..$current_number_of_paragraphs) {
  $text .= "<p>";
  $current_number_of_sentences = int(rand($maximal_sentences_per_paragraph))+1;
  foreach my $sentence_position (1..$current_number_of_sentences) {
    $current_number_of_words =int(rand($maximal_words_per_sentence))+1;
      foreach my $word_position (1..$current_number_of_words) {
      
        # $counter is the switch variable for alterating vowels and consonants
        my $counter = 1;
    	my $ending = &append_ending();
    	
    	my $prefix = &append_prefix();
    	if ($text =~ m/[\.\?\!\:\>] ?$/) {$prefix = &upper_case_first($prefix);}
    	$text .= $prefix;
    	if ($prefix =~ m/[aeiou]$/) {$counter = 2;}
    	
        foreach my $letter_position (1..int(rand(abs($maximal_letters_per_word - length($ending) - length($prefix)))
                                      )) {
            # consonants
            if ($counter % 2 == 0) {
              $text .= &append_consonant();
            }
            
            # vowels
            else {
              $text .= &append_vowel();
            }
            
            $counter++;
        }
    	if ($text =~ m/(:?а|я|о|ё|у|ю|и|ы|э|е)$/i and $ending =~ m/^(:?а|я|о|ё|у|ю|и|ы|э|е)/) {$text .= &append_consonant();}
    	if ($text =~ m/(:?б|в|г|д|ж|з|й|к|л|м|н|п|р|с|т|ф|х|ц|ч|ш|щ|ъ|ь)$/i and $ending =~ m/^(:?б|в|г|д|ж|з|й|к|л|м|н|п|р|с|т|ф|х|ц|ч|ш|щ|ъ|ь)/) {$text .= &append_vowel(2,2);}
    	if ($text =~ m/[\.\?\!\:\>] ?$/) {$ending = &upper_case_first($ending);}
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
print $cgi->header(-charset=>'UTF-8');
print "<html><head><title>arturs wortgenerator</title></head><body>";
print '<form name="confs" action="russian" method="post">
<select name="maximal_paragraphs">
<option value="1" selected>1 Absatz</option>
<option value="2">2 Abs&auml;tze</option>
<option value="3">3 Abs&auml;tze</option>
<option value="4">4 Abs&auml;tze</option>
<option value="5">5 Abs&auml;tze</option>
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
<option value="10" selected>Bis zu 10 W&ouml;rter pro Satz</option>
<option value="15">Bis zu 15 W&ouml;rter pro Satz</option>
<option value="20">Bis zu 20 W&ouml;rter pro Satz</option>
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
print "</body></head>";

sub append_consonant {
    my $consonant;
    $consonant = eval($consonants_for_eval);
    return $consonant;
}

sub append_vowel {
    my $vowel;
    $vowel = eval($vowels_for_eval);
    return $vowel;
}


sub append_prefix {
    my $prefix;
    $prefix = eval($prefixes_for_eval);
    return $prefix;
}


sub append_ending {
    my $ending;
    $ending = eval($endings_for_eval); 
    return $ending;
}

sub upper_case_first {
  my $word = shift;
  
  $word =~ s/^а/А/g;
  $word =~ s/^б/Б/g;
  $word =~ s/^в/В/g;
  $word =~ s/^г/Г/g;
  $word =~ s/^д/Д/g;
  $word =~ s/^е/Е/g;
  $word =~ s/^ё/Ё/g;
  $word =~ s/^ж/Ж/g;
  $word =~ s/^з/З/g;
  $word =~ s/^и/И/g;
  $word =~ s/^й/Й/g;
  $word =~ s/^к/К/g;
  $word =~ s/^л/Л/g;
  $word =~ s/^м/М/g;
  $word =~ s/^н/Н/g;
  $word =~ s/^о/О/g;
  $word =~ s/^п/П/g;
  $word =~ s/^р/Р/g;
  $word =~ s/^с/С/g;
  $word =~ s/^т/Т/g;
  $word =~ s/^у/У/g;
  $word =~ s/^ф/Ф/g;
  $word =~ s/^х/Х/g;
  $word =~ s/^ц/Ц/g;
  $word =~ s/^ч/Ч/g;
  $word =~ s/^ш/Ш/g;
  $word =~ s/^щ/Щ/g;
  $word =~ s/^ь//g; # The soft sign must not be in first position
  $word =~ s/^ы/Ы/g;
  $word =~ s/^ъ//g; # The hard sign must not be in first position
  $word =~ s/^э/Э/g;
  $word =~ s/^ю/Ю/g;
  $word =~ s/^я/Я/g;
  
  return $word;
}
