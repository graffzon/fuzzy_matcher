module FuzzyMatcher
  class Indexer
    class << self
      def index!(connection, distance_function, height)
        level_values = select_level_values(connection, height)
        connection.create_index_table(height)
        index_values(connection, level_values, distance_function)
      end

      private

        def select_level_values(conn, height)
          indexes = []
          height.times do |l|
            query_result = 
              conn.connection.send(conn.query_method, query_for_select_levels(conn))
            indexes << parse_result(conn.type, query_result)
          end
          indexes
        end

        # Mysql and Postgresql has different
        # random functions
        def rand_func(db_type)
          case db_type
          when "pg" then "random()"
          when "mysql" then "rand()"
          end
        end

        def query_for_select_levels(connection)
          "select value from #{connection.table_name} order by #{rand_func(connection.type)} limit 1"
        end

        def parse_result(type, result)
          case type
          when "pg"
            # rstrip because string we may take
            # as "word        "
            result.field_values("value")[0].rstrip
          when "mysql"
            result.first["value"]
          end
        end

        def index_values(connection, level_values, distance_function)
          unparsed_result = connection.select_all(:value)
          values = connection.parse(unparsed_result)
          connection.build_fqa(level_values, values, distance_function)
        end
    end
  end
end


# d - ф-я расстояния
# р - переданный нам шаблон
# u1 - точка отсчёта 1го уровня
# u2 - точка отсчёта 2го уровя
# n - заданное пользователем расстояние
