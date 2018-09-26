class Dog
  attr_accessor :name, :breed, :id

  def initialize(params)
    @name = params[:name]
    @breed = params[:breed]
    @id = params[:id]
  end

  def self.create_table
    sql=<<-SQL
      CREATE TABLE IF NOT EXISTS dogs(
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      );
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE dogs;")
  end

  def save
    sql = <<-SQL
      INSERT INTO dogs(name, breed)
      VALUES (?,?);
    SQL

    DB[:conn].execute(sql, name, breed)

    self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

  def self.create(params)
    dog = Dog.new(params)
    dog.save
    dog
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE id=?;
    SQL

    new_from_db(DB[:conn].execute(sql, id).first)
  end

  def self.new_from_db(row)
    id = row[0]
    name = row[1]
    breed = row[2]
    dog = self.new(id: id, name: name, breed: breed)
  end

  def self.find_or_create_by(params)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name=? AND breed=?", params[:name], params[:breed])

    if dog.empty?
      dog = self.create(name: params[:name], breed: params[:breed])
    else
      dog_data = dog[0]
      dog = Dog.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
    end
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name=? LIMIT 1;
    SQL

    new_from_db(DB[:conn].execute(sql, name).first)
  end

  def update
    sql = "UPDATE dogs SET name=?, breed=? WHERE id=?"
    DB[:conn].execute(sql, name, breed, id)
  end
end