require 'active_support/core_ext/object/try'
require 'active_support/inflector'
require_relative './db_connection.rb'

class AssocParams
  def other_class
    @other_class_name.contantize
  end

  def other_table
    @other_class_name.constantize.table_name
  end
end

class BelongsToAssocParams < AssocParams
  attr_reader :other_class_name, :primary_key, :foreign_key#, :other_class, :other_table_name
  def initialize(name, params = {})
    @other_class_name = params[:class_name] || name.to_s.camelize
    @primary_key = params[:primary_key] || :id
    @foreign_key = params[:foreign_key] || "#{name}_id".to_sym
      #   
    # @other_class = other_class_name.constantize
    # @other_table_name = other_class.table_name
    #       
  end

  def type
  end
end

class HasManyAssocParams < AssocParams
  attr_reader :other_class_name, :primary_key, :foreign_key#, :other_class, :other_table_name
  def initialize(name, params, self_class)
    @other_class_name = params[:class_name] || name.to_s.camelize.singularize
    @primary_key = params[:primary_key] || :id
    @foreign_key = params[:foreign_key] || "#{name}_id".to_sym
        # 
    # @other_class = other_class_name.constantize
    # @other_table_name = other_class.table_name

    @self_class = self_class
  end

  def type
  end
end

module Associatable
  def assoc_params
    if @assoc_params.nil?
      @assoc_params = {}
      return @assoc_params
    else
      return @assoc_params
    end
  end

  def belongs_to(name, params = {})
    @assoc_params[name] = BelongsToAssocParams.new(name, params)
    
    define_method(name.to_sym) do
      other_class_name = params[:class_name] || name.to_s.camelize
      primary_key = params[:primary_key] || :id
      foreign_key = params[:foreign_key] || "#{name}_id".to_sym
      
      other_class = other_class_name.constantize
      other_table_name = other_class.table_name
      
      query = "
        SELECT
          #{other_table_name}.*
        FROM
          #{other_table_name} 
        WHERE
          #{other_table_name}.#{primary_key} = #{self.send(foreign_key)}
      "
      p query
      rows = DBConnection.execute(query)
      other_class.parse_all(rows)
    end
  end

  def has_many(name, params = {})
    define_method(name.to_sym) do
      other_class_name = params[:class_name] || name.to_s.camelize.singularize
      primary_key = params[:primary_key] || :id
      foreign_key = params[:foreign_key] || "#{name}_id".to_sym
      
      other_class = other_class_name.constantize
      other_table_name = other_class.table_name
      
      query = "
        SELECT
          #{other_table_name}.*
        FROM
          #{other_table_name} 
        WHERE
          #{self.send(primary_key)} = #{other_table_name}.#{foreign_key}  
      "
      
      p query
      rows = DBConnection.execute(query)
      other_class.parse_all(rows)
      
    end
  end

  def has_one_through(name, assoc1, assoc2)
    query = "
      SELECT #{self.assoc_params[assoc2].other_table}.*
      FROM #{assoc_params[assoc2].other_table}
      JOIN #{assoc_params[assoc1].other_table}
      ON #{assoc_params[assoc1].other_table}.#{foreign_key} 
        = #{assoc_params[assoc2].other_table}.#{primary_key} 
      WHERE #{self.send(foreign_key)} = #{assoc_params[assoc1].other_table}.#{primary_key} 
    "
    

    p query
    rows = DBConnection.execute(query)
    assoc_params[assoc2].other_class.parse_all(rows)
  
  end
end
