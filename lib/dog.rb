class Dog


	attr_accessor :name, :breed, :id

	def initialize( id: nil , name: , breed: )
		@name, @breed = name,breed
		@id = id
	end

	def save
		if !!!self.id
			sql = <<-SQL
				INSERT INTO dogs(id,name,breed) VALUES (?,?,?)
			SQL
			DB[:conn].execute(sql,self.id,self.name,self.breed)
			@id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
		else
			update
		end

		self
	end

	def update 
	    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
	    DB[:conn].execute(sql, self.name, self.breed, self.id)
	end

	def Dog.find_or_create_by(name: , breed: )
		 dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = '#{name}' AND breed = '#{breed}'")
		    if !dog.empty?
		      dog_data = dog[0]
		      dog = Dog.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
		    else
		      dog = self.create(name: name, breed: breed)
		    end
   		 dog
	end

	def self.find_by_name(name)
 		sql = "SELECT * FROM dogs WHERE name = ? LIMIT 1 ;"
   		student = Dog.new_from_db(DB[:conn].execute(sql, name)[0])
   		student
	end

	def self.find_by_id(id)
 		sql = "SELECT * FROM dogs WHERE id = ?"
   		student = Dog.new_from_db(DB[:conn].execute(sql, id)[0])
   		student
	end

	def self.new_from_db(row)
    # create a new Student object given a row from the database
	    stud = Dog.new(id: row[0],name: row[1], breed: row[2])
	    stud

	end

	def self.create(name:,breed:)
		student = Dog.new(name: name,breed: breed)
		student.save
		student
	end

	def self.create_table
		sql = "CREATE TABLE IF NOT EXISTS dogs (
			id INTEGER PRIMARY KEY,
			name TEXT,
			breed INTEGER
		);"
		DB[:conn].execute(sql)
	end

	def self.drop_table
		sql = "DROP TABLE IF EXISTS dogs;"
		DB[:conn].execute(sql)
	end
 


end