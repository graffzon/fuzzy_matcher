module FuzzyMatcher
  class Searcher
    class << self
      def find(level_values, conn, distance_function, height, accuracy, aim)
        conditions = condition_string(level_values, distance_function, accuracy, aim)
        result = conn.send_find_query(conditions)
        clarify_result(conn, distance_function, accuracy, aim, result)
      end

      private

        def clarify_result(conn, distance_function, accuracy, aim, result)
          result.delete_if do |r|
            conn.calculate_distance(distance_function, aim, r).to_i > accuracy
          end
        end

        def condition_string(level_values, distance_function, accuracy, aim)
          conditions = []
          level_values.each_with_index do |lv,i|
            conditions << 
              "abs(#{distance_function}('#{lv}','#{aim}') - u#{i})<#{accuracy}"
          end
          conditions.join(" and ")
        end
    end
  end
end