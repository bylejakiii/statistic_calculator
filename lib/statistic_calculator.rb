# frozen_string_literal: true

require_relative "statistic_calculator/version"
require_relative "statistic_calculator/data_validator"
require_relative "statistic_calculator/data_calculator"
module StatisticCalculator
  class Error < StandardError;end
  class FormatDataError < StandardError;end
  class NotEnoughDataError < StandardError;end
  class UndefinedFormatDataError < StandardError;end
  class StatisticCalculator

    attr_accessor  :data, :summary, :average, :wariantion, :standard_deviation, :coefficient_of_variation,
                 :third_central_moment, :asymmetry_coefficient,:q1,:q2,:q3,:d1,:d9,
                 :quarter_devation,:quarter_coefficient_of_variation, :quarter_asymmetry_coefficient,
                 :quarter_concentration_coefficient, :sqrt_count_rounded, :compartment_hash

    def initialize(data:nil, environment: :development)
      if environment == :test
        data = [35,49,73,52,53,44,51,51,40,50,54,30,37,62,62,36,69,52,50,26,60,60,70,59,56,
                62,69,86,46,33,68,72,39,57,32,55,60,43,26,45,64,57,57,43,49,62,42,55,53,36,
                50,51,52,36,32,42,49,44,45,55,68,88,56,52,62,67,36,63,37,58,50,66,45,44,60,
                20,49,41,85,63].sort
        print data
      end
      unless @data = validate_data(data)
        raise FormatDataError
      end
    end

    def calculate_data
      begin
        #statystyka standardowa
        @summary = @data.sum
        @average = @summary/@data.count
        xi_average = @data.map{|x| x - @average}
        xi_average2_sum= xi_average.map{|x| x ** 2 }.sum
        @wariantion = xi_average2_sum/@data.count
        @standard_deviation = Math.sqrt(@wariantion)
        @coefficient_of_variation = @standard_deviation/@average
        @third_central_moment =  xi_average.map{|x| x ** 3 }.sum/@data.count
        @asymmetry_coefficient = @third_central_moment/(@standard_deviation ** 3)
        @forth_central_moment =  xi_average.map{|x| x ** 4 }.sum/@data.count
        @concentration_coefficient = @forth_central_moment/(@standard_deviation ** 4)

        #statystyka ćwiartkowa
        @q2= @data.count % 2 == 0 ? (@data[index = @data.count/2] + @data[index+=1])/2 : @data[(@data.count/2) + 1]
        @q1= @data.count % 2 == 0 ? (@data[index = @data.count/4] + @data[index+=1])/2 : @data[(@data.count/4) + 1]
        @q3= @data.count % 2 == 0 ? (@data[index = @data.count*(3/4.0)] + @data[index+=1])/2 : @data[(@data.count*(3/4.0)) + 1]
        @d1= @data.count % 2 == 0 ? (@data[index = @data.count/10] + @data[index+=1])/2 : @data[(@data.count/2) + 1]
        @d9= @data.count % 2 == 0 ? (@data[index = @data.count*(9/10.0)] + @data[index+=1])/2 : @data[(@data.count*(9/10.0)) + 1]
        @quarter_devation = (@q3 - @q1) / 2
        @quarter_coefficient_of_variation = (@quarter_devation/@q2) * 100
        @quarter_asymmetry_coefficient = (@q1 + @q3 = (2 * @q2)) / (2 * @quarter_devation )
        @quarter_concentration_coefficient = (@d9 - @d1)/(@q3 - @q1)

        #statystyka przedziałowa
        @sqrt_count_rounded = Math.sqrt(@data.count).round.to_f
        define_compartment
        @xiU_ni_sum = 0
        @compartment_hash.each do |hash|
          hash[:xiU] = (hash[:from] + hash[:to]) / 2
          hash[:xiU_ni] = hash[:xiU] * hash[:count]
          @xiU_ni_sum += hash[:xiU_ni]
          @compartmant_average = @xiU_ni_sum / @data.count

        end



        true
      rescue => e
        puts e
        false
      end
    end

    def define_compartment
      h = ((@data.max - @data.min)/@sqrt_count_rounded).round
      a = []
      v = @data.min
      a.append({from: v, to: v = v + (h-1), count: 0 })
      while v < @data.max
        a.append({from: v = v + 1, to: v = v + (h-1), count: 0 })
      end
      @data.each do |val|
        a.each_with_index do |hash, index|
          if val >= hash[:from] and val <= hash[:to]
            hash[:count] += 1
            a[index] = hash
            break
          end
        end
      end
      check_count = 0 ;state = :up ;failed = false
      a.each do |hash|
        if hash[:count] >= check_count and state == :up
          check_count = hash[:count]
        elsif hash[:count] < check_count and state == :up
          check_count = hash[:count]
          state = :down
        elsif hash[:count] > check_count and state == :down
          failed = true
          @sqrt_count_rounded = (@sqrt_count_rounded - 1).to_f
          define_compartment

          break
        elsif hash[:count] <= check_count and state == :down
          check_count = hash[:count]
        end
      end
      @compartment_hash = a unless failed
    end
    private


    def validate_data data
      case data.class.to_s
      when "String"
        if data.index(',') != nil
          x = data.split(',').map{|x| DataValidator.convert_s(x)}.sort
          return x
        end
      when 'Fixnum', 'Integer'
        raise NotEnoughDataError
      when 'Array'
        return data.map{|x| DataValidator.convert_s(x)}.sort
      when 'Hash'
        raise FormatDataError
      else
        raise UndefinedFormatDataError
      end
    end


  end
end
