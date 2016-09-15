#160812		ver0.1		���n��

use strict;
use warnings;
use Time::HiRes;

###�T�u���[�`��

sub getExecutionDate(){
	my @youbi = ('��', '��', '��', '��', '��', '��', '�y');
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime time;
	$year +=1900;
	$mon += 1;
	return "$year�N$mon��$mday��($youbi[$wday]) $hour��$min��$sec�b";
}

###�ϐ�
my $startTime = Time::HiRes::time();

my $DBFilename = "uniprot-all.fasta";	#�^���p�N���̔z����܂񂾃f�[�^�x�[�X�t�@�C���B160812����FASTA�`�������z�肵�Ă��Ȃ��B
my $motif = "[KRQ]V.P.";				#�T�����������`�[�t�B���K�\���ŏ����B

my $ResultFileName = "MotifResult";			#�o�̓t�@�C���̖��O
my $ResultFileName2 = "MotifResultTab";		#�o�̓t�@�C���̖��O�B�^�u��؂�ɂ��Ă���̂�Excel�Ɏg���B
my $now = getExecutionDate();			#���s����

my $proteinName = "";					#�T�����̃^���p�N���̖��O
my $AASequence = "";					#�^���p�N���̃A�~�m�_�z��
my $matchCounter = 0;					#���`�[�t���������^���p�N���̐�

my $proteinNumber = 0;					#�f�[�^�t�@�C���̃^���p�N���̐�
my $counter = 0;						#�v���O���X�o�[�̃J�E���^�[
my $progress = 0;

###�R�[�h

#�f�[�^�x�[�X�t�@�C�����J���B�����f�B���N�g���ɒu�����ƁB
if(!open(DBF,$DBFilename) ){
	die("DataBaseFile does not exist!")
}

#�o�̓t�@�C�����J���B�������O������Ȃ�i���o�����O������B
my $i = 1;
while (-e $ResultFileName.$i.".txt"){
	$i++;
}

open(RF,">",$ResultFileName.$i.".txt");
open(TRF, ">", $ResultFileName2.$i.".csv");

#�o�̓t�@�C���ɏ�������
print RF "���s�����F$now\n�T�����`�[�t�F$motif\n�T���t�@�C���F$DBFilename\n\n";
print TRF "���s�����F$now\n�T�����`�[�t�F$motif\n�T���t�@�C���F$DBFilename\n\n";

###����
#�f�[�^�x�[�X���̃^���p�N�����̎擾�i�v���O���X�o�[�Ɏg���j
while(<DBF>){
	if(m/^>/){
		$proteinNumber++;
	}
}
print "$proteinNumber\n";

close DBF; open DBF, $DBFilename;

#���`�[�t�T��
while(<DBF>){
	if(m/^>/){
	#�V�����^���p�N�����̍s��������A���܂ł̃A�~�m�_�z��ŖړI�̏������s���B
	
		#�v���O���X�o�[�̏���
		$counter++;
		if($progress != int($counter*10/$proteinNumber)){
			$progress = int($counter*10/$proteinNumber);
			print "��" x $progress;
			print "��" x (10-$progress);
			print "\n";
		}
	
		if($AASequence =~ m/$motif/){
		#�A�~�m�_�z�񒆂Ɏw��̃��`�[�t���܂܂�Ă�����̂�T�������B
			
			$matchCounter++;

			chomp($proteinName);

			print RF "$proteinName\n$AASequence\n";
			print TRF "$matchCounter\t$proteinName\t$AASequence\n";
		}
		
		#����������
		$proteinName = $_;
		$AASequence = "";
		
	}else{
		#�A�~�m�_�z����擾���Ă����B
		$AASequence = $AASequence.$_;
		chomp($AASequence);
	}
}

#�Ō�̃^���p�N���͏�������Ȃ��̂ŁB

if($AASequence =~ m/$motif/){
#�A�~�m�_�z�񒆂Ɏw��̃��`�[�t���܂܂�Ă�����̂�T�������B
	$matchCounter++;

	chomp($proteinName);

	print RF "$proteinName\n$AASequence\n";
	print TRF "$matchCounter\t$proteinName\t$AASequence\n";	
}

print RF "\n$matchCounter / $proteinNumber  matched.";

printf("%0.3f",Time::HiRes::time - $startTime); 

close DBF;	close RF;


