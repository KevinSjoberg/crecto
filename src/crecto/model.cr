module Crecto
  # Your data models should extend `Crecto::Model`:
  #
  # `class User < Crecto::Model`
  #  -or-
  #
  # ```
  # class User
  #   include Crecto::Schema
  #   extend Crecto::Changeset(User)
  # end
  # ```
  abstract class Model
    macro inherited
      include Crecto::Schema
      include Crecto::Schema::HasMany
      include Crecto::Schema::HasOne
      include Crecto::Schema::BelongsTo
      extend Crecto::Changeset({{@type}})

      CRECTO_DESTROY_ASSOCIATIONS = Array(Symbol).new
      CRECTO_NULLIFY_ASSOCIATIONS = Array(Symbol).new
      CRECTO_MODEL_FIELDS = [] of NamedTuple(name: Symbol, type: String)

      def self.use_primary_key?
        CRECTO_USE_PRIMARY_KEY
      end

      def self.fields
        CRECTO_MODEL_FIELDS
      end

      def self.destroy_associations
        CRECTO_DESTROY_ASSOCIATIONS
      end

      def self.nullify_associations
        CRECTO_NULLIFY_ASSOCIATIONS
      end

      def self.add_destroy_association(a)
        CRECTO_DESTROY_ASSOCIATIONS << a
      end

      def self.add_nullify_association(a)
        CRECTO_NULLIFY_ASSOCIATIONS << a
      end

      # Class variables
      @@changeset_fields = [] of Symbol
      @@initial_values = {} of Symbol => DbValue

      # Instance properties
      property initial_values : Hash(Symbol, DbValue)?

      def initialize
      end

      # Return the primary key field as a String
      def self.primary_key_field
        CRECTO_PRIMARY_KEY_FIELD
      end

      # Return the primary key field as a Symbol
      def self.primary_key_field_symbol
        CRECTO_PRIMARY_KEY_FIELD_SYMBOL
      end

      def self.created_at_field
        CRECTO_CREATED_AT_FIELD
      end

      def self.updated_at_field
        CRECTO_UPDATED_AT_FIELD
      end

      # Class method to get the `changeset_fields`
      def self.changeset_fields
        @@changeset_fields
      end

      # Class method to get the table name
      def self.table_name
        @@table_name
      end

      def get_changeset
        self.class.changeset(self)
      end

      # Get the Class for the assocation name
      # i.e. :posts => Post
      def self.klass_for_association(association : Symbol)
        CRECTO_ASSOCIATIONS.select{|a| a[:key] == association && a[:this_klass] == self}.first[:klass]
      end

      # Get the foreign key for the association
      # i.e. :posts => :user_id
      def self.foreign_key_for_association(association : Symbol) : Symbol
        CRECTO_ASSOCIATIONS.select{|a| a[:key] == association && a[:this_klass] == self}.first[:foreign_key]
      end

      def self.foreign_key_for_association(klass : Crecto::Model.class)
        CRECTO_ASSOCIATIONS.select{|a| a[:klass] == klass && a[:this_klass] == self}.first[:foreign_key]
      end

      # Get the foreign key value from the relation object
      # i.e. :posts, post => post.user_id
      def self.foreign_key_value_for_association(association : Symbol, item)
        CRECTO_ASSOCIATIONS.select{|a| a[:key] == association && a[:this_klass] == self}.first[:foreign_key_value].call(item).as(PkeyValue)
      end

      # Set the value for the association
      # i.e. :posts, user, [posts] => user.posts = [posts]
      def self.set_value_for_association(association : Symbol, item, items)
        CRECTO_ASSOCIATIONS.select{|a| a[:key] == association && a[:this_klass] == self}.first[:set_association].call(item, items)
      end

      # Get the association type for the association
      # i.e. :posts => :has_many
      def self.association_type_for_association(association : Symbol)
        CRECTO_ASSOCIATIONS.select{|a| a[:key] == association && a[:this_klass] == self}.first[:association_type]
      end

      # Get the through association symbol
      # i.e. :posts => :user_posts (if has_many through)
      def self.through_key_for_association(association : Symbol) : Symbol?
        CRECTO_ASSOCIATIONS.select{|a| a[:key] == association && a[:this_klass] == self}.first[:through]
      end
    end
  end
end
