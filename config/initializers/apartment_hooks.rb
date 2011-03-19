class ActiveRecord::Base
  # def scoping_with_security *args
  #   $stderr.puts "My Haxx" + args.inspect
  #   scoping_without_security *args
  # end
  # alias_method_chain :scoping, :security
  
  class << self
    alias_method :current_scoped_methods_super, :current_scoped_methods
    def current_scoped_methods
      $stderr.puts "Yay hooked it."
      apt = Apartment.current
      csm = current_scoped_methods_super
      #if apt
      #  csm = csm.where( apt )
      #end
      # Apartment.partitions.each do |name, opts|
      #   csm = csm.where( { name => apt[name] } )
      # end
      csm
    end
  end
end