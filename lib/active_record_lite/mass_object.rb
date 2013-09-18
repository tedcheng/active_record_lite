class MassObject
  def self.set_attrs(*attributes)
    attr_accessor *attributes
    @attributes = *attributes
  end

  def self.attributes
    @attributes
  end

  def self.parse_all(results)
    results.map { |result| self.new(result) }
  end

  def initialize(params = {})
    params.each do |attr_name, value|
      if self.class.attributes.include?(attr_name.to_sym)
        self.send("#{attr_name.to_s}=".to_sym, value)
      else
        raise "mass assignment to unregistered attribute #{attr_name}"
      end
    end
  end

  def new_attr_accessor(*attributes)
    attributes.each do |attribute|
      define_method(attribute.to_s.concat("=").to_sym) do |obj|
        instance_variable_set("@#{attribute}", obj)
      end
      
      define_method(attribute) do
        instance_variable_get("@#{attribute}")
      end
      
    end
  end
end

class MyClass < MassObject
  set_attrs :x, :y
end




