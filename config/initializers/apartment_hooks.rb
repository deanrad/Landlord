class Apartment
  class << self
    alias :really_set_current= :current=
    def current= apt
      # $stderr.puts "ApartmentHooks -> Apartment#current"
      self.really_set_current = apt
      
      tenants.each do |t|
        if apt.blank?
          Thread.current[:"#{t}_scoped_methods"] = []
        else
          newarel = apt.inject(ActiveRecord::Relation.new(t, Arel::Table.new( t.table_name, Arel::Table.engine ))) do |arel, (k,v)|
            arel = arel.where({k => v})
          end
          Thread.current[:"#{t}_scoped_methods"] = [newarel]
        end
      end
    end
    
  end
end
