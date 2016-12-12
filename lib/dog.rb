class Dog
  attr_accessor :name, :id
  attr_reader :breed

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

  def self.drop_table
    sql = <<-SQL
    DROP TABLE IF EXISTS dogs
    SQL
    DB[:conn].execute(sql)
  end

  def self.create(hash)
    Dog.new(hash).save
  end

  def self.find_by_id(id)
    sql = <<-SQL
    SELECT * FROM dogs
    WHERE id = ?
    SQL
    new_dog = DB[:conn].execute(sql, id)
    Dog.new(name: new_dog[0][1], breed: new_dog[0][2], id: new_dog[0][0])
  end

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT * FROM dogs
    WHERE name = ?
    SQL
    new_dog = DB[:conn].execute(sql, name)
    Dog.new(name: new_dog[0][1], breed: new_dog[0][2], id: new_dog[0][0])
  end

  def self.find_or_create_by(hash)
    sql = <<-SQL
    SELECT * FROM dogs
    WHERE name = ? AND breed = ?
    LIMIT 1
    SQL
    new_dog = DB[:conn].execute(sql, hash[:name], hash[:breed])[0]
    # binding.pry
    if new_dog
      Dog.new(name: new_dog[0][1], breed: new_dog[0][2], id: new_dog[0][0])
    else
      self.create(hash)
    end
  end

  def self.new_from_db(new_dog)
    Dog.new(name: new_dog[1], breed: new_dog[2], id: new_dog[0])
  end

  def initialize(name:, breed:, id: nil)
    @name = name
    @breed = breed
    @id = id
  end

  def save
    sql = <<-SQL
    INSERT INTO dogs
    (name, breed)
    VALUES (?, ?)
    SQL
    DB[:conn].execute(sql, self.name, self.breed)
    sql_get_id = <<-SQL
    SELECT last_insert_rowid()
    FROM dogs
    SQL
    self.id = DB[:conn].execute(sql_get_id)[0][0]
    self
  end

  def update
    sql = <<-SQL
    UPDATE dogs
    SET name = ?, breed = ?
    WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
    self
  end
end
