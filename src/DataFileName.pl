
package DFName;

my $species = "human";

my $catalog_file_dir = "../catalog_list/$species/rev/";
my $data_file_dir = "../data/$species/rev/";
my $catalog_dir = "../contents_catalog_list/$species/rev/";

#my $raw_data_file_name = "rev_uniprot-all.txt";
#my $raw_data_file_name = "uniprot_test_doc.txt";
my $raw_data_file_name = "181101_rev_uniprot_human_all.txt";

my %code_list =(
    'GNDE' => "GMDE",
    'FT' => "FT",
    'CC' => "CC",
    'GO' => "GO",
    'SQ' => "SQ",
    'SL' => "SL");

sub get_data_file_dir{
	return $data_file_dir;
}

sub get_raw_data_file_name{
	return $raw_data_file_name;
}

sub get_raw_data_file_path{
	return $data_file_dir.$raw_data_file_name;
}

sub _data_file_name_template{
	my $code_name = shift;
	return "ID-${code_name}_$raw_data_file_name";
}

sub get_GNDE_file_name{
	my $code_name = $code_list{'GNDE'};
	return &_data_file_name_template($code_name);
}

sub get_FT_file_name{
	my $code_name = $code_list{'FT'};
	return &_data_file_name_template($code_name);
}

sub get_CC_file_name{
	my $code_name = $code_list{'CC'};
	return &_data_file_name_template($code_name);
}

sub get_GO_file_name{
	my $code_name = $code_list{'GO'};
	return &_data_file_name_template($code_name);
}

sub get_SQ_file_name{
	my $code_name = $code_list{'SQ'};
	return &_data_file_name_template($code_name);
}

sub get_SL_file_name{
	my $code_name = $code_list{'SL'};
	return &_data_file_name_template($code_name);
}

sub _file_path_template{
	my $code_name = shift;
	return $data_file_dir.&_data_file_name_template($code_name);
}

sub get_GNDE_file_path{
	my $code_name = $code_list{'GNDE'};
	return &_file_path_template($code_name);
}

sub get_FT_file_path{
	my $code_name = $code_list{'FT'};
	return &_file_path_template($code_name);
}

sub get_CC_file_path{
	my $code_name = $code_list{'CC'};
	return &_file_path_template($code_name);
}

sub get_GO_file_path{
	my $code_name = $code_list{'GO'};
	return &_file_path_template($code_name);
}

sub get_SQ_file_path{
	my $code_name = $code_list{'SQ'};
	return &_file_path_template($code_name);
}

sub get_SL_file_path{
	my $code_name = $code_list{'SL'};
	return &_file_path_template($code_name);
}

sub get_GNDE_code_name{
	return $code_list{'GNDE'};
}

sub get_FT_code_name{
	return $code_list{'FT'};
}

sub get_CC_code_name{
	return $code_list{'CC'};
}

sub get_GO_code_name{
	return $code_list{'GO'};
}

sub get_SQ_code_name{
	return $code_list{'SQ'};
}

sub get_SL_code_name{
	return $code_list{'SL'};
}

1;