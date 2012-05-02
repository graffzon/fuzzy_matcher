require "pg"
require "mysql2"

module FuzzyMatcher
  class Adapter
    attr_reader :type, :connection, :table_name

    AVAILABLE_DBS = ['pg', 'mysql']

    def initialize(db_type, db_name, db_user, db_password, table_name = 'library')
      @type = db_type
      @table_name = table_name
      @connection = make_connection(db_name, db_user, db_password)
    end

    def send_query(query)
      connection.send(query_method, query)
    end

    def create_index_table(height)
      case @type
      when 'pg'
        create_table_pg(height)
      when 'mysql'
        create_table_mysql(height)
      end
      fill_index_table
    end

    def select_all(columns)
      send_query "select #{columns.to_s} from #{@table_name}_indexed"
    end

    def parse(values, known_key = true, value = 'value')
      case @type
      when 'pg'
        pg_parse_values(values, value)
      when 'mysql'
        mysql_parse_values(values, known_key)
      end
    end

    def build_fqa(level_values, values, distance_function)
      level_values.each_with_index do |lv, id|
        values.each do |v|
          dist = calculate_distance(distance_function, lv, v)

          column = "u#{id}"
          update(v, column, dist)
        end
      end
    end

    private

      def query_method
        case @type
        when 'pg' then :exec
        when 'mysql' then :query
        end
      end

      def calculate_distance(distance_function, level_value, value)
        query_string = "select #{distance_function}('#{level_value}','#{value}')"
        result = parse(send_query(query_string), false, distance_function)
        result.is_a?(Array) ? result[0] : result
      end

      def update(value, column, dist)
        query_string = "update #{@table_name}_indexed set #{column} = #{dist} where value = '#{value}'"
        send_query query_string
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
          pg_connection(db_name, db_user, db_password)
        when 'mysql'
          mysql_connection(db_name, db_user, db_password)
        else
          raise "Current available pg and mysql databases"
        end
      end

      def create_table_pg(height)
        index_columns = take_index_columns(height)
        query_string = "CREATE TABLE #{@table_name}_indexed
          (
            id integer NOT NULL DEFAULT 0,
            value character(20),
            #{index_columns}
            CONSTRAINT #{@table_name}_indexed_pkey PRIMARY KEY (id )
          )
          WITH (
            OIDS=FALSE
        );"
        drop_and_create(query_string)
      end


      def create_table_mysql(height)
        index_columns = take_index_columns(height)
        query_string = "CREATE TABLE `#{@table_name}_indexed` (
          `id` int(11) NOT NULL AUTO_INCREMENT,
          `value` varchar(45) DEFAULT NULL,
          #{index_columns}
          PRIMARY KEY (`id`),
          UNIQUE KEY `id_UNIQUE` (`id`),
          UNIQUE KEY `value_UNIQUE` (`value`)
        ) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=koi8r"
        drop_and_create(query_string)
      end

      def take_index_columns(height)
        result = ''
        height.times { |h| result << "u#{h} integer," }
        result
      end

      def drop_and_create(create_table_string)
        send_query "drop table if exists #{@table_name}_indexed;"
        send_query create_table_string
      end

      def pg_parse_values(result, key = "value")
        result.field_values(key).collect { |v| v.rstrip }
      end

      def mysql_parse_values(result, known_key, key = "value")
        result.collect { |v| known_key ? v[key] : v.values[0] }
      end

      def fill_index_table
        query_string = "insert into #{@table_name}_indexed (id, value) select id, value from #{@table_name}"
        send_query query_string
      end
  end
end
