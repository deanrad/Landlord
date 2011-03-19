class Apartment
  # DSL
  class << self
    attr_accessor :partitions

    def setup &block
      @partitions = {}
      instance_eval &block
    end

    private

    def partition name, type, opts
      setup_partition name, type, opts
      puts "Setting Up Partition:#{name} (#{type}): #{opts}"
    end
    
    
    def setup_partition name, type, opts
      @partitions.store(name, {:type => type, :opts => opts})
    end
  end
  # End DSL

  # Class
  class << self
    # The classes who are lessees 
    attr_accessor :tenants
    
    def with apt, &block
      saved = current && current.dup
      self.current= apt
      yield
    ensure
      self.current= saved
    end
    
    attr_accessor :current
    def current= apt
      return clear_current if apt.nil?
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
        elsif fk = opts[:opts][:references]
          klass, field = fk.split('#')
          unless const_get(klass).send( "find_by_#{field}", apt[name])
            raise "#{apt[name]} is not a valid value for Apartment #{name}, defined by #{klass}##{field}" 
          end
        end
      end
      
      @current = apt
    end
    def clear_current
      @current = nil
    end
    
  end
  # End Instance
  
  # Instance
  attr_accessor :name
  attr_accessor :type 
  # End Instance
end
