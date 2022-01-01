# regex_stdin

## What is the regex_stdin project about?
This is a General Purpose Tool that reads lines of text from Standard Input.<br>
Lines that match the PCRE regular expression become eligible for output (multiple groups are allowed).
Output is formatted with a "printf" formatting specification (similar to AWK, Perl, C),<br>
with matched group value positional values passed to the printf spec in any order desired.<br>

*Make use of your Regular Expression super-powers!*

## How can regex_stdin be useful?
- Allows data transformations with no extra programming.
- Useful as an ad-hoc filter or tranformation tool
- Command output from a program can be piped into regex_stdin.pl to be filtered or transformed
- Cat a file as input to regex_stdin.pl to be filtered or transformed
- Send logging output through regex_stdin.pl to identify specifix error messages or other conditions that match a given regular expression
- Used as part of a shell script in string string transformations in variable assignments
- Use printf_stdin.pl to generate custom commands based groups matched and the formatting specification
- Use printf_stdin.pl as a tool for data profiling by extracting a specific group match that can then be passed to  "| sort | uniq -c"
- Use printf_stdin.pl to display the line numbers and full text where match occurred (NUMROWS)
- Use printf_stdin.pl to display how many matches occurred (MATCHCOUNT)
- Use printf_stdin.pl to display how many out of total number of rows that matched (MATCHSUMMARY)

## Requirements for regex_stdin.pl ?    
- Very little at all.
- Perl verion 5.xx is all that is required, which is normally on Unix, Linux, AIX by default.<br>To get the version of perl... try:<br>   **perl -v**
- regex_stdin.pl should work fine on MacOS if perl is installed.
- regex_stdin.pl will work with Windows version that supports ActiveState Perl or Strawberry Perl (5.xx)
- (Tested on versions of Perl ... 5.6 through 5.28)

## Here are a few Regular Expression web sites that will come in handy for reference
- (https://www.rexegg.com/regex-quickstart.html)
- (https://cheatography.com/davechild/cheat-sheets/regular-expressions/)
- (https://devhints.io/regexp)
- (https://regexcheatsheet.com/)



regex_stdin.pl takes are "regex" as the first parameter)

#### 
