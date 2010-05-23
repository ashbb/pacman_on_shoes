Shoes.app height: 200, title: 'PAC-MAN on Shoes' do

  background black
  stroke gray
  cells = Array.new(7){Array.new(25){nil}}
  7.times do |j|
    25.times do |i|
      cells[j][i] = rect(i*20+40, j*20+20, 20, 20)
      cells[j][i].click{cells[j][i].style[:fill] == gray ? (cells[j][i].style fill: black) : (cells[j][i].style fill: gray)}
    end
  end
  
  button 'write', top: 170 do
    open 'logo_data.txt', 'w' do |f|
      7.times do |j|
        25.times do |i|
          f.print "[#{j}, #{i}], " if cells[j][i].style[:fill] == gray
        end
      end
    end
  end
end