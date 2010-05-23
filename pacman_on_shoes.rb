# pacman_on_shoes.rb

module Mod
  LINE_X = [[(40..140), 20], [(40..140), 140], [(80..140), 60], [(40..100), 100], [(140..500), 120], [(180..200), 100], [(180..200), 80], [(240..320), 80], [(400..440), 80], [(480..520), 80], [(180..200), 40], [(280..320), 40], [(400..520), 40], [(180..240), 20]]
  LINE_Y = [[40, (20..140)], [140, (20..140)], [180, (20..40)], [180, (80..120)], [200, (20..40)], [200, (80..140)], [240, (20..120)], [280, (40..80)], [300, (40..80)], [320, (40..80)], [360, (20..120)], [440, (40..140)], [520, (20..80)], [260, (120..140)], [320, (120..140)], [380, (120..140)]]

  def right; move @c[0].left + 2, @c[0].top, [0, 1, 2][@n%3], :right; end
  def left; move @c[0].left - 2, @c[0].top, [0, 3, 4][@n%3], :left; end
  def up; move @c[0].left, @c[0].top - 2, [0, 5, 6][@n%3], :up; end
  def down; move @c[0].left, @c[0].top + 2, [0, 7, 8][@n%3], :down; end
  
  def move x, y, n, dir = :up
    r = false; @n += 1
    @c.each{|s| s.hide; (s.move(x, y); @dir = dir) if r = check(x, y)}
    @c[0].show; @c[n].show
    return r
  end
  
  def check x, y
    LINE_Y.each{|i, j| return true if x == i and j.include?(y)}
    LINE_X.each{|i, j| return true if y == j and i.include?(x)}
    false
  end
  
  def pos n = 0
    return @c[n].left, @c[n].top
  end
end

class Pacman < Shoes::Widget
  include Mod
  def initialize x, y
    @c, @n, @dir = [], 0, :right
    face = [[5, 10, -PI/6, PI/6], [5, 10, -PI/12, PI/12], 
            [15, 10, PI-PI/6, PI+PI/6], [15, 10, PI-PI/12, PI+PI/12], 
            [10, 15, PI*1.5-PI/6, PI*1.5+PI/6], [10, 15, PI*1.5-PI/12, PI*1.5+PI/12], 
            [10, 5, PI*0.5-PI/6, PI*0.5+PI/6], [10, 5, PI*0.5-PI/12, PI*0.5+PI/12]]
    @c << oval(10, 10, 20, fill: yellow, stroke: black)
    face.each{|a, b, c, d| @c << shape(fill: black, stroke: black){move_to a, b; arc_to a, b, 30, 30, c, d}}
    move x, y, 1
  end
end

class Ghost < Shoes::Widget
  include Mod
  attr_accessor :dir
  def initialize color, x, y
    @c, @n, @dir = [], 0, :up
    face = [[0, nil, nil], [1, 8, 7], [2, 8, 7], [1, 4, 7], [2, 4, 7], [1, 6, 5], [2, 6, 5], [1, 6, 10], [2, 6, 10]]
    face.each do |a, b, c|
      @c << image(width: 20, height: 20) do
        image("imgs/#{color}#{a}.png")
        oval 2, 5, 7, fill: white, stroke: white
        oval 10, 5, 7, fill: white, stroke: white
        (oval(b, c, 2); oval(b+6, c, 2)) if b
      end
    end
    move x, y, 0
  end
end

class Foods < Shoes::Widget
  include Mod
  def initialize
    @foods = []
    LINE_Y.each{|x, j| j.step(20){|y| @foods << oval(8+x, 8+y, 5, fill: pink, stroke: pink)}}
    LINE_X.each{|i, y| i.step(20){|x| @foods << oval(8+x, 8+y, 5, fill: pink, stroke: pink)}}
  end
  
  def del x, y
    @foods.each{|f| (@foods -= [f]; f.remove ) if x == f.left - 8 and y == f.top - 8}
  end
  
  def length
    @foods.length
  end
end

Shoes.app height: 215, title: 'PAC-MAN on Shoes' do
  def finish
    (@won.show; @a.stop) if @fs.length.zero?
  end
  
  background 'imgs/background.png'
  DIR = [:up, :down, :right, :left]
  
  @fs = foods
  
  pm = pacman 80, 60
  keypress{|key| (eval("pm.#{key}"); @fs.del(*pm.pos); finish) if key.to_s =~ /right|left|up|down/}
  
  gs = []
  %w[orange blue red pink].each.with_index{|color, i| gs << ghost(color, 260+i*20, 80)}
  @a = animate(36){|i| gs.each{|g|
    g.dir = DIR[rand 4] if !eval("g.#{g.dir}") or i%50 == 49; (@lost.show; @a.stop) if g.pos == pm.pos}}

  @won = title('Congrats! You won!', left: 40, top: 155, width: 500, stroke: gold).hide
  @lost = title('Oops! Ghost ate you...', left: 40, top: 155, width: 500, stroke: gold).hide
end