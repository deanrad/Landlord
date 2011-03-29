class Apartment
  class InvalidError < StandardError
    class ReferenceError < self; end
    class ValueError < self; end
    class PartitionError < NoMethodError
      def initialize name, *args
        name = "#{name.to_s.sub('current_', '')} does not specify a valid property of #{Apartment.current}"
        super 
      end
    end
  end

  # DSL
  class << self
    attr_accessor :partitions

    def setup &block
      @partitions = {}
      instance_eval &block
      @current = {}
    end

    private

    def partition name, opts
      setup_partition name, opts
      # $stderr.puts "Setting Up Partition:#{name}: #{opts}"
    end
    
    
    def setup_partition name, opts
      @partitions.store(name, {:opts => opts})
    end
  end
  # End DSL

  # Class
  class << self
    # The classes who are lessees 
    attr_accessor :tenants
    def tenants= ts
      case ts
      when :all_models
        Dir[ File.join(Rails.root, 'app/models/**/*.rb') ].each{ |m| require m }
        @tenants = ActiveRecord::Base.descendants
      else
        @tenants = ts
      end
    end
    
    def with apt, &block
      saved = current && current.dup
      self.current= apt
      yield
    ensure
      self.current= saved
    end
    
    # constructs a hash suitable for passing to Apartment.current from a request object
    def from_request request
      {}.tap do |apt|
        partitions.each do |name, opts|
          if proc = opts[:opts][:http_initializer]
            apt[name] = proc.call(request)
          end
        end
      end
    end
    
    attr_accessor :current
    def current= apt
      # $stderr.puts "Apartment::current=: #{apt.inspect}"
      
      # May want to enable this with a config flag
      #return clear_current if apt.nil?
      #all_keys = partitions.keys.inject(true) do |all, v|
      #  apt.keys.include?(v)
      #end
      #raise InvalidError, "An apartment must specify all keys: #{partitions.keys.map(&:to_s).to_sentence }" unless all_keys

      partitions.each do | name, opts |
        if values = opts[:opts][:values]
          next if apt[name].nil? && opts[:opts][:allow_nil]
          unless values.include?( apt[name] )
            raise InvalidError::ValueError, "#{apt[name]} is not a valid value for Apartment #{name}, defined by #{values.inspect}" 
          end
        # Works, but causes a class load too early, conflicting with Apartments
        elsif fk = opts[:opts][:references]
          klass, field = fk.split('#')
          unless const_get(klass).send( "find_by_#{field}", apt[name])
            raise InvalidError::ReferenceError, "#{apt[name]} is not a valid value for Apartment #{name}, defined by #{klass}##{field}" 
          end
        end
      end unless apt.blank?
      
      @current = apt
    end
    
    def clear_current
      @current = nil
    end
    
    # allows Apartment.current_user to return User.find( Apartment.current[:user_id] )
    def method_missing name, *args
      case name.to_s
      when /current_(\w+)_id/
        if self.current.keys.include?("#{$1}_id".to_sym)
          self.current[:"#{$1}_id"]
        else
          raise InvalidError::PartitionError, name
        end
      when /current_(\w+)/
        if self.current.keys.include?("#{$1}_id".to_sym)
          Kernel.const_get($1.classify).find( self.current[:"#{$1}_id"] )
        elsif self.current.keys.include?("#{$1}".to_sym)
          self.current[:"#{$1}"]
        else
          raise InvalidError::PartitionError, name
        end
      else
        raise InvalidError::PartitionError, name
      end
    rescue Apartment::InvalidError::PartitionError => ex
      raise ex
    end
    
  end
  # End Instance
  
  # Instance
  attr_accessor :name
  # End Instance
end
