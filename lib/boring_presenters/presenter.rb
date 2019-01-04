# frozen_string_literal: true
require "byebug"
require 'boring_presenters/collection'

# Automate the instantiation of the collection class
#
# class PriorAuthRequestPresenter::Collection < Boring::Collection
# end

module Boring
  class Presenter #:nodoc:
    extend Forwardable

    collection_klass = Class.new(Boring::Collection) do

    end

    Object.const_set('Collection', collection_klass)

    byebug

    class << self
      attr_accessor :__arguments

      def class_name
        name
      end

      private

      # Takes a list of arguments and types that will
      # be passed to the +bind+ method, and defines
      # the +initialize+ and +bind+ methods.
      #
      #   arguments hash: Hash # => bind presenter to a Hash
      def arguments(args)
        @__arguments = args.nil? ? {} : args

        class_eval do
          unless method_defined?(:initialize)
            define_method(:initialize) do |**bindings|
              # dies if nil or empty
              self.class.__arguments.each do |arg_name, arg_class|
                arg_value = bindings[arg_name]

                # Ensure all of our bindings are the appropriate type
                if bindings.key?(arg_name) && !arg_value.is_a?(arg_class)
                  raise ArgumentError, "Argument '#{arg_name}' is of type #{arg_value.class}, expecting #{arg_class}."
                end

                instance_variable_set("@#{arg_name}", arg_value)
              end

              # Ensure we don't have any unexpected arguments
              extra_bindings = (bindings.keys - args.keys)

              unless extra_bindings.empty?
                raise ArgumentError, "Unexpected argument: #{extra_bindings.join(', ')}."
              end
            end
          end

          unless method_defined?(:bind)
            define_method(:bind) do |**bindings|
              self.class.__arguments.each.each do |arg_name, arg_class|
                arg_value = bindings[arg_name]

                unless arg_value.is_a?(arg_class)
                  raise ArgumentError, "Argument '#{arg_name}' is of type #{arg_value.class}, expecting #{arg_class}."
                end

                instance_variable_set("@#{arg_name}", arg_value)
              end
            end
          end

          # TODO: Move to rails extension helper
          # unless method_defined?(:render)
          #   define_method(:render) do |**render_args|
          #     view_context.render(**render_args)
          #   end
          # end

          # unless method_defined?(:view_context)
          #   define_method(:view_context) do
          #     @__view_context ||= ActionView::Base.new(
          #       ActionController::Base.view_paths,
          #       {}
          #     )
          #   end
          # end

          private

          attr_reader(*args.keys)
        end
      end

      # Process all methods on the presenter class
      # and add a processing step where we will
      # check whether or not the presenter bindings
      # are set up properly.
      #
      # The wrapped method is aliased to the original
      # method name, while a new method is defined
      # as +{method_name}_without_before_each_method+
      # that will call the original, unwrapped method.
      def method_added(method_name)
        return if self == Boring::Presenter
        return if @__last_methods_added && @__last_methods_added.include?(method_name)

        skipped_methods = %i[initialize render bind]
        return if skipped_methods.include?(method_name)

        skipped_methods = @__arguments.keys
        return if skipped_methods.include?(method_name)

        with = :"#{method_name}_with_before_each_method"
        without = :"#{method_name}_without_before_each_method"

        @__last_methods_added = [method_name, with, without]
        define_method with do |*args, &block|
          before_each_method method_name
          send without, *args, &block
        end

        alias_method without, method_name
        alias_method method_name, with

        @__last_methods_added = nil
      end

      # Shorthand for adding delegation between two
      # objects, wrapping the +def_delegators+
      # method from +Forwardable+
      #
      #   delegate :foo, to: :bar # => delegates +foo+ to +bar+
      def delegate(*methods)
        options = methods.pop

        unless options.is_a?(Hash) && to = options[:to]
          raise ArgumentError, 'Delegation needs a target. Supply an options hash with a :to key as the last argument.'
        end

        def_delegators(to, *methods)
      end
    end

    private

    # This method is called before each bound method
    # and ensures that the proper arguments have
    # been bound to the presenter before we proceed.
    def before_each_method(*)
      # Ensure everything is properly bound before invoking this method
      self.class.__arguments.each do |arg_name, arg_class|
        arg_value = send(arg_name.to_sym)

        if arg_name.nil?
          raise ArgumentError, "Argument '#{arg_name}' is not bound."
        end

        unless arg_value.is_a?(arg_class)
          raise ArgumentError, "Argument '#{arg_name}' is of type #{arg_value.class}, expecting #{arg_class}."
        end
      end
    end
  end
end
