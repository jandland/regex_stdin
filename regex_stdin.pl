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
# Parameter 1: Enter the regular expression string within double quotes, 
#              can include multiple paren groupings
# Parameter 2: The printf format string 
#              (note: do not include linefeed, it is automatically added on output)
# Parameters 3 or more can be:
#     Integer position numbers  representing the specific paren group position,
#     and the order you list the group position numbers, correspond with the 
#     the order the values get plugged into the format string.
# 
# Additionally this script has other variations:
#  =>  passing just the RegEx, it acts similar to "egrep" in that it prints matching lines
#  =>  passing the RegEx and the phrase "ROWNUMS" as 2nd param, this displays the following 
#         "12 digit rownum=> full matching line"
#  =>  passing the RegEx and the phrase "MATCHCOUNT" as 2nd param, displays number of lines matching the regular expression
#  =>  passing the RegEx and the phrase "MATCHSUMMARY" as 2nd param, displays summary of # lines matched vs. # total lines in input
#
#
# Example:  run unix command "who -b" as input, grabs the last boot time value, 
#    using the regular expression with paren section matching the boot time 
#    Notice the use of backquoted unix commands within the format string parameter
#           in this case hostname is added to provide more info. 
#
# echo "Unix box $(hostname) was last booted $(who -b | getstr_match.pl ".*boot (.*)$" 1)"
# who -b | regex_stdin.pl ".*boot (.*)$" "Unix box `hostname` was last booted %s" 1
# Answer:
#     Unix box bighost was last booted Aug 10 10:38
#
# Additional Parameter Options that operate on a Positional Match number:
#
#   uc:<posn#>         Output string value of <posn#> match as UPPERCASE
#                      echo "bill" | regex_printf.pl "(.*)" "My name is %s" uc:1
#                      output:  
#                      My name is BILL
#
#   lc:<posn#>         Output string value of <posn#> match as lowercase
#                      echo "GWEN" | regex_printf.pl "(.*)" "My name is %s" lc:1
#                      output:  
#                      My name is gwen
#
#   ucfirst:<posn#>    Output string value of <posn#> match so first char is Uppercase
#                      echo "john" | regex_printf.pl "(.*)" "My name is %s" ucfirst:1
#                      output:  
#                      My name is John
#
#   length:<posn#>     Output integer char length of value of <posn#> match 
#                      echo "Hello World" | regex_printf.pl "(.*)" "%i" length:1
#                      output:  
#                      11
#
#   accum:<posn#>      Output numeric accumulating sum of value of <posn#> match
#                      print "1\n2\n3" | regex_printf.pl "(\d+)" "Value: %i  RunningTL: %i" 1 accum:1
#                      output:
#                      Value: 1  RunningTL: 1
#                      Value: 2  RunningTL: 3
#                      Value: 3  RunningTL: 6
#
# Additional (p) Parameter Option that does not depend on <posn#> match.
# (can be a lowercase or upppercase P)
#  "p:Hello world"    where output position can be a constant string "Hello world"
#             echo "hi" | regex_stdin.pl "(hi)" "%s" p:"Hello world"     
#             output:    
#             Hello world
#
#  "p:34"     where value can be a 34 decimal representing a double quote, with "%c" format
#             echo "hi" | regex_stdin.pl "(hi)" "The match was: %c%s%c" p:34 1 p:34
#             output:
#             The match was: "hi"
#
#  "P:${SHELL}"    where value is a environment variable, in this case SHELL
#             echo "hi" | regex_stdin.pl "(hi)" "Current shell is: %s" "P:${SHELL}"
#             output:
#             Current shell is: /bin/bash
#             
#             
#     p:value
# but can be sent to a format spec.
#    Use p or P stant as Parameter instead of positional match value
#   
#   l
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
    $numargs = scalar(@ARGV);		# also known as:    $#ARGV + 1;
    if ($numargs == 1) {
        $RegEx_pattern = shift;		# Regular expression in double quotes
        $full_line_prt=1;	        # only RegEx provided, 
                                        # print matching lines prefixed by 
                                        # "12digit linenumber => "
        $full_line_conditional=0;	# you are not printing full lines 
                                        # based on conditional statement
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

my $host = `hostname`; chomp $host;
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
            foreach $i (@neworder) {	            
                #array newlist will now contain the values in the proper order specified
		#but can also include passed in strings "p:stringvalue"
		if ($i =~ m/p:/i) {       #This is a passed in string parameter
                    $newlist[$c] = substr($i, 2);	#Use the string after "p:" or "P:"
	        } elsif ($i =~ m/^lineno:$/i) {         #Print line number feature, 
                      # If string is "lineno:" or "LINENO:"
                      $newlist[$c] = $.;                # Current line
	        } elsif ($i =~ m/^line:$/i) {         #Print Full Text Line feature, 
                      # If string is "line:" or "LINE:"
                      $newlist[$c] = $line;                # Current line
	        } elsif ($i =~ m/^host:$/i) {         #Print hostname feature, 
                      # If string is "host:" or "HOST:"
                      $newlist[$c] = $host;                # Current line
	        } elsif ($i =~ m/^uc:/i) {         #Print UPPERCASE feature, 
                      # If string is "uc:<POSN#>" or "UC:<POSN#>"
                      $ucposn = substr($i,3);
                      $newlist[$c] = uc $values[$ucposn - 1]; # uppercase position value
	        } elsif ($i =~ m/^lc:/i) {         #Print lowercase feature, 
                      # If string is "lc:<POSN#>" or "LC:<POSN#>"
                      $lcposn = substr($i,3);
                      $newlist[$c] = lc $values[$lcposn - 1]; # lowercase position value
	        } elsif ($i =~ m/^ucfirst:/i) {         #Print title case feature, 
                      # If string is "ucfirst:<POSN#>" or "UCFIRST:<POSN#>"
                      $ucfirstposn = substr($i,8);
                      $newlist[$c] = ucfirst $values[$posn - 1]; # ucfirst position value
	        } elsif ($i =~ m/^length:/i) {         #Print line number feature, 
                      # If string is "length:<POSN#>" or "LENGTH:<POSN#>:"
                      $lenposn = substr($i,7);
                      $newlist[$c] = length($values[$lenposn - 1]);  # length of position value
	        } elsif ($i =~ m/^substr:/i) {         #Substring feature
                      # useful for getting or substituting a portion of string
                      # substr:<POSN#>:<OFFSET#>         (offset from beginning of string)
                      # substr:<POSN#>:<-OFFSET#>        (offset from end of string)
                      # substr:<POSN#>:<OFFSET#>,<LEN#>  (w/ length limiter) 
                      # substr:<POSN#>:<-OFFSET#>,<LEN#> (w/ length limiter)
                      # substr:<POSN#>:<OFFSET#>,<LEN#>,"ReplaceString"    (w/substitution)
                      # substr:<POSN#>:<-OFFSET#>,<LEN#>,"ReplaceString"   (w/substitution)
                      my ($sub_offset,$sub_len,$sub_repl);

                      # this will hold:   "posn:OFFSET[[,LEN],REPLACEMENT]"
                      $posn_plus = substr($i,7);

                      # Find colon index following posn
                      $posn_colon_index = index($posn_plus, ":");

                      # Determine which match position number the substr command should apply to
                      if ( $posn_colon_index == -1 ) {
		          # No trailing colon given, default to offset 0
			  ($sub_offset,$sub_len,$sub_repl) = ( 0, undef, undef);
                          #Assume since there was no colon following match posn number,
			  #posn is the string
			  $subposn = $posn_plus;    
                      } else {
		          # This will hold "posn"
			  # get the matchposn number, before the colon
			  $subposn = substr($posn_plus,0,$posn_colon_index);

			  # this will hold  "OFFSET[[,LEN],REPLACEMENT]"
			  # get everything after the colon
			  $offset_plus = substr($posn_plus,index($posn_plus,":")+1);

			  # Try breaking params into 3 parts
			  ($sub_offset,$sub_len,$sub_repl) = split(',', $offset_plus);
                      }

		      # Perform Substr command... 
		      # Depending on what additional parameters were given
		      if ( length($sub_offset) == 0 ) {    
		          # if no offset given, its an error
		          # Assume no ofset value followed "substr:posn:",
			  # assign offset zero   "substr:posn:0"
                          # Defaulting to take full string instead of erroring
			  $sub_offset = 0;   
			  # Substr using: offset
			  $newlist[$c] = substr($values[$subposn - 1], $sub_offset);
                      } elsif ( ! length $sub_len ) {
		          # No length provided... perform substr:posn:offset
			  # Substr using: offset
			  $newlist[$c] = substr($values[$subposn - 1], $sub_offset);
                      } elsif ( ! length $sub_repl ) {
		          # If no replacement string given, just use   offset, len
			  # perform  substr:pos:offset,length
			  $newlist[$c] = substr($values[$subposn - 1], $sub_offset, $sub_len);
                      } else {
		          # Assume all substr options, use:  offset, len, stringreplacement
			  # Replacement provided...
			  # perform   substr:pos:offset,length,replacement
			  $origstr = $values[$subposn - 1];
			  for  (substr($origstr, $sub_offset, $sub_len)) {
			      # replacement str magically substitutes 
			      # at offset and length match area
			      $_ = $sub_repl;
			      # This now contains the replacement/substitution
			      $newlist[$c] = $origstr;
                          }
                      }

		  } elsif ($i =~ m/^accum:/i) {     # Accumulator feature, "accum:<posn#>"
		      # This is the positional match to accumulate numeric values
		      $accposn = substr($i,6);
		      # Add the specified match location value to the accumulator hash loc
		      $acchash{$accposn} += $values[$accposn - 1];
		      # store accumulated value in proper placeholder posn newlist array
		      $newlist[$c] = $acchash{$accposn};
		  } else {             
		      # Otherwise it is a parentheses match position number
		      # re-order values as specified in newlist array
		      $newlist[$c] = $values[$i - 1];
		  }
		  # Increase counter for each print spec positional specifier to print
		  $c++;
              }
	      # prints matching RegEx patterns with printf format and order of values
	      # Note:  by default, always tacks on newline to format, before printing
	      printf($format . "\n", @newlist);
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

