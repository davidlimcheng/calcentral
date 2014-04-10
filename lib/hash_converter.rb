module HashConverter

  def self.camelize(value)
    case value
      when Array
        value.map { |v| HashConverter.camelize(v) }
      when Hash
        Hash[value.map { |k, v| [k.to_s.camelize(:lower).to_sym, HashConverter.camelize(v)] }]
      else
        value
    end
  end

end
