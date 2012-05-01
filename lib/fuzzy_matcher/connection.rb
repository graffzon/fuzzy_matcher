require "pg"
require "mysql2"

module FuzzyMatcher
  class Connection
    attr_reader :type, :connection, :query_method

    AVAILABLE_DBS = ['pg', 'mysql']

    def initialize(db_type, db_name, db_user, db_password)
      @type = db_type
      @connection = make_connection(db_name, db_user, db_password)
    end

    def pg_connection(db_name, db_user, db_password)
      PG.connect(host: 'localhost', user: db_user, password: db_password, dbname: db_name)
    end

    def mysql_connection(db_name, db_user, db_password)
      Mysql2::Client.new(username: db_user, password: db_password, database: db_name)
    end

    def make_connection(db_name, db_user, db_password)
        case @type
        when 'pg'
          @query_method = :exec
          pg_connection(db_name, db_user, db_password)
        when 'mysql'
          @query_method = :query
          mysql_connection(db_name, db_user, db_password)
        else
          raise "Current available pg and mysql databases"
        end
    end
  end
end