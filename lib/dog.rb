class Dog

  attr_accessor :id, :name, :breed

  def initialize(name:, breed:, id:nil)
    @id, @name, @breed = id, name, breed
  end

  def self.create_table

    sql = <<-SQL
      DROP TABLE IF EXISTS dogs
    SQL

    DB[:conn].execute(sql)

    sql = <<-SQL
      CREATE TABLE dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE dogs
    SQL

    DB[:conn].execute(sql)
  end


  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
      SQL

      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      return self
    end
  end

  def update
    sql = <<-SQL
      UPDATE dogs
      SET name = ?,
      breed = ?
      WHERE id = ?
    SQL

    DB[:conn].execute(sql, self.name, self.breed, self.id)
    return self
  end

  def self.create(name:, breed:)
    new_dog = Dog.new(name: name, breed: breed)
    new_dog.save
    new_dog
  end

  def self.new_from_db(row)
    new_dog = Dog.new(name:row[1], breed:row[2])
    new_dog.id = row[0]
    new_dog.name = row[1]
    new_dog.breed = row[2]
    new_dog
  end

  def self.find_by_id(provided_id)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE dogs.id = ?
    SQL
    DB[:conn].execute(sql, provided_id).map do |row|
      self.new_from_db(row)
    end.first
  end

  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if !dog.empty?
      dog_data = dog[0]
      dog = Dog.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
    else
      dog = self.create(name: name, breed: breed)
    end
    dog
  end

  def self.find_by_name(provided_name)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE dogs.name = ?
    SQL
    DB[:conn].execute(sql, provided_name).map do |row|
      self.new_from_db(row)
    end.first
  end



end
