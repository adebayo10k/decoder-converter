#!/bin/bash
#: Title			:utils.decoder-converter
#: Date				:2019-06-10
#: Author			:"Damola Adebayo" <damola@algoLifeNetworks.com>
#: Version			:1.0
#: Description		:use to encode/decode and convert data between some common encoding and number systems
#: Description		:
#: Description		:
#: Options			:None
#: Usage			:

##################################################################
##################################################################
# THIS STUFF IS HAPPENING BEFORE MAIN FUNCTION CALL:
#===================================

# 1. MAKE SHARED LIBRARY FUNCTIONS AVAILABLE HERE

# make all those library function available to this script
shared_bash_functions_fullpath="${SHARED_LIBRARIES_DIR}/shared-bash-functions.sh"
shared_bash_constants_fullpath="${SHARED_LIBRARIES_DIR}/shared-bash-constants.inc.sh"

for resource in "$shared_bash_functions_fullpath" "$shared_bash_constants_fullpath"
do
	if [ -f "$resource" ]
	then
		echo "Required library resource FOUND OK at:"
		echo "$resource"
		source "$resource"
	else
		echo "Could not find the required resource at:"
		echo "$resource"
		echo "Check that location. Nothing to do now, except exit."
		exit 1
	fi
done


# 2. MAKE SCRIPT-SPECIFIC FUNCTIONS AVAILABLE HERE

# must resolve canonical_fullpath here, in order to be able to include sourced function files BEFORE we call main, and  outside of any other functions defined here, of course.

# at runtime, command_fullpath may be either a symlink file or actual target source file
command_fullpath="$0"
command_dirname="$(dirname $0)"
command_basename="$(basename $0)"

# if a symlink file, then we need a reference to the canonical file name, as that's the location where all our required source files will be.
# we'll test whether a symlink, then use readlink -f or realpath -e although those commands return canonical file whether symlink or not.
# 
canonical_fullpath="$(readlink -f $command_fullpath)"
canonical_dirname="$(dirname $canonical_fullpath)"

# this is just development debug information
if [ -h "$command_fullpath" ]
then
	echo "is symlink"
	echo "canonical_fullpath : $canonical_fullpath"
else
	echo "is canonical"
	echo "canonical_fullpath : $canonical_fullpath"
fi

# included source files for json profile import functions
#source "${canonical_dirname}/preset-profile-builder.inc.sh"


# THAT STUFF JUST HAPPENED BEFORE MAIN FUNCTION CALL!
##################################################################
##################################################################


echo "OUR CURRENT SHELL LEVEL IS: $SHLVL"

echo "USAGE: $(basename $0)"

# Display a program header and give user option to leave if here in error:
echo
echo -e "		\033[33m===================================================================\033[0m";
echo -e "		\033[33m||         Welcome to the DECODER CONVERTER UTILITY              ||  author: adebayo10k\033[0m";  
echo -e "		\033[33m===================================================================\033[0m";
echo
echo " Type q to quit NOW, or press ENTER to continue."
echo && sleep 1
read last_chance
case $last_chance in 
[qQ])	echo
		echo "Goodbye!" && sleep 1
		exit 0
			;;
*) 		echo "You're IN..." && echo && sleep 1
	 		;;
esac 
exit 0

# specify error codes
# capitalise variables?

# base64 encoded strings
# ascii encoded strings
# hexidecimal number sequences 00-FF
# decimal number sequences 0-255
# bytes

## bitpatterns

## start with flowchart algorithm this time
## practice using branches to start new functionality
## input from command line and from file (local, then remote?)
## output to stdout (terminal) then to file

###########################################################
## unset runs before any function calls
## global associative array available to several functions

unset b64enc_char_table_array
declare -A b64enc_char_table_array #associative array [eg. D -> 3]
###########################################################

#create associative array to model the base64 index table
#populate the array
function create_b64_ref_table()
{
#char_count=0

for char in {{A..Z},{a..z},{0..9},+,/}
do
	b64enc_char_table_array[$char]=${#b64enc_char_table_array[@]}

done

}
###########################################################
#translate the current base64 coded field characters into a base64 index table value and
#add them to the indexed b64_index_numbers array
function convert_b64chars_to_b64nums()
{
create_b64_ref_table

################# EDIT THIS PART ##########################
## or could be passed in as a parameter ###
b64enc_string="8IskDiWEFm7Q7gff7Gb1H7IzblE="
##########################################################


lineIn=$b64enc_string
echo "the b64 encoded string is: $b64enc_string"
total=0

## a single line
for (( i=0 ; i < ${#lineIn} ; i++ ));
do
	char=${lineIn:i:1}
	# ignore the trailing = signs for now...
	if [[ $char =~ ^[=]$ ]]; then
		b64_index_numbers[$i]="0"
		continue
	fi

	#add chars' index value (from the assoc array) to an indexed array
	b64_index_numbers[$i]="${b64enc_char_table_array[$char]}"

done

# print the size of the indexed array of index numbers
printf "\n%s index numbers\n" "${#b64_index_numbers[@]}"

# print the array
echo "${b64_index_numbers[@]}"

# use a loop to iterate over, add and print elements
for value in "${b64_index_numbers[@]}";
do
	printf "%s " "$value"
	total=$((total+value))
done

echo && echo "total=$total"	
	
}
###########################################################
##########################################################
#
function convert_decimals_to_6bits()
{
b64_index_numbers=(4 8 12 16 20 24 28 32 36 40 44 48 52 56 60)
bit_pattern6=""
bits=""

for ((i=0; i<${#b64_index_numbers[@]}; i++));
do
	
	b64num="${b64_index_numbers[$i]}"
	bits=`bc <<< "obase=2;$b64num"` ## default ibase=10
	echo "starting order: ${#bits}"

	if [ ${#bits} -gt 6 ]; then
		echo "unexpected number of bits outside b64 table range,\(>6, as 63 is 111111\) exiting"
		exit 1
	fi

	if [ ${#bits} -lt 6 ]; then
		case ${#bits} in
		1)	bits="00000${bits}"
				#echo $bits
				#echo "new order: ${#bits}"
				;;
		2)	bits="0000${bits}"
				#echo $bits
				#echo "new order: ${#bits}"
				;;
		3)	bits="000${bits}"
				#echo $bits
				#echo "new order: ${#bits}"
				;;
		4)	bits="00${bits}"
				#echo $bits	#add decimal number to array
				#echo "new order: ${#bits}"
				;;
		5)	bits="0${bits}"
				#echo $bits
				#echo "new order: ${#bits}"
				;;
		*)	echo "unexpected number of bits,\(must be 0\) exiting"
				exit 1
				;;
		esac
	fi
	
	echo "$bits"
	bit_pattern6=$bit_pattern6${bits}
	echo "$i --> $b64num --> $bits"

done


echo $bit_pattern6
echo "bit_pattern6 order: ${#bit_pattern6} characters"
##194 166 200 110 130 30 204 199 33 231 166 227 124 214 161 6 13 54 17 6
}
##############################################################################################
#try converting to ascii, UNLESS BITS HAVE VALUES >127!!!
#groups of 8 bits in a 32-bit string (24 and 32 having a common denominator)
# 1.bitpatten6 string to 8-bit chunks stored in array as base10 integer(words_array10)
# 2.iterate over words_array elements to create ascii string (if possible)

function convert_bitpattern6_to_bytes()
{
#bit_pattern6="100101000101111100100111010000011000011000101011110000010110011101111000010011011100111110101011101101001010010011010101010011001100110011001110111011000011010100000000"
#bit_pattern6="01000010011010010111010001100011011011110110100101101110"
bit_pattern6="0111010001101000011010010111001100100000011010010111001100100000011000100110100101101110011000010111001001111001"
number_of_8bits=$(( (${#bit_pattern6}-(${#bit_pattern6}%8))/8 ))
echo "number of 8-bit bytes: $number_of_8bits"

lineIn=$bit_pattern6

count=0
#try_ascii=true

## loop through $bitpattern $number_of_8bits times 
for ((i=0; i<$number_of_8bits; i++));
do
	
	temp=${lineIn#????????}	## all but first 8 characters
	byte=${lineIn%"$temp"}

	#echo "i set to: $i, byte set to $byte"
		
	# convert to 8-bit binary to decimal, hex, oct integer
	dec_num=`bc <<< "obase=10; ibase=2; $byte"` ##
	hex_num=`bc <<< "obase=16; ibase=2; $byte"` ##
	oct_num=`bc <<< "obase=8; ibase=2; $byte"` ##
	#echo "dec value: $dec_num"
	#echo "hex value: $hex_num"
	#echo "oct value: $oct_num"

	#add hex number to array
	words_array16[$count]="$hex_num"
	#add decimal number to array
	words_array10[$count]="$dec_num"
	#add decimal number to array
	words_array8[$count]="$oct_num"
						
	lineIn=$temp
	count=$((count+1))

done

echo "hex:"	
printf "%s\n" "${#words_array16[@]}"	
echo "decimal:"
printf "%s\n" "${#words_array10[@]}"

arrayClone=("${words_array10[@]}")
try_ascii=true
#byte_sum=0

## so if ANY of the bytes are more than 127..
for value in "${arrayClone[@]}";
do
	if [ $value -gt 127 ]; then
		try_ascii=false
		echo $try_ascii 
		chr "$value" && echo
	fi
done

	
#if possible (ie dec_num< 127), convert to ascii
#if [ $dec_num -gt 127 ]; then
#	try_ascii=false	
#fi

echo "try_ascii now set to: " $try_ascii

	
printf "\n%s hexidecimals\n" "${#words_array16[@]}"	

if [ "$try_ascii" = true ]; then
	## output ascii value of each words_array element
	for value in "${words_array16[@]}";
	do
		#convert hex to ascii
			printf "\x$value "
	done 
else
	echo "BYTES FOUND COULD NOT BE ENCODED INTO ASCII \(ie > 127\)"
fi

}
############################################################################################
chr() {
  [ "$1" -lt 256 ] || return 1
  printf "\\$(printf '%03o' "$1")"
}
############################################################################################
ord() {
  LC_CTYPE=C printf '%d' "'$1"
}
############################################################################################


###########################################################

