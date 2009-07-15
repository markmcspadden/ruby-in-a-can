class Solutions

  class << self

    def john
      sum = 0 
      (1..999).each do |n| 
         if (n % 3 == 0) || (n % 5 == 0) 
           sum += n 
         end 
      end 
      sum
    end

    def shannon
      sum = 0 
      for i in 1..999 
         sum = (i % 3 == 0) || (i % 5 == 0) ? sum + i : sum 
      end 
      sum
    end

    def shannon2
      sum = 0 
      for i in 1..999 
         sum += i if (i % 3 == 0) || (i % 5 == 0)
      end 
      sum
    end

    def mark
      total = (1..999).inject(0) { |sum, i| 
         sum += i if (i % 3 == 0) || (i % 5 == 0)
         sum
      }
      total
    end

    def mark2
      total = (1...1000).inject(0) { |sum, i| 
         sum += i if (i % 3 == 0) || (i % 5 == 0)
         sum
      }
      total    
    end 
  end
  
end