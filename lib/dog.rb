class Dog
    attr_accessor :id, :name, :breed
  
    def initialize(name:, breed:, id: nil)
      @id = id
      @name = name
      @breed = breed
    end
  
    # .drop_table
    def self.drop_table
      sql = <<-SQL
        DROP TABLE IF EXISTS dogs
      SQL
  
      DB[:conn].execute(sql)
    end
  
    # .create_table
    def self.create_table
      sql = <<-SQL
        CREATE TABLE IF NOT EXISTS dogs(
          id INTEGER PRIMARY KEY,
          name TEXT,
          breed TEXT
        )
      SQL
      DB[:conn].execute(sql)
    end
  
    #Save
    def save
      if self.id
        update
      else
        insert
      end
      self
    end
  
    def insert
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
      SQL
  
      DB[:conn].execute(sql, self.name, self.breed)
  
      self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
  
    def update
      sql = <<-SQL
        UPDATE dogs
        SET name = ?, breed = ?
        WHERE id = ?
      SQL
  
      DB[:conn].execute(sql, self.name, self.breed, self.id)
    end
  
    # .create
    def self.create(name:, breed:)
      dog = self.new(name: name, breed: breed)
      dog.save
    end
  
    # .new_from_db
    def self.new_from_db(row)
      self.new(id: row[0], name: row[1], breed: row[2])
    end

    #.all
    def self.all
      sql = <<-SQL
        SELECT *
        FROM dogs
      SQL
      DB[:conn].execute(sql).map do |row|
        self.new_from_db(row)
      end
    end
  
    # .find_by_name(name)
    def self.find_by_name(name)
      sql = <<-SQL
        SELECT *
        FROM dogs
        WHERE name = ?
        LIMIT 1
      SQL
      DB[:conn].execute(sql, name).map do |row|
        self.new_from_db(row)
      end.first
    end

     #.find(id)
    def self.find(id)
      sql = <<-SQL
        SELECT *
        FROM dogs
        WHERE id = ?
        LIMIT 1
      SQL
      DB[:conn].execute(sql, id).map do |row|
        self.new_from_db(row)
      end.first
    end
  end
  