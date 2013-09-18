require_relative './associatable'
require_relative './db_connection'
require_relative './mass_object'
require_relative './searchable'


class SQLObject < MassObject
  extend Searchable
  extend Associatable
  def self.set_table_name(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name
  end

  def self.all    
    query = "
      SELECT
        *
      FROM
        #{table_name}

    "
    all_objects = []
    all_rows = DBConnection.execute(query)
    all_rows.each do |row|
      new_object = self.new(row)
      all_objects << new_object unless new_object.nil?
    end
    
    all_objects
  end

  def self.find(id)
    query = "
      SELECT
        *
      FROM
        #{table_name}
      WHERE
        id = ?
    "
    new_row = DBConnection.execute(query, id).first
    self.new(new_row) unless new_row.nil?
  end

  def create
    attr_str = self.class.attributes.join(", ")
    
    question_array = []
    self.class.attributes.length.times {question_array << "?"}
    question_str = question_array.join(", ")
    
    
    query = "
      INSERT INTO
        #{self.class.table_name} (#{attr_str})
      VALUES 
        (#{question_str})
    "
    
    DBConnection.execute(query, attribute_values)
    
    @id = DBConnection.last_insert_row_id
    
  end

  def update
    assignment= []
    attr_values = self.attribute_values
    self.class.attributes.each_with_index do |attr, idx|
      assignment << "#{attr}=#{attr_values[idx]}"
    end
    assignment_str = assignment.join(", ")
    
    query = "
      UPDATE
        #{self.class.table_name}
      SET
        #{assignment_str}
      WHERE
        id = #{@id}
    "
  end

  def save
    self.id.nil? ? self.create : self.update
  end

  def attribute_values
    params = []
    self.class.attributes.each do |attr|
      params << self.send(attr)
    end

    params
  end
end
