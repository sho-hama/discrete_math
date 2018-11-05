class Highway_advertisement # アルゴリズムを動作するにあたって共通部分となるクラス
  def initialize
    @res_score = 0
    @res_list = []
    @x = []
    @r = []
    @m = $m
    @n = $n
    # 文字列データを整数化してリストに格納
    $x_str.each do |value|
      @x.push(value.to_i) # 整数化してpush
    end
    $r_str.each do |value|
      @r.push(value.to_i) # 整数化してpush
    end
  end

  def output_result
    print "スコアの最大値: "
    p @res_score
    print "配置リスト: \n"
    p @res_list
  end

  def score_sum
    @res_list.each do |score|
      @res_score = @res_score + score if(score > 0)
    end
  end


end

class Hamana_algorithm1 < Highway_advertisement
  def run_algorithm
    # 選択した点を記録しておくリスト -1:選択しない, 0:未定, 1以上:選択した点の収入
    @r_max_list = [] #選択した点を除いた場合の最大値を求めるようのリスト
    for i in 0..@n-1 do
      @res_list.push(0) # 全部0で初期化
      @r_max_list.push(@r[i])
    end
    # 未定がなくなるまで繰り返す
    while (@res_list.include?(0) == true)
      for i in 0..@n-1 do
        if(@r_max_list.max == @r[i] &&
           @res_list[i] == 0 && #未定かどうか
           self.distance_check(i) == true) # その点を採用するとして, 距離が5以上かどうか
          @res_list[i] = @r[i]
          @r_max_list[i] = 0
          break
        elsif(@r_max_list.max == @r[i] &&
              @res_list[i] == 0 && #未定かどうか
              self.distance_check(i) == false) # 距離5が以下
          @res_list[i] = -1
          @r_max_list[i] = 0
          break
        else # それ以外なら次へ
          next
        end
      end
    end
    self.score_sum
  end

  def distance_check(i)
    for j in 0 .. @res_list.length - 1 do
      if(@res_list[j] > 0 && (@x[i] - @x[j]).abs < 5)
        return false
      end
    end
    return true
  end

end

class Higuchi_algorithm1 < Highway_advertisement
  def run_algorithm
    for i in 0 .. @n-1 do
      @res_list.push(0) # 全部0で初期化
    end
    less_than_equal5 = []
    # 座標5以下の点の中で最大の点をとりあえず採用
    for i in 0 .. @n-1 do
      less_than_equal5.push(@r[i]) if(@x[i] <= 5)
    end
    for k in 0 .. @n-1 do
      if(@r[k] == less_than_equal5.max)
        @res_list[k] = @r[k]
        break
      end
    end

    # 座標5より上の点を見ていく
    for i in less_than_equal5.length .. @n-1 do
      if((@x[i] - @x[i-1]).abs >= 5) #5以上離れていたら採用
        @res_list[i] = @r[i]
      else #5以上離れていなかったら
        for j in (0 .. i-1).reverse_each do
          break if((@x[i] - @x[j]) >= 5) #一番近くで5以上離れている点を見つける.
        end
        # 比較値1: 自分自身(i)+一番近くで5以上離れている点(j)
        compair_value1 = @r[i] + @r[j]
        # 比較値2: j から i-1 までで採用の点の合計
        compair_value2 = 0
        for k in j .. i-1 do
          compair_value2 += @res_list[k] if(@res_list[k] > 0)
        end
        # これらを比較
        if(compair_value1 > compair_value2)
          @res_list[i] = @r[i] #その点は採用する
          @res_list[j] = @r[j] #jも採用する
          for k in j+1 .. i-1 do
            @res_list[k] = 0 #間の点は全て不採用
          end
        end
      end
    end
    self.score_sum
  end
end

#データ読み取り
$m = gets.chomp.to_i
$n = gets.chomp.to_i
# 改行消してx, rのリストをスペースで区切って入力 (ただし文字列型)
$x_str = gets.chomp.split(" ")
$r_str = gets.chomp.split(" ")

#データの妥当性
exit if($x_str.length != $n || $x_str.last.to_i > $m)

runner1 = Higuchi_algorithm1.new
runner1.run_algorithm
runner1.output_result

runner2 = Hamana_algorithm1.new
runner2.run_algorithm
runner2.output_result




