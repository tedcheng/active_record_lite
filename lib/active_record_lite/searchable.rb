require_relative './db_connection'

module Searchable
  def where(params)
    where_clause = params.keys.map do |key|
      "#{key} = ?"
    end.join(" AND ")
    
    where_values = params.values
    
    query = "
      SELECT 
        *
      FROM
        #{table_name}
      WHERE
        #{where_clause}
    "
    
    DBConnection.execute(query, where_values)
    
  end
end