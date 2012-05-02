module FuzzyMatcher
  class Searcher
    class << self
      def find(level_values, conn, distance_function, height, accuracy, aim)
        conditions = condition_string(level_values, distance_function, accuracy, aim)
        query_string = "select * from #{conn.table_name}_indexed where #{conditions}"
        conn.send_query "#{query_string}"
      end

      private
        def condition_string(level_values, distance_function, accuracy, aim)
          conditions = []
          level_values.each do |lv|
            conditions << 
              "abs(#{distance_function}('#{lv}','#{aim}') - #{distance_function}(value, '#{aim}'))<#{accuracy}"
          end
          conditions.join(" and ")
        end
    end
  end
end