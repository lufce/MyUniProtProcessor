
use strict;
use warnings;

package MyName;

my $species = "human";

my $data_file_dir = "../data/$species/rev/";
my $catalog_dir = "../contents_catalog_list/$species/rev/";

#my $raw_data_file_name = "rev_uniprot-all.txt";
#my $raw_data_file_name = "uniprot_test_doc.txt";
#my $raw_data_file_name = "181101_rev_uniprot_human_all.txt";
my $raw_data_file_name = "sorted_181101_rev_uniprot_human_all.txt";

my $KEY_COUNT = 6;
our $GNDE_KEY = "GNDE";
our $FT_KEY = "FT";
our $CC_KEY = "CC";
our $GO_KEY = "GO";
our $SQ_KEY = "SQ";
our $SL_KEY = "SL";

my $ID_code = "ID";
my %code_list =(
    $GNDE_KEY => "GNDE",
    $FT_KEY => "FT",
    $CC_KEY => "CC",
    $GO_KEY => "GO",
    $SQ_KEY => "SQ",
    $SL_KEY => "SL");

sub get_catalog_dir{
	return $catalog_dir;
}

sub get_data_file_dir{
	return $data_file_dir;
}

sub get_raw_data_file_name{
	return $raw_data_file_name;
}

sub get_raw_data_file_path{
	return $data_file_dir.$raw_data_file_name;
}

sub get_data_file_name{
	my $code_key = shift;
	my $code_name = $code_list{$code_key};
	
	return $ID_code. "-" .$code_name. "_" .$raw_data_file_name;
}

sub get_data_file_path{
	my $code_key = shift;
	
	return $data_file_dir.&get_data_file_name($code_key);
}

sub get_line_code_name{
	my $code_key = shift;
	return $code_list{$code_key};
}

sub get_key_count{
	return $KEY_COUNT;
}

1;