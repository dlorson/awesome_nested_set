require 'awesome_nested_set/move'

module CollectiveIdea #:nodoc:
  module Acts #:nodoc:
    module NestedSet #:nodoc:
      module Model
        module BatchSavable
          
          
          # Construct the (in-memory) nested set for this node and it descendants in batch, then save.
          # Attention: won't save the depth column for now (raises if one is defined)
          def batch_save_nested_set
            raise 'Depth not supported when batch saving a nested set' if nested_set_scope.column_names.map(&:to_s).include?(depth_column_name.to_s)
            self.class.in_batch_update = true
            set_in_memory_left_and_right
            save # should save descendants, too
            self.class.in_batch_update = false
          end
        
          # Recursively sets the left and right properties (in-memory) for this node and its descendants.
          def set_in_memory_left_and_right(count = nil)
          
            # The lowest left should be larger than the highest right in the entire table!
            unless count
              highest_right_row = nested_set_scope(:order => "#{quoted_right_column_full_name} desc").limit(1).lock(true).first
              maxright = highest_right_row ? (highest_right_row[right_column_name] || 0) : 0
              count = maxright + 1
            end
          
            self.lft = count
            count += 1
            children.each { |c| count = c.set_in_memory_left_and_right(count) + 1 }
            self.rgt = count
          
          end
          

        end
      end
    end
  end
end
