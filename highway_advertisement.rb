require 'pry'

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

  def score_sum
    @res_list.each do |score|
      @res_score = @res_score + score if(score > 0)
    end
  end

  def output_result
    for i in 0 .. @res_list.length do
      @res_list[i] = 0 if(@res_list[i]==-1)
    end
    STDERR.print "スコアの最大値:" 
    puts  @res_score
    STDERR.puts  @res_score
    STDERR.print "スコアの到達率:" 
    score_rate = (@res_score.to_f / (@r.inject(:+).to_f)) * 100
    puts  score_rate.floor(3)
    STDERR.puts  score_rate.floor(3)
    STDERR.print "配置リスト:\n"
    STDERR.print "["
    @res_list.each_with_index do |res, index|
      STDERR.printf "%d, ", res if index != @res_list.length - 1
      STDERR.printf "%d", res if index == @res_list.length - 1
    end
    STDERR.print "]\n"
  end
end

class Algorithm1 < Highway_advertisement
  def run_algorithm
    # 選択した点を記録しておくリスト -2:選択しない, 0:未定, 1以上:選択した点の収入
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
           self.distance_check(i) == true) #その点を採用したとして, 距離5以上かどうか
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

class Algorithm2 < Highway_advertisement
  def run_algorithm
    for i in 0 .. @n-1 do
      @res_list.push(0) # 全部0で初期化
    end
    less_than_equal5 = []
    # 座標5以下の点の中で最大の点をとりあえず採用
    for i in 0 .. @n-1 do
      less_than_equal5.push(@r[i]) if((@x[0] - @x[i]).abs <= 5)
    end
    for k in 0 .. @n-1 do
      if(@r[k] == less_than_equal5.max)
        @res_list[k] = @r[k]
        break
      end
    end

    # 座標5より上の点を見ていく
    for i in less_than_equal5.length .. @n-1 do
      #p @res_list
      # 自分より前の点で距離5以内に採用している点がなければ採用
      distance5_from_i_choiced = []
      for v in (0 .. i-1).reverse_each do
        if((@x[i]-@x[v]).abs <5 && @res_list[v] > 0)
          distance5_from_i_choiced.push(v)
          break
        end
        if((@x[i]-@x[v]).abs >=5)
          break
        end
      end
      if(distance5_from_i_choiced.length == 0)
        # p "5以内採用なし"
        @res_list[i] = @r[i]
      # elsif((@x[i] - @x[i-1]).abs >= 5) #5以上離れていたら採用
      #   # p "距離5以上"
      #   @res_list[i] = @r[i]
      elsif((@x[i-1] - @x[i-2]).abs > 5) #1個前の点から距離5位内で点がなければどちらか大きい方
        if (@r[i] >  @r[i-1])
          for v in (0 .. i-2).reverse_each do
            if((@x[i]-@x[v]).abs <5)
              exist = true
              break
            end
          end
          if !exist
            @res_list[i] = @r[i]
            @res_list[i-1] = 0
          end
        end
      else #5以上離れていなかったら
       # p "距離5以内"
        for j in (0 .. i-1).reverse_each do
          break if((@x[i] - @x[j]) >= 5) #一番近くで5以上離れている点を見つける.
        end
       #  p "i="
       #  p i
       #  p "j="
       #  p j
        # 比較値1: 自分自身(i)+一番近くで5以上離れている点(j) - jから距離5以内かつiからは5以上離れている点で採用している点
        distance5_from_j_choiced =[]
        for v in 0 .. @n-1 do
          distance5_from_j_choiced.push(v) if( v!=j && (@x[j]-@x[v]).abs <5 &&(@x[i]-@x[v]).abs > 5 &&@res_list[v] > 0)
        end
        # p "5fromjchoice"
        # p distance5_from_j_choiced
        distance5_from_j_choiced_score = 0
        distance5_from_j_choiced.each do |point|
          distance5_from_j_choiced_score += @res_list[point]
        end
        # p "5fromjchoice_score"
        # p distance5_from_j_choiced_score
        compair_value1 = @r[i] + @r[j] - distance5_from_j_choiced_score
        # 比較値2: j から i-1 までで採用の点の合計
        compair_value2 = 0
        for k in j .. i-1 do
          compair_value2 += @res_list[k] if(@res_list[k] > 0)
        end
        compair_value3 = @r[i]
        # p "com1"
        # p compair_value1
        # p "com2"
        # p compair_value2
        # これらを比較
        if(compair_value3 > compair_value1 && compair_value3 > compair_value2)
          @res_list[i] = @r[i] #その点は採用する
          if (i-j == 2)
            @res_list[i-1] = 0
          else
            for k in j+1 .. i-1 do
              @res_list[k] = 0 #間の点は全て不採用
            end
          end
        elsif(compair_value1 > compair_value2)
          @res_list[i] = @r[i] #その点は採用する
          @res_list[j] = @r[j] #jも採用する
          if (i-j == 2)
            @res_list[i-1] = 0
          else
            for k in j+1 .. i-1 do
              @res_list[k] = 0 #間の点は全て不採用
            end
          end
          # jから距離5以内のものも不採用
          distance5_from_j_choiced.each do |z|
            @res_list[z] = 0
          end
        end
      end
    end
    self.score_sum
  end
end



class Algorithm3 < Highway_advertisement
  def run_algorithm
    w = []
    w_sum = []
    for i in 0 .. @n-1 do
      @res_list.push(0) # 全部0で初期化
    end
    @res_list[0] = @r[0] #最初の要素は無条件で暫定採用
    w[0] = Array.new(@n)
    for i in 0..@n-1 do
      w[0][i] = 0 if(i != 0)
      w[0][0] = @r[i] if(i == 0)
    end
    #i番目の点を採用するとして,その時の最適採用パターンw[i]を求める
    tmp = Array.new(@n)
    for i in 1..@n-1 do
      max = 0
      for j in 0..@n-1 do
        tmp[j] = 0 # 全部0で初期化
      end
      tmp[i] = @r[i]
      # 連結する際はwとtmpを足せば良い?
      if((@x[i] - @x[i-1]).abs < 5) 
        # 5以上離れているwの中で最大のw_sumの時のw[j]を求める
        index = nil
        for j in (0..i-1).reverse_each do
          if(@x[i] - @x[j] >= 5 && max < w[j].sum)
            max = w[j].sum
            index = j
          end
        end
        # 5以上離れているw[j]が存在しなければ何もしない
        if(index == nil)
        #  p w
          w.push(tmp.dup)
        else # 5以上離れているw[j]が存在するなら最大のw[index]を連結
          w.push(tmp.dup.zip(w[index]).map{|a, b| a+b})
        end
      else
        # 5以上はなれていればその点は採用
        # かつw[0]~w[i-1]の中で最大のwを連結
        for j in (0..i-1).reverse_each do
          if(max < w[j].sum)
            max = w[j].sum
            index = j
          end
        end
        # 5以上離れているw[j]が存在するなら最大のw[index]を連結
        w.push(tmp.dup.zip(w[index]).map{|a, b| a+b})
      end

      # @res_list[i] = max{@res_list[i-1], w[i]}
      if(@res_list.sum < w[i].sum)
        @res_list = w[i].dup
      end
      #p @res_list
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

# ダメなヒューリスティックアルゴリズム
runner1 = Algorithm1.new
runner1.run_algorithm
runner1.output_result

# マシなヒューリスティックアルゴリズム
runner2 = Algorithm2.new
runner2.run_algorithm
runner2.output_result

# 動的計画法
# 恐らく完璧
runner3 = Algorithm3.new
runner3.run_algorithm
runner3.output_result



# dup忘れて大変な目に合った...
# インスタンスの生成dup
