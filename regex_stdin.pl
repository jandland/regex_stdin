#!/usr/bin/perl 
# Script : regex_stdin.pl
# Version: 1.0
# GitHub project:  jandland/regex_stdin
# Purpose: This Perl script is used to match a specific RE pattern containing parenthesis section(s) 
#          and print the parenthesis matched text using your own printf format string with the values in any order you want.
#
#          - The regular expression parameter containing one or more parenthesis positional match areas
#          - This script can be used with one or more lines of standard input.
#          - Use the standard printf format field syntax.
#
# Parameter 1: Enter the regular expression string containing needed sections within parenthesis, can have multiple paren groupings
# Parameter 2: The printf format string (note: do not include linefeed, it is automatically added for you)
# Parameters 3 or more	Integer position numbers of the paren groupings as to positioning in the printf format string
#			Where position number is an integer corresponding to which (.*) parenthesis section you included
#                       from which you want to copy the string from.  You can have more than one parethesis section in
#                       the regular expression.  These numbers correspond with the paren groupings, listed in the order to be supplied
#                       to the printf format string.
# 
# Additionally this script has other variations:
#  =>  passing just the RegEx, it acts similar to "egrep" in that it prints matching lines
#  =>  passing the RegEx and the phrase "ROWNUMS" as 2nd param, this displays the following 
#         "12 digit rownum=> full matching line"
#  =>  passing the RegEx and the phrase "MATCHCOUNT" as 2nd param, displays number of lines matching the regular expression
#  =>  passing the RegEx and the phrase "MATCHSUMMARY" as 2nd param, displays summary of # lines matched vs. # total lines in input
#
# Tips for regular expression construction:
# Meta character meanings:                             Various RegEx Examples:
#   \ quote the next metacharacter                       [012345679] # any single digit
#   ^  Match the beginning of the line                   [0-9] # also   any single digit
#   .  Match any character (except newline)              [a-z] # any single lower case letter
#   $  Match the end of the line (or before newline)     [a-z] # any single lower case letter
#   |  Alternation                                       [0-9\-] # 0-9 plus minus character
#   () grouping                                          [^0-9] # any single non-digit, caret negates meaning
#   [] character classes                                 fa*t   # matches to ft, fat, faat, faaat etc 
#                                                        (.*)   # can be used a wild card match for any number (zero or more) any char
# Quantifiers:                                           f.*k   # matches to fk, fak, fork, flunk, etc.
#   *      Match 0 or more times                         fa+t   # matches to fat, faat, faaat etc
#   +      Match 1 or more times                         [A-Za-z0-9_]   #any single char that is a letter,number, or underscore
#   ?      Match 1 or 0 times
#   {n}    Match exactly n times
#   {n,}   Match at least n times
#   {n,m}  Match at least n but not more than m times
#   .*     Match 0 or more of any char
#   .+     Match 1 or more of any char
#   .?     Matches 0 or 1 of any char
#
# Perl Extensions:
#   \t	   tab character
#   \e	   escape
#   \033   octal
#   \x1B   hex
#   \c[    control
#   \l     lowercase next character
#   \L     lowercase until \E found
#   \u     Uppercase next character
#   \U     Uppercase until \E found
#   \d     Match a digit
#   \D     Match a non-digit
#   \s     Match a white-space character
#   \S     Match a nonwhite-space character
#   \w     Match a word character (alphanumeric char and underscore)
#   \W     Match a nonword character

# Assertions:
#   ^      Match the beginning of the line
#   $      Match the end of the line
#   \b     Match a word boundary
#   \B     Match a non-word boundary
#   \A     Match only at beginning of string
#   \Z     Match only at the end of string, or before newline at the end
#   \z     Match only at end of string
#   
   
# Example:  run unix command "who -b" as input, grabs the last boot time value, using the regular expression with paren section matching the boot time 
#           Notice that you can even used backquoted unix commands within the format string parameter
#           in this case hostname is added to provide more info. 
# echo "Unix box $(hostname) was last booted $(who -b | getstr_match.pl ".*boot (.*)$" 1)"
# who -b | regex_stdin.pl ".*boot (.*)$" "Unix box `hostname` was last booted %s" 1
# Answer:
#     Unix box bighost was last booted Aug 10 10:38
#---------------------------------------------------------------------
sub usage() {
    print "\n" . 'USAGE for printing full input lines of matching regular expression:' . "\n" . '  stdin | regex_stdin.pl "Reg(Ex)(Pattern)(String)" ';
    print "\n\n" . 'USAGE for printing line numbers and full input lines of matching regular expression:' . "\n" . '  stdin | regex_stdin.pl "Reg(Ex)(Pattern)(String)" NUMROWS';
    print "\n\n" . 'USAGE for printing just the Number of Lines matching the regular expression:' . "\n" . '  stdin | regex_stdin.pl "Reg(Ex)(Pattern)(String)" MATCHCOUNT';
    print "\n\n" . 'USAGE for printing Summary of Number of Lines matching the regular expression vs Total Number of Input lines:' . "\n" . '  stdin | regex_stdin.pl "Reg(Ex)(Pattern)(String)" MATCHSUMMARY';
    print "\n\n" . 'USAGE for specifying custom print format for matching paren groups of regular expression:' . "\n" . '  stdin | regex_stdin.pl "Reg(Ex)(Pattern)(String)" "%sFormat%sString%s" num1 num3 num2' . "\n" . '  where numbers correspond to the paren groups used in the regular expression' . "\n" . '  and those position numbers can be placed in any order you want to correspond with the format string ';
    print "\n\n";
    exit 1;
}


BEGIN {
    $numargs = scalar(@ARGV);					# also known as:    $#ARGV + 1;
    if ($numargs == 1) {
        $RegEx_pattern = shift;		# Regular expression in double quotes
        $full_line_prt=1;		    #only RegEx provided, print matching lines prefixed by "12digit linenumber => "
        $full_line_conditional=0;	# you are not printing full lines based on conditional statement
        $match_count=0;
    } elsif ($numargs == 2) {
        $RegEx_pattern = shift;		# Regular expression in double quotes
        $cmd = shift;
        if ($cmd eq "NUMROWS") {
            $full_line_prt=0;		# you are not printing all full lines
            $full_line_rownums=1;	# you are printing:  rownumbers=> full lines 
            $match_count=0;
        }
        elsif ($cmd eq "MATCHCOUNT") {
            $full_line_prt=0;		# you are not printing all full lines
            $full_line_rownums=0;	# you are printing:  rownumbers=> full lines 
            $match_count=1;		    # just show match count
        }
        elsif ($cmd eq "MATCHSUMMARY") {
            $full_line_prt=0;		# you are not printing all full lines
            $full_line_rownums=0;	# you are printing:  rownumbers=> full lines 
            $match_count=1;		    # just show match count summary
        } else { 
            usage; 			        # 2nd param needed to be "NUMROWS"
        }
    } elsif ($numargs > 2) {
        $RegEx_pattern = shift;		# Regular expression in double quotes
        $format = shift;		    # printf format in double quotes
        $full_line_prt=0;		    # you are not printing full line, you are specifying the format
        $full_line_rownums=0;		# you are not printing full lines based on conditional statement
        $match_count=0;
        @neworder = @ARGV;		    #Remaining Command-Line Parameters, number positioning of paren match format string
		                            #Plus new feature that allows string parameters to be passed in.
        for (;scalar(@ARGV) > 0;) {
            shift;			        #pop off remaining command-line args, in preparation for receiving standard-input
        }
    } else {  
        usage;				        #No parameters given
    }
}

my $tl_inp_rows = 0;
my $tl_matches = 0;
while (<>) {                        #Read standard input now that command-line parameters have been removed
    chomp;                          #Take off linefeed
    $line = $_;                     #Save current line of input
    $tl_inp_rows++;				    #Count rows read

    #If input line matches pattern string, each pattern match is placed into array values
    my @values = $line =~ m/$RegEx_pattern/;     

    #If expected number of patterns were matched, print values in specified format
    if (scalar(@values) > 0) {		#match occurred if number of elements in array is greater than zero
        if ($full_line_prt) {
            printf("%s\n", $line);	#prints matching RegEx patterns w printf format and order of values
        } elsif ($full_line_rownums) {
            printf("%012i=> %s\n", $., $line);	#prints matching RegEx patterns w printf format and order of values
        } elsif ($match_count) {
            $tl_matches++;
        } else {
            my $c = 0;				                #counter
            my @newlist = ();			            #to hold re-arranged values
            foreach $i (@neworder) {	            #array newlist will now contain the values in the proper order specified
			                                        #but can also include passed in strings "p:stringvalue"
			    if ($i =~ m/p:/i) {					#This is a passed in string parameter
				    $newlist[$c] = substr($i, 2);	#Use the string after "p:" or "P:"
				}
			    else {								#Otherwise it is a match position
                    $newlist[$c] = $values[$i - 1];     #re-order values as specified
				}
                $c++;
            }
            printf($format . "\n", @newlist);	    #prints matching RegEx patterns w printf format and order of values
        }
    }
}

END {
    if ($match_count and ($cmd eq "MATCHCOUNT")) {
        printf("%i\n", $tl_matches);
    } elsif ($match_count and ($cmd eq "MATCHSUMMARY")) {
        printf("\nSummary:\n%i out of %i input lines matched Regular Expression:\n%s%s%s\n", $tl_matches, $tl_inp_rows, chr(34), $RegEx_pattern, chr(34));
    }
}
