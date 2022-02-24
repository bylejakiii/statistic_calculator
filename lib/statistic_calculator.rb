# frozen_string_literal: true

require_relative "statistic_calculator/version"
require_relative "statistic_calculator/data_validator"
module StatisticCalculator
  class Error < StandardError;end
  class FormatDataError < StandardError;end
  class NotEnoughDataError < StandardError;end
  class UndefinedFormatDataError < StandardError;end
  class StatisticCalculator

    attr_reader :data
    def initialize data=nil
      unless @data = validate_data(data)
        puts @data
        raise FormatDataError
      end
    end
    def validate_data data
      puts data
      puts data.class
      puts data.class.to_s == "String"
      case data.class.to_s
      when "String"
        puts data
        puts data.index(',')
        if data.index(',') != nil
          x = data.split(',').map{|x| DataValidator.convert_s(x)}
          puts x
          return x
        end
      when 'Fixnum', 'Integer'
        raise NotEnoughDataError
      when 'Array'
        return data.map{|x| DataValidator.convert_s(x) unless DataValidator.not_number?(x)}
      when 'Hash'
        raise FormatDataError
      else
        raise UndefinedFormatDataError
      end
    end
  end
end
