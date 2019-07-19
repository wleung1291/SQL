require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject

  #  return an array with the names of the table's columns
  #  DBConnection::execute2 method returns an array
  def self.columns
    return @columns if @columns

    column = DBConnection.execute2(<<-SQL).first
      SELECT
        *
      FROM
        #{self.table_name}
    SQL

    @columns = column.map!{ |col_name| col_name.to_sym }
  end

  # automatically adds getter and setter methods for each column
  # ActiveRecord::Base gives a method #attributes that hands us a hash of all 
  # our model's columns and values.
  def self.finalize!
    self.columns.each do |name|
      define_method(name) { self.attributes[name] }

      define_method("#{name}=") { |value| self.attributes[name] = value }
    end
    
  end

  # setter for table 
  def self.table_name=(table_name)
    @table_name = table_name
  end
  # getter for table name
  def self.table_name
    @table_name || self.name.underscore.pluralize
  end

  # return an array of all the records in the DB
  # DBConnection will return an array of raw Hash objects where the keys are 
  # column names and the values are column values.
  def self.all
    records = DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        #{self.table_name}
    SQL

    self.parse_all(records)
  end

  # Turns the hash objects obtained from SQLObject::all into ruby objects
  def self.parse_all(results)
    results.map { |hash_obj| self.new(hash_obj) }
  end

  # look up a single record by primary key
  def self.find(id)
    result = DBConnection.execute(<<-SQL, id)
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
        #{self.table_name}.id = ?
    SQL

    self.parse_all(result).first
  end

  #cat = Cat.new(name: "Gizmo", owner_id: 123)
  # cat.name #=> "Gizmo"
  # cat.owner_id #=> 123
  def initialize(params = {})
    params.each do |attr_name, value|
      attr_name_sym = attr_name.to_sym
      if self.class.columns.include?(attr_name_sym)
        self.send("#{attr_name_sym}=", value)
      else
        raise "unknown attribute '#{attr_name_sym}'"
      end
    end
  end

  # ActiveRecord::Base gives a method #attributes that hands us a hash of all 
  # our model's columns and values. It should lazily initialize @attributes to 
  # an empty hash in case it doesn't exist yet. 
  def attributes
    @attributes ||= {}
  end

  # returns an array of the values for each attribute
  def attribute_values
    # call Array#map on SQLObject::columns, call send on the instance to 
    # get the value
    self.class.columns.map { |attribute| self.send(attribute) }
  end

  # insert a new row into the table to represent the SQLObject
  def insert
    # the array of ::columns of the class joined with commas, drop id
    col_names = self.class.columns[1..-1].join(", ")  
    # an array of question marks
    question_marks = (["?"] * col_names.split.size).join(", ")

    DBConnection.execute(<<-SQL, *attribute_values[1..-1])
      INSERT INTO
        #{self.class.table_name} (#{col_names})
      VALUES
        (#{question_marks})
    SQL

    self.id = DBConnection.last_insert_row_id
  end
  
  #  update the row with the id of this SQLObject
  def update
    set_line = self.class.columns.map { |attr| "#{attr} = ?" }.join(", ")

    DBConnection.execute(<<-SQL, *attribute_values, self.id)
      UPDATE
        #{self.class.table_name} 
      SET
        #{set_line}
      WHERE
        id = ?
    SQL
  end

  # convenience method that either calls insert/update depending on whether or 
  # not the SQLObject already exists in the table.
  def save
    if self.id.nil?
      self.insert
    else
      self.update
    end
  end
end
