class Othello
  BLANK = "\e[32m□\e[0m " # 置き石無し
  BLACK = "◯ " # 黒石
  WHITE = "● " # 白石
  WALL = "■ " # 外枠
  MAX_ROW = 10 # 行
  MAX_COL = 10 # 列

  @@board = nil
  @@turn = nil

  def start()
    # 初期化
    @@turn = BLACK
    make_board()
    print_board()

    while true
      puts "<< #{@@turn}のターン >>"

      # 石を置ける場所をチェック
      can_put_pos_list = search_can_put_pos(@@turn)
      if can_put_pos_list.empty?
        puts "石を置ける場所が無い為、#{@@turn}のターンは飛ばされます。"
        change_turn()
        next
      end

      # 石を置く場所を入力
      # puts "置ける場所 ---> #{can_put_pos_list}"
      print "石の置き場所を行,列の順で指定してください。ex.) 1,2 ---> "
      put_pos = gets

      # 入力文字チェック
      if !check_input(put_pos)
        next
      end

      # 置き場所チェック
      put_pos = put_pos.chomp.split(",")
      # 行、列を取得:Integerで正の整数かどうか判定
      row = Integer(put_pos[0].strip) # row = put_pos[0]
      col = Integer(put_pos[1].strip) # col = put_pos[1]
      if !can_put_pos_list.include?([row, col])
        puts "指定された場所に石を置く事はできません。"
        next
      end

      # 反転処理
      reverse(row, col)

      # オセロ盤表示
      print_board()

      # 終了判定
      if finish?()
        break
      end

      # ターン交代
      change_turn()
    end

    # 結果表示
    print_result()
  end

  # オセロ盤の基礎作成
  def make_board()
    @@board = []
    # 外枠含めた全てのマス(10*10)を置き石無しの状態にする(初期化)
    MAX_ROW.times {
      row = []
      MAX_COL.times {
        row << BLANK
      }
      @@board << row
    }
    
    # 外枠を作る[行][列]
    (0..MAX_COL - 1).each { |i|
      @@board[0][i] = WALL # 最上行
      @@board[MAX_ROW - 1][i] = WALL # 最下行
    }
    (0..MAX_ROW - 1).each { |i|
      @@board[i][0] = WALL # 左列
      @@board[i][MAX_COL - 1] = WALL # 右列
    }

    # 中央に石を置く[行][列]
    @@board[4][4] = WHITE
    @@board[5][5] = WHITE
    @@board[4][5] = BLACK
    @@board[5][4] = BLACK
  end

  # 盤面を表示
  def print_board
    print "  "
    # 列座標
    (0..MAX_COL - 1).each { |i|
      print i.to_s + " "
    }
    print "\n"

    # 行座標
    (0..MAX_ROW - 1).each { |i|
      print i.to_s + " "
      row = @@board[i]
      row.each { |stone|
        print stone
      }
      print "\n"
    }
  end

  # 石の配置場所が正しいか判定
  def check_input(input)
    input = input.chomp.split(",")
    if input.length != 2
      puts "石を置く場所を正しく指定してください。"
      return false
    end

    if !integer_string?(input[0].strip) || !integer_string?(input[1].strip)
      puts "石を置く場所は数値で指定してください。"
      return false
    end

    return true
  end

  def search_can_put_pos(turn)
    enemy = get_enemy(turn)
    can_put_pos_list = []
    # 石を置いたマスの8方向(左隣のマスから時計回り)に引っくり返せる石が無いかチェック
    directions = [[-1, 0], [-1, 1], [0, 1], [1, 1], [1, 0], [1, -1], [0, -1], [-1, -1]]

    (0..MAX_ROW - 1).each { |row_num|
      (0..MAX_COL - 1).each { |col_num|
        if @@board[row_num][col_num] != BLANK
          next
        end

        # 置いた石の周りに相手の石があるか確認
        directions.each { |direction|
          can_put_flag = false
          search_row = row_num + direction[0]
          search_col = col_num + direction[1]
          # 相手の石で無い場合は次の方向を確認
          if @@board[search_row][search_col] != enemy
            next
          end

          # 見つけた方向を捜査していく
          while true
            search_row += direction[0]
            search_col += direction[1]
            if @@board[search_row][search_col] != enemy && @@board[search_row][search_col] != turn
              break
            elsif @@board[search_row][search_col] == enemy
              next
            else
              can_put_pos_list << [row_num, col_num]
              can_put_flag = true
              break
            end
          end

          if can_put_flag
            break
          end
        }
      }
    }

    return can_put_pos_list
  end

  def reverse(put_row, put_col)
    enemy = get_enemy(@@turn)
    directions = [[-1, 0], [-1, 1], [0, 1], [1, 1], [1, 0], [1, -1], [0, -1], [-1, -1]]

    @@board[put_row][put_col] = @@turn
    directions.each { |direction|
      reverse_pos = []
      reverse_row = put_row + direction[0]
      reverse_col = put_col + direction[1]
      if @@board[reverse_row][reverse_col] != enemy
        next
      end

      reverse_flag = false
      reverse_pos << [reverse_row, reverse_col]
      while true
        reverse_row += direction[0]
        reverse_col += direction[1]
        if @@board[reverse_row][reverse_col] == enemy
          reverse_pos << [reverse_row, reverse_col]
        elsif @@board[reverse_row][reverse_col] == @@turn
          reverse_flag = true
          break
        else
          break
        end
      end

      # 間にあった相手の石を裏返す
      if reverse_flag
        reverse_pos.each { |pos|
          @@board[pos[0]][pos[1]] = @@turn
        }
      end
    }
  end

  def finish?()
    can_put_white_list = search_can_put_pos(WHITE)
    can_put_black_list = search_can_put_pos(BLACK)
    if can_put_white_list.empty? && can_put_black_list.empty?
      return true
    end
    return false
  end

  def print_result()
    black_num = 0
    white_num = 0
    @@board.each { |row|
      row.each { |stone|
        if stone == BLACK
          black_num += 1
        elsif stone == WHITE
          white_num += 1
        end
      }
    }

    puts "<< 勝敗結果 >>"
    puts "#{BLACK}:#{black_num} #{WHITE}:#{white_num}"
    if black_num > white_num
      puts "#{BLACK}の勝利です!"
    elsif black_num < white_num
      puts "#{WHITE}の勝利です!"
    else
      puts "引き分けです。"
    end
  end

  def change_turn()
    if @@turn == BLACK
      @@turn = WHITE
    else
      @@turn = BLACK
    end
  end

  def get_enemy(turn)
    if turn == BLACK
      return WHITE
    else
      return BLACK
    end
  end

  def integer_string?(str)
    begin
      Integer(str)
      return true
    rescue
      return false
    end
  end
end
