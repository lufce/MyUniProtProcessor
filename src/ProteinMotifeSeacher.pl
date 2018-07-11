#160812		ver0.1		作り始め

use strict;
use warnings;
use Time::HiRes;

###サブルーチン

sub getExecutionDate(){
	my @youbi = ('日', '月', '火', '水', '木', '金', '土');
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime time;
	$year +=1900;
	$mon += 1;
	return "$year年$mon月$mday日($youbi[$wday]) $hour時$min分$sec秒";
}

###変数
my $startTime = Time::HiRes::time();

my $DBFilename = "uniprot-all.fasta";	#タンパク質の配列を含んだデータベースファイル。160812現在FASTA形式しか想定していない。
my $motif = "[KRQ]V.P.";				#探索したいモチーフ。正規表現で書く。

my $ResultFileName = "MotifResult";			#出力ファイルの名前
my $ResultFileName2 = "MotifResultTab";		#出力ファイルの名前。タブ区切りにしているのでExcelに使う。
my $now = getExecutionDate();			#実行日時

my $proteinName = "";					#探索中のタンパク質の名前
my $AASequence = "";					#タンパク質のアミノ酸配列
my $matchCounter = 0;					#モチーフがあったタンパク質の数

my $proteinNumber = 0;					#データファイルのタンパク質の数
my $counter = 0;						#プログレスバーのカウンター
my $progress = 0;

###コード

#データベースファイルを開く。同じディレクトリに置くこと。
if(!open(DBF,$DBFilename) ){
	die("DataBaseFile does not exist!")
}

#出力ファイルを開く。同じ名前があるならナンバリングをする。
my $i = 1;
while (-e $ResultFileName.$i.".txt"){
	$i++;
}

open(RF,">",$ResultFileName.$i.".txt");
open(TRF, ">", $ResultFileName2.$i.".csv");

#出力ファイルに書き込み
print RF "実行日時：$now\n探索モチーフ：$motif\n探索ファイル：$DBFilename\n\n";
print TRF "実行日時：$now\n探索モチーフ：$motif\n探索ファイル：$DBFilename\n\n";

###処理
#データベース中のタンパク質数の取得（プログレスバーに使う）
while(<DBF>){
	if(m/^>/){
		$proteinNumber++;
	}
}
print "$proteinNumber\n";

close DBF; open DBF, $DBFilename;

#モチーフ探索
while(<DBF>){
	if(m/^>/){
	#新しいタンパク質名の行が来たら、今までのアミノ酸配列で目的の処理を行う。
	
		#プログレスバーの処理
		$counter++;
		if($progress != int($counter*10/$proteinNumber)){
			$progress = int($counter*10/$proteinNumber);
			print "■" x $progress;
			print "□" x (10-$progress);
			print "\n";
		}
	
		if($AASequence =~ m/$motif/){
		#アミノ酸配列中に指定のモチーフが含まれているものを探しだす。
			
			$matchCounter++;

			chomp($proteinName);

			print RF "$proteinName\n$AASequence\n";
			print TRF "$matchCounter\t$proteinName\t$AASequence\n";
		}
		
		#初期化処理
		$proteinName = $_;
		$AASequence = "";
		
	}else{
		#アミノ酸配列を取得していく。
		$AASequence = $AASequence.$_;
		chomp($AASequence);
	}
}

#最後のタンパク質は処理されないので。

if($AASequence =~ m/$motif/){
#アミノ酸配列中に指定のモチーフが含まれているものを探しだす。
	$matchCounter++;

	chomp($proteinName);

	print RF "$proteinName\n$AASequence\n";
	print TRF "$matchCounter\t$proteinName\t$AASequence\n";	
}

print RF "\n$matchCounter / $proteinNumber  matched.";

printf("%0.3f",Time::HiRes::time - $startTime); 

close DBF;	close RF;


