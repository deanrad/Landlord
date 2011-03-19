class Apartment
  class << self
    alias :current_no_hook= :current=
    def current= apt
      current_no_hook= apt
      #$stderr.puts "Changing to apartment scope #{apt.inspect}"
      tenants.each do |t|
        newarel = apt.inject(ActiveRecord::Relation.new(t, Arel::Table.new( t.table_name, Arel::Table.engine ))) do |arel, (k,v)|
          arel = arel.where({k => v})
        end unless apt.blank?
        Thread.current[:"#{t}_scoped_methods"] = newarel ? [newarel] : []
      end
    end
  end
end

=begin   # This file tried to intercept/modify activerecord method calls
         # The new hotness way involves changing the Thread.current values
         # that AR looks at, whenever the apartment is defined
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
=end