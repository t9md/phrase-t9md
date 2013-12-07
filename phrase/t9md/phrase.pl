# Phrase: file conversion
#======================================================================
#!/usr/local/bin/perl
#
# convert series of images from one format to another
#
if ($#ARGV != 5) {
   print "usage: fconvert intype outtype old new start stop\n";
   exit;
}

$intype = $ARGV[0];
$outtype = $ARGV[1];
$old = $ARGV[2];
$new = $ARGV[3];
$start = $ARGV[4];
$stop = $ARGV[5];

for ($i=$start; $i <= $stop; $i++) {

   $num = $i;
   if($i<10) {      $num = "00$i"; }
   elsif($i<100) { $num = "0$i"; }

   $cmd = "imgcvt -i $intype -o $outtype $old.$num $new.$num";
   print $cmd."\n";
   if(system($cmd)) { print "imgcvt failed\n"; }
}

#  Phrase: Renaming Files
# ======================================================================
#
# rename series of frames
#
if ($#ARGV != 3) {
   print "usage: rename old new start stop\n";
   exit;
}

$old = $ARGV[0];
$new = $ARGV[1];
$start = $ARGV[2];
$stop = $ARGV[3];

for ($i=$start; $i <= $stop; $i++) {

   $num = $i;
   if($i<10) {      $num = "00$i"; }
   elsif($i<100) { $num = "0$i"; }

   $cmd = "mv $old.$num $new.$num";
   print $cmd."\n";
   if(system($cmd)) { print "rename failed\n"; }
}

#  Phrase: Image Processing
# ======================================================================
# composite series of images over a background image
#

if ($#ARGV != 4) {
print "usage: compem bg.rgb inbase outbase startNum stopNum\n";
exit;
}

$bg = $ARGV[0];
$inbase = $ARGV[1];
$outbase = $ARGV[2];
$start = $ARGV[3];
$stop = $ARGV[4];

# for each image
for ($i=$start; $i <= $stop; $i++) {

   # pad numbers
   $num = $i;
   if($i<10) { $num = "00$i"; }
   elsif($i<100) { $num = "0$i"; }

   # call unix command "over"
   $cmd = "over $bg $inbase.$num $outbase.$num 0 0";
   print $cmd."\n";
   if(system($cmd)) { print "over failed\n"; }
}

#  Phrase: yokutukau
# ======================================================================
$start  = substr($string, 5, 2);  # "is"
$rest   = substr($string, 13);    # "you have"
$last   = substr($string, -1);    # "e"
$end    = substr($string, -4);    # "have"
$piece  = substr($string, -8, 3); # "you"

#  Phrase:  get a 5-byte string, skip 3, then grab 2 8-byte strings, then the rest
# ======================================================================
($leading, $s1, $s2, $trailing) =
   unpack("A5 x3 A8 A8 A*", $data);

#  Phrase: (basic) String manupilation
# ======================================================================
$string = '\n';                     # two characters, \ and an n
$string = 'Jon \'Maddog\' Orwant';  # literal single quotes
#-----------------------------
$string = "\n";                     # a "newline" character
$string = "Jon \"Maddog\" Orwant";  # literal double quotes
#-----------------------------
$string = q/Jon 'Maddog' Orwant/;   # literal single quotes
#-----------------------------
$string = q[Jon 'Maddog' Orwant];   # literal single quotes
$string = q{Jon 'Maddog' Orwant};   # literal single quotes
$string = q(Jon 'Maddog' Orwant);   # literal single quotes
$string = q<Jon 'Maddog' Orwant>;   # literal single quotes
#-----------------------------
$a = <<"EOF";
This is a multiline here document
terminated by EOF on a line by itself
EOF


