module Database
  class Connection
    def initialize(url)
      @url = url
    end
  end
end

module Database
  class ConnectionPool
    def initialize(database_url)
      @@connections ||= self.create_connections(database_url)
    end

    def self.get_connection(database_url)
      instance = new(database_url)

      if instance.available_connections?
        connection = instance.new_connection(database_url)
        yield connection if block
        checkout(connection)
      else
        puts "There is no connection available"
      end
    end

    def checkout(connection)
      @@available_connections << connection
    end

    def size
      @@connection.size
    end

    def available_connections_size
      @@available_connections.size
    end

    private

    def self.create_connections(database_url)
      0...5.each do
        connection = Database::Connection.new(url)
        @@connections << connection
        @@available_connections << connection
      end
    end

    def available_connections?
      @@available_connections.size > 0
    end

    def new_connection
      @@available_connections.pop
    end
  end
end

class Client
  def initialize(database_url)
    @database_url = database_url
  end

  def database_connection
    connection = Database::ConnectionPool.get_connection(@database_url)
    Database::ConnectionPool.checkout(connection)
  end

  def yield_database_connection
    Database::ConnectionPool.get_connection(@database_url) do |connection|
      puts "I have a new connection => #{connection.inspect}"
    end
  end
end
