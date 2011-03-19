class Apartment
  # DSL
  class << self
    attr_accessor :partitions

    def setup &block
      instance_eval &block
    end

    private

    def partition name, type, opts
      setup_partition name, type, opts
      puts "Setting Up Partition:#{name} (#{type}): #{opts}"
    end
    
    
    def setup_partition name, type, opts
      @partitions ||= {}
      @partitions.store(name, {:type => type, :opts => opts})
    end
  end
  # End DSL

  # Class
  class << self
    attr_accessor :current
    
    def set_current= apt
      all_keys = partitions.keys.inject(true) do |all, v|
        apt.keys.include?(v)
      end
      raise "An apartment must specify all keys: #{partitions.keys.map(&:to_s).to_sentence }" unless all_keys

      partitions.each do | name, opts |
        if values = opts[:opts][:values]
          unless values.include?( apt[name] )
            raise "#{apt[name]} is not a valid value for Apartment #{name}, defined by #{values.inspect}" 
          end
        # Works, but causes a class load too early, conflicting with Apartments
        # elsif fk = opts[:opts][:references]
        #   klass, field = fk.split('#')
        #   unless const_get(klass).send( "find_by_#{field}", apt[name])
        #     raise "#{apt[name]} is not a valid value for Apartment #{name}, defined by #{klass}##{field}" 
        #   end
        end
      end
      
      @current = apt
    end
    alias :current= :set_current=
    
  end
  # End Instance
  
  # Instance
  attr_accessor :name
  attr_accessor :type 
  # End Instance
end
