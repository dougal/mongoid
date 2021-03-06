require "mongoid/associations/decorator"
require "mongoid/associations/factory"
require "mongoid/associations/belongs_to_association"
require "mongoid/associations/has_many_association"
require "mongoid/associations/has_one_association"

module Mongoid # :nodoc:
  module Associations

    # Adds the association back to the parent document. This macro is
    # necessary to set the references from the child back to the parent
    # document. If a child does not define this association calling
    # persistence methods on the child object will cause a save to fail.
    #
    # Options:
    #
    # association_name: A +Symbol+ that matches the name of the parent class.
    #
    # Example:
    #
    #   class Person < Mongoid::Document
    #     has_many :addresses
    #   end
    #
    #   class Address < Mongoid::Document
    #     belongs_to :person
    #   end
    def belongs_to(association_name)
      @embedded = true
      add_association(:belongs_to, association_name.to_s.classify, association_name)
    end

    # Adds the association from a parent document to its children. The name
    # of the association needs to be a pluralized form of the child class
    # name.
    #
    # Options:
    #
    # association_name: A +Symbol+ that is the plural child class name.
    #
    # Example:
    #
    #   class Person < Mongoid::Document
    #     has_many :addresses
    #   end
    #
    #   class Address < Mongoid::Document
    #     belongs_to :person
    #   end
    def has_many(association_name)
      add_association(:has_many, association_name.to_s.classify, association_name)
    end

    # Adds the association from a parent document to its child. The name
    # of the association needs to be a singular form of the child class
    # name.
    #
    # Options:
    #
    # association_name: A +Symbol+ that is the plural child class name.
    #
    # Example:
    #
    #   class Person < Mongoid::Document
    #     has_many :addresses
    #   end
    #
    #   class Address < Mongoid::Document
    #     belongs_to :person
    #   end
    def has_one(association_name)
      add_association(:has_one, association_name.to_s.titleize, association_name)
    end

    private
    # Adds the association to the associations hash with the type as the key,
    # then adds the accessors for the association.
    def add_association(type, class_name, name)
      define_method(name) do
        Associations::Factory.create(type, name, self)
      end
      define_method("#{name}=") do |object|
        object.parentize(self, name)
        @attributes[name] = object.mongoidize
      end
    end
  end
end
