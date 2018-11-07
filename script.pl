# 乱数発生
# dist : 距離
# n : 看板の個数
# board[i] = 利益
# 引数 : 距離 利益最大値 看板の個数
#!/usr/bin/env perl
use strict;
use warnings;
use Math::Random::MT qw/rand srand/; # 擬似乱数に近いランダム関数作成
use Data::Dumper;
use 5.02;

srand time^$$;
my $dist = $ARGV[0];                  # 距離
my $n = defined $ARGV[2] ? $ARGV[2] : int(rand $dist-1) + 1;  # 看板の個数. 決まっている場合は入力から, 決まっていない時はランダム
my $max = $ARGV[1];                  # 利益の最大値は $max 以下にする
my @board = ();                 # 看板の座標. 座標に看板作成されている : 1, 作成されていない : 0
my $file_name = "in.txt";


open my $fout, '>', $file_name or die "cannot open file $!"; # ファイル作成

# ファイル書き込み
say $fout $dist;
say $fout $n;


# 座標決定 + 利益決定
for (1..$n) {
  my $i = int(rand $dist);
  while ( defined($board[$i]) ) { # 同じ座標の看板が作成されないようにする
    if ( $i == $dist-1 ) {
      $i = 0;
    }
    $i++;
  }
  $board[$i] = int(rand $max); # 利益決定. 取る値は正のみ
}

# 座標
for my $i (0..$#board) {
  print $fout $i . " " if (defined $board[$i]); # ファイル書き込み
}

print $fout "\n";

# 利益
for my $pref (@board) {
  print $fout $pref . " " if defined($pref);
}

