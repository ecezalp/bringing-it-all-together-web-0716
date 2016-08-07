class Dog
  require "pry"

attr_accessor :name, :breed, :id

  def initialize(variable_hash)
    @name = variable_hash[:name]
    @breed = variable_hash[:breed]
    if variable_hash[:id]
      @id = variable_hash[:id]
    else 
      @id = nil
    end
  end

  def self.create_table
    sql = "CREATE TABLE IF NOT EXISTS dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT)"
    DB[:conn].execute(sql) 
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE dogs") 
  end

  def save
    if @id == nil
      sql = "INSERT INTO dogs (name, breed)
      VALUES (?, ?)"
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      self
    else
      self.update
    end
  end

  def self.create(variable_hash)
    new_dog = self.new(variable_hash)
    new_dog.save
  end

  def self.new_from_db(row)
    new_data_hash = {id: row[0], name: row[1], breed: row[2]}
    new_dog = self.new(new_data_hash)
    new_dog
  end

  def self.find_by_id(id_no)
    sql = "SELECT * FROM dogs WHERE id = ?"
    new_dog = (DB[:conn].execute(sql, id_no)[0])
    new_from_db(new_dog)
  end

  def self.find_or_create_by(data)
  
    sql = "SELECT * FROM dogs WHERE name = ? AND breed = ?"
    new_dog = (DB[:conn].execute(sql, data[:name], data[:breed]))

    if !new_dog.empty?
      new_dog_data = new_dog[0]
      new_dog_hash = {id: new_dog_data[0], name: new_dog_data[1], breed: new_dog_data[2]}  
      new_dog = self.new(new_dog_hash)
    else
      new_dog = self.new(data)
      new_dog.save
    end
    new_dog
  end


  def self.find_by_name(name_string)
    sql = "SELECT * FROM dogs WHERE name = ?"
    new_dog = (DB[:conn].execute(sql, name_string)[0])
    new_from_db(new_dog)
  end

  def update
    if id != nil
      sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
      DB[:conn].execute(sql, self.name, self.breed, self.id)
    else 
      self.save
    end
  end



end