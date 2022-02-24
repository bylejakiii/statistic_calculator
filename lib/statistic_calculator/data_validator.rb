module DataValidator
  ZERO_F_S = "0.0"
  def self.convert_s(x)
    if x == ZERO_F_S
      0.0
    else
      x.to_f == 0.0 ? nil : x.to_f
    end
  end

  def self.not_number?(x)
    ['Fixnum','Float','Integer'].include?(x.class.to_s)
  end
end
